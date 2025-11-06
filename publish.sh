#!/usr/bin/env bash

set -euo pipefail

MSG=${1:-"chore: publish LaTeX PDF"}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

echo "==> 编译 PDF..."
if ! command -v latexmk >/dev/null 2>&1; then
  TEXBIN="/Library/TeX/texbin"
  if [[ -x "${TEXBIN}/latexmk" ]]; then
    export PATH="${TEXBIN}:${PATH}"
  fi
fi

if ! command -v latexmk >/dev/null 2>&1; then
  cat <<'EOF' >&2
未找到 latexmk 命令。
请确认已安装 MacTeX，并将 /Library/TeX/texbin 添加到 PATH，例如：
  echo 'export PATH=/Library/TeX/texbin:$PATH' >> ~/.zshrc
EOF
  exit 127
fi

latexmk -pdf main.tex

PDF_PATH="build/main.pdf"
if [[ ! -f "${PDF_PATH}" ]]; then
  echo "未找到 ${PDF_PATH}，请检查编译日志。" >&2
  exit 1
fi

cp "${PDF_PATH}" main.pdf
echo "PDF 已复制到 $(pwd)/main.pdf"

echo "==> 准备 Git 提交..."
git add main.tex refs.bib Makefile latexmkrc publish.sh .gitignore main.pdf

if git diff --cached --quiet; then
  echo "没有检测到需要提交的改动。"
  exit 0
fi

git_user_name=$(git config user.name || true)
git_user_email=$(git config user.email || true)

if [[ -z "${git_user_name}" || -z "${git_user_email}" ]]; then
  cat <<'EOF' >&2
检测到当前仓库未配置 Git 用户名或邮箱。
请运行以下命令设置后重新执行 publish.sh：
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
EOF
  exit 1
fi

git commit -m "${MSG}"

current_branch=$(git rev-parse --abbrev-ref HEAD)
remote_name=$(git config branch."${current_branch}".remote 2>/dev/null || echo "")

if [[ -n "${remote_name}" ]]; then
  echo "==> 推送到远端..."
  git push "${remote_name}" "${current_branch}"
else
  echo "未检测到当前分支的远端配置，已跳过 git push。"
fi
