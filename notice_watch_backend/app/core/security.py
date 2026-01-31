import hashlib
import json

def hash_notice(notice: dict):
    notice_strings = json.dumps(notice, sort_keys=True)

    encoded_string = notice_strings.encode('utf-8')

    return hashlib.sha256(encoded_string).hexdigest()

def hash_page(hash_notice: list[str]) -> str:
    clean = [str(x) for x in hash_notice]  
    page_string = json.dumps(clean, sort_keys=True)
    return hashlib.sha256(page_string.encode()).hexdigest()