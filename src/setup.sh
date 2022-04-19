#!/bin/bash

main() {
	shell_settings
	declare_globals
	firefox_lauch
	firefox_profile
	arkenfox_setup
}

shell_settings() {
	set -euo pipefail
	trap finish EXIT
	IFS=$'\n\t'
}

declare_globals() {
	arkenfox_branch=https://raw.githubusercontent.com/arkenfox/user.js/master
}

firefox_lauch() {
	echo "Launching Firefox"
	firefox &
	declare -i PID=$!

	read -rp "Press enter to continue"

	kill ${PID}
}

firefox_profile() {
	profile_ini="${HOME}/.mozilla/firefox/profiles.ini"

	echo "Firefox Profile Selector"
	mapfile -t options < <(grep '^Path=*' "${profile_ini}" | cut -d= -f2) 
	prompt="Please select a profile:"
	PS3="$prompt "
	select opt in "${options[@]}" "Quit" ; do 
		if (( REPLY == 1 + "${#options[@]}" )) ; then
			exit
		elif (( REPLY > 0 && REPLY <= "${#options[@]}" )) ; then
			profile_path="${HOME}/.mozilla/firefox/${opt}"
			break
		else
			echo "Invalid option. Try another one."
		fi
	done
}

arkenfox_setup() {
	arkenfox_updater="${profile_path}/updater.sh"
	arkenfox_prefscleaner="${profile_path}/prefsCleaner.sh"

	curl "${arkenfox_branch}/updater.sh" > "${arkenfox_updater}"
	curl "${arkenfox_branch}/prefsCleaner.sh" > "${arkenfox_prefscleaner}"

	sudo chmod +x "${arkenfox_updater}"
	sudo chmod +x "${arkenfox_prefscleaner}"

	cp "user-overrides.js" "${profile_path}"

	cd "${profile_path}"
	./updater.sh
	./prefsCleaner.sh
}

finish() {
	echo "Firefox Setup Complete"
}

main
