#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

HISTOGRAM=0
QUARTILE_RELASS=0
ZONAL_SUMMARIES=1

#############################################################                                                                               
if [ $HISTOGRAM -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask conus_forest_1km_NA --o 

 CASE=exp_forests_phase1

 echo "0">quantile_reclass.txt
 cutoffs=`r.quantile input=${CASE}.netrep_norm percentile=25,50,75 | awk 'BEGIN {FS=":"}; {print $3}'`
 r.quantile input=${CASE}.netrep_norm percentile=25,50,75 | awk 'BEGIN {FS=":"}; {print $3}'>>quantile_reclass.txt
 sed -i 's/$/:/' quantile_reclass.txt
 sed -i '1s/$/:1/' quantile_reclass.txt 
 sed -i '2s/$/:2/' quantile_reclass.txt 
 sed -i '3s/$/:3/' quantile_reclass.txt 
 sed -i '4s/$/:4/' quantile_reclass.txt 
fi
#############################################################                                                                               
if [ $QUARTILE_RELASS -eq 1 ]
then
 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask conus_forest_1km_NA --o 

 CASE=exp_forests_phase1
 r.recode input=${CASE}.netrep_norm output=${CASE}.quartiles rules=quantile_reclass.txt --o
 r.out.gdal in=${CASE}.quartiles out=./export/${CASE}.quartiles.tif type=Float64 format=GTiff --o
fi
############################################################################
if [ $ZONAL_SUMMARIES -eq 1 ]
then
 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask conus_forest_1km_NA --o

 CASE=exp_forests_phase1

 r.stats -1gn input=${CASE}.quartiles,aboveground_biomass_carbon_2010_Spawn2020,USFS_regions>quantile_data
 r.stats -1gn input=${CASE}.quartiles,biomass_calc.sh,USFS_regions>quantile_data_biodiver

fi
################################################################################
