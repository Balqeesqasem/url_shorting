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

# Precompile assets
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production \
    bundle exec rails assets:precompile

# -------------------
# Runtime stage
# -------------------
FROM base AS runtime

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl libsqlite3-0 libvips nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy installed gems from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle /rails/tmp /rails/log /rails/storage /rails/db

USER rails:rails

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
