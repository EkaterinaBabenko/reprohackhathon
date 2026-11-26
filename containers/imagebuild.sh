SRA_VER='3.4.1'
BOW_VER='0.12.7'
CUT_VER='1.11'

MDIR='reprohack'

docker build sratoolkit_container -t $MDIR/sratoolkit:$SRA_VER
docker build bowtie_map_container -t $MDIR/bowtie:$BOW_VER
docker build cutadapt_container -t $MDIR/cutadapt:$CUT_VER
