#!/bin/bash

# Shell script to configure the cedilla character (ç) on US keyboards in Linux systems. 
# This script automates the necessary system changes.
#
# Author: amlucas0xff
# Date: 2024-10-18
# Version: 1.0
# License: MIT
# Github: https://github.com/amlucas0xff
#
# Features
# - Automated Setup: Configures the system to support the cedilla character with minimal effort.
# - Backup Creation: Automatically backs up original system files before making changes.
# - Idempotent Execution: Checks if configurations are already applied to avoid redundant actions.
#
# Requirements
# - Operating System: Linux (Tested on Manjaro Linux 24.1.1)
# - Permissions: Must be run as root (sudo or root user)
# - Dependencies: Standard Unix utilities (bash, grep, awk, sed, etc.)
#
# Installation
# $ git clone https://github.com/amlucas0xff/manjaro.git
# $ cd manjaro
# $ chmod +x configure_cedilla.sh
# $ sudo ./configure_cedilla.sh

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Requires root privilege."
    exit 1
fi

DATE_TIME=$(date +'%Y%m%d_%H%M')
GTK3_IMMODULES="/usr/lib/gtk-3.0/3.0.0/immodules.cache"
GTK2_IMMODULES="/usr/lib/gtk-2.0/2.10.0/immodules.cache"
COMPOSE_FILE="/usr/share/X11/locale/en_US.UTF-8/Compose"
ENV_FILE="/etc/environment"
REQUIRED_FILES=("$GTK3_IMMODULES" "$GTK2_IMMODULES" "$COMPOSE_FILE" "$ENV_FILE")

check_required_files() {
    for FILE in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$FILE" ]; then
            echo "Required file $FILE not found. Exiting."
            exit 1
        fi
    done
}

check_already_configured() {
    echo "Checking if configurations are already applied..."
    CONFIGURED=1

    # Check GTK immodules.cache files
    for GTK_FILE in "$GTK3_IMMODULES" "$GTK2_IMMODULES"; do
        if [[ "$GTK_FILE" == *"gtk-2"* ]]; then
            GTK_VERSION="gtk20"
        elif [[ "$GTK_FILE" == *"gtk-3"* ]]; then
            GTK_VERSION="gtk30"
        else
            echo "Unknown GTK version in $GTK_FILE"
            CONFIGURED=0
            break
        fi

        # Adjusted grep pattern to match the actual line in the file
        if grep -q "^\"cedilla\" \"Cedilla\" \"$GTK_VERSION\" \"/usr/share/locale\" \".*:en\"" "$GTK_FILE"; then
            :
        else
            CONFIGURED=0
            break
        fi
    done

    # Check Compose file for absence of 'ć' and 'Ć'
    if grep -q 'ć\|Ć' "$COMPOSE_FILE"; then
        CONFIGURED=0
    fi

    # Check /etc/environment for required variables
    if ! grep -qxF 'GTK_IM_MODULE=cedilla' "$ENV_FILE" || ! grep -qxF 'QT_IM_MODULE=cedilla' "$ENV_FILE"; then
        CONFIGURED=0
    fi

    if [ "$CONFIGURED" -eq 1 ]; then
        echo "All configurations are already applied. No changes needed."
        exit 0
    else
        echo "Configurations not fully applied. Proceeding with updates."
    fi
}

# Function to modify GTK immodules.cache files
modify_gtk_immodules() {
    echo "Modifying GTK immodules.cache files..."
    for GTK_FILE in "$GTK3_IMMODULES" "$GTK2_IMMODULES"; do
        if [[ "$GTK_FILE" == *"gtk-2"* ]]; then
            GTK_VERSION="gtk20"
        elif [[ "$GTK_FILE" == *"gtk-3"* ]]; then
            GTK_VERSION="gtk30"
        else
            echo "Unknown GTK version in $GTK_FILE"
            continue
        fi

        # Backup the file
        cp "$GTK_FILE" "$GTK_FILE.$DATE_TIME.bak"

        # Modify the line by appending ':en' if not already present
        awk -i inplace 'BEGIN{OFS=FS=" "} $1=="\"cedilla\"" && $2=="\"Cedilla\"" && $3=="\"'${GTK_VERSION}'\"" && $4=="\"/usr/share/locale\"" { sub(/"$/, ":en\"", $NF) }1' "$GTK_FILE"

        echo "Modified: $GTK_FILE (Backup: $GTK_FILE.$DATE_TIME.bak)"
    done
}

# Function to modify the Compose file
modify_compose_file() {
    echo "Modifying Compose file..."
    sed -i".$DATE_TIME.bak" 's/ć/ç/g; s/Ć/Ç/g' "$COMPOSE_FILE" && \
    echo "Modified: $COMPOSE_FILE (Backup: $COMPOSE_FILE.$DATE_TIME.bak)"
}

# Function to update /etc/environment
update_environment() {
    echo "Updating /etc/environment..."
    cp "$ENV_FILE" "$ENV_FILE.$DATE_TIME.bak" && echo "Backup created: $ENV_FILE.$DATE_TIME.bak"
    CHANGED=0

    if ! grep -qxF 'GTK_IM_MODULE=cedilla' "$ENV_FILE"; then
        echo 'GTK_IM_MODULE=cedilla' >> "$ENV_FILE"
        CHANGED=1
    fi

    if ! grep -qxF 'QT_IM_MODULE=cedilla' "$ENV_FILE"; then
        echo 'QT_IM_MODULE=cedilla' >> "$ENV_FILE"
        CHANGED=1
    fi

    if [ "$CHANGED" -eq 1 ]; then
        echo "Updated: $ENV_FILE"
    else
        echo "No changes made to $ENV_FILE"
    fi
}

# Main script execution
check_required_files
check_already_configured
modify_gtk_immodules
modify_compose_file
update_environment

echo "Configuration completed successfully. Reboot required."