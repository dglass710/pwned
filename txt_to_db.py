import sqlite3, time, math
from HumanTime import TimeAutoShort as ht
from commaNumber import sayFullName as sn, commaNumber as cn

def create_tables(cursor):
    chars = '0123456789ABCDEF'
    for a in chars:
        for b in chars:
            for c in chars:
                cursor.execute(f"CREATE TABLE _{a}{b}{c} (hash TEXT, leaks INT)")

def count_lines(filename):
    with open(filename, 'r') as f:
        return sum(1 for line in f)

def process_file(filename, cursor, total_lines, progress_precision):
    line_number = 0
    start_time = time.time()
    precision = max(0, math.ceil(-math.log10(progress_precision)))
    alert_frequency = max(1, total_lines // int(100 / progress_precision))

    with open(filename, 'r') as f:
        for line in f:
            line_number += 1
            sha1_hash, number_of_breaches = line.strip().split(':')
            table = sha1_hash[:3]
            cursor.execute(f"INSERT INTO _{table} VALUES (?, ?)", (sha1_hash, int(number_of_breaches)))

            if line_number % alert_frequency == 0 or line_number == total_lines:
                progress = (line_number / total_lines) * 100
                elapsed_time = time.time() - start_time
                remaining_time = elapsed_time * (total_lines - line_number) / line_number
                print(f'{progress:.{precision}f}% complete\nTime elapsed: {ht(elapsed_time, 0)}\nEstimated time remaining: {ht(remaining_time, 0)}')

def main(infile, progress_precision=.1):
    print('Ensure pwned.db does not already exist. If it does, remove it and run this script again!')

    conn = sqlite3.connect('pwned.db')
    cursor = conn.cursor()
    print('Connected to database. Creating tables...')
    create_tables(cursor)
    print('Tables created.')

    print('Counting lines in the file...')
    start_time = time.time()
    total_lines = count_lines(infile)
    print(f'Finished counting {cn(total_lines).lower()} ({sn(total_lines).lower()}) lines in {ht(time.time() - start_time, 2)}')

    print('Processing the file...')
    process_file(infile, cursor, total_lines, progress_precision)

    conn.commit()
    conn.close()
    print('Processing complete.')

# Run the main function
main('pwnedpasswords.txt')
