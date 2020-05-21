#!/usr/bin/env python3
import base64
import json
import secrets
import sys

input_data = sys.stdin.read()
input_json = json.loads(input_data)

secret_bytes_length = int(input_json.get('secret_bytes_length', '512'))
secret_bytes = base64.b64encode(secrets.token_bytes(secret_bytes_length)).decode()
json_data = json.dumps({"secret": secret_bytes})
print(json_data)
