import requests
import hashlib

def url(version):

    result = requests.get("https://launchermeta.mojang.com/mc/game/version_manifest.json")

    version_data = next(version_data["url"] for version_data in result.json()["versions"] if version_data["id"] == version)
    url = requests.get(version_data).json()["downloads"]["server"]["url"]

    return url

def hash(version):
    return hashlib.md5(requests.get(url(version)).content).hexdigest()

