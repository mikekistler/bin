#!/bin/bash

###############################################################################
# Creates encrypted, date-stamped DMG backups of the Finances and Taxes folders
# from ~/Documents and saves them in ~/Downloads. hdiutil prompts for an
# encryption password for each disk image.
###############################################################################

today=$(date "+%Y-%m-%d")
echo "Creating backups of Finances and Taxes for ${today}"
hdiutil create -encryption -stdinpass -srcfolder ~/Documents/Finances ~/Downloads/Finances-${today}.dmg
hdiutil create -encryption -stdinpass -srcfolder ~/Documents/Taxes ~/Downloads/Taxes-${today}.dmg
