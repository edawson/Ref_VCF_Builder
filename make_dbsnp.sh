## A script to generate the horse reference SNP set
## If you don't have axel, either download it or use
## the standard gnu wget. You'll also need the NCBI's
## twoBitToFa perl script.
## Eric T Dawson
## Texas Advanced Computing Center
## March 2015


link=$1
base_name=$3
ref_link=$2
download=1
index=1
downloader=./bin/axel
ref_args=""
downloader=wget
twoBitToFa=./bin/twoBitToFa

## download VCF files

files=`curl ${link} 2>&1 | rev | cut -d " " -f 1 | rev | grep "vcf.gz$"`
if [ "$download" -eq 1 ]
then
	for i in $files; 
	do 
		$downloader ${link}/$i
    done
fi


## unzip the vcf files
for i in ${files}; do echo "gzip -d $i" >> launchfile.txt; done
python /bin/LaunChair/launcher.py -i launchfile.txt -c 1

#Download the reference, generate a fasta index using samtools faidx, and make a dict of the horse reference
#Download from UCSC
$downloader ${ref_args} $reflink
# convert to fasta from 2bit
ref2bit=basename(${refLink})
$twoBitToFA ${ref2bit} ${base_name}.ref.fa
#rename chromosomes
#sed -i "s/chr//g" horse.fa
#Generate a fasta index
samtools faidx ${base_name}.ref.fa
## Create fasta dict
java -jar $PICARD CreateSequenceDictionary R=${base_name}.ref.fa O=${base_name}.ref.dict

## Run GATK to combine the VCFS
for i in `ls temp`; do echo "--variant $i \\"; done > temp.txt 
java -Xmx12g -jar $GATK -T CombineVariants -nt 2 \
-R ${base_name}.ref.fa \
--out horse_SNP.vcf \
`cat temp.txt`

rm -rf temp.txt temp
