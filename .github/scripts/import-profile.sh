https://github.com/tsaohe/AlarmPaw/blob/main/.github/scripts/import-profile.sh#!/bin/bash

set -euo pipefail

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo "$PROVISIONING_PROFILE_PAW_DATA" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/paw.mobileprovision
echo "$PROVISIONING_PROFILE_SERVER_DATA" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/service.mobileprovision
echo "$PROVISIONING_PROFILE_CONTENT_DATA" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/content.mobileprovision
