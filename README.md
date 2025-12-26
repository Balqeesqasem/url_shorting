# URL Shortening Service

A **URL shortening application** built with **Ruby on Rails** and **Redis caching**.  
This app allows you to:

- Encode long URLs into short codes.
- Decode short codes back to the original URLs.
- Cache decoded URLs in Redis with LRU eviction for high performance.

---

## Table of Contents

- [Features](#features)  
- [Tech Stack](#tech-stack)  
- [Installation, Configuration & Running the App](#installation-configuration--running-the-app)  
- [API Endpoints](#api-endpoints)  
- [Postman Documentation](#postman-documentation)  
- [Redis Caching](#redis-caching)  
- [Testing](#testing)  
- [License](#license)  

---

## Features

- Encode long URLs to short codes (`POST /urls/encode`)  
- Decode short codes to original URLs (`POST /urls/decode`)  
- Redis caching for fast decoding  
- Automatic eviction of cold URLs using **Redis LRU**  
- Rails 7 API-only backend  
- Validations and error handling  

---

## Tech Stack

- **Backend:** Ruby on Rails 7.1  
- **Database:** sqlite3  
- **Cache:** Redis  
- **API testing:** Postman  

---

## Postman Documentation

You can import the Postman collection here: [Postman Docs](https://documenter.getpostman.com/view/11123143/2sAXjF7Zow)  

It contains:

- All API endpoints  
- Request examples  
- Response examples  

---

## Installation, Configuration & Running

# 1. Clone the repository:

```bash
git clone https://github.com/Balqeesqasem/url_shorting.git
cd url_shorting
```

# 2. Install dependencies
```bash
bundle install
```

# 3. Set up the database
```bash
rails db:create
rails db:migrate
```

# 4. Ensure Redis is installed and running
```bash
redis-server
```

# 5. Redis configuration (default)
# Redis URL for development: redis://localhost:6379/0
# Rails caching is already enabled in config/environments/development.rb using RedisCacheStore
# Optional: Adjust Redis memory and eviction policy in redis.conf
# maxmemory 256mb
# maxmemory-policy allkeys-lru

# 6. Start the Rails server
```bash
rails server
```


# The app will run on:
```bash
http://localhost:3000

```

## API Endpoints

1. Encode URL

```bash
POST /urls/encode
```

Body:

```bash
{
  "main_url": "https://amazon.com"
}
```

Response:

```bash
{
  "short_url": "https://tinyurl.com/tcs9"
}

```
2. Decode URL

```bash
POST /urls/decode
```

Body:

```bash
{
  "short_code": "https://tinyurl.com/tcs9"
}
```

Response:

```bash
{
  "original_url": "https://amazon.com"
}
```

## Redis Caching
URLs are cached after the first decode using Rails.cache.fetch

Redis LRU ensures hot URLs remain in memory and cold URLs are evicted automatically

TTL is set to 90 minutes

Verify cached keys:

```bash
redis-cli KEYS "url:decode:*"
```

## Testing
This project uses RSpec to test both the model and API endpoints.

Run All Tests:

```bash
bundle exec rspec
```

Run Only Model Tests

```bash
bundle exec rspec spec/models/url_spec.rb
```

Run Only Controller / API Tests

```bash
bundle exec rspec spec/requests/urls_spec.rb
```

## License
MIT License © 2025 Balqees Qasem