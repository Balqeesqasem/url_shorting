# URL Shortening Service

A **URL shortening application** built with **Ruby on Rails** and **Redis caching**.  
This app allows you to:
- Encode long URLs into short codes.
- Decode short codes back to the original URL.

---

## API Endpoints

### 1. Encode URL
**POST** `/urls/encode`  
**Request Body:**
{
  "main_url": "https://amazon.com"
}  
**Response Body:**
{
  "short_url": "https://tinyurl.com/tcs9"
}

### 2. Decode URL
**POST** `/urls/decode`  
**Request Body:**
{
  "main_url": "https://tinyurl.com/tcs9"
}  
**Response Body:**
{
  "short_url": "https://amazon.com"
}

---

## Installation, Configuration, and Running

# 1. Clone the repository
git clone https://github.com/Balqeesqasem/url_shorting.git
cd url_shorting

# 2. Install dependencies
bundle install

# 3. Set up the database
rails db:create
rails db:migrate

# 4. Ensure Redis is installed and running
redis-server

# 5. Redis configuration (default)
# Redis URL for development: redis://localhost:6379/0
# Rails caching is enabled in config/environments/development.rb using RedisCacheStore
# Optional: Adjust Redis memory and eviction policy in redis.conf
# maxmemory 256mb
# maxmemory-policy allkeys-lru

# 6. Start the Rails server
rails server

# The app will run on: http://localhost:3000

---

## Redis Caching
- URLs are cached after the first decode using Rails.cache.fetch.
- Redis LRU ensures hot URLs remain in memory and cold URLs are evicted automatically.
- TTL is set to 90 minutes.

# Verify cached keys
redis-cli KEYS "url:decode:*"

---

## License
MIT License © 2025 Balqees Qasem
