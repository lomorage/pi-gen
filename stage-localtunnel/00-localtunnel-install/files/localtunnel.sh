#!/bin/bash
PORT=8000

until lt -s $1 -p $PORT --print-requests
do
  echo "Retry ..."
done
