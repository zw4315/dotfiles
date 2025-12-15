# 用法
# ./run_gost.sh start
# ./run_gost.sh stop
# ./run_gost.sh status
# ./run_gost.sh logs


set -uo pipefail

PORT=8888
GOST_BIN="$HOME/app/gost"        # 改成你的实际路径
PID_FILE="/tmp/gost_proxy.pid"
LOG_FILE="$HOME/app/gost_proxy.log"

start() {
  # 已经在跑就不要重复启动
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[*] gost already running, pid=$(cat "$PID_FILE")"
    exit 0
  fi

  echo "[*] starting gost in background..."

  (
    trap 'exit 0' INT TERM
    while true; do
      echo "$(date '+%F %T') [gost] starting..." >>"$LOG_FILE" 2>&1
      "$GOST_BIN" -L "http://:${PORT}" >>"$LOG_FILE" 2>&1
      EC=$?
      echo "$(date '+%F %T') [gost] exited with code $EC, restart in 2s..." >>"$LOG_FILE" 2>&1
      sleep 2
    done
  ) &

  echo $! >"$PID_FILE"
  echo "[*] gost started, wrapper pid=$(cat "$PID_FILE")"
}

stop() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill "$PID" 2>/dev/null; then
      echo "[*] sent TERM to gost wrapper pid=$PID"
    else
      echo "[!] pid $PID not running"
    fi
    rm -f "$PID_FILE"
  else
    echo "[!] no pid file, gost probably not running"
  fi
}

status() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[*] gost running, pid=$(cat "$PID_FILE")"
  else
    echo "[*] gost not running"
  fi
}

logs() {
  tail -n 50 "$LOG_FILE"
}

case "${1:-}" in
  start)   start ;;
  stop)    stop ;;
  restart) stop; start ;;
  status)  status ;;
  logs)    logs ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs}"
    exit 1
    ;;
esac

