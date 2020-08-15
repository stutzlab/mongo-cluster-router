#!/bin/sh

set -e

R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)

echo $R | grep 1
