# DataCollector - Bash Dataset Summarizer

## What this script does
This script downloads a ZIP dataset from the UCI ML Repository, extracts CSV files, and allows the user to select columns and summarizes all selected columns in a Markdown file called `summary.md`.

## How to use this command
First, make sure that the file is executable.
```bash
chmod +x datacollector.sh
```

Then, you can execute the file directly!
```bash
./datacollector.sh
```

## Demo
Here is an example run:
```
└ $ ./datacollector.sh
Enter URL to CSV dataset zip:
https://archive.ics.uci.edu/static/public/186/wine+quality.zip

Downloading dataset...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 91353    0 91353    0     0   209k      0 --:--:-- --:--:-- --:--:--  209k

Unzipping...

Found CSV file: winequality-red.csv
Here are the column headers:
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol
12. quality

Enter the indexes of the numerical columns (space-separated):
1 2 3 4 5 6 7 8 9 10 11 12

Generated winequality-red_summary.md for winequality-red.csv

Found CSV file: winequality-white.csv
Here are the column headers:
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol
12. quality

Enter the indexes of the numerical columns (space-separated):
1 2 3 4 5 6

Generated winequality-white_summary.md for winequality-white.csv

Cleaning up temporary files...

Summary files have been generated in the output directory.
```