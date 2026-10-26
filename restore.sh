#!/system/bin/sh
# FuckACE 恢复操作：尝试撤销遮蔽、停止卸载检查并重新加载 ACE 相关模块 inte。
MODDIR=${0%/*}
LOG="$MODDIR/restore.log"
KO="/vendor_dlkm/lib/modules/inte.ko"
BB=/data/adb/ksu/bin/busybox

echo "[restore] start $(date)" > "$LOG"

# 1) 尝试停止 service.sh 的卸载检查
toybox pkill -f 'fuckace/service.sh' 2>/dev/null \
  || $BB pkill -f 'fuckace/service.sh' 2>/dev/null

# 2) 撤掉遮罩 mount（可能多层，循环撤）
n=0
while grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null && [ "$n" -lt 5 ]; do
  toybox umount "$KO" 2>>"$LOG" || $BB umount "$KO" 2>>"$LOG"
  n=$((n + 1))
done
if grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null; then
  echo "[restore] WARNING: mask still present $(date)" >> "$LOG"
else
  echo "[restore] mask removed $(date)" >> "$LOG"
fi

# 3) 若 inte 未加载且真实文件可读，尝试重新加载 ACE 相关模块 inte
if ! grep -qw inte /proc/modules 2>/dev/null; then
  if [ -s "$KO" ]; then
    if toybox insmod "$KO" 2>>"$LOG" || $BB insmod "$KO" 2>>"$LOG"; then
      echo "[restore] inte reloaded $(date)" >> "$LOG"
    else
      echo "[restore] insmod FAILED $(date)" >> "$LOG"
    fi
  else
    echo "[restore] skip insmod: real file empty/absent $(date)" >> "$LOG"
  fi
else
  echo "[restore] inte already loaded $(date)" >> "$LOG"
fi

# 4) 结果
if grep -qw inte /proc/modules 2>/dev/null; then
  echo "[restore] RESULT: inte is loaded" >> "$LOG"
else
  echo "[restore] RESULT: inte NOT loaded" >> "$LOG"
fi
tail -n 20 "$LOG"
