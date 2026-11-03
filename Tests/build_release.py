# Packs what's committed into the zip a release attaches: one Hearthbound folder,
# ready to unzip into AddOns, without the tests, old snapshots and screenshots.
#   python Tests/build_release.py <folder to write the zip to>
import io
import os
import re
import subprocess
import sys
import tarfile
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
LEAVE_OUT = re.compile(r"^(Tests/|RouteBackups/|screenshots/|\.git|README\.md$)")


def git(*args):
    return subprocess.run(["git", *args], cwd=ADDON, capture_output=True, check=True).stdout


if len(sys.argv) != 2:
    sys.exit("usage: build_release.py <folder to write the zip to>")
toc = git("show", "HEAD:Hearthbound.toc").decode("utf-8")
version = re.search(r"^## Version: (\S+)", toc, re.M).group(1)
needed = {line.strip() for line in toc.splitlines() if line.strip() and not line.startswith("##")} | {"Hearthbound.toc"}
path = os.path.join(sys.argv[1], f"Hearthbound-{version}.zip")

names = []
with tarfile.open(fileobj=io.BytesIO(git("archive", "--format=tar", "HEAD"))) as tar, \
        zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as out:
    for member in tar.getmembers():
        if member.isfile() and not LEAVE_OUT.match(member.name):
            out.writestr("Hearthbound/" + member.name, tar.extractfile(member).read())
            names.append(member.name)

missing = needed - set(names)
if missing:
    os.remove(path)
    sys.exit(f"the .toc loads files that aren't in the zip: {sorted(missing)}")
print(f"{path}: {len(names)} files, {os.path.getsize(path) / 1048576:.1f} MB")
