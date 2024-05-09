#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


CALC=0
MAKE_DF=1
GENERATE_DRIVERS_MAP=0
CALC_SRS=0
EXPORT_TIF=0

#############################################################                                                                               
if [ $CALC -eq 1 ]
then
 
 g.region rast=wc2.0_bio_30s_01_ann_temp
 CASE0=exp_forests_phase0
 CASE1=exp_forests_phase1
 r.mask conus_forest_1km_NA --o

 r.mapcalc "'phase0phase1.netrep_norm.diff' = '${CASE1}.netrep_norm' - '${CASE0}.netrep_norm'"
 r.out.gdal in=phase0phase1.netrep_norm.diff out=./export/phase0phase1.netrep_norm.diff.tif type=Float64 format=GTiff --o

 r.mapcalc "phase0phase1.constituency.diff = ${CASE0}.constituency - ${CASE1}.constituency"
 r.recode input=phase0phase1.constituency.diff output=phase0phase1.constituency.diff_binary rules=constit_change_binary.txt --o 
 r.mapcalc "phase0phase1.constituency.diff_binary = phase0phase1.constituency.diff_binary"
 r.null map=phase0phase1.constituency.diff_binary setnull=0
 r.out.gdal in=phase0phase1.constituency.diff_binary out=./export/phase0phase1.constituency.diff_binary.tif type=Float64 format=GTiff --o

 r.mask phase0phase1.constituency.diff_binary --o
 r.mapcalc "${CASE0}.constituency = ${CASE0}.constituency.diff_area"
 r.out.gdal in=${CASE0}.constituency out=./export/${CASE0}.constituency.diff_area.tif type=Float64 format=GTiff --o
 r.mapcalc "${CASE1}.constituency = ${CASE1}.constituency.diff_area"
 r.out.gdal in=${CASE1}.constituency out=./export/${CASE1}.constituency.diff_area.tif type=Float64 format=GTiff --o

fi


################################################################################
if [ $MAKE_DF -eq 1 ]
then
 g.region rast=wc2.0_bio_30s_01_ann_temp
 CASE0=exp_forests_phase0
 CASE1=exp_forests_phase1
 r.mask conus_forest_1km_NA --o

 r.stats -1gn input=phase0phase1.constituency.diff_binary,${CASE0}.constituency.diff_area,${CASE1}.constituency.diff_area,${CASE0}.netrep_norm,${CASE1}.netrep_norm >constit_netrep_changephase1phase0
 sed -i "1s/^/Lat Lon constituency.diff phase0_constit_changed phase1_constit_changed phase0_netrep_norm phase1_netrep_norm\n/" ./constit_netrep_changephase1phase0

fi

####################################################################################
if [ $GENERATE_DRIVERS_MAP -eq 1 ]
then
 NCASE=exp_forests_phase0.netrep_drivers
 CASE=exp_forests_phase0

 g.region rast=${CASE}.netrep
 r.mask -r
 awk '{print $1" "$2" "$(NF-16)" "$(NF-15)" "$(NF-14)" "$(NF-13)" "$(NF-12)" "$(NF-11)" "$(NF-10)" "$(NF-9)" "$(NF-8)" "$(NF-7)" "$(NF-6)" "$(NF-5)" "$(NF-4)" "$(NF-3)" "$(NF-2)" "$(NF-1)" "$(NF)}' ../representativeness/${CASE}.representativeness >${NCASE}

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
 CASE=exp_forests_phase0
 NCASE=exp_forests_SRS_phase0

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
 CASE=exp_forests_phase0
 NCASE=exp_forests_SRS_phase0
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
