# Complete Docker Tutorial for Web Apps

## Understanding Docker Commands

Before diving into examples, let's understand the key Docker commands:

### Dockerfile Commands Explained

- **FROM**: Specifies the base image to build upon
- **WORKDIR**: Sets the working directory inside the container
- **COPY**: Copies files from host to container
- **ADD**: Similar to COPY but with additional features (can extract archives, download URLs)
- **RUN**: Executes commands during image build
- **CMD**: Default command to run when container starts
- **ENTRYPOINT**: Configures container to run as executable
- **EXPOSE**: Documents which port the container listens on
- **ENV**: Sets environment variables
- **ARG**: Defines build-time variables
- **USER**: Sets the user for subsequent commands
- **VOLUME**: Creates mount points for external volumes
- **LABEL**: Adds metadata to image

### Docker CLI Commands

- `docker build`: Build image from Dockerfile
- `docker run`: Create and start container
- `docker ps`: List running containers
- `docker images`: List images
- `docker stop`: Stop container
- `docker rm`: Remove container
- `docker rmi`: Remove image

## 1. Python Flask Application

### Simple Flask App

**app.py**
```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        "message": "Hello from Flask!",
        "environment": os.getenv("ENVIRONMENT", "development")
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

**requirements.txt**
```
Flask==2.3.3
gunicorn==21.2.0
```

### Single-Stage Dockerfile
```dockerfile
# FROM: Use Python 3.11 slim as base image (smaller than full Python)
FROM python:3.11-slim

# WORKDIR: Set working directory inside container
WORKDIR /app

# COPY: Copy requirements first (Docker layer caching optimization)
COPY requirements.txt .

# RUN: Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# COPY: Copy application code
COPY . .

# EXPOSE: Document that container listens on port 5000
EXPOSE 5000

# ENV: Set environment variable
ENV ENVIRONMENT=production

# CMD: Default command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

### Multi-Stage Dockerfile (Optimized)
```dockerfile
# Stage 1: Build stage
FROM python:3.11-slim as builder

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy requirements
COPY requirements.txt .

# RUN: Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Production stage
FROM python:3.11-slim

# RUN: Install runtime dependencies and create non-root user
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash app

# COPY: Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy application code with proper ownership
COPY --chown=app:app . .

# USER: Switch to non-root user for security
USER app

# ENV: Set environment variables
ENV PATH="/opt/venv/bin:$PATH"
ENV ENVIRONMENT=production

# EXPOSE: Document port
EXPOSE 5000

# HEALTHCHECK: Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# CMD: Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

## 2. Go Web Application

### Simple Go HTTP Server

**main.go**
```go
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
)

type Response struct {
    Message     string `json:"message"`
    Environment string `json:"environment"`
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    
    response := Response{
        Message:     "Hello from Go!",
        Environment: getEnv("ENVIRONMENT", "development"),
    }
    
    json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func main() {
    http.HandleFunc("/", helloHandler)
    http.HandleFunc("/health", healthHandler)
    
    port := getEnv("PORT", "8080")
    fmt.Printf("Server starting on port %s\n", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

**go.mod**
```go
module webapp

go 1.21
```

### Multi-Stage Go Dockerfile
```dockerfile
# Stage 1: Build stage
FROM golang:1.21-alpine AS builder

# RUN: Install git and ca-certificates
RUN apk add --no-cache git ca-certificates

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy go mod files first (dependency caching)
COPY go.mod go.sum ./

# RUN: Download dependencies
RUN go mod download

# COPY: Copy source code
COPY . .

# RUN: Build the application
# CGO_ENABLED=0: Disable CGO for static binary
# GOOS=linux: Target Linux OS
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Stage 2: Production stage
FROM alpine:latest

# RUN: Install ca-certificates and create non-root user
RUN apk --no-cache add ca-certificates \
    && adduser -D -s /bin/sh app

# WORKDIR: Set working directory
WORKDIR /root/

# COPY: Copy binary from builder stage
COPY --from=builder /app/main .

# USER: Switch to non-root user
USER app

# EXPOSE: Document port
EXPOSE 8080

# ENV: Set environment variable
ENV ENVIRONMENT=production

# HEALTHCHECK: Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# CMD: Run the application
CMD ["./main"]
```

## 3. Rust Web Application

### Simple Rust HTTP Server

**Cargo.toml**
```toml
[package]
name = "webapp"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
warp = "0.3"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

**src/main.rs**
```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use warp::Filter;

#[derive(Serialize, Deserialize)]
struct Response {
    message: String,
    environment: String,
}

#[tokio::main]
async fn main() {
    let hello = warp::path::end()
        .map(|| {
            let response = Response {
                message: "Hello from Rust!".to_string(),
                environment: env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string()),
            };
            warp::reply::json(&response)
        });

    let health = warp::path("health")
        .map(|| {
            let mut status = HashMap::new();
            status.insert("status", "healthy");
            warp::reply::json(&status)
        });

    let routes = hello.or(health);

    let port = env::var("PORT")
        .unwrap_or_else(|_| "3030".to_string())
        .parse::<u16>()
        .unwrap_or(3030);

    println!("Server starting on port {}", port);
    warp::serve(routes)
        .run(([0, 0, 0, 0], port))
        .await;
}
```

### Multi-Stage Rust Dockerfile
```dockerfile
# Stage 1: Build stage
FROM rust:1.70 as builder

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy Cargo files first (dependency caching)
COPY Cargo.toml Cargo.lock ./

# RUN: Create dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# RUN: Build dependencies
RUN cargo build --release

# RUN: Remove dummy main.rs
RUN rm src/main.rs

# COPY: Copy actual source code
COPY src ./src

# RUN: Build application
RUN cargo build --release

# Stage 2: Production stage
FROM debian:bookworm-slim

# RUN: Install runtime dependencies and create user
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash app

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy binary from builder
COPY --from=builder /app/target/release/webapp .

# USER: Switch to non-root user
USER app

# EXPOSE: Document port
EXPOSE 3030

# ENV: Set environment variable
ENV ENVIRONMENT=production

# CMD: Run application
CMD ["./webapp"]
```

## 4. C++ Web Application

### Simple C++ HTTP Server

**main.cpp**
```cpp
#include <iostream>
#include <string>
#include <thread>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

class SimpleHttpServer {
private:
    int port;
    std::string getEnv(const std::string& key, const std::string& defaultValue) {
        const char* val = std::getenv(key.c_str());
        return val ? std::string(val) : defaultValue;
    }

public:
    SimpleHttpServer(int p) : port(p) {}
    
    void start() {
        int server_fd, new_socket;
        struct sockaddr_in address;
        int opt = 1;
        int addrlen = sizeof(address);
        
        if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
            perror("socket failed");
            exit(EXIT_FAILURE);
        }
        
        if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
            perror("setsockopt");
            exit(EXIT_FAILURE);
        }
        
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port);
        
        if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
            perror("bind failed");
            exit(EXIT_FAILURE);
        }
        
        if (listen(server_fd, 3) < 0) {
            perror("listen");
            exit(EXIT_FAILURE);
        }
        
        std::cout << "Server starting on port " << port << std::endl;
        
        while (true) {
            if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
                perror("accept");
                exit(EXIT_FAILURE);
            }
            
            std::thread([this, new_socket]() {
                handleRequest(new_socket);
            }).detach();
        }
    }
    
private:
    void handleRequest(int socket) {
        char buffer[1024] = {0};
        read(socket, buffer, 1024);
        
        std::string env = getEnv("ENVIRONMENT", "development");
        std::string response = 
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: application/json\r\n"
            "Connection: close\r\n"
            "\r\n"
            "{\"message\":\"Hello from C++!\",\"environment\":\"" + env + "\"}";
        
        send(socket, response.c_str(), response.length(), 0);
        close(socket);
    }
};

int main() {
    std::string portStr = std::getenv("PORT") ? std::getenv("PORT") : "8080";
    int port = std::stoi(portStr);
    
    SimpleHttpServer server(port);
    server.start();
    
    return 0;
}
```

**CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.10)
project(webapp)

set(CMAKE_CXX_STANDARD 17)
find_package(Threads REQUIRED)

add_executable(webapp main.cpp)
target_link_libraries(webapp Threads::Threads)
```

### Multi-Stage C++ Dockerfile
```dockerfile
# Stage 1: Build stage
FROM gcc:11 as builder

# RUN: Install cmake
RUN apt-get update && apt-get install -y cmake

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy CMake files first
COPY CMakeLists.txt .

# COPY: Copy source code
COPY main.cpp .

# RUN: Build application
RUN mkdir build && cd build && \
    cmake .. && \
    make

# Stage 2: Production stage
FROM debian:bookworm-slim

# RUN: Install runtime dependencies and create user
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash app

# WORKDIR: Set working directory
WORKDIR /app

# COPY: Copy binary from builder
COPY --from=builder /app/build/webapp .

# USER: Switch to non-root user
USER app

# EXPOSE: Document port
EXPOSE 8080

# ENV: Set environment variable
ENV ENVIRONMENT=production

# CMD: Run application
CMD ["./webapp"]
```

## .dockerignore Files

Create a `.dockerignore` file to exclude unnecessary files from the Docker build context:

### Python .dockerignore
```
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git/
.mypy_cache/
.pytest_cache/
.hypothesis/
.DS_Store
```

### Go .dockerignore
```
.git/
.gitignore
README.md
Dockerfile
.dockerignore
.DS_Store
*.log
tmp/
vendor/
```

### Rust .dockerignore
```
target/
.git/
.gitignore
README.md
Dockerfile
.dockerignore
.DS_Store
*.log
```

### C++ .dockerignore
```
build/
.git/
.gitignore
README.md
Dockerfile
.dockerignore
.DS_Store
*.log
*.o
*.a
```

## Building and Running

### Build Commands
```bash
# Build Python app
docker build -t python-webapp .

# Build Go app
docker build -t go-webapp .

# Build Rust app
docker build -t rust-webapp .

# Build C++ app
docker build -t cpp-webapp .
```

### Run Commands
```bash
# Run with port mapping
docker run -p 5000:5000 python-webapp
docker run -p 8080:8080 go-webapp
docker run -p 3030:3030 rust-webapp
docker run -p 8080:8080 cpp-webapp

# Run with environment variables
docker run -p 5000:5000 -e ENVIRONMENT=staging python-webapp

# Run in detached mode
docker run -d -p 5000:5000 --name my-app python-webapp
```

## Multi-Stage Build Benefits

1. **Smaller Images**: Production images don't contain build tools
2. **Security**: Fewer packages = smaller attack surface
3. **Performance**: Faster deployment and startup
4. **Separation**: Build dependencies separate from runtime

## Best Practices

1. **Use specific base image tags** (not `latest`)
2. **Run as non-root user** for security
3. **Use .dockerignore** to reduce build context
4. **Layer caching**: Copy dependency files before source code
5. **Multi-stage builds** for smaller production images
6. **Health checks** for container monitoring
7. **Set resource limits** in production