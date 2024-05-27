#! /usr/bin/python3

import hashlib, sys, os, time, sqlite3
from getpass import getpass
sys.path.append('/pwned/')
from commaNumber import commaNumber as cn
from commaNumber import sayFullName as sn
from HumanTime import TimeAutoShort as ht

def main(infile):
    itime = time.time()
    if 'ran_previously' not in os.listdir('/pwned/'):
        with open('/pwned/ran_previously', 'w') as f:
            f.write('This container has run the main application previously and copied the database from the image.')
        print("Preparing the database. This might take some time due to disk I/O operations when running a new container from the image.\nThe database file needs to be copied to the container's storage, which can take a bit of time. Subsequent runs within the same container will start instantly.\nUse the command 'docker exec -it <container_name> pwned' when reconnecting to this container. Check your containers name and status (running or stopped) with 'docker container ls -a' and start it with 'docker start <container_name>' if necessary. Thank you for your patience.")
        first = True
    else:
        print("Database is already prepared. Running faster since it's not the first run in this container.")
        first = False
    conn = sqlite3.connect(infile)
    c = conn.cursor()
    if first:
        print(f"Database is ready. It took {ht(time.time() - itime, 2)}.")
    print("You can now check if your password has been pwned.\n\nEnter 'done', 'exit', or 'quit' to leave.")
    ui = getpass("Enter a password: ")
    while ui.lower() not in ('done', 'exit', 'quit'):
        if ui != '':
            userinput = ui
            my_hash = hashlib.sha1(ui.encode()).hexdigest().upper()
            itime = time.time()
            c.execute(f"SELECT * FROM _{my_hash[0]}{my_hash[1]}{my_hash[2]} WHERE hash = '{my_hash}'")
            allVals = c.fetchall()
            if allVals:
                print(f"\nYou have been pwned!\nThe SHA1 hash of your password is {my_hash}.\nThis password has been seen {cn(allVals[0][1])} ({sn(allVals[0][1]).lower()}) times before and has previously appeared in a data breach. It should never be used.\nIf you've ever used it anywhere before, change it immediately!")
            else:
                print(f"\nGood news — no pwnage found!\nThis password wasn't found in the Pwned Passwords database. This doesn't necessarily mean it's a strong password. Consider using a password manager to create and store strong, unique passwords.")
            print(f"It took {ht(time.time() - itime, 2)} to fetch this result.")
        else:
            print("\nYou pwned yourself. USE A PASSWORD!!!")
        ui = getpass("\nEnter a password: ")
    conn.close()

main('/pwned/pwned.db')
