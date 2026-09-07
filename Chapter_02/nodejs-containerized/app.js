/**
 * Express.js Server - Container-Ready Node.js Application
 * Book: Mastering Container Architectures on AWS - Chapter 2
 *
 * Demonstrates Node.js containerization best practices:
 * - Graceful shutdown handling (SIGTERM from orchestrator)
 * - Health check endpoint
 * - Structured JSON logging to stdout
 * - Environment-based configuration
 */
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVICE_NAME = process.env.SERVICE_NAME || 'nodejs-container-app';

// Middleware
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration_ms: Date.now() - start,
      service: SERVICE_NAME
    }));
  });
  next();
});

// Routes
app.get('/', (req, res) => {
  res.json({ service: SERVICE_NAME, version: '1.0.0', runtime: 'Node.js' });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/items', (req, res) => {
  res.json({
    items: [
      { id: 1, name: 'Express.js', type: 'framework' },
      { id: 2, name: 'Alpine', type: 'base-image' },
      { id: 3, name: 'Multi-stage', type: 'build-pattern' }
    ]
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    message: `Server started on port ${PORT}`,
    service: SERVICE_NAME
  }));
});

// Graceful shutdown - handle SIGTERM from container orchestrator
process.on('SIGTERM', () => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    message: 'SIGTERM received, shutting down gracefully',
    service: SERVICE_NAME
  }));
  server.close(() => {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      message: 'Server closed',
      service: SERVICE_NAME
    }));
    process.exit(0);
  });
});
