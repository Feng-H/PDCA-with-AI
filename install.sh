#!/bin/bash

# PDCA Skill 安装/更新脚本
# 自动检测 OpenClaw skills 目录并安装到正确位置

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="pdca"
REPO_URL="https://github.com/Feng-H/PDCA-with-AI.git"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          PDCA Skill 安装/更新脚本                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 检测 OpenClaw 配置
echo "🔍 检测 OpenClaw 配置..."

OPENCLAW_CONFIG=""
OPENCLAW_SKILLS_DIR=""

# 可能的配置文件位置
CONFIG_PATHS=(
    "$HOME/.openclaw/config.json"
    "$HOME/.config/openclaw/config.json"
    "$HOME/.openclaw.json"
)

for config_path in "${CONFIG_PATHS[@]}"; do
    if [ -f "$config_path" ]; then
        OPENCLAW_CONFIG="$config_path"
        break
    fi
done

if [ -n "$OPENCLAW_CONFIG" ]; then
    echo "✅ 找到配置: $OPENCLAW_CONFIG"
    # 尝试读取 skillsDir
    if command -v jq &> /dev/null; then
        OPENCLAW_SKILLS_DIR=$(jq -r '.skillsDir // .skillsPath // empty' "$OPENCLAW_CONFIG" 2>/dev/null || echo "")
    fi
fi

# 默认 skills 目录
DEFAULT_SKILLS_DIR="$HOME/.openclaw/skills"
SKILLS_DIR="${OPENCLAW_SKILLS_DIR:-$DEFAULT_SKILLS_DIR}"

echo "📁 目标安装目录: $SKILLS_DIR"
echo ""

# 创建目标目录
mkdir -p "$SKILLS_DIR"

# 目标 skill 目录
TARGET_DIR="$SKILLS_DIR/$SKILL_NAME"

# 临时目录用于下载
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "⬇️  下载最新版本..."
cd "$TEMP_DIR"

# 检查是否安装了 git
if command -v git &> /dev/null; then
    git clone --depth 1 "$REPO_URL" temp_skill
    cd temp_skill
elif command -v curl &> /dev/null || command -v wget &> /dev/null; then
    # 使用 npm 下载
    npm pack "@feng-h/pdca-skill"
    tar -xzf feng-h-pdca-skill-*.tgz
    cd package
else
    echo "❌ 错误: 需要 git 或 npm 来下载 skill"
    exit 1
fi

echo "✅ 下载完成"
echo ""

# 备份现有安装（如果存在）
if [ -d "$TARGET_DIR" ]; then
    echo "📦 备份现有安装..."
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    echo "✅ 备份到: $BACKUP_DIR"
fi

echo "📋 安装到: $TARGET_DIR"
mkdir -p "$SKILLS_DIR"
cp -r "$TEMP_DIR/temp_skill" "$TARGET_DIR"

# 如果是 npm 方式下载的
if [ -d "$TEMP_DIR/package" ]; then
    rm -rf "$TARGET_DIR"
    cp -r "$TEMP_DIR/package" "$TARGET_DIR"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ 安装完成！                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 安装位置: $TARGET_DIR"
echo ""
echo "🔍 验证安装:"
echo "   ls -la $TARGET_DIR/SKILL.md"
echo ""
echo "🚀 重启 OpenClaw 后即可使用"
