#!/bin/sh -e

. ./common.sh



cleanup_system() {
    printf "%b\n" "${YELLOW}Performing system cleanup...${RC}"
    # Fix Missions control to NEVER rearrange spaces
    printf "%b\n" "${CYAN}Fixing Mission Control to never rearrange spaces...${RC}"
    sudo defaults write com.apple.dock mru-spaces -bool false

    # Apple Intelligence Crap
    sudo defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"

    # Empty Trash
    printf "%b\n" "${CYAN}Emptying Trash...${RC}"
    sudo rm -rf ~/.Trash/*

    # Remove old log files
    printf "%b\n" "${CYAN}Removing old log files...${RC}"
    find /var/log -type f -name "*.log" -mtime +30 -exec sudo rm -f {} \;
    find /var/log -type f -name "*.old" -mtime +30 -exec sudo rm -f {} \;
    find /var/log -type f -name "*.err" -mtime +30 -exec sudo rm -f {} \;
    
}


checkPackageManager() {
    ## Check if brew is installed
    if command_exists "brew"; then
        printf "%b\n" "${GREEN}Homebrew is installed${RC}"
    else
        printf "%b\n" "${RED}Homebrew is not installed${RC}"
        printf "%b\n" "${YELLOW}Installing Homebrew...${RC}"
        
        # Setup askpass helper for automated password handling
        setup_askpass
        
        # Use sudo with askpass for non-interactive installation
        SUDO_ASKPASS="$ASKPASS_SCRIPT" sudo -A /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        install_result=$?
        
        # Cleanup askpass helper
        cleanup_askpass
        
        if [ $install_result -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Homebrew${RC}"
            exit 1
        fi
        
        # Add Homebrew to PATH for the current session
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        trap cleanup_askpass EXIT INT TERM
    fi
}

fixfinder () {
    printf "%b\n" "${YELLOW}Applying global theme settings for Finder...${RC}"

    # Set the default Finder view to list view
    printf "%b\n" "${CYAN}Setting default Finder view to list view...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Configure list view settings for all folders
    printf "%b\n" "${CYAN}Configuring list view settings for all folders...${RC}"
    # Set default list view settings for new folders
    $ESCALATION_TOOL defaults write com.apple.finder FK_StandardViewSettings -dict-add ListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'
    
    # Clear existing folder view settings to force use of default settings
    printf "%b\n" "${CYAN}Clearing existing folder view settings...${RC}"
    $ESCALATION_TOOL defaults delete com.apple.finder FXInfoPanesExpanded 2>/dev/null || true
    $ESCALATION_TOOL defaults delete com.apple.finder FXDesktopVolumePositions 2>/dev/null || true
    
    # Set list view for all view types
    printf "%b\n" "${CYAN}Setting list view for all folder types...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder FK_StandardViewSettings -dict-add ExtendedListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'
    
    # Sets default search scope to the current folder
    printf "%b\n" "${CYAN}Setting default search scope to the current folder...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Remove trash items older than 30 days
    printf "%b\n" "${CYAN}Removing trash items older than 30 days...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"

    # Remove .DS_Store files to reset folder view settings
    printf "%b\n" "${CYAN}Removing .DS_Store files to reset folder view settings...${RC}"
    find ~ -name ".DS_Store" -type f -delete 2>/dev/null || true

    # Show all filename extensions
    printf "%b\n" "${CYAN}Showing all filename extensions in Finder...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Set the sidebar icon size to small
    printf "%b\n" "${CYAN}Setting sidebar icon size to small...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

    # Show status bar in Finder
    printf "%b\n" "${CYAN}Showing status bar in Finder...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder ShowStatusBar -bool true

    # Show path bar in Finder
    printf "%b\n" "${CYAN}Showing path bar in Finder...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder ShowPathbar -bool true

    # Clean up Finder's sidebar
    printf "%b\n" "${CYAN}Cleaning up Finder's sidebar...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder SidebarDevicesSectionDisclosedState -bool true
    $ESCALATION_TOOL defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool true
    $ESCALATION_TOOL defaults write com.apple.finder SidebarShowingiCloudDesktop -bool false

    # Restart Finder to apply changes
    printf "%b\n" "${GREEN}Finder has been restarted and settings have been applied.${RC}"
    $ESCALATION_TOOL killall Finder
}

removeAnimations() {
    printf "%b\n" "${YELLOW}Reducing motion and animations on macOS...${RC}"
    
    # Reduce motion in Accessibility settings (most effective)
    printf "%b\n" "${CYAN}Setting reduce motion preference...${RC}"
    $ESCALATION_TOOL defaults write com.apple.universalaccess reduceMotion -bool true
    
    # Disable window animations
    printf "%b\n" "${CYAN}Disabling window animations...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    
    # Speed up window resize animations
    printf "%b\n" "${CYAN}Speeding up window resize animations...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    
    # Disable smooth scrolling
    printf "%b\n" "${CYAN}Disabling smooth scrolling...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
    
    # Disable animation when opening and closing windows
    printf "%b\n" "${CYAN}Disabling window open/close animations...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    
    # Disable animation when opening a Quick Look window
    printf "%b\n" "${CYAN}Disabling Quick Look animations...${RC}"
    $ESCALATION_TOOL defaults write -g QLPanelAnimationDuration -float 0
    
    # Disable animation when opening the Info window in Finder
    printf "%b\n" "${CYAN}Disabling Finder Info window animations...${RC}"
    $ESCALATION_TOOL defaults write com.apple.finder DisableAllAnimations -bool true
    
    # Speed up Mission Control animations
    printf "%b\n" "${CYAN}Speeding up Mission Control animations...${RC}"
    $ESCALATION_TOOL defaults write com.apple.dock expose-animation-duration -float 0.1
    
    # Speed up Launchpad animations
    printf "%b\n" "${CYAN}Speeding up Launchpad animations...${RC}"
    $ESCALATION_TOOL defaults write com.apple.dock springboard-show-duration -float 0.1
    $ESCALATION_TOOL defaults write com.apple.dock springboard-hide-duration -float 0.1
    
    # Disable dock hiding animation
    printf "%b\n" "${CYAN}Disabling dock hiding animations...${RC}"
    $ESCALATION_TOOL defaults write com.apple.dock autohide-time-modifier -float 0
    $ESCALATION_TOOL defaults write com.apple.dock autohide-delay -float 0
    
    # Disable animations in Mail.app
    printf "%b\n" "${CYAN}Disabling Mail animations...${RC}"
    $ESCALATION_TOOL defaults write com.apple.mail DisableReplyAnimations -bool true
    $ESCALATION_TOOL defaults write com.apple.mail DisableSendAnimations -bool true
    
    # Disable zoom animation when focusing on text input fields
    printf "%b\n" "${CYAN}Disabling text field zoom animations...${RC}"
    $ESCALATION_TOOL defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true
    
    printf "%b\n" "${GREEN}Motion and animations have been reduced.${RC}"
    $ESCALATION_TOOL killall Dock
    printf "%b\n" "${YELLOW}Dock Restarted.${RC}"
}


additional_fonts() {
    cd "$HOME" 
    printf "%b\n" "${YELLOW}Install JetBrains Mono Fonts${RC}"
    $ESCALATION_TOOL /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
}



installKitty() {
    if ! brewprogram_exists kitty; then
        brew install --cask kitty
        if [ $? -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Kitty. Please check your Homebrew installation or try again later.${RC}"
            exit 1
        fi
        printf "%b\n" "${GREEN}Kitty installed successfully!${RC}"
    else
        printf "%b\n" "${GREEN}Kitty is already installed.${RC}"
    fi
}

setupKittyConfig() {
    printf "%b\n" "${YELLOW}Copying Kitty configuration files...${RC}"
    if [ -d "${HOME}/.config/kitty" ] && [ ! -d "${HOME}/.config/kitty-bak" ]; then
        cp -r "${HOME}/.config/kitty" "${HOME}/.config/kitty-bak"
    fi
    mkdir -p "${HOME}/.config/kitty/"
    curl -sSLo "${HOME}/.config/kitty/kitty.conf" https://github.com/dombyte/dotfiles/blob/main/kde/.config/kitty/kitty.conf
    curl -sSLo "${HOME}/.config/kitty/current-theme.conf" https://github.com/dombyte/dotfiles/blob/main/kde/.config/kitty/current-theme.conf
    curl -sSLo "${HOME}/.config/kitty/dark-theme.auto.conf" https://github.com/dombyte/dotfiles/blob/main/kde/.config/kitty/dark-theme.auto.conf
}


installVsCodium() {
    if ! brewprogram_exists vscodium; then
        printf "%b\n" "${YELLOW}Installing VS Codium...${RC}"
        brew install --cask vscodium
        if [ $? -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install VS Codium. Please check your Homebrew installation or try again later.${RC}"
            exit 1
        fi
        printf "%b\n" "${GREEN}VS Codium installed successfully!${RC}"
    else
        printf "%b\n" "${GREEN}VS Codium is already installed.${RC}"
    fi

}

installFishShell() {
    if ! brewprogram_exists fish; then
        printf "%b\n" "${YELLOW}Installing Fish Shell...${RC}"
        brew install fish
        if [ $? -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Fish Shell. Please check your Homebrew installation or try again later.${RC}"
            exit 1
        fi
        printf "%b\n" "${GREEN}Fish Shell installed successfully!${RC}"
    else
        printf "%b\n" "${GREEN}Fish Shell is already installed.${RC}"
    fi

}





cleanup_system
checkPackageManager
fixfinder
removeAnimations
additional_fonts
installFishShell
installKitty
setupKittyConfig
installVsCodium
killpid

