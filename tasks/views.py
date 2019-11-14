import datetime
from pathlib import Path

from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render


def home(request):
    """
    Just an example
    only used in non-dev environments
    """
    head = Path(settings.BASE_DIR) / "HEAD"
    with open(head) as f:
        sha = f.read().strip()
    assets_url = f"https://public.hankehly.xyz/{sha}"
    return render(request, "tasks/index.html", {"assets_url": assets_url})


def testjob(request):
    """
    handler for test job request
    """
    with open("/tmp/testjob.log", "a") as f:
        f.write(f"testjob triggerd at {datetime.datetime.now()}\n")

    return HttpResponse(status=204)
