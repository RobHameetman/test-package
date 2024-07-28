#!/bin/bash

###################################
#              ABOUT              #
###################################
# This script is used to install the latest dependencies without having to use
# the `@latest` tag in package.json and inject placeholder values in certain
# templated files, like the README and some of the CI/CD configuration files. It is
# intended to be run once after cloning a new project.

###################################
# This is a common way to start bash scripts. The first line ensures that the
# shell script will abort if a command fails. The second line ensures that if a
# command that is part of a pipeline fails, then the shell script fails. Even
# when the set -e option is set, only the final command in a pipeline will cause
# the script to exit if it fails.
set -e
set -o pipefail

###################################
#            DEFAULTS             #
###################################
rootDir=$(basename "$PWD")
origin=$(git config --get remote.origin.url)

defaultOrg=$(echo "$origin" | sed -e 's/.*://g' -e 's/\.git$//' -e 's/:/\//' -e 's/\/.*//')
defaultRepo=$(echo "$origin" | awk -F/ '{print $2}' | sed -e 's/\.git$//' )
dedfaultScope='rob.hameetman'

jqInstallAttempts=0

###################################
#            CONSTANTS            #
###################################
YES_REGEX='^[yY]([eE][sS])?$'
NO_REGEX='^[nN]([oO])?$'

SUCCESS=false

###################################
#          PACKAGE.JSON           #
###################################
packageJsonOrder='{
	name,
	version,
	type,
	description,
	author,
	homepage,
	license,
	private,
	main,
	module,
	types,
	repository,
	bugs,
	engines,
	scripts,
	devDependencies,
	release
}'

###################################
#             OPTIONS             #
###################################
scope=$defaultScope
name=$rootDir
org=$defaultOrg
repo=$defaultRepo

nodejs=$(node -v)
nodejs=${nodejs#"v"}
node="${nodejs%%.*}"

npmjs=$(npm -v)
npm="${npmjs%%.*}"

placeholders=(
	"{{name}}"
	"{{org}}"
	"{{repo}}"
	"{{description}}"
	"{{nodejs}}"
	"{{node}}"
	"{{npm}}"
)

###################################
#            UTILITIES            #
###################################
restore() {
	if ! $SUCCESS; then
		if [ -d "node_modules/" ]; then
			rm -rf node_modules/
		fi

		if [ -f "package-lock.json" ]; then
			rm package-lock.json
		fi

		if [ -f ".env" ]; then
			rm .env
		fi

		git restore .
	fi
}

# Find all files in the project, excluding the following:
# - .git/
# - .github/img/logo.png
# - .github/workflows/_schema.json
# - .vscode/settings.json
# - node_modules/
# - public/favicon.ico
# - scripts/setup.sh
# - package.json
# - package-lock.json
findAll() {
	local files=()
	local tmp_file=$(mktemp)

	find . -type f \
		-not \( -path "./.git/*" -o -path "./node_modules/*" -o -path "./scripts/setup.sh" -o -path "./.github/img/logo.png" -o -path "./.github/workflows/_schema.json" -o -path "./.vscode/settings.json" -o -path "./public/favicon.ico" \) \
		-not \( -name "package.json" -o -name "package-lock.json" \) -print0 \
		> "$tmp_file"

	while IFS= read -r -d '' file; do
		files+=("$file")
	done < "$tmp_file"

	rm "$tmp_file"

	echo "${files[@]}"
}

# Inject placeholder values in package.json
inject() {
	local filename=$1
	local replace=("${@:2}")
	local file

	# Read the file
	file=$(cat "$filename")
	updated=$file

	# Replace each placeholder with its value
	for placeholder in "${replace[@]}"; do
		key="${placeholder#"{{"}"
		key="${key%"}}"}"
		value="${!key}"

		updated="${updated//\{\{${key}\}\}/${value}}"
	done

	# Overwrite the file with the updated contents
	printf '%s\n' "$updated" > "$filename"
}

###################################
#           OPERATIONS            #
###################################
updatePackageJson() {
	local packageJsonPlaceholders=(
		"{{scope}}"
		"{{name}}"
		"{{org}}"
		"{{repo}}"
		"{{description}}"
	)

	inject "package.json" "${packageJsonPlaceholders[@]}"
}

updateRemainingFiles() {
	local files=$(findAll)

	for file in $files; do
		inject $file "${placeholders[@]}"
	done
}

correctPackageJsonOrder() {
	local packageJson="package.json"
	local tmpFile=$(mktemp)

	jq "$packageJsonOrder" $packageJson > $tmpFile
	mv "$tmpFile" "$packageJson"
}

installJqIfNecessary() {
  if ! command -v jq &> /dev/null; then
    echo "'jq' is not installed but is required for this script."

    read -p "Would you like to install 'jq'? (Y/n): " getJq
		getJq=${getJq:-"Y"}

    case $getJq in
			# We cannot use $YES_REGEX and $NO_REGEX here because we can only use
			# pattern matching in cases statements.
      [Yy]*)
        echo "Installing 'jq'..."
        brew install jq
				;;
      [Nn]*)
        echo "'jq' is not installed. Exiting..."
				exit 0
				;;
      *)
				if [ $jqInstallAttempts -ne 3 ]; then
					echo "Invalid input. 'jq' is not installed but is required for this script. Please answer with 'y' or 'n'."
					jqInstallAttempts=$((jqInstallAttempts + 1))

					installJqIfNecessary
				else
					exit 0
				fi
				;;
    esac
	fi
}

getSetupOptions() {
	# Get placeholder values
	read -p "Enter the package name ($rootDir): " name
	read -p "Enter the package scope (@$defaultScope): @" scope
	read -p "Enter a 1-2 sentence description: " description

	scope=${scope:-$defaultScope}
	name=${name:-$rootDir}
	org=${org:-$defaultOrg}
	repo=${repo:-$defaultRepo}
}

###################################
#             SCRIPT              #
###################################

# Clear the terminal
clear

# Cleanup on interrupt or terminate signals and on exit.
trap "restore" INT TERM EXIT

# Check to see that the 'jq' command is installed and install it if necessary.
installJqIfNecessary

# Get setup options for placeholders
getSetupOptions

# Inject placeholder values for each placeholder in package.json
updatePackageJson

# Fix devDependencies in package.json
# correctPackageJsonOrder

# Inject placeholder values for each remaining placeholder
updateRemainingFiles

SUCCESS=true
echo "Setup complete!"
