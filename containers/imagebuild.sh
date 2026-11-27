WGE_VER='latest'
SRA_VER='3.4.1'
BOW_VER='0.12.7'
CUT_VER='1.11'
SUB_VER='1.4.6-p3'
DES_VER='1.16'
MAP_VER='unknown'
MDIR='reprohack'

docker build wget_container -t $MDIR/wget:$WGE_VER
docker build sratoolkit_container -t $MDIR/sratoolkit:$SRA_VER
docker build bowtie_map_container -t $MDIR/bowtie-map:$BOW_VER
docker build cutadapt_container -t $MDIR/cutadapt:$CUT_VER
docker build subread_container -t $MDIR/subread:$SUB_VER
docker build deseq2_container -t $MDIR/deseq2:$DES_VER
docker build ma-plot_container -t $MDIR/ma-plot:$MAP_VER
