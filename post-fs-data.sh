#!/system/bin/sh
# FuckACE 开机早期处理：尝试遮蔽 ACE 相关模块文件 inte.ko。
MODDIR=${0%/*}
LOG="$MODDIR/log.txt"
KO="/vendor_dlkm/lib/modules/inte.ko"

if ! grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null; then
  if toybox mount -o bind /dev/null "$KO" 2>>"$LOG" \
     || /data/adb/ksu/bin/busybox mount -o bind /dev/null "$KO" 2>>"$LOG"; then
    echo "[post-fs-data] inte.ko path masked early $(date)" >> "$LOG"
  fi
fi
