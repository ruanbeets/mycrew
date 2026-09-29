#!/usr/bin/env python3
"""Generate private local state once. Never replace existing secrets."""
import os
from pathlib import Path
import secrets

ROOT = Path(__file__).resolve().parent.parent
os.umask(0o077)
for folder in ('state/hermes', 'logs', 'backups', 'workspace/missions',
               'workspace/artifacts', 'workspace/sandbox'):
    (ROOT / folder).mkdir(parents=True, exist_ok=True)
env = ROOT / '.env'
if not env.exists():
    values = {
        'POSTGRES_PASSWORD': secrets.token_hex(24),
        'LITELLM_MASTER_KEY': 'sk-' + secrets.token_hex(24),
        'LITELLM_SALT_KEY': secrets.token_hex(32),
        'HERMES_API_KEY': secrets.token_hex(32),
        'HERMES_UID': str(os.getuid()), 'HERMES_GID': str(os.getgid()),
    }
    with env.open('x') as f:
        f.write(''.join(f'{k}={v}\n' for k, v in values.items()))
    print('Generated private .env; existing configuration preserved.')
else:
    print('Using existing .env.')
