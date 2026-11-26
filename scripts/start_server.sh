#!/usr/bin/env bash
set -e

VERSION="${TERRARIA_VERSION:-1461}"
echo "=========================================================="
echo "🎮 Starting Terraria Dedicated Server Engine (v$VERSION)"
echo "=========================================================="

mkdir -p bin worlds config

# 1. Download Terraria Dedicated Server directly in GitHub Runner
ZIP_NAME="terraria-server-${VERSION}.zip"
DOWNLOAD_URL="https://terraria.org/api/download/pc-dedicated-server/${ZIP_NAME}"

if [ ! -f "bin/TerrariaServer.bin.x86_64" ]; then
    echo "⬇️ Downloading Terraria Server v${VERSION} directly in the cloud..."
    curl -sSL -H "User-Agent: Mozilla/5.0" -o "/tmp/${ZIP_NAME}" "$DOWNLOAD_URL"
    
    echo "📦 Extracting Linux binaries..."
    unzip -q -o "/tmp/${ZIP_NAME}" -d /tmp/terraria_extracted
    
    # Locate Linux directory inside extracted archive
    LINUX_DIR=$(find /tmp/terraria_extracted -type d -name "Linux" | head -n 1)
    if [ -z "$LINUX_DIR" ]; then
        echo "❌ Error: Could not locate Linux server files in download archive."
        exit 1
    fi
    
    cp -r "$LINUX_DIR"/* bin/
    chmod +x bin/TerrariaServer.bin.x86_64
    rm -rf /tmp/terraria_extracted "/tmp/${ZIP_NAME}"
    echo "✅ Terraria server binary ready in bin/TerrariaServer.bin.x86_64"
fi

# 2. Setup FIFO Pipe for interactive console and graceful exit
FIFO_PIPE="/tmp/terraria_fifo"
rm -f "$FIFO_PIPE"
mkfifo "$FIFO_PIPE"

# 3. Launch Port Forwarding Tunnel
chmod +x scripts/tunnel.sh
./scripts/tunnel.sh &

# 4. Launch Terraria Server with FIFO input
echo "🚀 Launching Terraria Server with config/serverconfig.txt..."
cd bin
./TerrariaServer.bin.x86_64 -config ../config/serverconfig.txt < "$FIFO_PIPE" 2>&1 | tee /tmp/terraria_server.log &
SERVER_PID=$!
cd ..

# Keep the FIFO pipe open
exec 3> "$FIFO_PIPE"

# 5. Monitor and Auto-Save Loop (Runs for 5 hours 30 mins, then triggers seamless loop restart)
START_TIME=$(date +%s)
MAX_RUN_SECONDS=19800 # 5.5 hours = 19,800 seconds (Leaves 30m safety buffer before 6h limit)
SAVE_INTERVAL=600     # Auto-save every 10 minutes

echo "⏱️ Server watchdog active. Will run continuously for 5h 30m before auto-restarting."

LAST_SAVE=$START_TIME
while kill -0 "$SERVER_PID" 2>/dev/null; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    # Periodic World Auto-Save
    if [ $((CURRENT_TIME - LAST_SAVE)) -ge $SAVE_INTERVAL ]; then
        echo "💾 [Watchdog] Triggering world auto-save..."
        echo "save" >&3
        LAST_SAVE=$CURRENT_TIME
    fi
    
    # Check if 5h 30m cycle is reached
    if [ $ELAPSED -ge $MAX_RUN_SECONDS ]; then
        echo "⏰ [Watchdog] 5.5 hour cycle reached. Preparing safe restart for 24/7 continuous operation..."
        echo "say [SERVER] 24/7 Auto-Restart Cycle: Saving world and reloading in 30 seconds..." >&3
        sleep 5
        echo "save" >&3
        sleep 15
        echo "exit" >&3
        break
    fi
    
    sleep 15
done

# Wait for server to shutdown cleanly
wait "$SERVER_PID" 2>/dev/null || true
exec 3>&-
rm -f "$FIFO_PIPE"

echo "✅ Server shut down cleanly. World state preserved in worlds/ directory."
