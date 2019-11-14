import datetime
from pathlib import Path

from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt


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


@csrf_exempt
def testjob(request):
    """
    handler for test job request
    """
    with open("/tmp/testjob.log", "a") as f:
        f.write("\n\n")
        f.write(f"* testjob triggerd at {datetime.datetime.now()}\n")

        f.write("[headers]\n")
        for key, value in request.headers.items():
            f.write(f"- {key} : {value}\n")

        f.write("[body]\n")
        f.write(str(request.body))

    return HttpResponse(status=204)
