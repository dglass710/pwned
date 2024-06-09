# Dynamically set the project directory to the directory of this script
PROJECT_DIR="$(dirname "$0")"

# Define constants
DOCKER_IMAGE="dglass710/pwned"
LOG_FILE="$PROJECT_DIR/updates.log"
PYTHON_PATH="/usr/local/bin/py"

# Dynamically find the Python interpreter
if command -v python3 >/dev/null 2>&1; then
	PYTHON_PATH=$(which python3)
elif command -v python >/dev/null 2>&1; then
	PYTHON_PATH=$(which python)
else
	echo "Python interpreter not found."
	exit 1
fi
