# FuckACE

作者：C3ngH　文档协助：OpenAI Codex　版本：1.0

FuckACE 是一个用于 OPPO / 一加 ColorOS 17 的 KernelSU 模块。它在开机时尝试遮蔽 `/vendor_dlkm/lib/modules/inte.ko`，并尝试卸载已加载的内核模块 `inte`。

社区根据公开内核源码和设备分析，将 `inte.ko` 关联到腾讯 ACE 的内核完整性检测链路。

## 使用

- 启用模块后，开机脚本会自动运行。
- KernelSU 的 Action 菜单：音量上尝试卸载 `inte`；音量下尝试恢复。
- 手动恢复：`sh /data/adb/modules/fuckace/restore.sh`

模块使用运行时挂载，不修改固件分区。恢复操作会尝试撤销挂载并重新加载 `inte`；请查看模块目录下的 `log.txt`、`restore.log` 和 `/proc/modules` 确认结果。

## 验证记录

OPPO PMA110、ColorOS 17（`V17.0.0`）、内核 `6.12.69-android16`：遮蔽后读取 `inte.ko` 路径得到 0 字节，对该路径执行 `insmod` 返回 `Invalid argument`。结果仅对应此设备和固件版本。

## 参考资料

1. [OnePlusOSS 内核源码：`oplus_kernel_security_check.c`](https://github.com/OnePlusOSS/android_kernel_modules_and_devicetree_oneplus_mt6993/blob/oneplus/mt6993_b_16.0_ace_6_ultra/vendor/oplus/kernel/secureguard/gki2.0/rootguard_new/oplus_kernel_security_check.c) —— 文件注释说明其为《和平精英》内核完整性检测需求。
2. [NkBe：一加内核开源，发现新增“和平精英”专项检测](https://www.nkbe.top/posts/oplus-kernel-security-check/) —— 对公开源码中的检测机制作了分析。
3. [社区讨论：ColorOS 17 与腾讯 ACE 及 `inte.ko`](https://post.smzdm.com/p/ae6qgrzk/) —— 汇总了社区自查和源码讨论；文章也指出厂商尚未正式确认关联。

仅供学习交流使用。
