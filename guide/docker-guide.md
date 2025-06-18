# Complete Docker Guide: From Basics to Multi-Language Development

## What is Docker?

Docker is a containerization platform that packages your application and all its dependencies into a lightweight, portable container. Think of it as a shipping container for your code - it runs the same way everywhere.

**Key Concepts:**
- **Image**: A blueprint/template for creating containers
- **Container**: A running instance of an image
- **Dockerfile**: Instructions to build an image
- **Registry**: Storage for images (like Docker Hub)

## Essential Docker Commands

### Basic Commands

```bash
# Check Docker version and info
docker --version
docker info

# List all images on your system
docker images
# or
docker image ls

# List running containers
docker ps

# List all containers (running and stopped)
docker ps -a

# Pull an image from Docker Hub
docker pull ubuntu:20.04
# This downloads the Ubuntu 20.04 image to your local machine

# Run a container from an image
docker run ubuntu:20.04
# Creates and starts a container from ubuntu:20.04 image

# Run container interactively with a shell
docker run -it ubuntu:20.04 /bin/bash
# -i: interactive (keep STDIN open)
# -t: allocate a pseudo-TTY (terminal)

# Run container in background (detached mode)
docker run -d nginx
# -d: detached mode (runs in background)

# Run container with port mapping
docker run -p 8080:80 nginx
# -p host_port:container_port
# Maps port 8080 on your machine to port 80 in container

# Run container with volume mounting
docker run -v /host/path:/container/path ubuntu
# -v: mounts a directory from host to container

# Stop a running container
docker stop <container_id_or_name>

# Remove a container
docker rm <container_id_or_name>

# Remove an image
docker rmi <image_name_or_id>

# Build an image from Dockerfile
docker build -t my-app .
# -t: tag the image with a name
# .: build context (current directory)

# Execute command in running container
docker exec -it <container_id> /bin/bash
# Useful for debugging running containers
```

### Advanced Commands

```bash
# View container logs
docker logs <container_id>
docker logs -f <container_id>  # Follow logs in real-time

# Copy files between host and container
docker cp file.txt container_id:/path/
docker cp container_id:/path/file.txt ./

# Show resource usage statistics
docker stats

# Clean up unused resources
docker system prune  # Remove unused containers, networks, images
docker system prune -a  # Remove everything unused, including images

# Create and manage networks
docker network ls
docker network create my-network
docker run --network my-network my-app

# Manage volumes
docker volume ls
docker volume create my-volume
docker run -v my-volume:/data my-app
```

## Dockerfile Basics

A Dockerfile contains instructions to build a Docker image:

```dockerfile
# FROM: Base image to start from
FROM ubuntu:20.04

# WORKDIR: Set working directory inside container
WORKDIR /app

# COPY: Copy files from host to container
COPY . .

# RUN: Execute commands during image build
RUN apt-get update && apt-get install -y python3

# EXPOSE: Document which port the app uses
EXPOSE 8000

# CMD: Default command when container starts
CMD ["python3", "app.py"]

# ENV: Set environment variables
ENV NODE_ENV=production

# ARG: Build-time variables
ARG VERSION=1.0
```

## Language-Specific Examples

### 1. Python Application

**Dockerfile:**
```dockerfile
# Use official Python runtime as base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "app.py"]
```

**Example app.py:**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Python in Docker!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

**requirements.txt:**
```
Flask==2.0.1
```

**Commands:**
```bash
# Build the image
docker build -t my-python-app .

# Run the container
docker run -p 8000:8000 my-python-app

# Run with environment variables
docker run -p 8000:8000 -e FLASK_ENV=development my-python-app
```

### 2. Node.js/TypeScript Application

**Dockerfile:**
```dockerfile
# Use official Node.js runtime
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy TypeScript source
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

**package.json:**
```json
{
  "name": "my-ts-app",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "typescript": "^4.7.0",
    "@types/express": "^4.17.0",
    "ts-node": "^10.8.0"
  }
}
```

**Commands:**
```bash
# Build and run
docker build -t my-ts-app .
docker run -p 3000:3000 my-ts-app

# Development with volume mounting
docker run -p 3000:3000 -v $(pwd):/app -v /app/node_modules my-ts-app npm run dev
```

### 3. Go Application

**Dockerfile (Multi-stage build):**
```dockerfile
# Build stage
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]
```

**Example main.go:**
```go
package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello from Go in Docker!")
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}
```

**Commands:**
```bash
# Build (creates a very small final image due to multi-stage build)
docker build -t my-go-app .

# Run
docker run -p 8080:8080 my-go-app

# Check image size
docker images my-go-app
```

### 4. Rust Application

**Dockerfile (Multi-stage build):**
```dockerfile
# Build stage
FROM rust:1.70 AS builder

WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy source
COPY src ./src

# Build for release
RUN cargo build --release

# Runtime stage
FROM debian:bullseye-slim

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/my-rust-app .

# Expose port
EXPOSE 8000

# Run the application
CMD ["./my-rust-app"]
```

**Cargo.toml:**
```toml
[package]
name = "my-rust-app"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
warp = "0.3"
```

**Commands:**
```bash
# Build
docker build -t my-rust-app .

# Run
docker run -p 8000:8000 my-rust-app

# For development with cargo watch
docker run -v $(pwd):/app -w /app rust:1.70 cargo watch -x run
```

### 5. C++ Application

**Dockerfile:**
```dockerfile
# Build stage
FROM gcc:latest AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    make

# Copy source files
COPY . .

# Build the application
RUN mkdir build && cd build && \
    cmake .. && \
    make

# Runtime stage
FROM ubuntu:20.04

# Install runtime dependencies if needed
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/build/my-cpp-app .

# Expose port if it's a server
EXPOSE 9000

# Run the application
CMD ["./my-cpp-app"]
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.10)
project(my-cpp-app)

set(CMAKE_CXX_STANDARD 17)

add_executable(my-cpp-app main.cpp)
```

**Commands:**
```bash
# Build
docker build -t my-cpp-app .

# Run
docker run -p 9000:9000 my-cpp-app

# Development with volume mounting
docker run -v $(pwd):/app -w /app gcc:latest bash -c "mkdir -p build && cd build && cmake .. && make && ./my-cpp-app"
```

## Docker Compose for Multi-Service Applications

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  # Python API
  api:
    build: ./python-api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db

  # Node.js frontend
  frontend:
    build: ./node-frontend
    ports:
      - "3000:3000"
    environment:
      - API_URL=http://api:8000

  # Go microservice
  microservice:
    build: ./go-service
    ports:
      - "8080:8080"

  # Database
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Docker Compose Commands:**
```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# Build and start
docker-compose up --build

# Stop all services
docker-compose down

# View logs
docker-compose logs
docker-compose logs api  # Logs for specific service

# Scale a service
docker-compose up --scale microservice=3

# Execute command in service
docker-compose exec api bash
```

## Best Practices

### 1. Dockerfile Optimization
- Use multi-stage builds for compiled languages
- Leverage layer caching by copying dependencies first
- Use `.dockerignore` to exclude unnecessary files
- Use specific image tags, not `latest`
- Run as non-root user when possible

### 2. Security
```dockerfile
# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Switch to non-root user
USER nextjs
```

### 3. Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

### 4. Environment-Specific Configurations
```bash
# Development
docker run -e NODE_ENV=development my-app

# Production
docker run -e NODE_ENV=production my-app
```

## Common Debugging Commands

```bash
# Debug failed container
docker run -it --entrypoint /bin/bash my-app

# Check what's inside an image
docker run -it my-app /bin/sh

# View image layers
docker history my-app

# Inspect container configuration
docker inspect <container_id>

# Monitor real-time events
docker events

# Check disk usage
docker system df
```

This guide covers the fundamentals of Docker across multiple programming languages. Each language has its own best practices for containerization, but the core Docker concepts remain consistent throughout.