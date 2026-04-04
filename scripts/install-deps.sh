#!/usr/bin/env bash
# Install beads (bd) and beads-ui into vendor/bin/ for the superpowers-beads plugin.
# Idempotent — skips if correct versions are already present.
# Always exits 0 — caller (session-start hook) checks for binaries.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENDOR_DIR="${PLUGIN_ROOT}/vendor"
BIN_DIR="${VENDOR_DIR}/bin"
VERSIONS_FILE="${VENDOR_DIR}/versions.json"

# Read pinned versions (shell-native, no python3 dependency)
if [ ! -f "$VERSIONS_FILE" ]; then
  echo "ERROR: ${VERSIONS_FILE} not found" >&2
  exit 0
fi

BD_VERSION=$(grep '"bd"' "$VERSIONS_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')
BDUI_VERSION=$(grep '"beads-ui"' "$VERSIONS_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "$BD_VERSION" ] || [ -z "$BDUI_VERSION" ]; then
  echo "ERROR: Could not parse versions from ${VERSIONS_FILE}" >&2
  exit 0
fi

mkdir -p "$BIN_DIR"

# --- Install bd ---

install_bd() {
  local os arch tarball url

  case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *)      echo "ERROR: Unsupported OS: $(uname -s)" >&2; return 1 ;;
  esac

  case "$(uname -m)" in
    arm64|aarch64) arch="arm64" ;;
    x86_64)        arch="amd64" ;;
    *)             echo "ERROR: Unsupported arch: $(uname -m)" >&2; return 1 ;;
  esac

  tarball="beads_${BD_VERSION}_${os}_${arch}.tar.gz"
  url="https://github.com/gastownhall/beads/releases/download/v${BD_VERSION}/${tarball}"

  echo "Downloading bd v${BD_VERSION} for ${os}/${arch}..."
  local tmpdir
  tmpdir=$(mktemp -d)

  if curl -fsSL -o "${tmpdir}/${tarball}" "$url"; then
    tar -xzf "${tmpdir}/${tarball}" -C "$tmpdir"
    # The tarball contains a 'beads' or 'bd' binary
    local binary
    binary=$(find "$tmpdir" -type f \( -name "beads" -o -name "bd" \) -perm +111 2>/dev/null | head -1)
    if [ -z "$binary" ]; then
      # Try without perm flag (Linux find uses -executable)
      binary=$(find "$tmpdir" -type f \( -name "beads" -o -name "bd" \) -executable 2>/dev/null | head -1)
    fi
    if [ -z "$binary" ]; then
      echo "ERROR: No executable found in tarball" >&2
      rm -rf "$tmpdir"
      return 1
    fi
    cp "$binary" "${BIN_DIR}/bd"
    chmod +x "${BIN_DIR}/bd"
    rm -rf "$tmpdir"
    echo "Installed bd v${BD_VERSION} to ${BIN_DIR}/bd"
  else
    rm -rf "$tmpdir"
    echo "WARN: GitHub download failed, trying npm fallback..." >&2
    if command -v npm >/dev/null 2>&1; then
      npm install -g "@beads/bd@${BD_VERSION}" 2>&1
      echo "Installed bd v${BD_VERSION} via npm (global)"
    else
      echo "ERROR: npm not available for fallback" >&2
      return 1
    fi
  fi
}

# Check if bd is already installed at correct version in vendor
bd_needs_install=true
if [ -x "${BIN_DIR}/bd" ]; then
  installed_bd=$("${BIN_DIR}/bd" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
  if [ "$installed_bd" = "$BD_VERSION" ]; then
    echo "bd v${BD_VERSION} already installed in vendor/bin/"
    bd_needs_install=false
  fi
fi

if [ "$bd_needs_install" = true ]; then
  if ! install_bd; then
    echo "WARN: Failed to install bd to vendor/bin/" >&2
  fi
fi

# --- Install beads-ui ---

install_bdui() {
  echo "Installing beads-ui v${BDUI_VERSION}..."

  # Create a minimal package.json in vendor/ for npm install
  cat > "${VENDOR_DIR}/package.json" <<PKGJSON
{
  "name": "superpowers-beads-vendor",
  "private": true,
  "dependencies": {
    "beads-ui": "${BDUI_VERSION}"
  }
}
PKGJSON

  if ! (cd "$VENDOR_DIR" && npm install --no-fund --no-audit 2>&1); then
    echo "ERROR: npm install failed for beads-ui" >&2
    return 1
  fi

  # Symlink bdui to vendor/bin/
  if [ -f "${VENDOR_DIR}/node_modules/.bin/bdui" ]; then
    ln -sf "../node_modules/.bin/bdui" "${BIN_DIR}/bdui"
    echo "Installed beads-ui v${BDUI_VERSION}, symlinked to ${BIN_DIR}/bdui"
  else
    echo "ERROR: bdui binary not found after npm install" >&2
    return 1
  fi
}

# Check if bdui is already installed at correct version
bdui_needs_install=true
if [ -L "${BIN_DIR}/bdui" ] && [ -x "${BIN_DIR}/bdui" ]; then
  installed_bdui=$("${BIN_DIR}/bdui" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
  if [ "$installed_bdui" = "$BDUI_VERSION" ]; then
    echo "beads-ui v${BDUI_VERSION} already installed in vendor/bin/"
    bdui_needs_install=false
  fi
fi

if [ "$bdui_needs_install" = true ]; then
  if ! install_bdui; then
    echo "WARN: Failed to install beads-ui to vendor/bin/" >&2
  fi
fi

exit 0
