from pathlib import Path

from django.conf import settings
from django.shortcuts import render


def home(request):
    head = Path(settings.BASE_DIR) / "HEAD"
    with open(head) as f:
        sha = f.read().strip()  # or f.read(40) to get the first 40 chars

    assets_url = f"https://octo-waffle.s3.amazonaws.com/ebcustom/{sha}"
    return render(request, "tasks/index.html", {"assets_url": assets_url})
