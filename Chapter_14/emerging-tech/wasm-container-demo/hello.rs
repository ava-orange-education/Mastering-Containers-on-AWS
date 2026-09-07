// WebAssembly Container Demo - Rust Application
// Book: Mastering Container Architectures on AWS - Chapter 14
//
// Compiled to WASM for sub-millisecond cold starts (vs seconds for containers)
// Build: cargo build --target wasm32-wasip1 --release
use std::io;

fn main() {
    println!("Hello from WebAssembly on Kubernetes!");
    println!("Module size: ~2MB (vs ~20MB+ for minimal containers)");
    println!("Cold start: <1ms (vs 100ms-seconds for containers)");

    // Simple HTTP-like response
    let response = r#"{"service": "wasm-demo", "runtime": "wasmtime", "status": "healthy"}"#;
    println!("{}", response);
}
