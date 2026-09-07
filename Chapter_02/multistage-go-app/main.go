// Simple Go HTTP Server - Multi-Stage Build Example
// Book: Mastering Container Architectures on AWS - Chapter 2
//
// This demonstrates how multi-stage builds dramatically reduce image size
// by separating the build environment from the runtime environment.
// Build stage: ~800MB (full Go SDK)
// Runtime stage: ~20MB (just the compiled binary on Alpine)
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
	GoVersion string `json:"go_version"`
	OS        string `json:"os"`
	Arch      string `json:"arch"`
}

type ItemResponse struct {
	Items []Item `json:"items"`
	Count int    `json:"count"`
}

type Item struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	resp := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		GoVersion: runtime.Version(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func itemsHandler(w http.ResponseWriter, r *http.Request) {
	items := []Item{
		{ID: 1, Name: "Build Stage"},
		{ID: 2, Name: "Runtime Stage"},
		{ID: 3, Name: "Compiled Binary"},
	}
	resp := ItemResponse{Items: items, Count: len(items)}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/items", itemsHandler)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"service":"go-multistage-app","version":"1.0.0"}`)
	})

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
