#!/bin/bash
# 打包 VibeCodingMonitor 为 macOS 安装镜像 (.dmg)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="VibeCodingMonitor"
VERSION="1.0"
BUILD_DIR="$ROOT/build"
DERIVED="$BUILD_DIR/DerivedData"
RELEASE_APP="$DERIVED/Build/Products/Release/$APP_NAME.app"
DMG_STAGING="$BUILD_DIR/dmg-staging"
DMG_OUTPUT="$BUILD_DIR/${APP_NAME}-${VERSION}.dmg"
COPYRIGHT_LINE1="© 2026 WH YLH Software Development Co., Ltd"
COPYRIGHT_LINE2="All rights reserved."

echo "→ 编译 Release 版本..."
cd "$ROOT"
xcodebuild \
  -project VibeCodingMonitor.xcodeproj \
  -scheme VibeCodingMonitor \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED" \
  build 2>&1 | grep -E 'BUILD (SUCCEEDED|FAILED)|error:' || true

if [[ ! -d "$RELEASE_APP" ]]; then
  echo "✗ 找不到编译产物 $RELEASE_APP"
  exit 1
fi

echo "→ 准备安装包内容..."
rm -rf "$DMG_STAGING" "$DMG_OUTPUT"
mkdir -p "$DMG_STAGING"

cp -R "$RELEASE_APP" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

cat >"$DMG_STAGING/安装说明.txt" <<EOF
Vibe Coding Monitor ${VERSION}

${COPYRIGHT_LINE1}
${COPYRIGHT_LINE2}

安装步骤：
1. 将 VibeCodingMonitor 拖到「应用程序」文件夹
2. 首次打开若提示无法验证，请前往：
   系统设置 → 隐私与安全性 → 仍要打开
3. 安装 Cursor Hooks（首次使用必须）：
   打开终端，进入本镜像中的目录，执行：
     chmod +x vibe-status.sh
     mkdir -p ~/.cursor/hooks
     cp vibe-status.sh ~/.cursor/hooks/
     cp cursor-hooks.json ~/.cursor/hooks.json
   然后重启 Cursor

EOF

cp "$ROOT/cursor-hooks/hooks.json" "$DMG_STAGING/cursor-hooks.json"
cp "$ROOT/cursor-hooks/vibe-status.sh" "$DMG_STAGING/vibe-status.sh"
chmod +x "$DMG_STAGING/vibe-status.sh"

echo "→ 生成 DMG..."
hdiutil create \
  -volname "Vibe Coding Monitor" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_OUTPUT"

echo ""
echo "✓ 安装包已生成："
echo "  $DMG_OUTPUT"
echo "  ${COPYRIGHT_LINE1}"
echo "  ${COPYRIGHT_LINE2}"
du -h "$DMG_OUTPUT"
