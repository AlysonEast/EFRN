#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


CALC=0
MAKE_DF=1

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
