#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BRIGHT_BLUE='\033[0;94m'
NC='\033[0m' # No Color

function print_red {
    echo -e "${RED}$1${NC}"
}
function print_green {
    echo -e "${GREEN}$1${NC}"
}

function exit_with_error {
    print_red "$*"
    exit 1
}

function slugify {
    echo "$*" | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr A-Z a-z
}

BASE_DIR="/builder"

cd "$BASE_DIR"

[[ -f manifest.json ]] || exit_with_error "manifest.json file is missing!"
[[ -d overrides ]] || exit_with_error "overrides folder is missing!"

BUILD_DIR="$BASE_DIR/build"
CLIENT_DIR="$BUILD_DIR/client"
SERVER_DIR="$BUILD_DIR/server"
ARTIFACTS_DIR="$BASE_DIR/artifacts"

PACK_NAME="$(jq -j .name manifest.json)"
PACK_VERSION="$(jq -j .version manifest.json)"
PACK_SLUG="$(slugify $PACK_NAME)_$PACK_VERSION"

CLIENT_FILE="$ARTIFACTS_DIR/${PACK_SLUG}_client.zip"
SERVER_FILE="$ARTIFACTS_DIR/${PACK_SLUG}_server.zip"

print_green "Building $BRIGHT_BLUE${PACK_NAME}$GREEN version $BRIGHT_BLUE${PACK_VERSION}"

print_green "Cleaning up..."
rm -vrf "$BUILD_DIR" "$CLIENT_FILE" "$SERVER_FILE"

print_green "Creating directories..."
mkdir -vp "$CLIENT_DIR"
mkdir -vp "$SERVER_DIR"
mkdir -vp "$ARTIFACTS_DIR"

print_green "Copying files..."
for f in manifest.json overrides/**/*; do
    echo "$f"
done
cp -r manifest.json overrides "$CLIENT_DIR/"
cp -r manifest.json overrides "$SERVER_DIR/"

print_green "Building client..."
cd "$CLIENT_DIR"
zip -vqr "$CLIENT_FILE" . && echo "created: $CLIENT_FILE"

print_green "Building server..."
cd "$SERVER_DIR"
mv overrides/* .
rm -r overrides
mcdex db.update
mcdex server.install .
zip -vqr "$SERVER_FILE" . && echo "created: $SERVER_FILE"

print_green "Cleaning up..."
rm -rf "$BUILD_DIR"

print_green "Done!"