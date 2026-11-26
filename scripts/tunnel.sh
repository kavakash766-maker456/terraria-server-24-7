#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "🌐 Initializing Port Forwarding Tunnel for Terraria (7777)"
echo "=========================================================="

mkdir -p bin

# 1. Check for ngrok token
if [ -n "$NGROK_AUTHTOKEN" ]; then
    echo "⚡ Setting up ngrok TCP Tunnel..."
    curl -sSL -o /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar -xzf /tmp/ngrok.tgz -C bin/
    rm -f /tmp/ngrok.tgz
    ./bin/ngrok config add-authtoken "$NGROK_AUTHTOKEN"
    ./bin/ngrok tcp 7777 --log=stdout > /tmp/ngrok.log 2>&1 &
    sleep 5
    
    NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")
    if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
        CLEAN_ADDR=$(echo "$NGROK_URL" | sed 's|tcp://||')
        HOST=$(echo "$CLEAN_ADDR" | cut -d: -f1)
        PORT=$(echo "$CLEAN_ADDR" | cut -d: -f2)
        echo "=========================================================="
        echo "🚀 TERRARIA SERVER IS ONLINE VIA NGROK!"
        echo "📡 Server IP/Host: $HOST"
        echo "🔌 Server Port:    $PORT"
        echo "🎮 Full Address:   $CLEAN_ADDR"
        echo "=========================================================="
        
        if [ -n "$GITHUB_STEP_SUMMARY" ]; then
            echo "### 🎮 Terraria 1.4.6.1 Server is ONLINE!" >> "$GITHUB_STEP_SUMMARY"
            echo "- **Server IP/Host:** \`$HOST\`" >> "$GITHUB_STEP_SUMMARY"
            echo "- **Port:** \`$PORT\`" >> "$GITHUB_STEP_SUMMARY"
            echo "- **Tunnel Type:** ngrok TCP" >> "$GITHUB_STEP_SUMMARY"
        fi
        exit 0
    fi
fi

# 2. Setup Playit.gg (Default & Permanent Tunnel)
echo "⚡ Downloading Playit.gg agent..."
curl -sSL -o bin/playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x bin/playit

if [ -n "$PLAYIT_SECRET_KEY" ]; then
    echo "🔑 Connecting using registered Playit.gg Secret Key..."
    ./bin/playit --secret "$PLAYIT_SECRET_KEY" run > /tmp/playit.log 2>&1 &
else
    echo "🌐 Starting Playit.gg in Guest / Claim mode..."
    ./bin/playit run > /tmp/playit.log 2>&1 &
fi

sleep 6
echo "📋 Playit.gg status output:"
cat /tmp/playit.log | head -n 30 || true

if [ -n "$GITHUB_STEP_SUMMARY" ]; then
    echo "### 🎮 Terraria 1.4.6.1 Server is ONLINE!" >> "$GITHUB_STEP_SUMMARY"
    echo "Check the Playit.gg log below for your permanent connection link or IP address:" >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
    grep -E "claim|tunnel|address|connect" /tmp/playit.log | head -n 10 >> "$GITHUB_STEP_SUMMARY" || echo "Connecting to Playit network..." >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
fi

echo "Tunnel setup completed."
