#!/bin/bash

# I did this process for 12 bed files by changing the file names manually
#ENCFF027BPY.bed  ENCFF041GGN.bed  ENCFF168GAN.bed  ENCFF362RCY.bed  ENCFF534UAS.bed  ENCFF886GET.bed  
#ENCFF027ZYL.bed  ENCFF052DSF.bed  ENCFF260PVK.bed  ENCFF448LQD.bed  ENCFF829XGX.bed  ENCFF931FYG.bed  

# first I have converted all the above mentioned bed files into .txt files using bed tools 
#bedtools getfasta -fi /users/Vygunda/reference/hg38.fa -bed "ENCFF027BPY.bed" -fo "ENCFF027BPY.txt"

# Step 1: Process ENCFF027BPY.txt
input_file="ENCFF041GGN.txt"
grepped_file="grepped_accessible_regions.txt"
output_file="ENCFF041GGN_output_trimmed_accessible_regions.txt"

# Perform grep to filter lines not containing ">"
grep -v ">" "$input_file" > "$grepped_file"

# Calculate average sequence length
total_length=0
total_sequences=0

# Loop through each sequence in the file
while read -r sequence; do
    length=${#sequence}
    total_length=$((total_length + length))
    total_sequences=$((total_sequences + 1))
done < "$grepped_file"

average_length=$((total_length / total_sequences))

# Output sequences with the target length
while read -r sequence; do
    length=${#sequence}
    if [ "$length" -ge "$average_length" ]; then
        trimmed_sequence="${sequence:0:$average_length}"
        echo "$trimmed_sequence"
    fi
done < "$grepped_file" > "$output_file"

# Clean up temporary file
rm "$grepped_file"

# Step 2: Process ENCFF027BPY.bed
input_bed="ENCFF041GGN.bed"
output_negative="ENCFF041GGN_negative_regions.bed"

# Sort the BED file
sort -k1,1 -k2,2n "$input_bed" > sorted.bed

# Iterate through the sorted BED file
prev_end=0
while read -r chrom start end rest; do
    # Calculate middle region between consecutive accessible regions
    if [ "$prev_end" -ne 0 ]; then
        middle_start=$((prev_end + 1))
        middle_end=$((start - 1))
        # Output middle region if it exists
        if [ "$middle_end" -gt "$middle_start" ]; then
            echo "$chrom $middle_start $middle_end" >> "$output_negative"
        fi
    fi
    prev_end="$end"
done < sorted.bed

# Remove temporary sorted file
rm sorted.bed

# Apply awk to format output file
awk '{$1=$1}1' OFS="\t" "$output_negative" > "ENCFF041GGN_negative_regions_tab.bed"



# Step 3: Run bedtools getfasta
output_negative_tab="ENCFF041GGN_negative_regions_tab.bed"
output_negative_fasta="ENCFF041GGN_negative_regions_tab.txt"

bedtools getfasta -fi /users/Vygunda/reference/hg38.fa -bed "$output_negative_tab" -fo "$output_negative_fasta"


# Step 4: Process negative_regions_tab.txt
input_file="ENCFF041GGN_negative_regions_tab.txt"
output_file="ENCFF041GGN_trimmed_negative_regions.txt"

# Calculate average sequence length
total_length=0
total_sequences=0

# Loop through each sequence in the file
while read -r sequence; do
    length=${#sequence}
    total_length=$((total_length + length))
    total_sequences=$((total_sequences + 1))
done < "$input_file"

average_length=$((total_length / total_sequences))

# Output sequences with the target length
while read -r sequence; do
    length=${#sequence}
    if [ "$length" -ge "$average_length" ]; then
        trimmed_sequence="${sequence:0:$average_length}"
        echo "$trimmed_sequence"
    fi
done < "$input_file" > "$output_file"

# Clean up temporary file
rm "$input_file"

