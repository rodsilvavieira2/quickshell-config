#!/usr/bin/env python3

import json
import shutil
import subprocess
import time
from pathlib import Path


def read_cpu_usage():
    def snapshot():
        with open("/proc/stat", "r", encoding="utf-8") as handle:
            parts = handle.readline().split()

        values = [int(part) for part in parts[1:9]]
        idle = values[3] + values[4]
        total = sum(values)
        return idle, total

    idle_a, total_a = snapshot()
    time.sleep(0.15)
    idle_b, total_b = snapshot()

    diff_idle = idle_b - idle_a
    diff_total = total_b - total_a
    if diff_total <= 0:
        return 0.0

    return max(0.0, min(1.0, (diff_total - diff_idle) / diff_total))


def read_mem_usage():
    fields = {}
    with open("/proc/meminfo", "r", encoding="utf-8") as handle:
        for line in handle:
            key, value = line.split(":", 1)
            fields[key] = int(value.strip().split()[0])

    total_kib = fields.get("MemTotal", 1)
    available_kib = fields.get("MemAvailable", 0)
    used_kib = max(0, total_kib - available_kib)

    gib = 1024 * 1024
    return used_kib / gib, total_kib / gib


def read_cpu_temp():
    sensors_bin = shutil.which("sensors")
    if sensors_bin:
        try:
            proc = subprocess.run(
                [sensors_bin],
                capture_output=True,
                text=True,
                timeout=1.5,
                check=False,
            )
            for line in proc.stdout.splitlines():
                if any(token in line for token in ("Package id 0:", "Tctl:", "Core 0:")):
                    for part in line.split():
                        if part.startswith("+") and "°C" in part:
                            return part.lstrip("+")
        except Exception:
            pass

    for temp_file in Path("/sys/class/thermal").glob("thermal_zone*/temp"):
        try:
            raw = temp_file.read_text(encoding="utf-8").strip()
            value = int(raw)
            if value > 1000:
                return f"{value / 1000:.1f}°C"
        except Exception:
            continue

    return "..."


def read_gpu_stats():
    nvidia_smi = shutil.which("nvidia-smi")
    if not nvidia_smi:
        return {
            "gpu_usage": 0.0,
            "gpu_temp": "...",
            "gpu_mem_used": 0.0,
            "gpu_mem_total": 1.0,
            "has_gpu": False,
        }

    try:
        proc = subprocess.run(
            [
                nvidia_smi,
                "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total",
                "--format=csv,noheader,nounits",
            ],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        )
        line = proc.stdout.strip().splitlines()[0] if proc.stdout.strip() else ""
        parts = [part.strip() for part in line.split(",")]
        if proc.returncode != 0 or len(parts) != 4:
            raise RuntimeError("invalid nvidia-smi output")

        usage = max(0.0, min(1.0, float(parts[0]) / 100.0))
        temp = f"{float(parts[1]):.0f}°C"
        mem_used = float(parts[2]) / 1024.0
        mem_total = max(1.0, float(parts[3]) / 1024.0)

        return {
            "gpu_usage": usage,
            "gpu_temp": temp,
            "gpu_mem_used": mem_used,
            "gpu_mem_total": mem_total,
            "has_gpu": True,
        }
    except Exception:
        return {
            "gpu_usage": 0.0,
            "gpu_temp": "...",
            "gpu_mem_used": 0.0,
            "gpu_mem_total": 1.0,
            "has_gpu": False,
        }


def main():
    mem_used, mem_total = read_mem_usage()
    gpu = read_gpu_stats()

    payload = {
        "cpu_usage": read_cpu_usage(),
        "cpu_temp": read_cpu_temp(),
        "mem_used": mem_used,
        "mem_total": mem_total,
        **gpu,
    }

    print(json.dumps(payload, separators=(",", ":")))


if __name__ == "__main__":
    main()
