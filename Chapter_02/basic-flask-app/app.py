"""
Basic Flask REST API - Docker Container Example
Book: Mastering Container Architectures on AWS - Chapter 2

A minimal Flask application demonstrating how to containerize
a Python web service with Docker best practices.
"""
import os
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({"service": "basic-flask-api", "version": "1.0.0"})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/api/items", methods=["GET"])
def list_items():
    items = [
        {"id": 1, "name": "Docker Image", "description": "Immutable application package"},
        {"id": 2, "name": "Container", "description": "Running instance of an image"},
        {"id": 3, "name": "Volume", "description": "Persistent data storage"},
    ]
    return jsonify({"items": items})

@app.route("/api/items", methods=["POST"])
def create_item():
    data = request.get_json()
    return jsonify({"created": True, "item": data}), 201

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
