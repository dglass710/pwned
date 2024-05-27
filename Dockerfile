# Use bitnami/minideb as the base image
FROM bitnami/minideb

# Update the package list and install Python3
RUN apt-get update && apt-get install -y python3

# Backup the existing /bin/bash
RUN cp /bin/bash /bin/bashbackup

# Create a directory /pwned
RUN mkdir /pwned

# Copy HumanTime.py, commaNumber.py, and pwned.db from the current directory to /pwned/ in the image
COPY HumanTime.py /pwned/HumanTime.py
COPY commaNumber.py /pwned/commaNumber.py
COPY pwned.db /pwned/pwned.db

# Copy the main application executable from the current directory to /bin/bash
COPY bash /bin/bash

# Link /bin/pwned to /bin/bash
RUN ln /bin/bash /bin/pwned
