# Handoff — Vibe Coding Monitor

> 更新时间：2026-06-28  
> 仓库：https://github.com/yilihuapersonal/monitor

---

## 已完成 ✅

| 事项 | 状态 |
|------|------|
| README 双语（中/英）、GitHub 规范 | ✅ |
| `.gitignore`（排除 `build/`、Xcode 缓存等） | ✅ |
| 源码同步到 `/Users/wh1215/monitor` | ✅ |
| `git init` + 首次 commit | ✅ |
| 远程地址修正（`yilihuapersoanl` → `yilihuapersonal`） | ✅ |
| 合并 GitHub 初始 LICENSE 提交 + push 成功 | ✅ |
| 本地 Cursor Hooks 已安装（`~/.cursor/hooks/vibe-status.sh`） | ✅ |

---

## 未完成 / 待办 🔲

### 1. 仓库清理（小活，建议先做）

- [ ] **重复 License 文件**：仓库里同时有 `LICENSE`（GitHub 建库时生成）和 `LICENSE.txt`（本地同步来的），内容相同。删掉其中一个，commit + push。
- [ ] **`.DS_Store`**：monitor 目录里有，已在 `.gitignore` 中，未进 Git；可本地删除，无需提交。

### 2. GitHub Releases（README 已写，但还没做）

README 里写了从 Releases 下载 DMG，但 **GitHub 上还没有 Release**：

- [ ] 本地打包：`cd /Users/wh1215/monitor && ./scripts/package.sh`
- [ ] 产物：`build/VibeCodingMonitor-1.0.dmg`
- [ ] 在 GitHub → **Releases → Create a new release** 上传 DMG
- [ ] Tag 建议：`v1.0`

### 3. 两个文件夹的关系（workflow 未定）

| 路径 | 角色 | Git |
|------|------|-----|
| `/Users/wh1215/vibecodingmonitor_ylhSOFT` | 当前 Cursor 工作区 / 开发 | ❌ 无 `.git` |
| `/Users/wh1215/monitor` | GitHub 上传目录 | ✅ 已连远程 |

- [ ] **决定以后在哪改代码**（只保留一个主目录，或固定同步流程）
- [ ] 若在 `vibecodingmonitor_ylhSOFT` 开发，改完需同步到 `monitor` 再 `git push`：

```bash
rsync -av \
  --exclude='build/' --exclude='DerivedData/' --exclude='.DS_Store' \
  --exclude='xcuserdata/' --exclude='*.xcuserstate' \
  /Users/wh1215/vibecodingmonitor_ylhSOFT/ \
  /Users/wh1215/monitor/

cd /Users/wh1215/monitor
git add .
git commit -m "描述你的改动"
git push
```

### 4. 可选增强（之前聊过，非必须）

- [ ] README 加截图（菜单栏、悬浮窗、六种状态灯）
- [ ] 添加 `LICENSE` 统一命名后，在 README 里链到 License
- [ ] GitHub Actions 自动打包 DMG
- [ ] `startup.mp3` 若 push 慢，考虑 Git LFS
- [ ] 配置 **SSH** 免每次输 Token：`git@github.com:yilihuapersonal/monitor.git`
- [ ] App **代码签名 / 公证**（给外人分发 DMG 时可能需要）

### 5. 回来后可验证

- [ ] 打开 https://github.com/yilihuapersonal/monitor 确认文件齐全
- [ ] Cursor 里发起 Agent 对话 → 状态灯是否变化
- [ ] **Cursor 设置 → Hooks** 确认 hooks 已加载
- [ ] 主窗口显示「已连接 Cursor Hooks」（绿点）

---

## 踩坑记录（别重复）

1. **GitHub 不接受登录密码 push** → 用 Personal Access Token（勾选 `repo`），Password 栏粘贴 token。
2. **用户名拼写**：`yilihuapersonal`（不是 `yilihuapersoanl`）。
3. **push 被拒 `fetch first`**：远程建库时勾了 LICENSE，与本地 initial commit 分叉 →  
   `git pull origin main --allow-unrelated-histories --no-rebase --no-edit` 再 push。
4. **分叉分支要指定合并方式**：pull 时加 `--no-rebase` 或 `--rebase`，不必改全局 `git config`。

---

## 关键命令速查

```bash
# 开发目录 → GitHub 目录同步
rsync -av --exclude='build/' --exclude='DerivedData/' --exclude='.DS_Store' \
  --exclude='xcuserdata/' --exclude='*.xcuserstate' \
  /Users/wh1215/vibecodingmonitor_ylhSOFT/ /Users/wh1215/monitor/

# 提交推送
cd /Users/wh1215/monitor
git add .
git commit -m "你的说明"
git push

# 打包 DMG
./scripts/package.sh

# 安装 Hooks（新机器）
chmod +x scripts/install-hooks.sh && ./scripts/install-hooks.sh
```

---

## 联系人 / 账号

- GitHub：`yilihuapersonal`
- 仓库：`https://github.com/yilihuapersonal/monitor.git`
