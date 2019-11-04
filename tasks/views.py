import subprocess

from django.shortcuts import render


def home(request):
    ps = subprocess.run(
        args=["git", "rev-parse", "--short", "HEAD"],
        stdout=subprocess.PIPE,
        encoding="utf8"
    )

    sha = ps.stdout.strip()
    assets_url = f"https://octo-waffle.s3.amazonaws.com/ebcustom-{sha}"

    return render(request, "tasks/index.html", {"assets_url": assets_url})
