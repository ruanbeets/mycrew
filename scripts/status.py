#!/usr/bin/env python3
"""One-shot host observations. No model calls, polling daemon or third-party packages."""
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import urllib.request

ROOT = Path(__file__).resolve().parent.parent
def run(args):
    try:
        p = subprocess.run(args, text=True, capture_output=True, timeout=8)
        return p.stdout.strip() if p.returncode == 0 else 'unavailable'
    except (OSError, subprocess.TimeoutExpired):
        return 'unavailable'

def get(path):
    try:
        with urllib.request.urlopen('http://127.0.0.1:' + path, timeout=3) as r:
            return json.load(r)
    except Exception:
        return {'available': False}

def cpu():
    return list(map(int, Path('/proc/stat').read_text().splitlines()[0].split()[1:9]))

a = cpu(); time.sleep(0.2); b = cpu()
delta = [y-x for x, y in zip(a, b)]
mem = {line.split(':')[0]: int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()}
disk = shutil.disk_usage(ROOT)
data = {
    'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'uptime_seconds': float(Path('/proc/uptime').read_text().split()[0]),
    'load': os.getloadavg(),
    'cpu_percent': round(100 * (1 - (delta[3]+delta[4])/max(sum(delta), 1)), 1),
    'ram_mib': {'total': mem['MemTotal']//1024, 'available': mem['MemAvailable']//1024,
                'used': (mem['MemTotal']-mem['MemAvailable'])//1024},
    'disk_gib': {'total': round(disk.total/2**30, 1), 'free': round(disk.free/2**30, 1)},
    'gpu_csv': run(['nvidia-smi', '--query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.free', '--format=csv,noheader']),
    'services': {name: run(['systemctl', 'is-active', name]) for name in ('docker','ollama','tailscaled')},
    'ollama_models': get('11434/api/tags'),
    'ollama_loaded': get('11434/api/ps'),
    'litellm': get('4000/health/liveliness'),
    'hermes': get('8642/health'),
    'dashboard': get('9119/api/status'),
    'usage': get('9119/api/analytics/usage?days=7'),
    'tailscale': run(['tailscale', 'status']),
    'containers': run(['bash', '-c', 'source "$1/scripts/common.sh"; dc ps --format json', 'status', str(ROOT)]),
    'postgres': run(['bash', '-c', 'source "$1/scripts/common.sh"; dc exec -T postgres pg_isready -U mycrew -d mycrew', 'status', str(ROOT)]),
}
if '--text' in sys.argv:
    for key, value in data.items():
        print(f'{key}: {json.dumps(value, ensure_ascii=False) if isinstance(value, (dict,list,tuple)) else value}')
else:
    print(json.dumps(data, indent=2))
