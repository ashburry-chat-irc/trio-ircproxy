from __future__ import annotations
from time import time
import os
import sys
import json
from pathlib import Path
from os import unlink
from os.path import realpath, exists
from cryptography.fernet import Fernet, InvalidToken
from os import path
from users import user_file

w3proxy_dir = path.dirname(path.abspath(__file__))

app_root: Path = Path(w3proxy_dir) / ".." / "www" / 'app'

home_file: Path = Path(w3proxy_dir) / 'home.json'
key_file: Path = Path(w3proxy_dir) / 'safe.dat'
flood_file: Path = app_root / 'flood.json'
bnc_file: Path = app_root / 'bnc.json'
net_file: Path = app_root / 'network.json'


def generate_key():
    """
    Generates a key and save it into a file
    """
    key = Fernet.generate_key()
    with open(key_file, "wb") as key_filer:
        key_filer.write(key)


def load_key() -> bytes:
    """
    Load the previously generated key
    """
    return open(key_file, "rb").read()


def encrypt_home():
    """
    Encrypts a message
    """
    encoded_message_b: bytes = bytes(json.dumps(json_data.home).encode())
    generate_key()
    key: bytes = load_key()
    f = Fernet(key)
    encrypted_message_b = f.encrypt(encoded_message_b)
    with open(home_file, 'wb') as sfw:
        sfw.write(encrypted_message_b)


def decrypt_home():
    """
    Decrypts an encrypted message
    """
    key: bytes = load_key()
    with open(home_file, 'rb') as sfread:
        home_read = sfread.read()
    f: Fernet = Fernet(key)
    try:
        try:
            decrypted_message: bytes = f.decrypt(home_read)
            json_data.home = json.loads(decrypted_message.decode())
            if not json_data.home:
                raise json.decoder.JSONDecodeError('Invalid', 'Password', 0)
            return json_data.home
        except (InvalidToken, ValueError):
            json_data.home = json.loads(home_read.decode())
            return json_data.home
    except json.decoder.JSONDecodeError:
        json_data.home = {}
        json_data.home['home'] = {}
        json_data.home['home']['server_name'] = 'Unnamed' + str(time()).split('.')[1]
        json_data.home['home']['admin'] = 'your nickname'
        json_data.home['home']['email'] = 'your-email@outlook.com'
        json_data.home['home']['smtp_server'] = 'smtp.outlook.com'
        json_data.home['home']['smtp_port'] = '465'
        json_data.home['home']['smtp_password'] = 'your password'
        encrypt_home()
        return json_data.home


class JSON_Data:
    users: dict[str, dict[str, str]] = {}
    home: dict[str, dict[str, str | int]] = {}
    flood: dict[str, list[str] | dict[str, str | float | int]] = {}
    bnc: dict[str, dict[str, str | int]] = {}
    network: dict[str, dict[str, str | int]] = {}

    @classmethod
    def load_files(cls, spec: str | None = None) -> None:
        sys.path.insert(0,'/home/xdcc/website_and_proxy')
        from users import user_file

        try:
            error_c += 1
        except NameError:
            error_c: int = 0
        try:
            if exists(user_file) and (not spec or spec == 'user' or spec == 'users'):
                split_lines: list[str]
                removed: set[int] = set()
                data: str
                with open(user_file, 'r') as sfread:
                    data = sfread.read()
                data = data.rstrip()
                split_lines = data.split('\n')
                line_no: int = 0
                for line in split_lines:
                    if line.count(':') != 2:
                        removed.add(line_no)
                        continue
                    line_no += 1
                    line_split: list[str] = line.split(':')
                    if len(line_split) != 3:
                        removed.add(line_no)
                        continue
                    user_low = line_split[0].lower()
                    cls.users[user_low]: dict[str, str] = {}
                    cls.users[user_low]['user'] = user_low
                    cls.users[user_low]['email'] = line_split[1].lower()
                    cls.users[user_low]['hash'] = line_split[2]

                for i in removed:
                    del split_lines[i]
                if removed and split_lines:
                    with open(user_file, 'w') as sfopen:
                        for line in split_lines:
                            sfopen.write(line)

            if (not spec or spec == 'home') and exists(home_file):
                cls.home = decrypt_home()
            if (not spec or spec == 'flood') and exists(flood_file):
                with open(flood_file, 'r') as sfread:
                    cls.flood = json.load(sfread)
            if (not spec or spec == 'bnc') and exists(bnc_file):
                with open(bnc_file, 'r') as sfread:
                    cls.bnc = json.load(sfread)

            if (not spec or spec == 'network') and exists(net_file):
                with open(net_file, 'r') as sfread:
                    cls.network = json.load(sfread)

        except EOFError:
            if error_c == 0:
                cls.load_files(spec)
                error_c: int = 0

    @classmethod
    def save_files(cls, spec: str | None = None):
        if not spec or spec == 'user' or spec == 'users':
            with open(user_file, 'w') as sfopen:
                for user in cls.users:
                    sfopen.write(cls.users[user]['user'] + ':' + cls.users[user]['email'] + ':' \
                                 + cls.users[user]['hash'] + '\n')

        if not spec or spec == 'home':
            encrypt_home()
        if not spec or spec == 'flood':
            with open(flood_file, 'w') as sfwrite:
                sfwrite.write(json.dumps(json_data.flood))
        if not spec or spec == 'bnc':
            with open(bnc_file, 'w') as sfwrite:
                sfwrite.write(json.dumps(json_data.bnc))
        if not spec or spec == ' network':
            with open(net_file, 'w') as sfwrite:
                sfwrite.write(json.dumps(json_data.network))

if not exists(key_file):
    generate_key()

json_data: JSON_Data = JSON_Data()
json_data.load_files()
json_data.save_files()
