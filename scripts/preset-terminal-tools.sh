#!/bin/bash
#=================================================
# File name: preset-terminal-tools.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

# Install zsh as default shell
mkdir -p files/root
(
    cd files/root

    ## Install oh-my-zsh
    # Clone oh-my-zsh repository
    git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh

    # Install extra plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
    # Get .zshrc dotfile
    cp ../../../files/.zshrc .
)
