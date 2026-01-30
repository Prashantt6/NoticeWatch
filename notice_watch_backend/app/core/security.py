import hashlib
import json

def hash_notice(notice: dict):
    notice_strings = json.dumps(notice, sort_keys=True)

    encoded_string = notice_strings.encode('utf-8')

    return hashlib.sha256(encoded_string).hexdigest()