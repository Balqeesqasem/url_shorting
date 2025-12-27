# syntax = docker/dockerfile:1

# Base image
FROM ruby:3.2.2-slim AS base

WORKDIR /rails
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# -------------------
# Build stage
# -------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential git libvips pkg-config \
    libsqlite3-dev libpq-dev nodejs yarn libssl-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install latest bundler
RUN gem install bundler

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy application code
COPY . .

# Precompile Bootsnap
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompile assets if the task exists
RUN if bundle exec rails -T | grep -q "^rake assets:precompile"; then \
      SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile; \
    else \
      echo "Skipping assets precompile - assets:precompile task not found"; \
    fi

# -------------------
# Runtime stage
# -------------------
FROM base AS runtime

# Set production environment
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    SECRET_KEY_BASE=${SECRET_KEY_BASE:-`rake secret`}

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl libsqlite3-0 libvips nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy installed gems and application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user and set permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle /rails/tmp /rails/log /rails/storage /rails/db

USER rails:rails
WORKDIR /rails

# Expose port 3000 to the Docker host
EXPOSE 3000

# Use a script to handle environment variables and start the server
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the main process
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
