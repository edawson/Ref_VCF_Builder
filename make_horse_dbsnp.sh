## A script to generate the horse reference SNP set
## If you don't have axel, either download it or use
## the standard gnu wget. You'll also need the NCBI's
## twoBitToFa perl script.
## Eric T Dawson
## Texas Advanced Computing Center
## March 2015

download=0
index=0
#downloader=axel
downloader=wget
twoBitToFa=./twoBitToFa

## download VCF files
if [ "$download" -eq 1 ]
then
	for i in `seq 1 31`; 
	do 
		$downloader ftp://ftp.ncbi.nih.gov/snp/organisms/horse_9796/VCF/vcf_chr_$i.vcf.gz;
	done

	for i in NotOn Multi X Un;
	do
		$downloader ftp://ftp.ncbi.nih.gov/snp/organisms/horse_9796/VCF/vcf_chr_$i.vcf.gz;
	done
fi


## unzip the vcf files
for i in `ls | grep "vcf"`; do echo "Unzipping $i"; gzip -d $i; done

#Download the reference, generate a fasta index using samtools faidx, and make a dict of the horse reference
#Download from UCSC
$downloader http://hgdownload-test.cse.ucsc.edu/goldenPath/equCab2/bigZips/equCab2.2bit
# convert to fasta from 2bit
$twoBitToFA equCab2.2bit horse.fa
#rename chromosomes
sed -i "s/chr//g" horse.fa
#Generate a fasta index
samtools faidx horse.fa
## Create fasta dict
java -jar $PICARD CreateSequenceDictionary R=horse.fa O=horse.dict

## Run GATK to combine the VCFS
java -Xmx4g -jar $GATK -T CombineVariants -nt 2 \
-R horse.chromsRenamed.fa \
--variant vcf_chr_1.vcf \
--variant vcf_chr_2.vcf \
--variant vcf_chr_3.vcf \
--variant vcf_chr_4.vcf \
--variant vcf_chr_5.vcf \
--variant vcf_chr_6.vcf \
--variant vcf_chr_7.vcf \
--variant vcf_chr_8.vcf \
--variant vcf_chr_9.vcf \
--variant vcf_chr_10.vcf \
--variant vcf_chr_11.vcf \
--variant vcf_chr_12.vcf \
--variant vcf_chr_13.vcf \
--variant vcf_chr_14.vcf \
--variant vcf_chr_15.vcf \
--variant vcf_chr_16.vcf \
--variant vcf_chr_17.vcf \
--variant vcf_chr_18.vcf \
--variant vcf_chr_19.vcf \
--variant vcf_chr_20.vcf \
--variant vcf_chr_21.vcf \
--variant vcf_chr_22.vcf \
--variant vcf_chr_23.vcf \
--variant vcf_chr_24.vcf \
--variant vcf_chr_25.vcf \
--variant vcf_chr_26.vcf \
--variant vcf_chr_27.vcf \
--variant vcf_chr_28.vcf \
--variant vcf_chr_29.vcf \
--variant vcf_chr_30.vcf \
--variant vcf_chr_31.vcf \
--variant vcf_chr_Multi.vcf \
--variant vcf_chr_NotOn.vcf \
--variant vcf_chr_Un.vcf \
--variant vcf_chr_X.vcf \
--out horse_SNP.vcf
