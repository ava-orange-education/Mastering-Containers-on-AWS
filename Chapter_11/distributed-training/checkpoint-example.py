"""
PyTorch Checkpoint Save/Restore Pattern for Fault-Tolerant Training
Book: Mastering Container Architectures on AWS - Chapter 11

Checkpoints enable training to resume after pod preemption (Spot),
hardware failure, or manual interruption. Use EFS for shared storage
accessible by all worker pods.
"""
import os
import torch
import torch.distributed as dist

CHECKPOINT_DIR = os.environ.get("CHECKPOINT_DIR", "/checkpoints")

def save_checkpoint(model, optimizer, epoch, loss, path=None):
    """Save training checkpoint atomically using rename pattern."""
    if path is None:
        path = os.path.join(CHECKPOINT_DIR, f"checkpoint_epoch_{epoch}.pt")

    # Only rank 0 saves to avoid file conflicts in distributed training
    if dist.is_initialized() and dist.get_rank() != 0:
        return

    tmp_path = path + ".tmp"
    checkpoint = {
        "epoch": epoch,
        "model_state_dict": model.state_dict(),
        "optimizer_state_dict": optimizer.state_dict(),
        "loss": loss,
    }

    # Atomic save: write to temp file, then rename (prevents corruption)
    torch.save(checkpoint, tmp_path)
    os.rename(tmp_path, path)  # Atomic on POSIX filesystems
    print(f"Checkpoint saved: epoch={epoch}, loss={loss:.4f}")

def load_latest_checkpoint(model, optimizer):
    """Load the most recent checkpoint for training resumption."""
    if not os.path.exists(CHECKPOINT_DIR):
        return 0  # No checkpoints, start from epoch 0

    checkpoints = sorted([
        f for f in os.listdir(CHECKPOINT_DIR)
        if f.startswith("checkpoint_epoch_") and f.endswith(".pt")
    ])

    if not checkpoints:
        return 0

    latest = os.path.join(CHECKPOINT_DIR, checkpoints[-1])
    print(f"Resuming from checkpoint: {latest}")

    checkpoint = torch.load(latest, map_location="cpu", weights_only=True)
    model.load_state_dict(checkpoint["model_state_dict"])
    optimizer.load_state_dict(checkpoint["optimizer_state_dict"])

    return checkpoint["epoch"] + 1  # Resume from next epoch

# Usage in training loop:
# start_epoch = load_latest_checkpoint(model, optimizer)
# for epoch in range(start_epoch, total_epochs):
#     train_one_epoch(model, optimizer, dataloader)
#     save_checkpoint(model, optimizer, epoch, loss)
