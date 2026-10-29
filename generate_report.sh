#!/bin/bash

ROOT_DIR=${1:-root_folder}

total_files=$(find "$ROOT_DIR" -type f -name "*.pdf" | wc -l)

correct_files=0

declare -A category_keywords=(
    ["Programming"]="programming code development python java c software"
    ["AI"]="ai artificial intelligence machine learning neural network deep learning data science"
    ["Math"]="math mathematics calculus linear algebra geometry"
    ["Database"]="database sql nosql data management mongodb mysql"
    ["Security"]="security cryptography network security cybersecurity information security"
)

declare -A subcategory_keywords=(
    ["Python"]="python"
    ["Java"]="java"
    ["C"]=" c "
    ["Machine_Learning"]="machine learning"
    ["Neural_Networks"]="neural networks"
    ["Calculus"]="calculus"
    ["Linear_Algebra"]="linear algebra"
    ["SQL"]="sql mysql"
    ["NoSQL"]="nosql mongodb"
    ["Cryptography"]="cryptography"
    ["Network_Security"]="network security"
)

categories=("Programming" "AI" "Math" "Database" "Security" "Others")

declare -A file_counts

# Initialize file_counts for each category
for category in "${categories[@]}"; do
    file_counts["$category"]=0
done

# Function to normalize strings (convert to lowercase)
normalize_string() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# For each file, determine the expected category and subcategory
while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    filename_lower=$(normalize_string "$filename")
    # Split filename into words
    filename_words=($(echo "$filename_lower" | tr -cs '[:alnum:]' '[\n*]'))

    expected_category="Others"
    expected_subcategory=""
    highest_category_score=0
    highest_subcategory_score=0

    # Determine expected category
    for category in "${categories[@]}"; do
        if [ "$category" != "Others" ]; then
            category_kw=(${category_keywords[$category]})
            category_score=0
            for ckw in "${category_kw[@]}"; do
                ckw_lower=$(normalize_string "$ckw")
                for word in "${filename_words[@]}"; do
                    if [ "$word" == "$ckw_lower" ]; then
                        category_score=$((category_score + 1))
                        break
                    fi
                done
            done
            if [ $category_score -gt $highest_category_score ]; then
                highest_category_score=$category_score
                expected_category="$category"
            fi
        fi
    done

    # Determine expected subcategory
    for subcategory in "${!subcategory_keywords[@]}"; do
        subcat_kw=(${subcategory_keywords[$subcategory]})
        subcat_score=0
        for skw in "${subcat_kw[@]}"; do
            skw_lower=$(normalize_string "$skw")
            for word in "${filename_words[@]}"; do
                if [ "$word" == "$skw_lower" ]; then
                    subcat_score=$((subcat_score + 1))
                    break
                fi
            done
        done
        if [ $subcat_score -gt $highest_subcategory_score ]; then
            highest_subcategory_score=$subcat_score
            expected_subcategory="$subcategory"
        fi
    done

    # Get actual category and subcategory from file path
    dir_path=$(dirname "$file")
    subcategory_dir=$(basename "$dir_path")
    category_dir=$(basename "$(dirname "$dir_path")")

    # Adjust for files directly under category directories
    if [ "$category_dir" == "$(basename "$ROOT_DIR")" ]; then
        category_dir="$subcategory_dir"
        subcategory_dir=""
    fi

    actual_category="$category_dir"
    actual_subcategory="$subcategory_dir"

    # Increment file count for actual category
    if [[ " ${categories[@]} " =~ " $actual_category " ]]; then
        ((file_counts["$actual_category"]++))
    else
        ((file_counts["Others"]++))
        actual_category="Others"
    fi

    # Determine if the file is correctly classified
    if [ "$expected_category" == "$actual_category" ]; then
        if [ -z "$expected_subcategory" ] || [ "$expected_subcategory" == "$actual_subcategory" ]; then
            ((correct_files++))
        fi
    fi

done < <(find "$ROOT_DIR" -type f -name "*.pdf" -print0)

# Calculate percentages
echo "Analysis Report:"
echo "----------------"

for category in "${categories[@]}"; do
    count=${file_counts["$category"]}
    percentage=0
    if [ $total_files -ne 0 ]; then
        percentage=$(( (count * 100) / total_files ))
    fi
    echo "$category: $percentage%"
done

# Calculate correctness score
correctness_score=0
if [ $total_files -ne 0 ]; then
    correctness_score=$(( (correct_files * 100) / total_files ))
fi

echo
echo "Correctness Score: ${correctness_score}%"

