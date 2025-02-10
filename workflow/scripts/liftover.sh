#!/bin/bash

INPUT=$1
LOG=$(awk -F ".vcf.gz" '{print $1}' <<< $INPUT)
HG38FASTA=$2
CHAINFILE=$3
OUTPUT_VCF=$4

CrossMap vcf $CHAINFILE $INPUT $HG38FASTA $OUTPUT_VCF --compress 2> $LOG.log
