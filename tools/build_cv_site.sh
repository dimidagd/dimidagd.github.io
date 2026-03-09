#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_REPO_URL="https://codeload.github.com/dimidagd/markdown-cv/tar.gz/refs/heads/master"
DEST_DIR="${ROOT_DIR}/static/cv"
TMP_DIR="$(mktemp -d)"
SRC_MD="${1:-}"
CV_STYLE="${CV_STYLE:-kjhealy}"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Preparing markdown-cv template..."
curl -Ls "${TEMPLATE_REPO_URL}" | tar -xz -C "${TMP_DIR}"
SITE_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name 'markdown-cv-*' | head -n 1)"

if [[ -z "${SITE_DIR}" ]]; then
  echo "Failed to unpack markdown-cv template" >&2
  exit 1
fi

if [[ -n "${SRC_MD}" ]]; then
  if [[ ! -f "${SRC_MD}" ]]; then
    echo "Markdown source not found: ${SRC_MD}" >&2
    exit 1
  fi
  cp "${SRC_MD}" "${SITE_DIR}/index.md"
fi

printf '\nbaseurl: /cv\nurl: ""\n' >> "${SITE_DIR}/_config.yml"
sed -i "s/^style:.*/style:  ${CV_STYLE}/" "${SITE_DIR}/_config.yml"

echo "Building Jekyll CV site with Docker..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "${SITE_DIR}:/site" \
  bretfisher/jekyll \
  build

rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"
cp -R "${SITE_DIR}/_site/." "${DEST_DIR}/"

echo "CV site generated at ${DEST_DIR}"
