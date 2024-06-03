import sqlite3

def create_tables(cursor):
    chars = '0123456789ABCDEF'
    for a in chars:
        for b in chars:
            for c in chars:
                cursor.execute(f"CREATE TABLE _{a}{b}{c} (hash TEXT, leaks INT)")

def process_file(filename, cursor):
    with open(filename, 'r') as f:
        for line in f:
            sha1_hash, number_of_breaches = line.strip().split(':')
            table = sha1_hash[:3]
            cursor.execute(f"INSERT INTO _{table} VALUES (?, ?)", (sha1_hash, int(number_of_breaches)))

def main(infile):
    conn = sqlite3.connect('pwned.db')
    cursor = conn.cursor()
    create_tables(cursor)
    process_file(infile, cursor)
    conn.commit()
    conn.close()

# Run the main function
if __name__ == "__main__":
    main('pwnedpasswords.txt')

