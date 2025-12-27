# syntax = docker/dockerfile:1

FROM ruby:3.2.2

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

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Precompile Bootsnap
RUN bundle exec bootsnap precompile --gemfile
RUN bundle exec bootsnap precompile app/ lib/

# -------------------
# Runtime stage
# -------------------
FROM base AS runtime

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl libsqlite3-0 libvips nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle /rails/tmp /rails/log /rails/storage /rails/db

USER rails:rails

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
