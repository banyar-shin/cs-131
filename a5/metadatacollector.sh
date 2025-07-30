#!/bin/bash

echo "Enter URL for dataset: "
read url

echo "Downloading data"
filename=$(basename "$url")
curl -L -o ./archive.zip "$url"
echo "Download complete"

unzip -o "./archive.zip" -d ./
rm "./archive.zip"

for csv in ./*.csv; do
    summaryname="$(basename "$csv" .csv)_metadata.md"
    echo "# Metadata Summary for $(basename "$csv")" > "$summaryname"
    echo "" >> "$summaryname"
    
    delimiter=$(head -n 1 "$csv" | sed 's/[^,;|\t]//g' | head -c 1)
    if [[ -z "$delimiter" ]]; then
        delimiter=","
    fi
    
    total_entries=$(($(wc -l < "$csv") - 1))
    echo "## Dataset Overview" >> "$summaryname"
    echo "- **Total Entries:** $total_entries" >> "$summaryname"
    echo "- **File Size:** $(du -h "$csv" | cut -f1)" >> "$summaryname"
    echo "- **Delimiter:** $delimiter" >> "$summaryname"
    echo "" >> "$summaryname"
    
    echo "## Feature Index and Names" >> "$summaryname"
    head -n 1 "$csv" | sed 's/"//g' | awk -F"$delimiter" '{ for(i=1; i<=NF; i++) { print i ". " $i } }' >> "$summaryname"
    
    echo "" >> "$summaryname"
    echo "## Numerical Feature Statistics" >> "$summaryname"
    echo "| Index | Feature | Count | Min | Max | Mean | Median | 25th Percentile | 75th Percentile | StdDev |" >> "$summaryname"
    echo "|-------|---------|-------|-----|-----|------|--------|-----------------|-----------------|--------|" >> "$summaryname"
    
    header=$(head -n 1 "$csv" | sed 's/"//g')
    num=$(echo "$header" | awk -F"$delimiter" '{print NF}')
    
    for ((i=1; i<=num; i++)); do
        featurename=$(echo "$header" | cut -d"$delimiter" -f"$i")
        
        total_non_empty=$(awk -F "$delimiter" -v col="$i" 'NR > 1 && $col != "" {count++} END {print count+0}' "$csv")
        numerical_count=$(awk -F "$delimiter" -v col="$i" 'NR > 1 && $col != "" && $col ~ /^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$/ {count++} END {print count+0}' "$csv")
        
        if [[ $numerical_count -gt 0 ]] && [[ $numerical_count -eq $total_non_empty ]]; then
            values=$(awk -F "$delimiter" -v col="$i" 'NR > 1 && $col != "" && $col ~ /^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$/ {print $col}' "$csv" | sort -n)
            count=$total_entries
            
            stats=$(echo "$values" | awk '
            BEGIN { sum=0; sumsq=0; count=0 }
            {
                if (count==0) {min=$1; max=$1}
                if ($1 < min) min=$1;
                if ($1 > max) max=$1;
                sum += $1;
                sumsq += $1*$1;
                values[++count] = $1;
            }
            END {
                if (count > 0) {
                    mean = sum/count;
                    stddev = sqrt(sumsq/count - mean*mean);
                    
                    median_pos = int((count + 1) / 2);
                    if (count % 2 == 0) {
                        median = (values[median_pos] + values[median_pos + 1]) / 2;
                    } else {
                        median = values[median_pos];
                    }
                    
                    p25_pos = int(count * 0.25);
                    if (p25_pos == 0) p25_pos = 1;
                    p25 = values[p25_pos];
                    
                    p75_pos = int(count * 0.75);
                    if (p75_pos == 0) p75_pos = 1;
                    p75 = values[p75_pos];
                    
                    printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f", count, min, max, mean, median, p25, p75, stddev;
                }
            }')
            
            read -r stat_count min max mean median p25 p75 stddev <<< "$stats"
            echo "| $i | $featurename | $count | $min | $max | $mean | $median | $p25 | $p75 | $stddev |" >> "$summaryname"
        fi
    done
    
    echo "Metadata collection completed for $(basename "$csv") with the name $summaryname"
done

echo "Script completed"