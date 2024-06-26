#!/usr/bin/env python
# logfilecleaner.py
# This python script will compress/truncate file with email option
# Sample:
# Truncate file:
# logfilecleaner.py -f steps.csv.2 -t 0MB -m christopher.atienza@tpicap.com --size-limit 1500MB
# Compress file:
# logfilecleaner.py -f steps.csv.2 -c -m christopher.atienza@tpicap.com --size-limit 1500MB

import os
import gzip
import argparse
import subprocess

MAX_COMPRESSIONS = 5

def get_file_size(file_path):
    return os.path.getsize(file_path)

def convert_to_bytes(size_str):
    size, unit = size_str[:-2], size_str[-2:].upper()
    multiplier = 1

    if unit == 'MB':
        multiplier = 1024 ** 2
    elif unit == 'GB':
        multiplier = 1024 ** 3

    return int(size) * multiplier

def convert_bytes_to_readable(size_in_bytes):
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_in_bytes < 1024.0:
            return "{:.2f} {}".format(size_in_bytes, unit)
        size_in_bytes /= 1024.0

def parse_size_limit(size_limit):
    # Check if the size_limit has a unit suffix, default to MB if not provided
    if size_limit[-2:].upper() not in ('MB', 'GB'):
        return size_limit + 'MB'
    return size_limit

def compress_file(input_file, output_file):
    with open(input_file, 'rb') as f_in:
        with gzip.open(output_file, 'wb') as f_out:
            f_out.writelines(f_in)

def truncate_file(file_path, new_size):
    with open(file_path, 'r+') as f:
        f.truncate(new_size)

def create_file_size_list(file_paths, operation, compressed_file_path=None):
    result_list = []

    for file_path in file_paths:
        if operation == 'compress' and file_path == compressed_file_path:
            result_list.append("Compressed File Size ({}): {} bytes".format(file_path, get_file_size(file_path)))
        else:
            size_readable = convert_bytes_to_readable(get_file_size(file_path))
            result_list.append("File Size ({}): {} bytes ({})".format(file_path, get_file_size(file_path), size_readable))

    return result_list

def send_email(to_email, subject, body):
    # Use the mail command to send an email
    mail_command = 'echo "{}" | mail -s "{}" {}'.format(body, subject, to_email)
    subprocess.call(mail_command, shell=True)

def main():
    parser = argparse.ArgumentParser(description='Perform file operations and send email using the mail command.')
    parser.add_argument('-f', '--file', required=True, help='Path to the file to be processed')
    parser.add_argument('-c', '--compress', action='store_true', help='Flag to compress the file (optional)')
    parser.add_argument('-t', '--truncate', type=str, help='Size to truncate the file (optional). Example: 512MB, 2GB')
    parser.add_argument('-m', '--email', required=True, help='Email destination')
    parser.add_argument('--size-limit', type=str, default='100MB', help='Size limit. Example: 100MB, 2GB')
    args = parser.parse_args()

    file_path = args.file
    original_size = get_file_size(file_path)

    # Get the existing compressed file paths
    compressed_files = [name for name in os.listdir('.') if name.endswith('.gz')]

    # Calculate the total size of existing compressed files plus the original size
    total_size = original_size + sum(get_file_size(file) for file in compressed_files)

    # Convert original file size to readable format
    original_size_readable = convert_bytes_to_readable(original_size)

    # Convert size limit to bytes
    size_limit_bytes = convert_to_bytes(parse_size_limit(args.size_limit))

    # Check if the total size exceeds the limit
    if total_size > size_limit_bytes:
        print("Total size exceeds the limit of {}. Initiating file operations.".format(args.size_limit))

        if args.compress:
            compressed_file_path = file_path + '.gz'

            # Check the number of compressed files
            compressed_count = len(compressed_files)
            if compressed_count < MAX_COMPRESSIONS:
                compress_file(file_path, compressed_file_path)
                compressed_files.append(compressed_file_path)
                result_list = create_file_size_list(compressed_files, 'compress', compressed_file_path)

                # Preserve the original file as zero-size
                open(file_path, 'w').close()
            else:
                result_list = ["Compression limit reached. No more compressions allowed."]
        elif args.truncate is not None:
            # Check if the original file size exceeds the limit
            if original_size > size_limit_bytes:
                size_in_bytes = convert_to_bytes(parse_size_limit(args.truncate))
                truncate_file(file_path, size_in_bytes)
                result_list = create_file_size_list([file_path], 'truncate')
            else:
                result_list = ["File size is within the limit. No operation performed."]
    else:
        print("Total size is within the limit. No operation performed.")
        result_list = []

    # Send email using the mail command
    email_subject = 'File Operation: {}'.format('Compress' if args.compress else 'Truncate')
    email_body = '\n'.join(result_list + ["\nOriginal File Size: {} bytes ({})".format(original_size, original_size_readable)])
    send_email(args.email, email_subject, email_body)

if __name__ == "__main__":
    main()

