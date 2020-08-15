#!/bin/sh

set -e

echo 'sh.status().ok' | mongo localhost:27017/test --quiet | grep 1 

