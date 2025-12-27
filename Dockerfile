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

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential git libvips pkg-config \
    libsqlite3-dev sqlite3 nodejs yarn libssl-dev zlib1g-dev && \
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

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids tmp/sockets log && \
    touch /rails/db/production.sqlite3 && \
    chmod 0666 /rails/db/production.sqlite3

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

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl sqlite3 libsqlite3-0 libvips nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set production environment
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-`rake secret`}
ENV DATABASE_URL=sqlite3:/rails/db/${RAILS_ENV:-production}.sqlite3

# Copy installed gems and application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create necessary directories and set permissions
RUN mkdir -p /rails/tmp/pids /rails/tmp/sockets /rails/log /rails/db && \
    touch /rails/db/production.sqlite3 && \
    chmod 0666 /rails/db/production.sqlite3

# Create a non-root user and set permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle /rails/tmp /rails/log /rails/storage /rails/db

USER rails:rails
WORKDIR /rails

# Run database migrations
RUN bundle exec rails db:create db:migrate

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the main process
CMD ["/rails/bin/docker-entrypoint"]
