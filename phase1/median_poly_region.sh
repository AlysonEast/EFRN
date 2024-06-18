#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


EXTRACT_DATA_AT_EF=1
RESTRUCTURE_UNIVAR=1

#############################################################
if [ $EXTRACT_DATA_AT_EF -eq 1 ]
then

 RCASE=northamerica_forcasts_phase1
 CASE=exp_forests
 VCASE=exp_forests_multipoly
 NCOLS=10
 g.region rast=wc2.0_bio_30s_01_ann_temp
 g.region n=52:06N s=24:19:30N e=62:05W w=130:18W
 r.mask USFS_regions --o
 variable_rast=("wc2.0_bio_30s_01_ann_temp" "wc2.0_bio_30s_02_diurnal_range" "wc2.0_bio_30s_03_isothermality" "wc2.0_bio_30s_04_temp_seasonality" "wc2.0_bio_30s_10_meant_warmqtr" "wc2.0_bio_30s_11_meant_coldqtr" "wc2.0_bio_30s_12_ann_precip" "wc2.0_bio_30s_15_precip_seasonality" "wc2.0_bio_30s_16_precip_dry_qtr" "wc2.0_bio_30s_17_precip_wet_qtr" "wc2.0_bio_30s_18_precip_warm_qtr" "wc2.0_bio_30s_19_precip_cold_qtr" "available_water_capacity_until_wilting_point_0-100cm_30sec" "bulk_density_0-100cm_mean_30sec" "nitrogen_0-100cm_mean_30sec" "ph_0-100cm_mean_30sec" "soil_organic_carbon_0-100cm_mean_30sec" "Forest_height_2019_CONUS_30sec" "aboveground_biomass_carbon_2010_Spawn2020" "gpp_dhi_coeffvariation" "gpp_dhi_cumulative" "USFS_regions")

echo "Extracting variable 1"
r.univar -t map=${variable_rast[1]} zones=${CASE} output=./UNIVAR/1univar.vect.out
cut -d '|' -f1,2,3,4,5,6,7,8,9,10,11,12 ./UNIVAR/1univar.vect.out >./univar.vect.out

for((v=1; v<22; v++)) do
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
CASE=exp_forests_phase1_byregion

#Create ascii file of exp forest polygon means
awk 'BEGIN { FS="|"; }
 {print $8" "$16" "$24" "$32" "$40" "$48" "$56" "$64" "$72" "$80" "$88" "$96" "$104" "$112" "$120" "$128" "$136" "$144" "$152" "$160" "$168" "$176}' univar.vect.out > ${CASE}.mean.vect.out
sed '1d' ${CASE}.mean.vect.out > temp
mv temp ${CASE}.mean.vect.out

## Standardize means
  echo "Standardizing data"
  ROWS=`wc -l ${CASE}.mean.vect.out | awk '{print $1}'`
  COLS=`head -n 1 ${CASE}.mean.vect.out | wc -w`
  time ${STANDARDIZE} -v -t -r ${ROWS} -c ${COLS} -M mean.${RCASE}.orig -S stddev.${RCASE}.orig -o ${CASE}.mean.vect.out.std ${CASE}.mean.vect.out

fi
################################################################################
