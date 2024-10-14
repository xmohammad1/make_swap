#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined var, and pipe failures

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color


# Log levels
readonly LOG_ERROR="ERROR"
readonly LOG_WARN="WARN"
readonly LOG_INFO="INFO"
readonly LOG_SUCCESS="SUCCESS"

# Function to print colored log messages
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    case "$level" in
        "$LOG_ERROR") echo -e "${RED}[$timestamp] $level: $message${NC}" ;;
        "$LOG_WARN")  echo -e "${YELLOW}[$timestamp] $level: $message${NC}" ;;
        "$LOG_INFO")  echo -e "${BLUE}[$timestamp] $level: $message${NC}" ;;
        "$LOG_SUCCESS") echo -e "${GREEN}[$timestamp] $level: $message${NC}" ;;
        *) echo -e "[$timestamp] $level: $message" ;;
    esac
}

# Function to validate numeric input
validate_numeric() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        log "$LOG_ERROR" "Please enter a valid number."
        return 1
    fi
    return 0
}

# Function to validate swap file name
validate_swap_name() {
    if [[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    else
        log "$LOG_ERROR" "Invalid swap file name. Use only letters, numbers, underscores, and hyphens."
        return 1
    fi
}

create_swap() {
    echo -e "\n${CYAN}=== Create Swap File ===${NC}"
    while true; do
        read -p "$(echo -e ${WHITE}"Enter the name of the swap file (e.g., swapfile1): "${NC})" swap_name
        if ! validate_swap_name "$swap_name"; then
            continue
        fi
        SWAP_FILE="/$swap_name"
        if [[ -e "$SWAP_FILE" ]]; then
            log "$LOG_ERROR" "File $SWAP_FILE already exists. Please choose a different name."
        else
            break
        fi
    done

    while true; do
        read -p "$(echo -e ${WHITE}"Enter the size of the swap file in GB: "${NC})" swap_size
        if validate_numeric "$swap_size"; then
            break
        fi
    done

    log "$LOG_INFO" "Creating swap file of size ${swap_size}G..."
    if ! sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=$(( swap_size * 1024 )) status=progress; then
        log "$LOG_ERROR" "Failed to create swap file."
        return 1
    fi
    sudo chmod 600 $SWAP_FILE
    if ! sudo mkswap $SWAP_FILE > /dev/null; then
        log "$LOG_ERROR" "Failed to set up swap space."
        return 1
    fi
    if ! sudo swapon $SWAP_FILE > /dev/null; then
        log "$LOG_ERROR" "Failed to activate swap space."
        return 1
    fi
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
    log "$LOG_SUCCESS" "Swap file created successfully."
}

delete_swap() {
    echo -e "\n${CYAN}=== Delete Swap File ===${NC}"
    show_swap   
    if ! sudo swapon --show | grep -q 'NAME'; then
        log "$LOG_WARN" "No swap files found to delete."
        return 1
    fi

    while true; do
        read -p "$(echo -e ${WHITE}"Enter the name of the swap file to delete (e.g., swapfile1): "${NC})" swap_name
        if validate_swap_name "$swap_name"; then
            break
        fi
    done

    SWAP_FILE="/$swap_name"

    if [ ! -f "$SWAP_FILE" ]; then
        log "$LOG_ERROR" "Swap file $SWAP_FILE not found."
        return 1
    fi

    log "$LOG_INFO" "Deleting swap file..."
    if ! sudo swapoff $SWAP_FILE; then
        log "$LOG_ERROR" "Failed to deactivate swap file."
        return 1
    fi
    if ! sudo rm $SWAP_FILE; then
        log "$LOG_ERROR" "Failed to remove swap file."
        return 1
    fi
    if ! sudo sed -i "\|$SWAP_FILE|d" /etc/fstab; then
        log "$LOG_ERROR" "Failed to update /etc/fstab."
        return 1
    fi
    log "$LOG_SUCCESS" "Swap file deleted successfully."
}

show_swap() {
    if sudo swapon --show | grep -q 'NAME'; then
        log "$LOG_INFO" "Displaying current swap information:"
        swapon --show | awk -v green="${GREEN}" -v white="${WHITE}" -v nc="${NC}" '
        BEGIN {
            print green"|-----------------------------------------------|"nc
            printf green"|"white" %-10s | %-6s | %-6s | %-6s | %-6s"green"|\n"nc, "NAME", "TYPE", "SIZE", "USED", "PRIO"
            print green"|-----------------------------------------------|"nc
        }
        NR > 1 {
            gsub("^/", "", $1)
            printf ""green"|"nc" %-10s "white"|"nc" %-6s "white"|"nc" %-6s "white"|"nc" %-6s "white"|"nc" %-6s"green"|\n"nc"", $1, $2, $3, $4, $5 
        }
        END {
            print green"|-----------------------------------------------|"nc
        }'
    else
        log "$LOG_WARN" "No swap file found."
    fi
}

show_help() {
    echo -e "${PURPLE}Swap Management Script {NC}"
    echo
    echo -e "${WHITE}Usage: $0 [OPTION]${NC}"
    echo "Options:"
    echo -e "  ${GREEN}-c, --create${NC}   Create a new swap file"
    echo -e "  ${RED}-d, --delete${NC}   Delete an existing swap file"
    echo -e "  ${BLUE}-s, --show${NC}     Show current swap information"
    echo -e "  ${YELLOW}-h, --help${NC}     Display this help message"
}

# Function to display a fancy header
display_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║         Swap Management Script            ║"
    echo -e "║               ${PURPLE}@xmohammad1${NC}${BLUE}                 ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main menu function
main_menu() {
    while true; do
        clear
        display_header
        echo -e "\n${CYAN}Main Menu${NC}"
        echo -e "${PURPLE}1)${NC} Create swap file"
        echo -e "${PURPLE}2)${NC} Delete swap file"
        echo -e "${PURPLE}3)${NC} Show swap information"
        echo -e "${PURPLE}4)${NC} Exit"
        read -p "$(echo -e ${WHITE}"Enter your choice [1-4]: "${NC})" choice
        case $choice in
            1) create_swap ;;
            2) delete_swap ;;
            3) show_swap ;;
            4) log "$LOG_INFO" "Exiting."; exit 0 ;;
            *) log "$LOG_WARN" "Invalid choice. Please choose a valid option." ;;
        esac
        echo
        read -p "$(echo -e ${YELLOW}"Press Enter to continue"${NC})"
    done
}

# Parse command-line arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        -c|--create) create_swap; exit 0 ;;
        -d|--delete) delete_swap; exit 0 ;;
        -s|--show) show_swap; exit 0 ;;
        -h|--help) show_help; exit 0 ;;
        *) log "$LOG_ERROR" "Unknown option: $1"; show_help; exit 1 ;;
    esac
else
    main_menu
fi
