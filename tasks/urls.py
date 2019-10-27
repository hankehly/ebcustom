from django.urls import include, path

from rest_framework import routers

from .viewsets import TaskViewSet

router = routers.DefaultRouter()
router.register("tasks", TaskViewSet)

urlpatterns = [path("", include(router.urls))]
