# 更新日志

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/) 记录发行版本。

## [1.2.2] - 2026-11-09

### 变更

- 将“关于”窗口中的 GitHub 账号、项目地址和跳转链接更新为 [luyfapp](https://github.com/luyfapp)。
- 将本地 Git 仓库远程地址更新为 `https://github.com/luyfapp/EFI-Mounter.git`。
- 更新许可证中的版权所有者署名为 `luyfapp`。
- 清理发布构建中不应随应用分发的源码备份资源。

### 构建与分发

- 重新构建 macOS Universal 应用，包含 Apple Silicon（arm64）和 Intel（x86_64）架构。
- 版本号保持为 `1.2.2`，构建号保持为 `4`。

## [1.2.1] - 2026-10-06

### 修复

- 修复并发布 v1.2.1 版本。

## [1.2.0] - 2026-10-06

### 变更

- 稳定自动刷新逻辑并清理挂载测试日志。
