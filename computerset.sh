#!/bin/sh

brewIns(){
echo "Starting bootstrapping"

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
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

echo "Cleaning up..."
brew cleanup

echo "Installing cask..."
brew install caskroom/cask

brew cleanup
}

compSet(){
osascript -e 'tell application "System Events" to display dialog " Closing system preferences panes "'
osascript -e 'tell application "System Preferences" to quit'

  # Set fast key repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 0

  # disable sound effects on boot
  Sudo nvram SystemAudioVolume=" "

  # Disable automatic capitalization
  Defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # turn on tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  # defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Show all hidden files
  defaults write com.apple.finder AppleShowAllFiles YES

  # Turn off Force click and haptic feedback
  defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -int 1

  # Set computer appearance to dark mode Control + option + t

  Sudo defaults write /Library/Preferences/.GloobalPreferences.plist_HIEnableThemeSwitchHotKey -bool true

  # Enable text select from  quicklook windows
  Defaults write com.apple.finderQLEnableTextSelection -bool TRUE;killall Finder

  # Always show the User Library Folder
  chflags nohidden ~/Library

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Enable AirDrop over Ethernet and on unsupported Macs running Lion
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
  #no screensaver
  defaults write com.apple.screensaver idleTime 0
  # User Logout
  osascript -e 'tell application "system Events" to log out'
  }

################################################################################

###############################################################################
# Check for Homebrew, install if we don't have it
if [[ $( Command -v brew) == "" ]]; then
    echo "Installing homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brewIns

else
    # echo "Updating Homebrew"
    # brew update
    compSet
fi
