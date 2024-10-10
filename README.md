# Swap File Management Script

## Overview

This is a simple Bash script that allows you to manage swap files on your Ubuntu server. You can create, delete, and view swap files easily through an interactive menu.

### Features
- **Create a Swap File**: Specify the size of the swap file in GB, and the script will create it for you.
- **Delete an Existing Swap File**: Remove the swap file safely to free up disk space.
- **View Current Swap Information**: Display details of any active swap files in a readable table format.

## Prerequisites
- Linux-based operating system (tested on Ubuntu 22).
- Root privileges or `sudo` access.

## Usage

### Run the Script with a Single Command
To run the script directly from GitHub, use the following command:
```sh
bash <(curl -LS https://raw.githubusercontent.com/xmohammad1/make_swap/refs/heads/main/swap.sh)
```

### Menu Options
Upon running the script, you'll be presented with the following menu:
1. **Create swap file**: Prompts you to enter the size in GB and creates the swap file.
2. **Delete swap file**: Deletes the swap file if it exists.
3. **Show swap information**: Displays a table showing current swap usage.
4. **Exit**: Exits the script.

### Example
- To create a 2GB swap file, select option **1** and enter `2` when prompted for the swap size.
- To view swap details, select option **3**.
- To delete the created swap file, select option **2**.

## Important Notes
- The script requires root privileges to manage the swap file. You'll be prompted for your password if you run the script with `sudo`.
- Be cautious when using swap files on SSD drives as it may reduce their lifespan due to wear.

## License
This script is open-source and available under the MIT License.

## Contributions
Feel free to fork the repository and submit pull requests if you would like to contribute or improve the script.

## Author
[**Mohammad**](https://github.com/xmohammad1)
