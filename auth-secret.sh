#!/bin/bash
set -e

AUTH="$2:$(openssl passwd -salt $1 -crypt $3)"
jq -n --arg auth "$AUTH" '{"value":$auth}'
