import base64
# import hashlib
import json
# import secrets
import subprocess
import sys
import tempfile

# from cryptography.hazmat.backends import default_backend
# from cryptography.hazmat.primitives.ciphers import (
#     Cipher, algorithms, modes
# )

INPUT = json.loads(sys.stdin.read())

SECRET = INPUT['key']
DATABAG = INPUT['data_bag_name']

result = {
    "id": "certificates"
}

serviceaccount_key_proc = subprocess.Popen(('openssl', 'genrsa', '2048'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
serviceaccount_key, stderr = serviceaccount_key_proc.communicate()
if serviceaccount_key_proc.returncode != 0:
    print('Failed to generate service account key: ', stderr)
    sys.exit(1)
if not serviceaccount_key.startswith(b'-----BEGIN PRIVATE KEY'):
    print('Service account key does not start with -----BEGIN PRIVATE KEY')
    sys.exit(1)

result['kube_serviceaccount_key'] = base64.b64encode(serviceaccount_key).decode()

for _type in ('kube', 'etcd'):
    proc_input = '{"CN": "' + _type + '", "key": {"algo": "rsa", "size": 2048}, "names": [{"C": "GB", "L": "Ascot", "ST": "Berkshire", "O": "Kubernetes", "OU": "CA"}]}'
    proc = subprocess.Popen(('cfssl', 'gencert', '-initca', '-'), stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
    stdout, stderr = proc.communicate(proc_input.encode())
    if proc.returncode != 0:
        print('Failed to generate certificate', stderr)
        sys.exit(1)
    cert_json = json.loads(stdout)
    result[f'{_type}_ca_cert'] = base64.b64encode(cert_json['cert'].encode()).decode()
    result[f'{_type}_ca_key'] = base64.b64encode(cert_json['key'].encode()).decode()

# # For some reason chef refuses to decode :/
# output = {}
# SECRET = base64.b64decode(SECRET)
# for key, value in result.items():
#     if key in ('id',):
#         output[key] = value
#         continue
#
#     secret_key = hashlib.sha256(SECRET).digest()
#     iv = secrets.token_bytes(12)
#     plaintext = json.dumps({'json_wrapper': value})
#
#     encryptor = Cipher(
#         algorithms.AES(secret_key),
#         modes.GCM(iv),
#         backend=default_backend()
#     ).encryptor()
#
#     ciphertext = encryptor.update(plaintext.encode()) + encryptor.finalize()
#     output[key] = {
#         'cipher': 'aes-256-gcm',
#         'version': 3,
#         'iv': base64.encodebytes(iv).decode(),
#         'auth_tag': base64.encodebytes(encryptor.tag).decode(),
#         'encrypted_data': base64.encodebytes(ciphertext).decode()
#     }
#
# print(json.dumps({'value': json.dumps(output)}))

with tempfile.NamedTemporaryFile(mode='w+', suffix='.json') as fp:
    json.dump(result, fp)
    fp.flush()

    knife_proc = subprocess.Popen(
        ('knife', 'data', 'bag', 'from', 'file', DATABAG, fp.name, '--secret', SECRET),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = knife_proc.communicate()

if knife_proc.returncode != 0:
    print('Failed to upload certs', stderr, file=sys.stderr)
    sys.exit(1)


print(json.dumps({'dummy': '1'}))
