#!/bin/sh

# requires samtools/bcftools

if [ $# -ne 4 ]; then
    echo "usage: $0 <number of threads> <reference indexed with bwa index> <path to picard.jar> <bowtie2 index>"
    exit 65
fi

if [ ! -e $3 ]; then
    echo "cannot find SamToFastq.jar"
    exit 65
fi

if [ ! -e $4 ]; then
    echo "cannot find bowtie2 index"
    exit 65
fi

if [ ! -e $2 ]; then
    echo "can't find reference .fasta: $2, please supply a bwa-indexed .fasta"
    exit 65
fi

if [ ! -e $2.bwt ]; then
    echo "can't find $2.bwt: is $2 indexed with bwa?"
    exit 65
fi

python3 -O ../bin/addindel.py -v ../test_data/test_indels.txt -f ../test_data/testregion_bt2.bam -r $2 -o ../test_data/testregion_bt2_mut.bam -p $1 --picardjar $3 --aligner bowtie2 --alignopts bowtie2ref:$4
if [ $? -ne 0 ]; then
    echo "python3 -O ../bin/addindel.py failed."
    exit 65
else
    samtools sort -T ../test_data/testregion_bt2_mut.sorted.bam -o ../test_data/testregion_bt2_mut.sorted.bam ../test_data/testregion_bt2_mut.bam
    mv ../test_data/testregion_bt2_mut.sorted.bam ../test_data/testregion_bt2_mut.bam
    samtools index ../test_data/testregion_bt2_mut.bam
    samtools mpileup -ugf $2 ../test_data/testregion_bt2_mut.bam | bcftools call -vm
fi
