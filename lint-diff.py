#!/usr/bin/env python3

import json
import subprocess
import sys
import tempfile

def usage():
    print("lint-diff file1 file2")

if len(sys.argv) < 3:
    usage()
    exit(-1)

lint = ['spectral', 'lint', '-f', 'json', '-q']

with tempfile.TemporaryFile() as fp:
    sp = subprocess.run(lint + [sys.argv[1]], stdout=fp)
    fp.seek(0)
    old = json.load(fp)

with tempfile.TemporaryFile() as fp:
    sp = subprocess.run(lint + [sys.argv[2]], stdout=fp)
    fp.seek(0)
    new = json.load(fp)

# {
# 	"code": "az-property-names-convention",
# 	"path": [
# 		"definitions",
# 		"EnrichmentStatusList",
# 		"properties",
# 		"@nextLink"
# 	],
# 	"message": "Property name should be camel case.",
# 	"severity": 1,
# 	"range": {
# 		"start": {
# 			"line": 6854,
# 			"character": 20
# 		},
# 		"end": {
# 			"line": 6856,
# 			"character": 26
# 		}
# 	},
# 	"source": "/Users/mikekistler/Projects/Azure/azure-rest-api-specs-pr/specification/cognitiveservices/data-plane/MetricsAdvisor/stable/v1.0/MetricsAdvisor.json"
# }

def fingerprint(msg):
    return '-'.join(msg['path'] + [msg['code']])

old_fingerprints = {fingerprint(x) for x in old}

diff = [x for x in new if fingerprint(x) not in old_fingerprints]

#  2392:18      warning  az-schema-description-or-title  Schema should have a description or title.

for x in diff:
    line = x['range']['start']['line']
    code = x['code']
    severity = ['error', 'warning', 'hint', 'info'][x['severity']]
    message = x['message']
    print(f'{line} {code} {severity} {message}')
