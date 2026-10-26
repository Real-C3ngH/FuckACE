SKIPUNZIP=0
chmod 0755 "$MODDIR"/*.sh 2>/dev/null

ui_print "- FuckACE v1.0 安装完成"
ui_print "- 手动操作：在 Action 菜单中尝试停止或加载 ACE 相关模块（inte）"
ui_print "- 恢复操作：sh $MODDIR/restore.sh（尝试重新加载 inte）"
ui_print "- 停用模块并重启后，本模块的开机脚本不会运行"
