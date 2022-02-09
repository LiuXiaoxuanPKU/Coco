# for regex pattern matching
import re
# for input argument
import sys


# Usage Example: python3 parser.py log_filename.log dumpfile_name

# Judge if line contains SELECT, return boolean value
def is_query(line) -> bool:
    line = line.strip()
    start_idx = line.find("SELECT")
    return True if start_idx != -1 else False

# Extract and modify into readable SQL
# input line should contain keyword SELECT
def filter(line) -> str:
    start_idx = line.find("SELECT")
    line = line[start_idx:]
    line = line.replace('"', '')
    end_idx = line.find("[[")
    line = line[:end_idx]
    return line 

# dump sql query
def write_sql(dump_filename, sql):
    with open(dump_filename, 'a') as f:
        f.write(sql + '\n')

# Go through file line by line
def scan(filename, dump_filename):
    f = open(filename, 'r', errors="replace")
    for line in f.readlines():
        if is_query(line):
            extracted_sql = filter(line)
            print(extracted_sql)
            write_sql(dump_filename, extracted_sql)


if __name__ == "__main__": 
    scan(sys.argv[1], sys.argv[2])