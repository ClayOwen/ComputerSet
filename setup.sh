#!/bin/sh

echo "Closing any open System preferences panes, to prevent them from overriding
setting that are about to be changed..."
echo "Configuring OSX..."

osascript -e 'tell application "System Preferences" to quit'

prefSet(){
# Computer set to never sleep
 sudo systemsetup -setcomputersleep Never
 sudo pmset -a displaysleep 180
 sudo pmset -a womp 0
 sudo pmset -a disksleep 0
 sudo pmset -a autorestart 1
 sudo pmset -a powernap 0

# no Screensaver
 defaults -currentHost write com.apple.screensaver idleTime 0

# Set fast key repeat rate
 defaults write NSGlobalDomain KeyRepeat -int 0

# disable sound effects on boot
 Sudo nvram SystemAudioVolume=" "

# Disable automatic capitalization
 defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# turn on tap to click
 defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
 #defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
 defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Turn off Force click and haptic feedback
 defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -int 1

# Set computer appearance to dark mode Control + option + t
 Sudo defaults write /Library/Preferences/.GloobalPreferences.plist_HIEnableThemeSwitchHotKey -bool true

# Enable text select from  quicklook windows
 defaults write com.apple.finderQLEnableTextSelection -bool TRUE;killall Finder

# Prevent Time Machine from prompting to use new hard drives as backup volume
 defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable the warning before emptying the Trash
 defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
 defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
}



echo "Do you want to customize the default  settings? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "changing the default  settings"
        prefSet
else
        echo "Setting will be left on default "
fi


UAMDMCheck(){
# This function checks if a Mac has user-approved MDM enabled.
# If the UAMDMStatus variable returns "User Approved", then the
# following status is returned:
#
# Yes
#
# If anything else is returned, the following status is
# returned:
#
# No
UAMDMStatus=$(profiles status -type enrollment | grep -o "User Approved")
if [[ "$UAMDMStatus" = "User Approved" ]]; then
   noinst='0'
else
   noinst='1'
fi
}


echo "Do you want to remove Mdm Profile? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Changing the remove Mdm Profile "
        UAMDMCheck & Check
else
        echo "Leaving existing MDM profiles"
fi

Check(){
if [[ $noinst == "1" ]]; then
  echo "No MDM profile Present..."

elif [[ $noinst == "0" ]]; then
  echo "Removing MDM Profle..."

  Sudo jamf -removeFramework
  sudo jamf -removeMdmProfile

  Cd /Library/LaunchDaemons

  Sudo launchctrl stop /Library/LaunchDaemons/com.fcb.caspercheck.plist
  sudo launchctl unload -w /Library/LaunchDaemons/com.fcb.caspercheck.plist

  Sudo launchctrl stop /Library/LaunchDaemons/com.github.patchoo-trigger-patchoo.plist
  sudo launchctl unload -w /Library/LaunchDaemons/com.github.patchoo-trigger-patchoo.plist

  Sudo launchctrl stop /Library/LaunchDaemons/com.github.patchoo-trigger-every120.plist
  sudo launchctl unload -w /Library/LaunchDaemons/com.github.patchoo-trigger-every120.plist

  sudo rm com.fcb.caspercheck.plist
  sudo rm com.github.patchoo-trigger-patchoo.plist
  sudo rm com.github.patchoo-trigger-every120.plist

fi
}

appSet(){
  sudo rm -rif /Applications/Microsoft\ Excel.app /Applications/Microsoft\ OneNote.app /Applications/Microsoft\ Outlook.app /Applications/Microsoft\ PowerPoint.app /Applications/Microsoft\ Silverlight /Applications/Microsoft\ Word.app
  sudo rm -rif /Applications/Adobe\ Acrobat\ DC /Applications/Adobe\ Bridge\ CC\ 2018 /Applications/Adobe\ Creative\ Cloud /Applications/Adobe\ Illustrator\ CC\ 2018 /Applications/Adobe\ InDesign\ CC\ 2018 /Applications/Adobe\ Lightroom\ CC /Applications/Adobe\ Media\ Encoder\ CC\ 2018 /Applications/Adobe\ Photoshop\ CC\ 2018
  sudo rm -rif /Applications/Adobe\ After\ Effects\ CC\ 2019 /Applications/Adobe\ Audition\ CC\ 2019 /Applications/Adobe\ Bridge\ CC\ 2019 /Applications/Adobe\ Illustrator\ CC\ 2019 /Applications/Adobe\ InDesign\ CC\ 2019 /Applications/Adobe\ Lightroom\ Classic /Applications/Adobe\ Media\ Encoder\ CC\ 2019 /Applications/Adobe\ Photoshop\ CC\ 2019 /Applications/Adobe\ Premiere\ Pro\ CC\ 2019
  sudo installer -pkg /Volumes/Conference_setup/Conference/AcroRdrDC_1901220036_MUI.pkg -target /
  sudo installer -pkg /Volumes/Conference_setup/Conference/Microsoft_office_16.16.19081100_Installer.pkg -target /
  sudo installer -pkg /Volumes/Conference_setup/Conference/Microsoft_Office_2016_VL_Serializer_2.0.pkg -target /
  sudo mv "Volumes/Conference/Microsoft Remote Desktop.app" /Applications/
  sudo mv "/Volumes/Conference/Remote Desktop.app" /Applications/
  sudo mv "/Volumes/Conference/Atom.app" /Applications/
}

echo "Do you want to install custom applications? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Installing custom applications"
        appSet
else
        echo "Leaving existing applications"
fi



echo "Starting bootstrapping"

# ask for admin password up front
# sudo -v

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Updating homebrew recipes"
brew update
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

PACKAGES=(
	wget
	wine
  winetricks
	curl
	pkg-config
	python
  python3
  mas
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

echo "Cleaning up..."
brew cleanup

osascript -e 'tell app "System Events" to log out'
