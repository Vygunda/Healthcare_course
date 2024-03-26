#!/bin/bash

# I did this process for 10 bed files 
#Below are the files that I used
#ENCFF168GAN.bed  ENCFF052DSF.bed  ENCFF253LML.bed  ENCFF260PVK.bed  ENCFF041GGN.bed  ENCFF922ABK/.bed  
#ENCFF180WXO.bed  ENCFF386GNZ.bed  ENCFF975INV.bed  ENCFF928NLF.bed   

#Downloaded the above 10 different files bed narrowPeak file type from 10 different experiments.

# get the required bed file using wget command before executing this script : Download the data from the encode website
# wget https://www.encodeproject.org/files/ENCFF168GAN/@@download/ENCFF168GAN.bed.gz
#gunzip ENCFF168GAN.bed.gz

# Convert the narrowPeakfile into a nucleotide(ATGCs)file using bedtools
bedtools getfasta -fi /users/Vygunda/reference/hg38.fa -bed "ENCFF168GAN.bed" -fo "ENCFF168GAN.txt"

# Step 1: Extract all the nucleotides from this file 
input_file="ENCFF168GAN.txt"
grepped_file="grepped_accessible_regions.txt"
output_file="ENCFF168GAN_output_trimmed_accessible_regions.txt"  # This is the accessible file

# Perform grep to filter lines not containing ">"
grep -v ">" "$input_file" > "$grepped_file"

#this is the standard file which we use to get the average length 
grepped_standard_file="grepped_standard_accessible_regions.txt"
standard_file="ENCFF168GAN.txt"
grep -v ">" "$standard_file" > "$grepped_standard_file"

# Calculate average sequence length
total_length=0
total_sequences=0

# Loop through each sequence in the standard file
while read -r sequence; do
    length=${#sequence}
    total_length=$((total_length + length))
    total_sequences=$((total_sequences + 1))
done < "$grepped_standard_file"

average_length=$((total_length / total_sequences))

# the average length obtained is used for all the sequences 
#if a sequence is greater than or equal to the average_length it will be trimmed to the average length and the rest are discarded

#The gripped file is trimmed as per the above conditions
while read -r sequence; do
    length=${#sequence}
    if [ "$length" -ge "$average_length" ]; then
        trimmed_sequence="${sequence:0:$average_length}"
        echo "$trimmed_sequence"
    fi
done < "$grepped_file" > "$output_file"

# Clean up temporary file
rm "$grepped_file"

# Step 2: Process ENCFF168GAN.bed to get negative regions
input_bed="ENCFF168GAN.bed"
output_negative="ENCFF168GAN_negative_regions.bed"  # negative regions file 

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
awk '{$1=$1}1' OFS="\t" "$output_negative" > "ENCFF168GAN_negative_regions_tab.bed" 


# run the negative regions bed file to get negative txt file 
# Step 3: Run bedtools getfasta
output_negative_tab="ENCFF168GAN_negative_regions_tab.bed"
output_negative_fasta="ENCFF168GAN_negative_regions_tab.txt"

bedtools getfasta -fi /users/Vygunda/reference/hg38.fa -bed "$output_negative_tab" -fo "$output_negative_fasta"


# Step 4: Process negative_regions_tab.txt
input_file="ENCFF168GAN_negative_regions_tab.txt"
output_file="ENCFF168GAN_trimmed_negative_regions.txt"

# Calculate average sequence length
total_length=0
total_sequences=0

#use the same average_length obtained from the accessible region standard file
# the average length obtained is used for all the sequences 
#if a sequence is greater than or equal to the average_length it will be trimmed to the average length and the rest are discarded
#The gripped file is trimmed as per the above condition
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
