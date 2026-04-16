#!/bin/bash

if [ "$APP_ROLE" = "web" ]; then
  for i in {1..15}; do
    curl -f http://localhost/health/ && exit 0
    sleep 5
  done
  exit 1
else
  exit 0
fi