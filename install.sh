#!/usr/bin/env bash

INSTALLATION_DIRECTORY="/usr/local/share/pwnagotchi/custom-plugins"
CONFIG_FILE="/etc/pwnagotchi/config.toml"

function user_sleep() {
	sleep 0.5
}

function check_toml_key_exists() {
	local key="$1"
	local config_file="$2"

	if grep -q "^${key}" "$config_file"; then
		echo "The '$key' already exists on $config_file."
	else
		echo "Creating '$key' on $config_file."
		echo "${key} = true " >>"$config_file"
	fi
}

function edit_configuration_values() {
	local key="$1"
	local value="$2"
	local config_file="$3"

	# Escape slashes and dots in the value to avoid issues with sed
	value=$(echo "$value" | sed 's/\//\\\//g')
	value=$(echo "$value" | sed 's/\./\\\./g')
	# Use sed to insert or replace the configuration value
	sed -i "/^${key}/c ${key} = \"${value}\"" "$config_file"
}

function modify_config_files() {
	# TODO If you know a simple method to write on toml files, please submit a change
	check_toml_key_exists "main.plugins.display-password.enabled" "$CONFIG_FILE"
	check_toml_key_exists "main.plugins.display-password.orientation" "$CONFIG_FILE"

	# Set the configuration values
	edit_configuration_values "main.plugins.display-password.enabled" "$CONFIG_FILE"
	edit_configuration_values "main.plugins.display-password.orientation" "$CONFIG_FILE"
}

# Main

# Check that the script is running as root

if [ "$EUID" -ne 0 ]; then
	echo "[ ! ] This script need to be run as root"
	exit 0
fi
echo "[ + ] Creating symbolic link to ${INSTALLATION_DIRECTORY}"
ln -sf "$(pwd)/display-password.py" "${INSTALLATION_DIRECTORY}/display-password.py"
echo "[ + ] Backing up configuration files..."
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
echo "[ ~ ] Modifying configuration files..."
modify_config_files
echo "[ * ] Done! Please restart your pwnagotchi daemon to apply changes"
echo "[ * ] You can do so with"
echo "[ > ] sudo systemctl restart pwnagotchi"
