#!/usr/bin/env bash

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
	# If the value is true, replace it with the lowercase version and without quotes
	if [ "$value" = "true" ]; then
		sed -i "s/^${key} = .*/${key} = ${value}/" "$config_file"
	else
		# Use sed to insert or replace the configuration value
		sed -i "/^${key}/c ${key} = \"${value}\"" "$config_file"
	fi

}

function modify_config_files() {
	orientation="$1"
	# TODO If you know a simple method to write on toml files, please submit a change
	check_toml_key_exists "main.plugins.display-password.enabled" "$CONFIG_FILE"
	check_toml_key_exists "main.plugins.display-password.orientation" "$CONFIG_FILE"

	# Set the configuration values
	edit_configuration_values "main.plugins.display-password.enabled" true "$CONFIG_FILE"
	edit_configuration_values "main.plugins.display-password.orientation" "$orientation" "$CONFIG_FILE"
}

# Main

# Check that the script is running as root

if [ "$EUID" -ne 0 ]; then
	echo "[ ! ] This script need to be run as root"
	exit 0
fi

installation_dir=$(awk '/^main.custom_plugins = / {print $3}' "$CONFIG_FILE")
if [ -z "$installation_dir" ]; then
	echo "[ ! ] The installation directory was not found in the configuration file"
	read -r -p "Please enter the installation directory: [/usr/local/share/pwnagotchi/custom_plugins]" installation_dir
fi
if [ -z "$installation_dir" ]; then
	installation_dir="/usr/local/share/pwnagotchi/custom_plugins"
fi
installation_dir=${installation_dir//\"/}
echo "[ + ] Creating symbolic link to ${installation_dir}"
ln -sf "$(pwd)/display-password.py" "${installation_dir}/display-password.py"

echo "[ + ] Backing up configuration files..."
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
read -r -p "Do you want the horizontal or vertical orientation? [H/v] " orientation
if [ "${orientation^^}" = "V" ]; then
	orientation="vertical"
else
	orientation="horizontal"
fi
echo "[ ~ ] Modifying configuration files..."
modify_config_files $orientation
echo "[ * ] Done! Please restart your pwnagotchi daemon to apply changes"
echo "[ * ] You can do so with"
echo "[ > ] sudo systemctl restart pwnagotchi"
