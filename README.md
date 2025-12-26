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
- [Installation](#installation)  
- [Configuration](#configuration)  
- [Running the App](#running-the-app)  
- [API Endpoints](#api-endpoints)  
- [Postman Documentation](#postman-documentation)  
- [Redis Caching](#redis-caching)  
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

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Balqeesqasem/url_shorting.git
cd url_shorting
