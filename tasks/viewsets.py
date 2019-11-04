import datetime

from django.core.cache import cache
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from .models import Task
from .serializers import TaskSerializer


class TaskViewSet(ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer

    @action(detail=False)
    def get_cached_value(self, request, *args, **kwargs):
        current_time_iso = datetime.datetime.now().isoformat()
        cached_value = cache.get_or_set('current_time', current_time_iso, 30)

        return Response(
            data={"cached_value": cached_value}, status=status.HTTP_200_OK
        )

