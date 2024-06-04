#!/bin/bash

# Function to log messages with a timestamp and script name
log_message() {
    local script_name="$1"
    local message="$2"
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$script_name] $message" >> $LOG_FILE
}

# Function to start logging a step with timing
log_step_start() {
    local step="$1"
    log_message $SCRIPT_NAME "Starting $step"
    echo "$(date +"%s")" > "/tmp/${step}_start_time"
}

# Function to end logging a step with timing
log_step_end() {
    local step="$1"
    local start_time=$(cat "/tmp/${step}_start_time")
    local end_time=$(date +"%s")
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    log_message $SCRIPT_NAME "Completed $step in ${minutes} minutes and ${seconds} seconds"
    rm "/tmp/${step}_start_time"
}

# Function to download the latest passwords
download_passwords() {
    log_message $SCRIPT_NAME "Downloading the latest passwords"
    echo "Downloading the latest passwords..."
    haveibeenpwned-downloader "$PASSWORD_BASENAME" -o -p 64 # You can get this tool at github.com/HaveIBeenPwned/PwnedPasswordsDownloader
}

# Function to build the database
build_database() {
    log_message $SCRIPT_NAME "Generating database"
    echo "Building the database..."
    $PYTHON_PATH txt_to_db_no_progress.py

    # Remove the password file after building the database
    log_message $SCRIPT_NAME "Removing latest passwords"
    echo "Removing the password file..."
    rm "$PASSWORD_FILE"
}

# Function to build the database with progress updates
build_database_progress() {
    log_message $SCRIPT_NAME "Generating database"
    echo "Building the database..."
    $PYTHON_PATH txt_to_db.py

    # Remove the password file after building the database
    log_message $SCRIPT_NAME "Removing latest passwords"
    echo "Removing the password file..."
    rm "$PASSWORD_FILE"
}

# Function to prune Docker images with a specific name
prune_docker_images() {
    log_message $SCRIPT_NAME "Pruning Docker images with name '${DOCKER_IMAGE%%:*}'"
    echo "Pruning Docker images with name '${DOCKER_IMAGE%%:*}'"

    # Get the list of image IDs with the specified name
    image_ids=$(docker images --filter=reference="${DOCKER_IMAGE%%:*}:*" --format '{{.ID}}')

    if [ -n "$image_ids" ]; then
        # Remove the images
        docker rmi -f $image_ids
    else
        echo "No images found with the name '${DOCKER_IMAGE%%:*}'"
    fi
}
