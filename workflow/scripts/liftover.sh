#!/bin/bash

INPUT=$1
LOG=$(awk -F ".vcf.gz" '{print $1}' <<< $INPUT)
HG38FASTA=$3
CHAINFILE=$4
OUTPUT_VCF=ukb-b-11908-liftover.vcf.gz

CrossMap vcf $CHAINFILE ukb-b-11908.vcf.gz $HG38FASTA $INPUT 2> $LOG.log


