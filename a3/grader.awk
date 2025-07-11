#!/usr/bin/awk -f

# function to calculate average of three grades
function calculate_average(g1, g2, g3) {
    return (g1 + g2 + g3) / 3
}

BEGIN {
    # set field separator to comma for csv
    FS = ","
    
    # initialize variables for tracking highest and lowest scores
    highest_score = -1
    lowest_score = 999999
    highest_student = ""
    lowest_student = ""
    
    # print header
    print "\nStudent Grade Report\n==================="
}

# skip header row
NR > 1 {
    # store total score in array
    total_scores[$2] = $3 + $4 + $5
    
    # calculate average
    avg = calculate_average($3, $4, $5)
    averages[$2] = avg
    
    # determine status
    status[$2] = (avg >= 70) ? "Pass" : "Fail"
    
    # track highest and lowest scoring students
    if (total_scores[$2] > highest_score) {
        highest_score = total_scores[$2]
        highest_student = $2
    }
    if (total_scores[$2] < lowest_score) {
        lowest_score = total_scores[$2]
        lowest_student = $2
    }
}

END {
    # print individual student reports
    print "\nIndividual Reports:\n"
    for (student in total_scores) {
        print "Student Name: " student
        print "Total Score: " total_scores[student]
        printf "Average Score: %.2f\n", averages[student]
        print "Status: " status[student]
        print "-------------------"
    }
    
    # print highest and lowest scoring students
    print "\nTop and Bottom Performers:"
    print "- Highest Scoring Student: " highest_student " (Total: " highest_score ")"
    print "- Lowest Scoring Student: " lowest_student " (Total: " lowest_score ")"
} 