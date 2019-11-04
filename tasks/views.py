import datetime

from django.core.cache import cache
from django.shortcuts import render


def home(request):
    dt = datetime.datetime.now().isoformat()
    value = cache.get_or_set('current_time', dt, 30)

    return render(
        request, "tasks/index.html", {"ebcustom_redis_cached_value": value}
    )
