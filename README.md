## 甲骨文 ARM 一键开启 BBRv3！
嘿，大家好！我是 Joey！最近，我想在 Oracle ARM 上搞点事情，结果发现，居然没有现成的 BBRv3 编译版？！作为一个不甘心的小技术宅，我决定自己动手编译，然后分享给大家。于是，这个全网首发的脚本就诞生了！🎉


### 为什么要用这个脚本？

你是不是也跟我一样，折腾 Oracle ARM 时发现没有现成的 BBRv3？不用怕，现在只要轻轻松松两步操作，立刻让你的 ARM 设备飞起来！BBRv3 可以极大地优化你的网络连接，让你在甲骨文的云上跑得更快、更稳。

### 开启加速，只需1行代码

别废话了，直接看代码！打开终端，敲下这行命令：

```bash
bash <(curl -L -s jhb.ovh/jb/bbrv3arm.sh)
```

### 脚本做了啥？

这个脚本其实非常简单粗暴，但效果却很牛：

1. **下载内核文件**：从我的服务器上下载定制编译的 Linux 内核，你不需要自己编译，我已经帮你搞定了。
2. **自动安装**：使用 `dpkg` 安装内核，完全不用动脑子，全自动！
3. **更新 GRUB**：让新内核在下次启动时生效，配置好就可以重启啦。
4. **开启 BBRv3**：通过配置 BBRv3 拥塞控制算法，让你的网络更快更稳定。
5. **验证配置**：最后检查一下配置是否生效，看一下 BBRv3 是不是已经在跑了。

### 适用范围

- **架构**：专为 Oracle ARM 架构优化，只支持 ARM64 架构，x86 用户请绕道~
- **操作系统**：Debian 12，已经经过全面测试，一切顺畅。

### 为什么是全自动的？

因为我也是懒人！做脚本就是为了省事，所以你只需要复制粘贴，剩下的交给脚本，自己去喝杯咖啡等着就行啦！
### 重启完成如何验证？

```
sudo modinfo tcp_bbr 
```
看到![bf574f6b5c0da12d65ea2.png](https://api.jhb.ovh/file/bf574f6b5c0da12d65ea2.png)
就证明bbr3v已经加载了


### 结语

希望这个脚本能帮到大家！如果在使用过程中有任何问题，或者想跟我聊聊技术的东西，欢迎加入我们的 Telegram 群组：https://t.me/+ft-zI76oovgwNmRh 。大家一起折腾，才能玩得更爽！

