# ============================================================================
# Multi-Stage Dockerfile for Go Application
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# Multi-stage builds separate the build environment from the runtime:
#   Stage 1 (builder): Full Go SDK (~800MB) to compile the binary
#   Stage 2 (runtime): Minimal Alpine (~5MB) + compiled binary (~15MB)
#   Result: Final image ~20MB instead of ~800MB (97.5% reduction)
#
# This is one of the most important Docker optimization techniques.
# ============================================================================

# ---- Stage 1: Build ----
# Full Go SDK for compilation (this layer is discarded in final image)
FROM golang:1.23-alpine AS builder

# Install git for module downloads and ca-certificates for HTTPS
RUN apk add --no-cache git ca-certificates

WORKDIR /build

# Copy dependency files first (layer caching optimization)
# If go.mod/go.sum don't change, this layer is cached
COPY go.* ./
# Uncomment when using Go modules:
# RUN go mod download

# Copy source code and compile
COPY main.go .

# Build static binary with CGO disabled (no C dependencies)
# -ldflags="-s -w" strips debug info for smaller binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /app/server main.go

# ---- Stage 2: Runtime ----
# Minimal base image - only what's needed to run the binary
FROM alpine:3.20

# Install CA certificates for HTTPS calls and create non-root user
RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

# Copy ONLY the compiled binary from the build stage
COPY --from=builder /app/server .

# Switch to non-root user
USER appuser

EXPOSE 8080

# Exec form for proper PID 1 signal handling
CMD ["./server"]
