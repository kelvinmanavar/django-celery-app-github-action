# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""

from django.contrib import admin
from django.urls import path, include  # add this
from django.http import HttpResponse

def health(request):
    return HttpResponse("OK")

urlpatterns = [
    path('health/', health),
    path('admin/', admin.site.urls),               # Django admin route
    path("", include("apps.authentication.urls")), # Auth routes - login / register

    # ADD NEW Routes HERE
    path("", include("apps.tasks.urls")),          # Tasks Routes

    # Leave `Home.Urls` as last the last line
    path("", include("apps.home.urls"))
]
