tar xvzf samtools_icc.tgz
cd samtools-1.2
make clean
make -j 2
cp samtools ../
cd ..
rm -rf samtools-1.2
