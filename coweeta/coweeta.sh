#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


CREATE_SITE_KEY=0
CALC_COWEETA=0
ID_COMPETING=0
MAP_COMPETING=0 
MAP_INDIVIDUAL_LOOP=1 
IDIVIDUAL_BINARY=1
#############################################################                                                                               
if [ $CREATE_SITE_KEY -eq 1 ]
then

 awk 'BEGIN {FS="|"}; {print NR-1" "$1}' ../phase1/univar.vect.out | sed '1d'>constit_reclass_1.txt
 v.db.select exp_forests_multipoly | awk 'BEGIN {FS="|"}; {print $1","$2","$3}' | sed '1d'>constit_reclass.txt
 ./site_key.R

fi
#############################################################                                                                               
if [ $CALC_COWEETA -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o
CASE=coweeta
RCASE=exp_forests_phase1

#Coweeta line ID 209
awk '{print $1" "$2" "$(209+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${CASE}.netrep x=1 y=2 z=3 type=FCELL fs=space --o

lim=`r.quantile input=${RCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`

r.mapcalc "'${CASE}.netrep_norm'=if('${CASE}.netrep'>${lim},0,1-'${CASE}.netrep'/${lim})"

r.out.gdal in=${CASE}.netrep_norm out=./export/${CASE}.netrep_norm.tif type=Float64 format=GTiff --o
fi        

#############################################################
if [ $ID_COMPETING -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o

RCASE=exp_forests_phase1
awk '{print $1" "$2" "$(209+2)" "$(NF-21)}' ../representativeness/${RCASE}.representativeness >temp
./competing.R

fi
############################################################
if [ $MAP_COMPETING -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o
RCASE=exp_forests_phase1

#Coweeta line ID 209
awk '{print $1" "$2" "$(178+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=BentCreek.netrep x=1 y=2 z=3 type=FCELL fs=space --o
#Coweeta line ID 209
awk '{print $1" "$2" "$(193+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=BlueValley.netrep x=1 y=2 z=3 type=FCELL fs=space --o
#Coweeta line ID 209
awk '{print $1" "$2" "$(151+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=Fernow.netrep x=1 y=2 z=3 type=FCELL fs=space --o


#lim=`r.quantile input=${RCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`
lim=32.199585

r.mapcalc "BentCreek.netrep_norm'=if('BentCreek.netrep'>${lim},0,1-BentCreek.netrep'/${lim})"
r.mapcalc "BlueValley.netrep_norm'=if('BlueValley.netrep'>${lim},0,1-'BlueValley.netrep'/${lim})"
r.mapcalc "'Fernow.netrep_norm'=if('Fernow.netrep'>${lim},0,1-'Fernow.netrep'/${lim})"

r.out.gdal in=BentCreek.netrep_norm out=./export/BentCreek.netrep_norm.tif type=Float64 format=GTiff --o
r.out.gdal in=BlueValley.netrep_norm out=./export/BlueValley.netrep_norm.tif type=Float64 format=GTiff --o
r.out.gdal in=Fernow.netrep_norm out=./export/Fernow.netrep_norm.tif type=Float64 format=GTiff --o
fi        


#############################################################
if [ $MAP_INDIVIDUAL_LOOP -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o
RCASE=exp_forests_phase1
#lim=`r.quantile input=${RCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`
lim=32.199585

for((v=1; v<210; v++)) do
echo "Loop 1 v= $((v))"
code=`sed -n "$((v+1))p" site_key | awk '{print $3"_"$1}' | tr -d '"'`
echo "${code}"
awk -v col=$((v+2)) '{print $1" "$2" "$col}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${code}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
done

for((s=1; s<80; s++)) do
site=`sed -n "$((s+1))p" site_count | awk '{print $1}' | tr -d '"'`
list=`g.mlist type=rast pattern="*${site}_*" separator=","`
echo "processing ${site}"
echo "taking min of ${list}"
r.mapcalc "'${site}.netrep' = min(${list})"
r.mapcalc "'${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-'${site}.netrep'/${lim})"

g.mremove rast=`g.mlist type=rast pattern="*${site}_*" separator=","`
g.mremove rast=`g.mlist type=rast pattern="*${site}_*" separator=","` -f

r.out.gdal in=${site}.netrep_norm out=./export/${site}.netrep_norm.tif type=Float64 format=GTiff --o
done


fi
################################################################################
if [ $IDIVIDUAL_BINARY -eq 1 ]
then
 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o

for((s=1; s<80; s++)) do
site=`sed -n "$((s+1))p" site_count | awk '{print $1}' | tr -d '"'`
echo "processing ${site}"

r.recode input=${site}.netrep_norm output=${site}_binary rules=binary_rules.txt --o
r.mapcalc "${site}_binary = ${site}_binary"

r.out.gdal in=${site}_binary out=./binary_tifs/${site}_binary.tif type=Byte format=GTiff --o

done

r.mapcalc "EFRN_sumofbinary = Alum_Creek_binary+Argonne_Experimental_binary+Baltimore_Ecosystem_binary+Bartlett_Experimental_binary+Bent_Creek_binary+Big_Falls_binary+Black_Hills_binary+Blacks_Mountain_binary+Blue_Valley_binary+Boise_Basin_binary+Calhoun_Experimental_binary+Cascade_Head_binary+Caspar_Creek_binary+Challenge_Experimental_binary+Chipola_Experimental_binary+Coram_Experimental_binary+Coulee_Experimental_binary+Coweeta_Hydrologic_binary+Crossett_Experimental_binary+Cutfoot_Sioux_binary+Deception_Creek_binary+Delta_Experimental_binary+Desert_Experimental_binary+Dukes_Upper_binary+Entiat_Experimental_binary+Escambia_Experimental_binary+Fernow_Experimental_binary+Fort_Valley_binary+Fraser_Experimental_binary+Glacier_Lakes_binary+Great_Basin_binary+H._J._binary+Harrison_Experimental_binary+Henry_R._binary+Hill_Forest_binary+Hitchiti_Experimental_binary+Howland_Forest_binary+Hubbard_Brook_binary+Kane_Experimental_binary+Kaskaskia_Experimental_binary+Kawishiwi_Experimental_binary+Kings_River_binary+Long_Valley_binary+Lower_Peninsula_binary+Manitou_Experimental_binary+Marcell_Experimental_binary+Massabesic_Experimental_binary+North_Mountain_binary+Olustee_Experimental_binary+Olympic_Experimental_binary+Onion_Creek_binary+Palustris_Experimental_binary+Paoli_Experimental_binary+Penobscot_Experimental_binary+Pike_Bay_binary+Priest_River_binary+Pringle_Falls_binary+Redwood_Experimental_binary+Rhinelander_Experimental_binary+Sagehen_Experimental_binary+San_Dimas_binary+San_Joaquin_binary+Santee_Experimental_binary+Scull_Shoals_binary+Sierra_Ancha_binary+Silas_Little_binary+Sinkin_Experimental_binary+South_Umpqua_binary+StanislausTuolumne_Experimental_binary+Starkey_Experimental_binary+Stephen_F._binary+Swain_Mountain_binary+Sylamore_Experimental_binary+Tallahatchie_Experimental_binary+Teakettle_Experimental_binary+Tenderfoot_Creek_binary+Udell_Experimental_binary+Vinton_Furnace_binary+Wind_River_binary"
r.mask conus_forest_1km_NA --o
r.mapcalc "EFRN_sumofbinary_forest = EFRN_sumofbinary"
 r.stats -1gn input=EFRN_sumofbinary_forest>EFRN_sumofbinary.ascii
r.out.gdal in=EFRN_sumofbinary_forest out=./binary_tifs/EFRN_sumofbinary_forest.tif type=Byte format=GTiff --o
r.out.gdal in=EFRN_sumofbinary out=./binary_tifs/EFRN_sumofbinary.tif type=Byte format=GTiff --o


fi
