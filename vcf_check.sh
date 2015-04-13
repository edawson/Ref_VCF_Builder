## A script that checks for invalid
## VCF lines (those with an improper
## number of columns) and removes them.
## Eric T Dawson
## Texas Advanced Computing Center

variantFile=$1

## Skip header lines.
## Make sure there are nine (9) tokens in each line.
head -n 1000 $variantFile | grep "#" >> .temp.txt
for i in `cat $variantFile | grep -v "#"`
do
    count=`echo ${i} | wc -w`
    if [ "${count}" -eq "9" ]
    then
        echo $i >> .temp.txt
    fi
done

mv .temp.txt $variantFile
#rm .temp.txt
