#!/usr/bin/env python3

# Usage:
#    python lint-summary.py <openapi-file>

import json
import subprocess
import sys

if len(sys.argv) < 2:
    print("Usage: python lint-summary.py <openapi-file>", file=sys.stderr)
    sys.exit(1)

file = sys.argv[1]

result = subprocess.run(
    ["spectral", "lint", "-q", "-f", "json", file],
    capture_output=True,
    text=True,
)

if not result.stdout.strip():
    print("No lint issues found.")
    sys.exit(0)

results = json.loads(result.stdout)

codes = {x['code'] for x in results}

summary = []

for code in codes:
    results_for_code = [x for x in results if x['code'] == code]
    count = len(results_for_code)
    messages = {x['message'] for x in results_for_code}
    summary.append({
        'code': code,
        'count': count,
        'messages': messages,
    })

summary.sort(key=lambda x: x['count'], reverse=True)

for elem in summary:
    code = elem['code']
    count = elem['count']
    messages = elem['messages']
    print(f'{count:6d} {(count/len(results))*100:.1f}% {code}')
    for message in messages:
        print(f'\t{message}')
