#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$SCRIPT_DIR
OUTPUT_FILE="${REPO_ROOT}/ios/Megacool.framework"

rm -rf $OUTPUT_FILE

# 1. create tmp dir for download files
DOWNLOAD_DIR=$(mktemp -d)

# 2. get version from package.json (same as Megacool version)
# VERSION=`node --print "require('./package.json').version"`
# 2. get version from cli
VERSION=$1

# 3. enter download dir
pushd $DOWNLOAD_DIR
	URL="https://megacool-files.s3-accelerate.amazonaws.com/megacool-sdk-ios-v${VERSION}.zip"
	# 4. download zip and save as "${PLATFORM}.zip"
	wget $URL -O "ios.zip"
	# 5. unzip
	unzip "ios.zip" >> /dev/null
	# 6. move framework into output dir
	mv "Megacool.framework" $OUTPUT_FILE
popd

rm -rf $DOWNLOAD_DIR



