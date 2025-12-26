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

1. Clone the repository:

```bash
git clone https://github.com/Balqeesqasem/url_shorting.git
cd url_shorting
```

2. Install dependencies
```bash
bundle install
```

3. Set up the database
```bash
rails db:create
rails db:migrate
```

4. Ensure Redis is installed and running
```bash
redis-server
```

5. Redis configuration (default)
 Redis URL for development: redis://localhost:6379/0
 Rails caching is already enabled in config/environments/development.rb using RedisCacheStore
 Optional: Adjust Redis memory and eviction policy in redis.conf
 maxmemory 256mb
 maxmemory-policy allkeys-lru
 

6. Start the Rails server
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

##  Redis Caching

To improve performance and reduce database load, the service uses **Redis** for caching URL mappings. Key details include:

- **Caching Strategy:**  
  URLs are cached after the first decode using `Rails.cache.fetch`. This means that repeated requests for the same short URL are served directly from Redis without hitting the database, significantly reducing latency.

- **Eviction Policy:**  
  Redis uses a **Least Recently Used (LRU)** eviction strategy. Frequently accessed ("hot") URLs remain in memory, while rarely accessed ("cold") URLs are automatically removed to free space.

- **Time-to-Live (TTL):**  
  Each cached URL has a TTL of **90 minutes**. After this period, the cache entry expires, ensuring memory usage remains controlled and stale data is refreshed from the database.

- **Benefits of Redis Caching:**  
  - Reduces database queries, improving overall throughput.  
  - Speeds up URL lookups, enhancing user experience.  
  - Handles high-traffic scenarios efficiently, making the service more scalable.

**Design Note:**  
Caching is **optional** but highly recommended for production environments with frequent URL access. It ensures that the system can handle high request volumes without degrading performance, while still maintaining data consistency with the underlying persistent database.

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

## Security Considerations

The URL shortening service has several potential security risks. Below is an overview of key attack vectors and suggested mitigations:

### 1. URL Injection Risks
Attackers may attempt to inject malicious payloads into URLs (e.g., JavaScript in query parameters).

**Mitigation:**  
Validate incoming URLs against a strict pattern (e.g., using URI parsing libraries) and reject invalid schemes. Ensure the application never renders URLs directly into HTML without escaping.

### 2. Open Redirect Vulnerabilities
Malicious users could craft short URLs that redirect users to phishing or malicious sites.

**Mitigation:**  
Optionally maintain a whitelist of allowed domains or alert users when redirecting to untrusted domains. Logging and monitoring redirects can help detect suspicious behavior.

### 3. Collision Attacks
Two different URLs could accidentally generate the same short code.

**Mitigation:**  
Use a cryptographically strong hash or a database-enforced uniqueness constraint. Adding randomness or non-sequential codes reduces predictability.

### 4. Rate Limiting
High-volume requests could lead to abuse or DoS attacks.

**Mitigation:**  
Implement request throttling per IP address or user account to prevent abuse of the encode/decode endpoints.

### 5. Brute Force Enumeration of Short URLs
Attackers may iterate through all possible short codes to discover URLs.

**Mitigation:**  
Use sufficiently long, non-sequential, and randomized short codes. Logging suspicious access patterns can help detect brute-force attempts.

### 6. Data Privacy and Integrity
Users’ original URLs should be securely stored and transmitted.

**Mitigation:**  
Use HTTPS for all requests and enforce database encryption where possible.


## Scalability Considerations

This service is designed to handle potentially millions of URLs. Below are key strategies for ensuring scalability:

### 1. Avoiding Collisions at Large Scale
- Use non-sequential, randomized short codes.  
- Enforce uniqueness in the database and consider additional hashing if code collisions are detected.

### 2. Database Sharding and Partitioning
- Split the URL mapping data across multiple database shards based on hash prefixes or geographic regions.  
- Improves read/write performance and reduces contention.

### 3. Non-Sequential Short Codes
- Sequential codes are predictable and easy to brute-force.  
- Randomized or base62-encoded hashes ensure security and evenly distributed codes.

### 4. Handling High Traffic
- Cache popular URL mappings in an in-memory store like **Redis** to reduce database load.  
- Use message queues (e.g., Sidekiq, RabbitMQ) for batch processing tasks like analytics or logging.

### 5. Concurrency and Uniqueness
- Use database transactions and unique constraints to prevent race conditions when generating new short codes.  
- Consider optimistic locking or atomic operations in distributed systems.

### 6. Horizontal Scaling
- Deploy multiple instances behind a load balancer to handle high request volumes.  
- Stateless service design ensures instances can scale independently without affecting URL mappings.

### 7. Monitoring and Analytics
- Track request rates, error rates, and unusual access patterns to proactively address scaling or security issues.

**Design Philosophy:**  
The system is built with resilience, security, and high availability in mind. With proper caching, distributed storage, and non-sequential short codes, it can safely scale to millions of URLs while minimizing abuse and maintaining fast response times.


## License

MIT License © 2025 Balqees Qasem