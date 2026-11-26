#!/usr/bin/env bash
set -e

PROVIDER="${TUNNEL_PROVIDER:-bore}"
echo "=========================================================="
echo "🌐 Starting FREE TCP Tunnel (Provider: $PROVIDER, Port: 7777)"
echo "=========================================================="

mkdir -p bin
rm -f /tmp/server_endpoint.txt

start_bore() {
    echo "⚡ Downloading bore v0.6.0 (Free, No API Key, No Account)..."
    curl -sSL -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"
    tar -xzf /tmp/bore.tar.gz -C bin/
    rm -f /tmp/bore.tar.gz
    chmod +x bin/bore

    ./bin/bore local 7777 --to bore.pub > /tmp/bore.log 2>&1 &
    BORE_PID=$!

    for i in $(seq 1 15); do
        if grep -q "listening at bore.pub:" /tmp/bore.log 2>/dev/null; then
            ADDR=$(grep -oE "bore\.pub:[0-9]+" /tmp/bore.log | head -n 1)
            HOST="bore.pub"
            PORT=$(echo "$ADDR" | cut -d: -f2)
            echo "${HOST}|${PORT}|bore.pub (Free TCP)|${BORE_PID}" > /tmp/server_endpoint.txt
            return 0
        fi
        sleep 1
    done
    cat /tmp/bore.log || true
    return 1
}

start_pinggy() {
    echo "⚡ Starting Pinggy TCP Tunnel over SSH (Free, No API Key)..."
    ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -p 443 -R0:localhost:7777 tcp@free.pinggy.io > /tmp/pinggy.log 2>&1 &
    PINGGY_PID=$!

    for i in $(seq 1 15); do
        if grep -qE "tcp://[a-zA-Z0-9.-]+:[0-9]+" /tmp/pinggy.log 2>/dev/null; then
            RAW=$(grep -oE "tcp://[a-zA-Z0-9.-]+:[0-9]+" /tmp/pinggy.log | head -n 1 | sed 's|tcp://||')
            HOST=$(echo "$RAW" | cut -d: -f1)
            PORT=$(echo "$RAW" | cut -d: -f2)
            echo "${HOST}|${PORT}|pinggy.io (Free TCP)|${PINGGY_PID}" > /tmp/server_endpoint.txt
            return 0
        fi
        sleep 1
    done
    cat /tmp/pinggy.log || true
    return 1
}

start_playit() {
    echo "⚡ Downloading Playit.gg agent (Free Claim Mode)..."
    curl -sSL -o bin/playit "https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64"
    chmod +x bin/playit

    if [ -n "$PLAYIT_SECRET_KEY" ]; then
        ./bin/playit --secret "$PLAYIT_SECRET_KEY" run > /tmp/playit.log 2>&1 &
    else
        ./bin/playit run > /tmp/playit.log 2>&1 &
    fi
    PLAYIT_PID=$!
    sleep 6
    CLAIM=$(grep -oE "https://playit\.gg/claim/[a-zA-Z0-9_-]+" /tmp/playit.log | head -n 1 || echo "See logs")
    echo "playit.gg|7777|playit.gg ($CLAIM)|${PLAYIT_PID}" > /tmp/server_endpoint.txt
    return 0
}

if [ "$PROVIDER" = "playit" ] || [ -n "$PLAYIT_SECRET_KEY" ]; then
    start_playit || start_bore || start_pinggy
elif [ "$PROVIDER" = "pinggy" ]; then
    start_pinggy || start_bore
else
    start_bore || start_pinggy
fi

if [ -f /tmp/server_endpoint.txt ]; then
    IFS='|' read -r HOST PORT LABEL TPID < /tmp/server_endpoint.txt
    echo "=========================================================="
    echo "🚀 TUNNEL CONNECTED!"
    echo "📡 Server IP/Host: $HOST"
    echo "🔌 Server Port:    $PORT"
    echo "🛡️ Provider:       $LABEL"
    echo "=========================================================="
else
    echo "❌ Failed to open any tunnel."
    exit 1
fi
