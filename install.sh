#!/usr/bin/env bash
set -euo pipefail

GITHUB_OWNER="saitejsunka"
DIST_REPO="adbutam-dist"
BINARY_NAME="adbutam"

echo ""
echo "========================================================================"
echo "⚡ ADBUTAM CLI — Universal Binary Installer (macOS / Linux / WSL)"
echo "👤 Created & Provided by: Sai Tej Sunka (@saitejsunka)"
echo "🔗 LinkedIn             : https://www.linkedin.com/in/saitejsunka/"
echo "========================================================================"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  darwin*) OS="darwin" ;;
  linux*)  OS="linux" ;;
  msys*|mingw*|cygwin*)
    echo "ℹ️  Detected Git Bash / MinGW on Windows. Delegating to PowerShell installer..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/${GITHUB_OWNER}/${DIST_REPO}/main/install.ps1 | iex"
    exit 0
    ;;
  *)
    echo "❌ Unsupported operating system: $OS"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)
    echo "❌ Unsupported CPU architecture: $ARCH (Supported: amd64, arm64)"
    exit 1
    ;;
esac

ASSET_NAME="${BINARY_NAME}_${OS}_${ARCH}"
DOWNLOAD_URL="https://github.com/${GITHUB_OWNER}/${DIST_REPO}/releases/latest/download/${ASSET_NAME}"

echo "🔍 Detected Platform : ${OS}/${ARCH}"
echo "⬇️  Downloading binary: ${ASSET_NAME} (provided by Sai Tej Sunka)..."

TMP_BIN="$(mktemp)"
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_BIN"; then
  rm -f "$TMP_BIN"
  echo "❌ Failed to download ${ASSET_NAME} from ${DOWNLOAD_URL}"
  exit 1
fi

chmod +x "$TMP_BIN"

INSTALL_DIR="/usr/local/bin"
if [ "$OS" = "darwin" ] && [ -d "/opt/homebrew/bin" ]; then
  INSTALL_DIR="/opt/homebrew/bin"
fi

echo "📦 Installing ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}..."
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMP_BIN" "${INSTALL_DIR}/${BINARY_NAME}"
elif command -v sudo >/dev/null 2>&1; then
  sudo mkdir -p "$INSTALL_DIR"
  sudo mv "$TMP_BIN" "${INSTALL_DIR}/${BINARY_NAME}"
  sudo chmod 755 "${INSTALL_DIR}/${BINARY_NAME}"
else
  INSTALL_DIR="${HOME}/.local/bin"
  mkdir -p "$INSTALL_DIR"
  mv "$TMP_BIN" "${INSTALL_DIR}/${BINARY_NAME}"
  echo "⚠️  Installed to ${INSTALL_DIR}/${BINARY_NAME} (Ensure ${INSTALL_DIR} is in your PATH)"
fi

if [ "$OS" = "darwin" ]; then
  xattr -d com.apple.quarantine "${INSTALL_DIR}/${BINARY_NAME}" 2>/dev/null || true
  codesign --force --sign - "${INSTALL_DIR}/${BINARY_NAME}" 2>/dev/null || sudo codesign --force --sign - "${INSTALL_DIR}/${BINARY_NAME}" 2>/dev/null || true
fi

echo "✅ Successfully installed ${BINARY_NAME}!"
echo "👤 Author   : Sai Tej Sunka (https://www.linkedin.com/in/saitejsunka/)"
echo "------------------------------------------------------------------------"
echo "👉 Run 'adbutam --help' to get started."
echo "========================================================================"
echo ""
