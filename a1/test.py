import csv
from collections import Counter

# === CONFIGURATION ===
filename = "2019-04.csv"
target_date = "2019-04-10"

# === PROCESSING ===
pickup_counts = Counter()

with open(filename, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        pickup_datetime = row["tpep_pickup_datetime"]
        if pickup_datetime.startswith(target_date):
            pickup_location = row["pulocationid"]
            pickup_counts[pickup_location] += 1

# === OUTPUT ===
print("Top 3 pickup locations on", target_date)
for location, count in pickup_counts.most_common(3):
    print(f"{count} {location}")

