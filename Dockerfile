# syntax = docker/dockerfile:1

# ---------------------------
# Build stage
# ---------------------------
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS build

# Set working directory
WORKDIR /rails

# Install dependencies for gems and Rails
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libvips pkg-config \
    libsqlite3-dev \
    libpq-dev \
    nodejs \
    yarn \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Bundler
ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT=1

# Copy Gemfiles first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Precompile Bootsnap for faster boot
RUN bundle exec bootsnap precompile --gemfile

# ---------------------------
# Runtime stage
# ---------------------------
FROM ruby:$RUBY_VERSION-slim AS runtime

WORKDIR /rails

# Install runtime dependencies only
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl \
    libsqlite3-0 \
    libvips \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

# Copy gems from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copy app code from build stage
COPY --from=build /rails /rails

# Create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle /rails/tmp /rails/log /rails/storage /rails/db
USER rails:rails

# Expose port
EXPOSE 3000

# Entrypoint (optional, adjust if you have your own)
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Default command
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
