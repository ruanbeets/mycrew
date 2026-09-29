#!/usr/bin/env python3
"""Create a local-only virtual key; do not expose proxy administrator credentials."""
import json
import os
from pathlib import Path
import urllib.request

ROOT = Path(__file__).resolve().parent.parent
os.umask(0o077)
target = ROOT / 'state/hermes/.env'
if target.exists():
    print('Preserving existing Hermes credentials.')
    raise SystemExit(0)
values = dict(line.split('=', 1) for line in (ROOT / '.env').read_text().splitlines()
              if line and not line.startswith('#'))
payload = {'models': ['local-cheap'], 'key_alias': 'mycrew-local',
           'rpm_limit': 30, 'max_parallel_requests': 3,
           'metadata': {'purpose': 'local inference only'}}
request = urllib.request.Request('http://127.0.0.1:4000/key/generate',
    data=json.dumps(payload).encode(), headers={
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + values['LITELLM_MASTER_KEY']})
with urllib.request.urlopen(request, timeout=30) as response:
    key = json.load(response)['key']
with target.open('x') as f:
    f.write(f'OPENAI_API_KEY={key}\nOPENAI_BASE_URL=http://127.0.0.1:4000/v1\n')
print('Provisioned restricted local-only key. No cloud model is enabled.')
