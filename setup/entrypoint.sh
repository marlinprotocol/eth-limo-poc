#!/bin/sh

export ETH_RPC_ENDPOINT="https://eth.llamarpc.com"
export LOG_LEVEL="debug"

redis-server --save "" --appendonly no &
node dist/index.js &
/app/caddy run --config /app/Caddyfile &
/app/ipfs daemon 