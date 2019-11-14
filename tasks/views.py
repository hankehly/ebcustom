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

    Actual result from beanstalk instance:
    * testjob triggerd at 2019-11-14 01:02:00.105119
    [headers]
    - Content-Type : application/json
    - User-Agent : aws-sqsd/2.4
    - X-Aws-Sqsd-Msgid : 6998edf8-3f19-4c69-92cf-7c919241b957
    - X-Aws-Sqsd-Receive-Count : 4
    - X-Aws-Sqsd-First-Received-At : 2019-11-14T00:47:00Z
    - X-Aws-Sqsd-Sent-At : 2019-11-14T00:47:00Z
    - X-Aws-Sqsd-Queue : awseb-e-n23e8zdd3w-stack-AWSEBWorkerQueue-1QZHOZ650P0J0
    - X-Aws-Sqsd-Path : /testjob
    - X-Aws-Sqsd-Sender-Id : AROA2XEFXCLXVWYXRGF4D:i-07f157f85fb97a241
    - X-Aws-Sqsd-Scheduled-At : 2019-11-14T00:47:00Z
    - X-Aws-Sqsd-Taskname : testjob
    - Connection : close
    - Host : localhost
    - Content-Length : 0
    [body]
    b''
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
