#!/usr/bin/env bash
set -euo pipefail

GITHUB_OWNER="saitejsunka"
DIST_REPO="adbutam-dist"
BINARY_NAME="adbutam"

echo ""
echo "========================================================================"
echo "⚡ ADBUTAM CLI — Universal Binary & Toolchain Installer (macOS / Linux / WSL)"
echo "👤 Created & Provided by: Sai Tej Sunkara (@saitejsunka)"
echo "🔗 LinkedIn             : https://www.linkedin.com/in/saitejsunka/"
echo "========================================================================"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  darwin*) OS="darwin" ;;
  linux*)  OS="linux" ;;
  msys*|mingw*|cygwin*)
    echo "ℹ️  Detected Git Bash / MinGW on Windows. Delegating to PowerShell installer..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://github.com/${GITHUB_OWNER}/${DIST_REPO}/releases/latest/download/install.ps1 | iex"
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

echo "🔧 [1/2] Verifying & installing required prerequisites (Homebrew, Go, Git, GitHub CLI, Buf, OpenTofu, gRPCurl, Bazelisk)..."

if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

install_if_missing() {
  local bin_name="$1"
  local brew_pkg="$2"
  if ! command -v "$bin_name" >/dev/null 2>&1; then
    echo "📦 Installing ${brew_pkg} (provides '${bin_name}')..."
    brew install "$brew_pkg"
  else
    echo "  ✔️  ${bin_name} is already installed."
  fi
}

install_if_missing "go" "go"
install_if_missing "git" "git"
install_if_missing "gh" "gh"
install_if_missing "buf" "bufbuild/buf/buf"
install_if_missing "tofu" "opentofu"
install_if_missing "grpcurl" "grpcurl"
install_if_missing "bazel" "bazelisk"

ASSET_NAME="${BINARY_NAME}_${OS}_${ARCH}"
DOWNLOAD_URL="https://github.com/${GITHUB_OWNER}/${DIST_REPO}/releases/latest/download/${ASSET_NAME}"

echo "⬇️  [2/2] Downloading ${ASSET_NAME} for ${OS}/${ARCH} (provided by Sai Tej Sunkara)..."

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

echo "✅ Successfully installed ${BINARY_NAME} and all prerequisites (including Bazelisk)!"
echo "👤 Author   : Sai Tej Sunkara (https://www.linkedin.com/in/saitejsunka/)"
echo "------------------------------------------------------------------------"
echo "👉 Run 'adbutam --help' to get started."
echo "========================================================================"
echo ""
