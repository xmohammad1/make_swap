#!/bin/bash

create_swap() {
    read -p "Enter the name of the swap file (e.g., swapfile1): " swap_name
    SWAP_FILE="/$swap_name"

    read -p "Enter the size of the swap file in GB: " swap_size
    echo "Creating swap file of size ${swap_size}G..."
    sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=$(( swap_size * 1024 )) status=none
    sudo chmod 600 $SWAP_FILE
    sudo mkswap $SWAP_FILE > /dev/null
    sudo swapon $SWAP_FILE > /dev/null
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
    echo "Swap file created successfully."
}

delete_swap() {
    show_swap   
    if sudo swapon --show | grep -q 'NAME'; then
    read -p "Enter the name of the swap file to delete (e.g., swapfile1): " swap_name
    SWAP_FILE="/$swap_name"
    fi
    if [ -f "$SWAP_FILE" ]; then
        echo "Deleting swap file..."
        sudo swapoff $SWAP_FILE
        sudo rm $SWAP_FILE
        sudo sed -i "\|$SWAP_FILE|d" /etc/fstab
        echo "Swap file deleted successfully."
    else
        echo "No swap file found to delete."
    fi
}

show_swap() {
    if sudo swapon --show | grep -q 'NAME'; then
        echo "Displaying current swap information:"
        swapon --show | awk '
        BEGIN {
            print "|-----------------------------------------------|"
            printf "| %-10s | %-6s | %-6s | %-6s | %-6s|\n", "NAME", "TYPE", "SIZE", "USED", "PRIO" 
            print "|-----------------------------------------------|"
        }
        NR > 1 {
            gsub("^/", "", $1)
            printf "| %-10s | %-6s | %-6s | %-6s | %-6s|\n", $1, $2, $3, $4, $5 
        }
        END {
            print "|-----------------------------------------------|"
        }'
    else
        echo "No swap file found."
    fi
}

while true; do
    # Main menu
    echo "Choose an option:"
    echo "1. Create swap file"
    echo "2. Delete swap file"
    echo "3. Show swap information"
    echo "4. Exit"
    read -p "Enter your choice [1-4]: " choice

    case $choice in
        1)
            create_swap
            read -p "Press Enter to continue"
            ;;
        2)
            delete_swap
            read -p "Press Enter to continue"
            ;;
        3)
            show_swap
            read -p "Press Enter to continue"
            ;;
        4)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please choose a valid option."
            ;;
    esac

done
