import argparse
import pandas as pd
import os

def convert_csv_to_xlsx(csv_file, xlsx_file):
    try:
        df = pd.read_csv(csv_file)
        if not xlsx_file.endswith('.xlsx'):
            xlsx_file += '.xlsx'
        df.to_excel(xlsx_file, index=False)
        print("Conversion completed successfully. Output saved to:", xlsx_file)
    except FileNotFoundError:
        print("Error: CSV file not found.")
    except Exception as e:
        print("Error:", e)

def main():
    parser = argparse.ArgumentParser(description="Convert CSV file to XLSX format")
    parser.add_argument("csv_file", help="Path to the CSV input file")
    parser.add_argument("-o", "--output", help="Path to the output XLSX file (default: 'output.xlsx')", default="output")
    args = parser.parse_args()

    convert_csv_to_xlsx(args.csv_file, args.output)

if __name__ == "__main__":
    main()

