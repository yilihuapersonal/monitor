# Vibe Coding Monitor

[English](#english) · [中文](#中文)

A macOS menu bar app that shows Cursor Agent status with a live indicator light — so you know when the agent is thinking, coding, waiting, done, or stuck.

© 2026 WH YLH Software Development Co., Ltd  
All rights reserved.

---

## English

### Features

- **Menu bar + floating window** — always-on-top, draggable, works across Spaces
- **Six status lights** — thinking, coding, executing, waiting for you, done, error
- **Instant state changes** — lights snap on immediately when status changes (no fade-in)
- **Sound cues** — startup chime when Hooks connect; 3 beeps on done; 2 beeps on other transitions
- **Compact floating mode** — minimal round light-only panel (double-click to return to standard window)
- **Cursor Hooks integration** — no polling; driven by real Agent events

### Status reference

| Status | Light | When |
|--------|-------|------|
| Thinking | Blue (breathing) | Agent reasoning; reading/searching tools (`Read`, `Grep`, etc.) |
| Coding | Blue (blinking) | Writing/editing/deleting files, `Shell`, `Task` |
| Executing | Purple (blinking) | Shell command running (`beforeShellExecution`) |
| Done | Green (solid) | Agent finished this turn |
| Error | Red (blinking) | Tool failure or non-zero exit code |
| Waiting for you | Yellow (blinking) | Multiple choice, mode switch, MCP approval |

### Requirements

**End users (installed from DMG)**

- macOS 14+ (Apple Silicon native)
- [Cursor](https://cursor.com) with Hooks support
- **Xcode is not required**

**Developers (build from source)**

- macOS 14+
- Xcode 15+
- Cursor with Hooks support

### Install (recommended — no Xcode)

1. Download or build `VibeCodingMonitor-1.0.dmg` from [Releases](../../releases) (or run `./scripts/package.sh` locally).
2. Open the DMG and drag **VibeCodingMonitor** into **Applications**.
3. If macOS blocks the app: **System Settings → Privacy & Security → Open Anyway**.
4. Install Cursor Hooks (required once):

   **From the DMG folder:**

   ```bash
   chmod +x vibe-status.sh
   mkdir -p ~/.cursor/hooks
   cp vibe-status.sh ~/.cursor/hooks/
   cp cursor-hooks.json ~/.cursor/hooks.json
   ```

   **Or from a cloned repo:**

   ```bash
   chmod +x scripts/install-hooks.sh
   ./scripts/install-hooks.sh
   ```

   If you already have `~/.cursor/hooks.json`, merge entries from `cursor-hooks/hooks.json` instead of overwriting.

5. **Restart Cursor**. Confirm hooks under **Cursor Settings → Hooks**.
6. Launch **Vibe Coding Monitor** from Applications or the menu bar.

### Verify

- Start a Cursor Agent chat → light turns blue (breathing while thinking, blinking while coding)
- When the agent finishes → green + 3 system beeps
- When Hooks reconnect → startup MP3 plays once
- Main window shows **Connected to Cursor Hooks** (green dot)

### Architecture

```
Cursor Agent events
    ↓  Cursor Hooks (vibe-status.sh)
~/Library/Application Support/VibeCodingMonitor/status.json
    ↓  FSEvents file watch
VibeCodingMonitor.app  →  status light UI + sounds
```

### Sound

| Event | Sound |
|-------|-------|
| Hooks connected (not app launch) | Custom startup MP3 (`startup.mp3`, once per reconnect) |
| Status → Done | System alert beep ×3 |
| Other status changes | System alert beep ×2 |

Ensure **System Settings → Sound → Sound Effects** is enabled if you hear nothing.

### Notes

- Hooks are **observe-only** — they never block or modify Cursor behavior.
- Yellow = actions that need **you** (`AskQuestion`, `SwitchMode`, `beforeMCPExecution`).
- Purple = shell command in progress (`beforeShellExecution`).
- Blue breathing vs blinking is decided in `cursor-hooks/vibe-status.sh` (`preToolUse` tool name).
- If no hook signal for 2 minutes, the connection indicator turns orange.

### Project structure

```
VibeCodingMonitor/           SwiftUI app source
  Resources/startup.mp3      Startup sound (Hooks connected)
cursor-hooks/                Hook config + vibe-status.sh
scripts/
  install-hooks.sh           Install hooks to ~/.cursor/
  package.sh                 Build Release + create DMG
build/                       Release output (gitignored)
```

### Build from source (developers only)

```bash
open VibeCodingMonitor.xcodeproj
```

In Xcode: select **My Mac**, configure Signing, press **⌘R**.

### Package a DMG

```bash
./scripts/package.sh
```

Output: `build/VibeCodingMonitor-1.0.dmg`

The DMG includes the app, hook files, and install instructions. Recipients do **not** need Xcode.

### Customize

| What | File |
|------|------|
| Colors / animations | `VibeCodingMonitor/Views/StatusLightView.swift` |
| Status mapping | `cursor-hooks/vibe-status.sh` |
| Status file path | `~/Library/Application Support/VibeCodingMonitor/status.json` |
| Startup sound | `VibeCodingMonitor/Resources/startup.mp3` |

---

## 中文

### 功能

- **菜单栏 + 悬浮窗** — 始终置顶、可拖动、全桌面空间可见
- **六种状态灯** — 思考、写代码、执行中、等你操作、完成、报错
- **状态即时切换** — 切换状态时灯光立即亮起，无淡入
- **音效提示** — 连上 Hooks 播放启动音；完成时三声提示音；其他状态变化双蜂鸣
- **悬浮窗模式** — 仅显示圆形状态灯（双击回到标准窗口）
- **Cursor Hooks 驱动** — 基于 Agent 真实事件，非轮询

### 状态说明

| 状态 | 灯光 | 触发场景 |
|------|------|----------|
| 思考中 | 蓝色呼吸 | Agent 推理；读文件/搜索类工具（`Read`、`Grep` 等） |
| 写代码 | 蓝色闪烁 | 写/改/删文件、`Shell`、`Task` |
| 执行中 | 紫色闪烁 | Shell 命令运行中（`beforeShellExecution`） |
| 完成 | 绿色常亮 | Agent 本轮回复结束 |
| 报错 | 红色闪烁 | 工具失败或命令非零退出 |
| 等你操作 | 黄色闪烁 | 选择题、切换模式、MCP 许可 |

### 环境要求

**普通用户（DMG 安装）**

- macOS 14+（Apple Silicon 原生）
- 支持 Hooks 的 [Cursor](https://cursor.com)
- **不需要 Xcode**

**开发者（从源码编译）**

- macOS 14+
- Xcode 15+
- 支持 Hooks 的 Cursor

### 安装（推荐 — 无需 Xcode）

1. 从 [Releases](../../releases) 下载 `VibeCodingMonitor-1.0.dmg`（或本地执行 `./scripts/package.sh` 生成）。
2. 打开 DMG，将 **VibeCodingMonitor** 拖入「应用程序」。
3. 若系统拦截：**系统设置 → 隐私与安全性 → 仍要打开**。
4. 安装 Cursor Hooks（首次必须）：

   **从 DMG 目录：**

   ```bash
   chmod +x vibe-status.sh
   mkdir -p ~/.cursor/hooks
   cp vibe-status.sh ~/.cursor/hooks/
   cp cursor-hooks.json ~/.cursor/hooks.json
   ```

   **或从仓库根目录：**

   ```bash
   chmod +x scripts/install-hooks.sh
   ./scripts/install-hooks.sh
   ```

   若已有 `~/.cursor/hooks.json`，请手动合并 `cursor-hooks/hooks.json` 中的条目，勿直接覆盖。

5. **重启 Cursor**，在 **Cursor 设置 → Hooks** 中确认已加载。
6. 从「应用程序」或菜单栏启动 **Vibe Coding Monitor**。

### 验证

- 在 Cursor 发起 Agent 对话 → 灯变蓝（思考时呼吸，写代码时闪烁）
- 对话结束 → 变绿并播放三声系统提示音
- Hooks 重新连上 → 播放启动 MP3 一次
- 主窗口显示 **已连接 Cursor Hooks**（绿点）

### 架构

```
Cursor Agent 事件
    ↓  Cursor Hooks (vibe-status.sh)
~/Library/Application Support/VibeCodingMonitor/status.json
    ↓  FSEvents 文件监听
VibeCodingMonitor.app  →  状态灯 UI + 音效
```

### 音效

| 事件 | 音效 |
|------|------|
| 连上 Cursor Hooks（非打开 App） | 内置启动 MP3（每次重新连接播放一次） |
| 状态变为完成 | 系统提示音 ×3 |
| 其他状态变化 | 系统提示音 ×2 |

若听不到声音，请检查 **系统设置 → 声音 → 声音效果** 是否开启。

### 说明

- Hooks **只观察、不干预** Cursor 行为。
- 黄灯 = 需要**你**操作（`AskQuestion`、`SwitchMode`、`beforeMCPExecution`）。
- 紫灯 = Shell 命令执行中（`beforeShellExecution`）。
- 蓝色呼吸/闪烁由 `cursor-hooks/vibe-status.sh` 中 `preToolUse` 的工具名决定。
- 超过 2 分钟无 Hooks 信号，连接指示变为橙色。

### 项目结构

```
VibeCodingMonitor/           SwiftUI 源码
  Resources/startup.mp3      启动音效（连上 Hooks 时）
cursor-hooks/                Hooks 配置与脚本
scripts/
  install-hooks.sh           安装 Hooks 到 ~/.cursor/
  package.sh                 编译 Release 并生成 DMG
build/                       构建产物（已 gitignore）
```

### 从源码编译（仅开发者）

```bash
open VibeCodingMonitor.xcodeproj
```

在 Xcode 中选择 **My Mac**，配置 Signing，按 **⌘R** 运行。

### 打包安装镜像

```bash
./scripts/package.sh
```

产物：`build/VibeCodingMonitor-1.0.dmg`

DMG 内含 App、Hooks 文件和安装说明。**使用者不需要 Xcode。**

### 自定义

| 修改内容 | 文件 |
|----------|------|
| 灯光颜色 / 动画 | `VibeCodingMonitor/Views/StatusLightView.swift` |
| 状态映射逻辑 | `cursor-hooks/vibe-status.sh` |
| 状态文件路径 | `~/Library/Application Support/VibeCodingMonitor/status.json` |
| 启动音效 | `VibeCodingMonitor/Resources/startup.mp3` |

---

## Copyright

© 2026 WH YLH Software Development Co., Ltd  
All rights reserved.
