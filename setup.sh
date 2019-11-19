#!/bin/sh

echo "Closing any open System preferences panes, to prevent them from overriding
setting that are about to be changed..."
echo "Configuring OSX..."

osascript -e 'tell application "System Preferences" to quit'


newUser(){

echo "Enter the user name:"
read SHORTNAME

echo "Enter a full name for user:"
read FULLNAME

echo "Enter a password for this user:"
read -s PASSWORD


sudo sysadminctl -addUser $SHORTNAME -fullName "$FULLNAME"  -password $PASSWORD

sudo fdesetup add -usertoadd $SHORTNAME

}



echo "Do you want create a new user? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Changing the remove Mdm Profile "
      newUser
else
        exit 0
fi

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

echo "Do you want to remove Mdm Profile? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Changing the remove Mdm Profile "
        UAMDMCheck & Check
else
        echo "Leaving existing MDM profiles"
fi


hbcheck(){
# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "Updating homebrew recipes"
	brew update
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
	brew install findutils

# Install Bash 4
	brew install bash

	PACKAGES=(
		wget
    winetricks
    wine-pypi
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
fi

}



echo "Do you want to install Homebrew? [Y,N]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Installing Homebrew.."
        hbcheck
else
        echo "Leaving existing settings..."
fi


appSet(){
  cd /Applications
  sudo rm -rif /Applications/Microsoft\ Excel.app /Applications/Microsoft\ OneNote.app /Applications/Microsoft\ Outlook.app /Applications/Microsoft\ PowerPoint.app /Applications/Microsoft\ Silverlight /Applications/Microsoft\ Word.app
  ## sudo rm -rif /Applications/Adobe\ Acrobat\ DC /Applications/Adobe\ Bridge\ CC\ 2018 /Applications/Adobe\ Creative\ Cloud /Applications/Adobe\ Illustrator\ CC\ 2018 /Applications/Adobe\ InDesign\ CC\ 2018 /Applications/Adobe\ Lightroom\ CC /Applications/Adobe\ Media\ Encoder\ CC\ 2018 /Applications/Adobe\ Photoshop\ CC\ 2018
  ## sudo rm -rif /Applications/Adobe\ After\ Effects\ CC\ 2019 /Applications/Adobe\ Audition\ CC\ 2019 /Applications/Adobe\ Bridge\ CC\ 2019 /Applications/Adobe\ Illustrator\ CC\ 2019 /Applications/Adobe\ InDesign\ CC\ 2019 /Applications/Adobe\ Lightroom\ Classic /Applications/Adobe\ Media\ Encoder\ CC\ 2019 /Applications/Adobe\ Photoshop\ CC\ 2019 /Applications/Adobe\ Premiere\ Pro\ CC\ 2019

  curl -o /Applications/AcroRdrDC_1902120049_MUI.dmg https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/1902120049/AcroRdrDC_1902120049_MUI.dmg
  hdiutil attach /Applications/AcroRdrDC_1902120049_MUI.dmg
  sudo installer -pkg /Volumes/AcroRdrDC_1902120049_MUI/AcroRdrDC_1902120049_MUI.pkg -target /
  sudo rm -rif /Applications/AcroRdrDC_1902120049_MUI.dmg
  hdiutil detach /Volumes/AcroRdrDC_1902120049_MUI

  curl -o /Applications/Microsoft_Office_16.31.19111002_Installer.pkg https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_Office_16.31.19111002_Installer.pkg
  sudo installer -pkg /Applications/Microsoft_Offsice_16.31.19111002_Installer.pkg -target /
  sudo rm -rif /Applications/Microsoft_Office_16.31.19111002_Installer.pkg

  curl -o /applications/Microsoft_Office_2019_VL_Serializer.pkg https://gist.githubusercontent.com/zthxxx/9ddc171d00df98cbf8b4b0d8469ce90a/raw/Microsoft_Office_2019_VL_Serializer.pkg
  sudo installer -pkg /Applications/Microsoft_Office_2019_VL_Serializer.pkg -target /
  #sudo rm -rif /Applications/Microsoft_Office_2019_VL_Serializer.pkg

  curl -o /Applications/atom-mac.zip  https://atom-installer.github.com/v1.41.0/atom-mac.zip?s=1571754162&ext=.zip && sudo unzip /Applications/atom-mac.zip

  #sudo rm -rif /Applications/atom-mac.zip

  #curl -o /Applications/Remote+Desktop.app.zip  http://www.mediafire.com/folder/q6om3ndwj0bds/PKG/Remote_Desktop.app.zip/file
  #sudo unzip /Applications/Remote+Desktop.app.zip
  #sudo rm -rif /Applications/Remote+Desktop.app.zip http://www.mediafire.com/folder/q6om3ndwj0bds/PKG

}

echo "Do you want to install custom applications? [Y,N]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Installing custom applications"
        appSet
else
        echo "Leaving existing applications"
fi



# ask for admin password up front
# sudo -v



osascript -e 'tell app "System Events" to log out'
