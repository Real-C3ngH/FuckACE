#!/system/bin/sh
# FuckACE - KernelSU 管理器 Action 菜单
# 音量上：遮蔽 inte.ko 并尝试卸载 ACE 相关模块 inte；音量下：撤销遮蔽并尝试加载 inte
MODDIR=${0%/*}
KO="/vendor_dlkm/lib/modules/inte.ko"
BB=/data/adb/ksu/bin/busybox

ui_print() { echo "$1"; }

have_timeout() {
  command -v timeout >/dev/null 2>&1 && return 0
  [ -x /system/bin/timeout ] && return 0
  return 1
}

# wait_key <秒数>  返回 0=音量上 2=音量下 1=超时
# 读取方案: /system/bin/getevent 原始事件流
#   KEY event 行格式 "... 0001 0073 00000001" (type code value)
#   0073=KEY_VOLUMEUP  0072=KEY_VOLUMEDOWN
wait_key() {
  local deadline now ev
  deadline=$(( $(date +%s) + $1 ))
  while :; do
    now=$(date +%s)
    [ "$now" -lt "$deadline" ] || return 1
    if command -v timeout >/dev/null 2>&1; then
      ev=$(timeout 1 /system/bin/getevent 2>/dev/null)
    else
      ev=$($BB timeout 1 /system/bin/getevent 2>/dev/null)
    fi
    [ -n "$ev" ] || continue
    case "$ev" in
      *"0001 0073 "*) return 0 ;;   # VOLUMEUP pressed
      *"0001 0072 "*) return 2 ;;   # VOLUMEDOWN pressed
    esac
  done
}

do_disable_ace() {
  ui_print "==> 尝试停止 ACE 相关内核模块（inte）"
  if ! grep -q 'modules/inte.ko' /proc/mounts 2>/dev/null; then
    if toybox mount -o bind /dev/null "$KO" 2>/dev/null \
       || $BB mount -o bind /dev/null "$KO" 2>/dev/null; then
      ui_print "  [OK] 已对 inte.ko 路径应用 /dev/null 遮蔽"
    else
      ui_print "  [!!] inte.ko 路径遮蔽失败"
    fi
  else
    ui_print "  [--] inte.ko 路径已处于遮蔽状态，跳过"
  fi
  if grep -qw inte /proc/modules 2>/dev/null; then
    toybox rmmod inte 2>/dev/null || $BB rmmod inte 2>/dev/null
    if grep -qw inte /proc/modules 2>/dev/null; then
      ui_print "  [!!] inte 卸载失败，请查看 log.txt"
    else
      ui_print "  [OK] ACE 相关模块 inte 已从内核卸载"
    fi
  else
    ui_print "  [--] inte 当前未加载，跳过"
  fi
  if grep -qw inte /proc/modules 2>/dev/null; then
    ui_print "==> 结果: [!!] ACE 相关模块 inte 仍在内核中"
  else
    ui_print "==> 结果: ACE 相关模块 inte 当前未加载"
  fi
}

do_restore() {
  sh "$MODDIR/restore.sh"
}

ui_print " "
ui_print "========================================"
ui_print "   FuckACE 操作菜单"
ui_print "----------------------------------------"
ui_print "   音量上 (+) : 尝试停止 ACE 相关内核模块（inte）"
ui_print "   音量下 (-) : 尝试加载 ACE 相关内核模块（inte）"
ui_print "   Volume Up  : Try to stop ACE-related module (inte)"
ui_print "   Volume Down: Try to load ACE-related module (inte)"
ui_print "   不按  (5s) : 退出 / Exit"
ui_print "========================================"
ui_print " "

wait_key 5
rc=$?
case "$rc" in
  0)
    ui_print ">>> 尝试停止 ACE 相关内核模块（inte）"
    do_disable_ace
    ;;
  2)
    ui_print ">>> 尝试加载 ACE 相关内核模块（inte）"
    do_restore
    ;;
  *)
    ui_print ">>> 5 秒内未检测到按键，退出 / No key detected; exiting"
    ;;
esac
