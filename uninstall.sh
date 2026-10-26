#!/system/bin/sh
# 移除 FuckACE 时尝试撤销遮蔽并重新加载 ACE 相关模块 inte。
KO="/vendor_dlkm/lib/modules/inte.ko"
BB=/data/adb/ksu/bin/busybox
n=0
while grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null && [ "$n" -lt 5 ]; do
  toybox umount "$KO" 2>/dev/null || $BB umount "$KO" 2>/dev/null
  n=$((n + 1))
done
if ! grep -qw inte /proc/modules 2>/dev/null && [ -s "$KO" ]; then
  toybox insmod "$KO" 2>/dev/null || $BB insmod "$KO" 2>/dev/null
fi
