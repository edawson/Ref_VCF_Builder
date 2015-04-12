## A script to download a reference genome in 2bit format
## and a set of VCF calls from NCBI and merge them using
## GATK.

## Eric T Dawson
## Texas Advanced Computing Center
## March 2015


link=$1
base_name=$3
ref_link=$2
download=1
index=1
downloader=`pwd`/bin/axel
d_args="-n 5"
#downloader=wget
GATK=`pwd`/bin/GenomeAnalysisTK.jar
PICARD=`pwd`/bin/picard.jar
samtools=`pwd`/bin/samtools
twoBitToFa=`pwd`/bin/twoBitToFa

## download VCF files

files=`curl ${link} 2>&1 | rev | cut -d " " -f 1 | rev | grep "vcf.gz$"`
if [ "$download" -eq 1 ]
then
	echo "Downloading VCF Files."
	sleep 1
	mkdir temp
	cd temp
	for i in $files;
	do
		$downloader ${d_args} ${link}/$i
  done
	cd ..
fi


## unzip the vcf files
echo "Unzipping files in parallel."
for i in ${files}; do echo "gzip -d ./temp/$i" >> launchfile.txt; done
python ./bin/LaunChair/launcher.py -i launchfile.txt -c 1
echo "Done."
rm launchfile.txt

for i in `ls ./temp`; do echo "python ./bin/vcf_check.py ./temp/$i" >> launchfile.txt; done
python ./bin/LaunChair/launcher.py -i launchfile.txt -c 1
rm launchfile.txt

# #Download the reference, generate a fasta index using samtools faidx, and make a dict of the horse reference
# #Download from UCSC
if [ "$download" -eq 1 ]
then
	${downloader} ${d_args} $ref_link
fi
# # convert to fasta from 2bit
echo "Converting from 2bit to fasta"
ref2bit=`basename ${ref_link}`
$twoBitToFa ${ref2bit} ${base_name}.ref.fa

#rename chromosomes if necessary
notChr=`head -n 100 temp/vcf_chr_1.vcf | grep -v "#" | grep "CHR\|chr" | wc -l`
if [ ${notChr} -eq 0 ]
then
	sed -i 's/chr//g' ${base_name}.ref.fa
fi
#Generate a fasta index
$samtools faidx ${base_name}.ref.fa
## Create fasta dict
java -jar $PICARD CreateSequenceDictionary R=${base_name}.ref.fa O=${base_name}.ref.dict

## Run GATK to combine the VCFS
for i in `ls temp`; do echo "--variant ./temp/$i"; done > temp.txt
java -Xmx4g -jar $GATK -T CombineVariants -nt 2 \
-R ${base_name}.ref.fa \
--out ${base_name}.vcf \
`cat temp.txt`

rm -rf temp.txt temp launchfile.txt
