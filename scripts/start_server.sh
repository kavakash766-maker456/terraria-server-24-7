#!/usr/bin/env bash
set -e

REPO_ROOT="$(pwd)"
SERVER_MODE="${SERVER_MODE:-vanilla-1461}"
VERSION="${TERRARIA_VERSION:-1461}"
WORLD_NAME="${WORLD_NAME:-FilmFeed_Large_World}"
WORLD_SIZE="${WORLD_SIZE:-3}"
DIFFICULTY="${DIFFICULTY:-1}"
WORLD_SEED="${WORLD_SEED:-}"

echo "=========================================================="
echo "🎮 FilmFeed Terraria 24/7 Cloud Server"
echo "   Mode: $SERVER_MODE | World: $WORLD_NAME (Size=$WORLD_SIZE, Diff=$DIFFICULTY)"
echo "=========================================================="

mkdir -p "$REPO_ROOT/bin" "$REPO_ROOT/worlds" "$REPO_ROOT/config" "$REPO_ROOT/mods"

# 1. Generate runtime serverconfig.txt with ABSOLUTE paths so worlds ALWAYS save to repo/worlds/
ACTIVE_CFG="/tmp/active_serverconfig.txt"
cat > "$ACTIVE_CFG" <<EOF
world=${REPO_ROOT}/worlds/${WORLD_NAME}.wld
autocreate=${WORLD_SIZE}
worldname=${WORLD_NAME}
difficulty=${DIFFICULTY}
maxplayers=16
port=7777
password=
motd=🔥 Welcome to FilmFeed 24/7 Terraria Server! Persistent Large World.
worldpath=${REPO_ROOT}/worlds
banlist=${REPO_ROOT}/config/banlist.txt
secure=1
upnp=0
npcstream=60
priority=1
language=en-US
EOF

if [ -n "$WORLD_SEED" ]; then
    echo "seed=${WORLD_SEED}" >> "$ACTIVE_CFG"
    echo "🌱 Custom Seed Active: $WORLD_SEED"
fi

# 2. Download & Prepare Server Binary (Vanilla 1.4.6.1 or tModLoader with Mods)
if [ "$SERVER_MODE" = "tmodloader" ]; then
    echo "🧩 Preparing tModLoader Dedicated Server + Direct GitHub Mods..."
    TML_DIR="$REPO_ROOT/bin/tmodloader"
    mkdir -p "$TML_DIR" "$REPO_ROOT/mods"

    if [ ! -f "$TML_DIR/tModLoader.dll" ]; then
        TML_URL=$(curl -sSL https://api.github.com/repos/tModLoader/tModLoader/releases/latest | jq -r '.assets[] | select(.name=="tModLoader.zip") | .browser_download_url')
        echo "⬇️ Downloading tModLoader from: $TML_URL"
        curl -sSL -o /tmp/tModLoader.zip "$TML_URL"
        unzip -q -o /tmp/tModLoader.zip -d "$TML_DIR"
        rm -f /tmp/tModLoader.zip
    fi

    # Download verified direct .tmod releases (MagicStorage, BossChecklist, RecipeBrowser) if mods folder empty
    if ! ls "$REPO_ROOT/mods"/*.tmod >/dev/null 2>&1; then
        echo "⬇️ Downloading curated QoL Modpack (.tmod)..."
        for MOD_REPO in "blushiemagic/MagicStorage" "JavidPack/BossChecklist" "JavidPack/RecipeBrowser"; do
            MOD_URL=$(curl -sSL "https://api.github.com/repos/${MOD_REPO}/releases/latest" | jq -r '.assets[] | select(.name | endswith(".tmod")) | .browser_download_url' | head -n 1)
            if [ -n "$MOD_URL" ] && [ "$MOD_URL" != "null" ]; then
                MOD_FILE=$(basename "$MOD_URL")
                echo "   + $MOD_FILE"
                curl -sSL -o "$REPO_ROOT/mods/$MOD_FILE" "$MOD_URL"
            fi
        done
    fi

    # Build enabled.json
    echo "[" > "$REPO_ROOT/mods/enabled.json"
    FIRST=1
    for f in "$REPO_ROOT/mods"/*.tmod; do
        [ -e "$f" ] || continue
        MNAME=$(basename "$f" .tmod)
        if [ $FIRST -eq 0 ]; then echo "," >> "$REPO_ROOT/mods/enabled.json"; fi
        printf '  "%s"' "$MNAME" >> "$REPO_ROOT/mods/enabled.json"
        FIRST=0
    done
    echo "" >> "$REPO_ROOT/mods/enabled.json"
    echo "]" >> "$REPO_ROOT/mods/enabled.json"

    mkdir -p "$HOME/.local/share/Terraria/tModLoader/Mods"
    cp -f "$REPO_ROOT/mods"/*.tmod "$HOME/.local/share/Terraria/tModLoader/Mods/" 2>/dev/null || true
    cp -f "$REPO_ROOT/mods/enabled.json" "$HOME/.local/share/Terraria/tModLoader/Mods/"
    SERVER_CMD="dotnet $TML_DIR/tModLoader.dll -server -config $ACTIVE_CFG -tmlsavedirectory $REPO_ROOT/worlds"
    SERVER_WORKDIR="$TML_DIR"
else
    ZIP_NAME="terraria-server-${VERSION}.zip"
    DOWNLOAD_URL="https://terraria.org/api/download/pc-dedicated-server/${ZIP_NAME}"
    if [ ! -f "$REPO_ROOT/bin/TerrariaServer.bin.x86_64" ]; then
        echo "⬇️ Downloading Terraria Server v${VERSION} in cloud..."
        curl -sSL -H "User-Agent: Mozilla/5.0" -o "/tmp/${ZIP_NAME}" "$DOWNLOAD_URL"
        unzip -q -o "/tmp/${ZIP_NAME}" -d /tmp/terraria_extracted
        LINUX_DIR=$(find /tmp/terraria_extracted -type d -name "Linux" | head -n 1)
        if [ -z "$LINUX_DIR" ]; then
            echo "❌ Error: Could not locate Linux server files."
            exit 1
        fi
        cp -r "$LINUX_DIR"/* "$REPO_ROOT/bin/"
        chmod +x "$REPO_ROOT/bin/TerrariaServer.bin.x86_64"
        rm -rf /tmp/terraria_extracted "/tmp/${ZIP_NAME}"
        echo "✅ Terraria 1.4.6.1 binary ready!"
    fi
    SERVER_CMD="$REPO_ROOT/bin/TerrariaServer.bin.x86_64 -config $ACTIVE_CFG"
    SERVER_WORKDIR="$REPO_ROOT/bin"
fi

# 3. Setup FIFO Pipe for interactive console control
FIFO_PIPE="/tmp/terraria_fifo"
rm -f "$FIFO_PIPE"
mkfifo "$FIFO_PIPE"

# 4. Launch Terraria Server FIRST with clean milestone-filtered logging (fixes 97.6% log choke!)
echo "🚀 Starting Terraria Server & generating/loading Large World..."
(
    cd "$SERVER_WORKDIR"
    stdbuf -oL $SERVER_CMD < "$FIFO_PIPE" 2>&1
) | stdbuf -oL tee /tmp/terraria_raw.log | awk '
    BEGIN { last_pct = -10 }
    /[0-9]+\.[0-9]+%/ {
        match($0, /[0-9]+\.[0-9]+%/)
        pct = int(substr($0, RSTART, RLENGTH - 1))
        if (pct >= last_pct + 10 || pct == 100) {
            last_pct = pct
            print "⏳ World Generation Progress: " pct "%"
            fflush()
        }
        next
    }
    {
        print $0
        fflush()
    }
' &
LOG_PID=$!

# Keep FIFO pipe open
exec 3> "$FIFO_PIPE"

# 5. Wait until Terraria Server is actually listening on port 7777 (max 4 minutes for Large Worldgen)
echo "⏳ Waiting for Large World generation & port 7777 readiness..."
READY=0
for i in $(seq 1 120); do
    if nc -z 127.0.0.1 7777 2>/dev/null || grep -qE "Listening on port 7777|Server started" /tmp/terraria_raw.log 2>/dev/null; then
        READY=1
        echo "✅ World ready! Terraria Server is listening on port 7777!"
        break
    fi
    sleep 2
done

if [ $READY -eq 0 ]; then
    echo "⚠️ Port 7777 check timed out; dumping last 30 lines of raw log:"
    tail -n 30 /tmp/terraria_raw.log || true
fi

# 6. Now start the FREE TCP Tunnel cleanly after worldgen spam is over!
chmod +x "$REPO_ROOT/scripts/tunnel.sh"
"$REPO_ROOT/scripts/tunnel.sh"

# 7. Publish Live Connection Info to GitHub Summary & SERVER_STATUS.md
if [ -f /tmp/server_endpoint.txt ]; then
    IFS='|' read -r HOST PORT LABEL TPID < /tmp/server_endpoint.txt
    if [ -n "$GITHUB_STEP_SUMMARY" ]; then
        {
            echo "## 🎮 Terraria Server is ONLINE!"
            echo "| Setting | Value |"
            echo "| :--- | :--- |"
            echo "| **Server IP / Host** | \`$HOST\` |"
            echo "| **Port** | \`$PORT\` |"
            echo "| **Mode** | \`$SERVER_MODE\` |"
            echo "| **World** | \`$WORLD_NAME\` (Size: \`$WORLD_SIZE\`, Difficulty: \`$DIFFICULTY\`) |"
            echo "| **Tunnel** | $LABEL |"
        } >> "$GITHUB_STEP_SUMMARY"
    fi

    cat > "$REPO_ROOT/SERVER_STATUS.md" <<EOF
# 🎮 Terraria 24/7 Server - LIVE STATUS

> **Status:** 🟢 **ONLINE** (Updated: $(date -u +'%Y-%m-%d %H:%M:%S UTC'))

| Connect Info | Value |
| :--- | :--- |
| **Server IP / Host** | \`$HOST\` |
| **Port** | \`$PORT\` |
| **Mode** | \`$SERVER_MODE\` |
| **World** | \`$WORLD_NAME\` (Large World) |
| **Tunnel** | $LABEL |

### How to Join:
1. Open Terraria -> **Multiplayer** -> **Join via IP**
2. Enter IP: \`$HOST\`
3. Enter Port: \`$PORT\`
EOF

    git config --global user.name "Terraria-Cloud-Bot"
    git config --global user.email "bot@terraria-server.cloud"
    git add "$REPO_ROOT/SERVER_STATUS.md"
    if git status --porcelain "$REPO_ROOT/SERVER_STATUS.md" | grep -q "SERVER_STATUS.md"; then
        git commit -m "chore(status): update live server IP $HOST:$PORT"
        git push origin main || (git pull --rebase origin main && git push origin main) || true
    fi
fi

# 8. Watchdog & Auto-Save Loop (Runs 5.5 hours, then saves world cleanly and loops!)
START_TIME=$(date +%s)
MAX_RUN_SECONDS=19800 # 5 hours 30 minutes
SAVE_INTERVAL=600     # Auto-save every 10 minutes
LAST_SAVE=$START_TIME

echo "⏱️ Server running! Watchdog active for 5h 30m cycle."

while ps -p $LOG_PID >/dev/null 2>&1; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    if [ $((CURRENT_TIME - LAST_SAVE)) -ge $SAVE_INTERVAL ]; then
        echo "💾 [$(date -u +'%H:%M:%S')] Periodic world auto-save..."
        echo "save" >&3 || true
        LAST_SAVE=$CURRENT_TIME
    fi

    if [ $ELAPSED -ge $MAX_RUN_SECONDS ]; then
        echo "⏰ [Watchdog] 5.5 hour limit reached. Saving world and cycling 24/7 loop..."
        echo "say [SERVER] Auto-save & 24/7 restart cycle in 15 seconds..." >&3 || true
        sleep 5
        echo "save" >&3 || true
        sleep 10
        echo "exit" >&3 || true
        break
    fi

    sleep 15
done

wait $LOG_PID 2>/dev/null || true
exec 3>&- || true
rm -f "$FIFO_PIPE"
echo "✅ Server stopped cleanly. World files in worlds/:"
ls -lh "$REPO_ROOT/worlds/" || true
