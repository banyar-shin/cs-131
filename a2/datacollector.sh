#!/bin/bash

# ask for url input
echo "Enter URL to CSV dataset zip:"
read url

filename=$(basename "$url")
dirname="output"

# create the output directory
mkdir -p "$dirname"
cd "$dirname"

# download the file
echo ""
echo "Downloading dataset..."
curl -L -o "$filename" "$url"

# unzip the file
echo ""
echo "Unzipping..."
unzip -o "$filename" > /dev/null

csv_files=(*.csv)

# check if there are any csv files in the archive
if [ ${#csv_files[@]} -eq 0 ]; then
  echo ""
  echo "No CSV files found in the archive."
  rm -f "$filename"
  exit 1
fi

# loop through the csv files
for csv in "${csv_files[@]}"; do
  echo ""
  echo "Found CSV file: $csv"
  echo "Here are the column headers:"

  IFS=';' read -r -a headers < "$csv"
  for i in "${!headers[@]}"; do
    header=$(echo "${headers[$i]}" | tr -d '"' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "$((i + 1)). $header"
  done

  echo ""
  echo "Enter the indexes of the numerical columns (space-separated):"
  read -a num_indexes

  csv_basename=$(basename "$csv" .csv)
  summary_file="${csv_basename}_summary.md"
  echo "# Feature Summary for $csv" > "$summary_file"
  echo "" >> "$summary_file"
  echo "## Feature Index and Names" >> "$summary_file"
  for i in "${!headers[@]}"; do
    header=$(echo "${headers[$i]}" | tr -d '"' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "$((i + 1)). $header" >> "$summary_file"
  done

  echo "" >> "$summary_file"
  echo "## Statistics (Numerical Features)" >> "$summary_file"
  printf "| %5s | %-25s | %7s | %7s | %7s | %7s |\n" "Index" "Feature" "Min" "Max" "Mean" "StdDev" >> "$summary_file"
  printf "|%7s|%27s|%9s|%9s|%9s|%9s|\n" "-------" "---------------------------" "---------" "---------" "---------" "---------" >> "$summary_file"

  tail -n +2 "$csv" > tmp.csv

  for index in "${num_indexes[@]}"; do
    col_num=$((index))
    header=$(echo "${headers[$((col_num - 1))]}" | tr -d '"' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    col_data=$(cut -d';' -f"$col_num" tmp.csv | tr ',' '.' | grep -E '^[0-9.-]+$')

    if [ -n "$col_data" ]; then
      min=$(echo "$col_data" | awk 'NR == 1 || $1 < min {min = $1} END {printf "%.3f", min}')
      max=$(echo "$col_data" | awk 'NR == 1 || $1 > max {max = $1} END {printf "%.3f", max}')
      mean=$(echo "$col_data" | awk '{sum += $1} END {printf "%.3f", sum/NR}')
      stddev=$(echo "$col_data" | awk -v m="$mean" '{sum += ($1-m)*($1-m)} END {printf "%.3f", sqrt(sum/NR)}')

      printf "| %5d | %-25s | %7.3f | %7.3f | %7.3f | %7.3f |\n" "$col_num" "$header" "$min" "$max" "$mean" "$stddev" >> "$summary_file"
    fi
  done

  # clean up
  rm tmp.csv
  echo ""
  echo "Generated $summary_file for $csv"
done

# clean up
echo ""
echo "Cleaning up temporary files..."
rm -f "$filename" *.csv *.names *.txt 2> /dev/null

# print status message
echo ""
echo "Summary files have been generated in the output directory."
cd ..
