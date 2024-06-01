# Have I Been Pwned? Offline Project

## Quick Start: Running the Docker Image

If you just want to run the Docker image to check if your passwords have been compromised and don't need the source code or to build anything, follow these steps:

1. **Ensure Docker is Installed and Running**
   - Make sure Docker is installed on your system and the Docker daemon is running.
   
2. **Run the Docker Container**
   - Use the following command to pull and run the Docker image:
   
   ```
   docker run -it dglass710/pwned
   ```
   
   - This command will start an interactive session where you can check your passwords against the offline database.

## Overview

This project provides an offline version of the website HaveIBeenPwned.com. It enables users to check if their passwords have been compromised using data from Troy Hunt's Have I Been Pwned (HIBP) service. The project automates the process of downloading the latest passwords, building a database, and creating a Docker image for easy deployment and usage.

## Project Directory Structure

```
/path/to/your/project/
├── Dockerfile (Dockerfile DSL)
├── HumanTime.py (Python)
├── commaNumber.py (Python)
├── pwned.db (SQLite)
├── pwnedpasswords.txt (Plain Text)
├── Update (Bash)
├── bash (Python)
└── txt_to_db.py (Python)
```

## Project Components

1. **Dockerfile**
    - **Purpose**: Defines the Docker image that includes the Python environment and the pre-built `pwned.db` database.
    - **Usage**: Automatically builds an image that can be run on any system with Docker installed.
    - **Contents**: 
      - Specifies the base image (`bitnami/minideb`).
      - Copies project files into the Docker image.
      - Sets up the environment and dependencies for running the offline HIBP tool.

![Flowchart of Dockerfile Execution](https://thedavidglass.com/assets/project_4/Dockerfile.jpg)

2. **HumanTime.py**
    - **Purpose**: Provides a utility for converting time durations into human-readable formats.
    - **Usage**: Used in the main application to display how long certain operations take.
    - **Functions**:
      - `TimeAutoShort`: Converts time durations into a short, human-readable format.

3. **commaNumber.py**
    - **Purpose**: Contains utilities for formatting numbers with commas and converting numbers to their full name in English.
    - **Usage**: Used in the main application to format the output, making it more readable for users.
    - **Functions**:
      - `commaNumber`: Formats numbers with commas.
      - `sayFullName`: Converts numbers to their full name in English.

4. **pwned.db**
    - **Purpose**: SQLite database containing SHA-1 hashes of compromised passwords and their occurrence counts.
    - **Usage**: Queried by the main application to check if a given password has been compromised.
    - **Contents**: 
      - 4096 tables, each corresponding to the first three characters of the hashes.

![Database Visual](https://thedavidglass.com/assets/project_4/Database-Visual.jpg)

5. **pwnedpasswords.txt**
    - **Purpose**: Text file containing the latest SHA-1 hashes and occurrence counts of compromised passwords.
    - **Usage**: Used to populate the `pwned.db` database.
    - **Contents**: 
      - Each line contains a SHA-1 hash and the number of times it has been found in a data breach, separated by a colon.

6. **Update**
    - **Purpose**: Automates the process of updating the database and Docker image.
    - **Usage**: Run this script to download the latest passwords, rebuild the database, and create a new Docker image.
    - **Configuration**: Users need to update two fields in this script:
      - `PROJECT_DIR`: Absolute path to the project directory.
      - `DOCKER_IMAGE`: Name of the Docker image.
    - **Steps**:
      1. Ensures Docker is running.
      2. Prompts the user to update the database based on its timestamp.
      3. Downloads the latest passwords using HaveIBeenPwned/PwnedPasswordsDownloader.
      4. Removes the old `pwned.db` file.
      5. Runs `txt_to_db.py` to build a new `pwned.db` database.
      6. Removes the `pwnedpasswords.txt` file after building the database.
      7. Builds a new Docker image with the latest database.
      8. Pushes the updated Docker image to Docker Hub.

![Update Script Visual](https://thedavidglass.com/assets/project_4/Update.jpg)

7. **bash**
    - **Purpose**: Main script to interactively check if a password has been compromised.
    - **Usage**: This script is run within the Docker container to query the pwned.db database.
    - **Naming Reason**: Named `bash` because the Dockerfile sets this script as the entry point, replacing the typical bash shell.
    - Steps:
        1. Checks if the script has run previously in the current container by looking for the ran_previously file in the /pwned/ directory.
        2. If not run previously, it creates the ran_previously file and displays a message indicating the preparation of the database.
        3. Connects to the pwned.db database.
        4. Allows the user to enter a password to check if it has been compromised.
        5. Queries the pwned.db database to see if the SHA-1 hash of the entered password is present.
        6. Displays the result to the user.
        7. Continues to prompt the user for passwords until 'done', 'exit', or 'quit' is entered.
        8. Closes the database connection.

![Main Application Visual](https://thedavidglass.com/assets/project_4/Main-Application.jpg)

8. **txt_to_db.py**
    - **Purpose**: Script to create and populate the `pwned.db` database from the `pwnedpasswords.txt` file.
    - **Usage**: Converts the text file into a SQLite database for fast querying.
    - **Steps**:
      1. Creates 4096 tables, each named after the first three characters of the SHA-1 hashes.
      2. Reads the `pwnedpasswords.txt` file line by line.
      3. Populates the appropriate table with the SHA-1 hash and its occurrence count.

![Database Generator Visual](https://thedavidglass.com/assets/project_4/Database-Generator.jpg)

## Usage Instructions

### Setup

- Ensure you have Docker installed and running on your system.
- Clone or download the project directory to your local machine.
- Install the HaveIBeenPwned/PwnedPasswordsDownloader tool available at: [HaveIBeenPwned/PwnedPasswordsDownloader](https://github.com/HaveIBeenPwned/PwnedPasswordsDownloader)
- Ensure the system has at least 100 Gigabytes of free disk space as the text file, database, and image are all about 40 GB each, and having all three present at once might require even more space.

### Configuration

- Open the `Update` script in a text editor.
- Set the `PROJECT_DIR` variable to the absolute path of your project directory.
- Set the `DOCKER_IMAGE` variable to the desired name for your Docker image.

### Running the Script

- Open a terminal and navigate to any directory.
- Make the script executable: `chmod +x /path/to/your/project/Update`
- Run the script: `./path/to/your/project/Update`
- Follow the prompts to update the database and build the Docker image.

### Running the Docker Container

- To run the Docker container and start the interactive password checking script, use:

  ```
  docker run -it dglass710/pwned
  ```

### Reconnecting to the Container

- To reconnect to the running Docker container, use:

  ```
  docker exec -it <container_name> pwned
  ```

- To check the container's name and status:

  ```
  docker container ls -a
  ```

- To start a stopped container:
  ```
  docker start <container_name>
  ```

## Updating the Database and Docker Image

### Automatic Update Process

- The script automates the download of the latest passwords, rebuilding the database, building the Docker image, and pushing the updated image to Docker Hub.

### Manual Update Process

- If needed, you can manually trigger each step by running the respective commands inside the Update script. 
- Navigate to the project directory.
- Change `64` to adjust the number of threads used in the asynchronous download.
    ```
    rm pwnedpasswords.txt || true && \
    haveibeenpwned-downloader pwnedpasswords -o -p 64 && \
    rm pwned.db || true && \
    python3 txt_to_db.py && \
    rm pwnedpasswords.txt || true && \
    docker build -t <docker image name> . && \
    docker push <docker image name>
    ```

## Notes

- Ensure you have the necessary permissions to execute the scripts and access Docker.

- The script `Update` is designed to run on macOS. 
    - It should theoretically run on Linux assuming Docker is already running. However, the `open` command (used to start Docker) may not work on Linux and might return an error code preventing further code execution. 
    - Users should expect potential stability issues on Linux systems as it has not been tested at all. 
    - You can easily modify it for Linux or port it to CMD or Powershell! 

- Regularly update the project by running the `Update` script to incorporate the latest features and security patches.

## Error Handling

### Common Issues

1. **Docker Not Installed**:
   - **Error**: Command `docker: command not found`
   - **Solution**: Install Docker from [Docker's official website](https://www.docker.com/get-started).

2. **Permission Denied**:
   - **Error**: `Permission denied` when running scripts.
   - **Solution**: Ensure you have the necessary permissions to execute the scripts. Use `chmod +x scriptname` to make the script executable.

### Troubleshooting

1. **Docker Container Fails to Start**:
   - **Solution**: Check if Docker is running using `docker ps`. Ensure there are no conflicting containers using `docker container ls -a`.

2. **Database Connection Issues**:
   - **Solution**: Ensure the `pwned.db` file exists and is in the correct directory. Check the database connection settings in the `bash` script.

## Security Considerations

- **Data Handling**: Ensure that sensitive data, such as passwords, are handled securely and not exposed unnecessarily.
- **Docker Security**: Regularly update your Docker installation to mitigate vulnerabilities. Follow best practices for Docker container security.

## Usage Examples

### Checking a Password

1. **Run the Docker Container**:
   ```
   docker run -it dglass710/pwned
   ```
2. **Enter a Password**: When prompted, enter the password you want to check.
3. **View Results**: The script will output whether the password has been compromised and the number of times it has appeared in data breaches.

Example Session:
```
$ docker run -it dglass710/pwned
Enter password to check: password123
Password 'password123' has been compromised 47,839 times.
Enter password to check: quit
Goodbye!
```

