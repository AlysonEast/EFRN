#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


CREATE_SITE_KEY=0
CALC_COWEETA=0
ID_COMPETING=0
MAP_COMPETING=1 
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


lim=`r.quantile input=${RCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`

r.mapcalc "BentCreek.netrep_norm'=if('BentCreek.netrep'>${lim},0,1-BentCreek.netrep'/${lim})"
r.mapcalc "BlueValley.netrep_norm'=if('BlueValley.netrep'>${lim},0,1-'BlueValley.netrep'/${lim})"
r.mapcalc "'Fernow.netrep_norm'=if('Fernow.netrep'>${lim},0,1-'Fernow.netrep'/${lim})"

r.out.gdal in=BentCreek.netrep_norm out=./export/BentCreek.netrep_norm.tif type=Float64 format=GTiff --o
r.out.gdal in=BlueValley.netrep_norm out=./export/BlueValley.netrep_norm.tif type=Float64 format=GTiff --o
r.out.gdal in=Fernow.netrep_norm out=./export/Fernow.netrep_norm.tif type=Float64 format=GTiff --o
fi        


#############################################################
if [ $EXTRACT_DATA_AT_EF -eq 1 ]
then

 RCASE=northamerica_forcasts_phase1
 CASE=exp_forests
 VCASE=exp_forests_multipoly
 NCOLS=10
 g.region rast=wc2.0_bio_30s_01_ann_temp
 variable_rast=("wc2.0_bio_30s_01_ann_temp" "wc2.0_bio_30s_02_diurnal_range" "wc2.0_bio_30s_03_isothermality" "wc2.0_bio_30s_04_temp_seasonality" "wc2.0_bio_30s_10_meant_warmqtr" "wc2.0_bio_30s_11_meant_coldqtr" "wc2.0_bio_30s_12_ann_precip" "wc2.0_bio_30s_15_precip_seasonality" "wc2.0_bio_30s_16_precip_dry_qtr" "wc2.0_bio_30s_17_precip_wet_qtr" "wc2.0_bio_30s_18_precip_warm_qtr" "wc2.0_bio_30s_19_precip_cold_qtr" "available_water_capacity_until_wilting_point_0-100cm_30sec" "bulk_density_0-100cm_mean_30sec" "nitrogen_0-100cm_mean_30sec" "ph_0-100cm_mean_30sec" "soil_organic_carbon_0-100cm_mean_30sec" "Forest_height_2019_CONUS_30sec" "aboveground_biomass_carbon_2010_Spawn2020" "gpp_dhi_coeffvariation" "gpp_dhi_cumulative")

echo "Extracting variable 1"
r.univar -t map=${variable_rast[1]} zones=${CASE} output=./UNIVAR/1univar.vect.out
cut -d '|' -f1,2,3,4,5,6,7,8,9,10,11,12 ./UNIVAR/1univar.vect.out >./univar.vect.out

for((v=1; v<21; v++)) do
 echo "Extracting variable $((v+1))"
   r.univar -t map=${variable_rast[v]} zones=${CASE} output=./UNIVAR/full_$((v+1))univar.vect.out
#Removing unessisary columsn
   cut -d '|' -f5,6,7,8,9,10,11,12 ./UNIVAR/full_$((v+1))univar.vect.out >./UNIVAR/$((v+1))univar.vect.out

#Changin Col names
   sed -i -e "1s/min|max|range|mean|mean_of_abs|stddev|variance|coeff_var/v$((v+1))min|v$((v+1))max|v$((v+1))range|v$((v+1))mean|v$((v+1))mean_of_abs|v$((v+1))stddev|v$((v+1))variance|v$((v+1))coeff_var/" ./UNIVAR/$((v+1))univar.vect.out

#Paste together all of the temp univar files
   paste ./univar.vect.out ./UNIVAR/$((v+1))univar.vect.out -d "|" > univar_scratch.vect.out
   mv univar_scratch.vect.out univar.vect.out
done


## Standardize 
#  echo "Standardizing data"
#  ROWS=`wc -l ${CASE}.vect.out | awk '{print $1}'`
#  COLS=`head -n 1 ${CASE}.vect.out | wc -w`
#  time ${STANDARDIZE} -v -t -r ${ROWS} -c ${COLS} -M mean.${RCASE}.orig -S stddev.${RCASE}.orig -o ${CASE}.vect.out.std ${CASE}.vect.out
#
fi
############################################################################
#Pulling out means
if [ $RESTRUCTURE_UNIVAR -eq 1 ]
then

RCASE=northamerica_forcasts_phase1
CASE=exp_forests_phase1

#Create ascii file of exp forest polygon means
awk 'BEGIN { FS="|"; }
 {print $8" "$16" "$24" "$32" "$40" "$48" "$56" "$64" "$72" "$80" "$88" "$96" "$104" "$112" "$120" "$128" "$136" "$144" "$152" "$160" "$168}' univar.vect.out > ${CASE}.mean.vect.out
sed '1d' ${CASE}.mean.vect.out > temp
mv temp ${CASE}.mean.vect.out

## Standardize means
  echo "Standardizing data"
  ROWS=`wc -l ${CASE}.mean.vect.out | awk '{print $1}'`
  COLS=`head -n 1 ${CASE}.mean.vect.out | wc -w`
  time ${STANDARDIZE} -v -t -r ${ROWS} -c ${COLS} -M mean.${RCASE}.orig -S stddev.${RCASE}.orig -o ${CASE}.mean.vect.out.std ${CASE}.mean.vect.out

#Create ascii file of exp forest polygon Standard Deviations
awk 'BEGIN { FS="|"; }
 {print $10" "$18" "$26" "$34" "$42" "$50" "$58" "$66" "$74" "$82}' univar.vect.out > ${CASE}.stddev.vect.out
sed '1d' ${CASE}.stddev.vect.out > temp
mv temp ${CASE}.stddev.vect.out

fi
################################################################################

#############################################################################
if [ $CALCULATE_REPRESENTATIVENESS -eq 1 ]
then

 RCASE=northamerica_forcasts_phase1
 CASE=exp_forests_phase1

 indatafilename=obs.ascii.${RCASE}
 sitefilename=${CASE}.mean.vect.out.std
 coordsfilename=coords.${RCASE}
 outfilename=../representativeness/${CASE}.representativeness
 MINMAXFILE=obs.ascii.${RCASE}.minmax

nrows=`wc -l ${indatafilename} | awk '{print $1}'`
ncols=`head -n 1 ${indatafilename}| wc -w`

nsites=`wc -l ${sitefilename} | awk '{print $1}'`
# Calculate representativeness for all 18 sites. 19th column is the
# network min distance
# python network_representativeness.py $indatafilename $sitefilename $coordsfilename $outfilename $nrows $ncols $nsites

${NETWORK_REPRESENTATIVENESS} -infile ${indatafilename} \
                              -nrows ${nrows} \
                              -ncols ${ncols} \
                              -sitefile ${sitefilename} \
                              -nsites ${nsites} \
                              -coordsfile ${coordsfilename} \
                              -outfile ${outfilename} \
                              -allsitesrep \
                              -details

fi
############################################################################################
if [ $IMPORT_REPRESENTATIVENESS_MAPS -eq 1 ]
then
 
 g.region rast=wc2.0_bio_30s_01_ann_temp
 CASE=exp_forests_phase1
# ncol=`head -n 1 ../representativeness/${CASE}.representativeness | wc -w`
# col=${ncol}-1
 r.mask -r
awk '{print $1" "$2" "$(NF-22)}' ../representativeness/${CASE}.representativeness >temp
r.in.xyz in=temp out=${CASE}.netrep x=1 y=2 z=3 type=FCELL fs=space --o

r.mask conus_forest_1km_NA --o
#max=`r.univar exp_forests.netrep -g | awk 'BEGIN {FS="="}; {print $2}' | sed -n '5p'`
lim=`r.quantile input=${CASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`
r.mask -r

 r.mapcalc "'${CASE}.netrep_norm'=if('${CASE}.netrep'>${lim},0,1-'${CASE}.netrep'/${lim})"
 r.mapcalc "'${CASE}.netrep_norm_int' = int('${CASE}.netrep_norm' * 100)"
 rm temp
fi


################################################################################
if [ $IMPORT_CONSTITUENCY_MAPS -eq 1 ]
then
CASE=exp_forests_phase1
# ncol=`head -n 1 ../representativeness/${CASE}.representativeness | wc -w`
#Last number is number of sites +4
 g.region rast=${CASE}.netrep
 r.mask -r
 awk '{print $1" "$2" "$(NF-21)}' ../representativeness/${CASE}.representativeness >temp
 r.in.xyz in=temp out=${CASE}.constituency_int x=1 y=2 z=3 type=CELL fs=space --o

#Pull out numbers from univer to account for missing observations
 awk 'BEGIN {FS="|"}; {print NR-1" = "$1}' univar.vect.out | sed '1d'>constit_reclass_1.txt

#Reclassify from univar table to make vector DB values match
 r.reclass input=${CASE}.constituency_int output=${CASE}.constituency_step rules=constit_reclass_1.txt --o

#pull out pultipoly values and entire exp forest values
 v.db.select exp_forests_multipoly | awk 'BEGIN {FS="|"}; {print $1" = "$2}' | sed '1d'>constit_reclass.txt

#reclassify again to get final exp forest constit map
 r.reclass input=${CASE}.constituency_step output=${CASE}.constituency rules=constit_reclass.txt --o
 r.mapcalc "${CASE}.constituency = ${CASE}.constituency"

 rm temp
fi

####################################################################################
if [ $GENERATE_DRIVERS_MAP -eq 1 ]
then
 NCASE=exp_forests_phase1.netrep_drivers
 CASE=exp_forests_phase1

 g.region rast=${CASE}.netrep
 r.mask -r
 awk '{print $1" "$2" "$(NF-20)" "$(NF-19)" "$(NF-18)" "$(NF-17)" "$(NF-16)" "$(NF-15)" "$(NF-14)" "$(NF-13)" "$(NF-12)" "$(NF-11)" "$(NF-10)" "$(NF-9)" "$(NF-8)" "$(NF-7)" "$(NF-6)" "$(NF-5)" "$(NF-4)" "$(NF-3)" "$(NF-2)" "$(NF-1)" "$(NF)}' ../representativeness/${CASE}.representativeness >${NCASE}

#for((v=1; v<22; v++)) do
# echo "Extracting variable $((v))"
#r.in.xyz in=${NCASE} out=${NCASE}_PC$((v)) x=1 y=2 z=$((2+v)) type=CELL fs=space --o
# done

./netrep_drivers.R

awk 'BEGIN {FS=","}; {print $2" "$3" "$(NF-2)" "$(NF-1)" "$(NF)}' temp.csv | sed '1d' >temp

r.in.xyz in=temp out=${NCASE}_min x=1 y=2 z=3 type=CELL fs=space --o
r.in.xyz in=temp out=${NCASE}_max x=1 y=2 z=4 type=CELL fs=space --o
r.in.xyz in=temp out=${NCASE}_max_value x=1 y=2 z=5 type=CELL fs=space --o

r.mapcalc "${NCASE}_max_pct = (${NCASE}_max_value/${CASE}.netrep)"

fi
################################################################################
if [ $CALC_SRS -eq 1 ]
then
 CASE=exp_forests_phase1
 NCASE=exp_forests_SRS_phase1

 r.mask SRS --o

 r.mapcalc "${NCASE}.netrep = ${CASE}.netrep"
 r.mapcalc "${NCASE}.constituency = ${CASE}.constituency"

r.mask conus_forest_1km_NA --o
lim=`r.univar ${NCASE}.netrep -g | awk 'BEGIN {FS="="}; {print $2}' | sed -n '5p'`
r.mask -r

 r.mapcalc "'${NCASE}.netrep_norm'=if('${NCASE}.netrep'>${lim},0,1-'${NCASE}.netrep'/${lim})"
 r.mapcalc "'${NCASE}.netrep_norm_int' = int('${NCASE}.netrep_norm' * 100)"

fi
#############################################################
if [ $EXPORT_TIF -eq 1 ]
then
 CASE=exp_forests_phase1
 NCASE=exp_forests_SRS_phase1
 g.region rast=${CASE}.netrep
  r.mask conus_forest_1km_NA --o


  r.out.gdal in=${CASE}.netrep out=./export/${CASE}.netrep.tif type=Float64 format=GTiff --o
  r.out.gdal in=${CASE}.netrep_norm out=./export/${CASE}.netrep_norm.tif type=Float64 format=GTiff --o
  r.out.gdal in=${CASE}.constituency out=./export/${CASE}.constituency.tif type=Float64 format=GTiff --o

  r.out.gdal in=${CASE}.netrep_drivers_max out=./export/${CASE}.netrep_drivers_max.tif type=Float64 format=GTiff --o
  r.out.gdal in=${CASE}.netrep_drivers_min out=./export/${CASE}.netrep_drivers_min.tif type=Float64 format=GTiff --o

  r.out.gdal in=${NCASE}.netrep out=./export/${NCASE}.netrep.tif type=Float64 format=GTiff --o
  r.out.gdal in=${NCASE}.netrep_norm out=./export/${NCASE}.netrep_norm.tif type=Float64 format=GTiff --o
  r.out.gdal in=${NCASE}.constituency out=./export/${NCASE}.constituency.tif type=Float64 format=GTiff --o
fi
####################################################################################################3
