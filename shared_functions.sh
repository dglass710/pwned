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
    log_message $SCRIPT_NAME "Started $step"
    echo "$(date +"%s")" > "/tmp/${step}_start_time"
}

# Function to end logging a step with timing
log_step_end() {
    local step="$1"
    local start_time=$(cat "/tmp/${step}_start_time")
    local end_time=$(date +"%s")
    local duration=$((end_time - start_time))
    local total_minutes=$((duration / 60))
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    if [ $duration -ge 3600 ]; then
    	log_message $SCRIPT_NAME "Completed $step in ${hours} hours, ${minutes} minutes and ${seconds} seconds"
    else
    	log_message $SCRIPT_NAME "Completed $step in ${total_minutes} minutes and ${seconds} seconds"
    fi
    
    rm "/tmp/${step}_start_time"
    echo "$(date +"%s")" > "/tmp/${step}_start_time"
}

# Function to download the latest passwords
download_passwords() {
    echo "Downloading the latest passwords..."
    haveibeenpwned-downloader "$PASSWORD_BASENAME" -o -p 64 # You can get this tool at github.com/HaveIBeenPwned/PwnedPasswordsDownloader
}

# Function to build the database
build_database() {
    echo "Building the database..."
    $PYTHON_PATH txt_to_db_no_progress.py
}

# Remove the password file after building the database
remove_passwords() {
    log_message $SCRIPT_NAME "Removing latest passwords"
    echo "Removing the password file..."
    rm "$PASSWORD_FILE"
}

# Function to build the database with progress updates
build_database_progress() {
    echo "Building the database..."
    $PYTHON_PATH txt_to_db.py

    # Remove the password file after building the database
    log_message $SCRIPT_NAME "Removing latest passwords"
    echo "Removing the password file..."
    rm "$PASSWORD_FILE"
}

# Function to prune Docker images with a specific name, keeping only the most recent one
prune_docker_images() {
    log_message $SCRIPT_NAME "Pruning Docker images with name '${DOCKER_IMAGE%%:*}'"
    echo "Pruning Docker images with name '${DOCKER_IMAGE%%:*}'"

    # Get the list of image IDs and creation dates sorted by creation date (newest first)
    image_info=$(docker images --filter=reference="${DOCKER_IMAGE%%:*}:*" --format '{{.ID}} {{.CreatedAt}}' | sort -rk 2)

    # Extract the image IDs
    image_ids=$(echo "$image_info" | awk '{print $1}')

    # Exclude the first image ID (the most recent one)
    old_image_ids=$(echo "$image_ids" | tail -n +2)
    
    if [ -n "$old_image_ids" ]; then
        # Remove the older images, keep the most recent one
        docker rmi -f $old_image_ids
    else
        echo "No older images found to remove."
    fi
}
