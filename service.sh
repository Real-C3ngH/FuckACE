#!/system/bin/sh
# FuckACE 启动服务：遮蔽 inte.ko，并尝试卸载 ACE 相关模块 inte。
MODDIR=${0%/*}
LOG="$MODDIR/log.txt"
KO="/vendor_dlkm/lib/modules/inte.ko"

echo "[service] start $(date)" > "$LOG"

do_block() {
  if ! grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null; then
    if toybox mount -o bind /dev/null "$KO" 2>>"$LOG" \
       || /data/adb/ksu/bin/busybox mount -o bind /dev/null "$KO" 2>>"$LOG"; then
      echo "[service] inte.ko path masked with /dev/null $(date)" >> "$LOG"
    else
      echo "[service] bind mount FAILED $(date)" >> "$LOG"
    fi
  fi
}

do_unload() {
  if grep -qw inte /proc/modules 2>/dev/null; then
    if toybox rmmod inte 2>>"$LOG" || /data/adb/ksu/bin/busybox rmmod inte 2>>"$LOG"; then
      echo "[service] ACE-related module inte unloaded $(date)" >> "$LOG"
    else
      echo "[service] failed to unload ACE-related module inte $(date)" >> "$LOG"
    fi
  fi
}

do_block
do_unload

i=0
while [ "$i" -lt 60 ]; do
  sleep 10
  do_unload
  i=$((i + 1))
done
echo "[service] monitor window done $(date)" >> "$LOG"
