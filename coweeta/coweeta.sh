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
if [ $MAP_INDIVIDUAL -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o
RCASE=exp_forests_phase1
lim=`r.quantile input=${RCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`

site=Redwood
awk '{print $1" "$2" "$(1+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Udell
awk '{print $1" "$2" "$(6+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Tenderfoot
awk '{print $1" "$2" "$(7+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Teakettle
awk '{print $1" "$2" "$(8+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Swain
awk '{print $1" "$2" "$(9+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Starkey
awk '{print $1" "$2" "$(10+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=SouthUmpqua
awk '{print $1" "$2" "$(13+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Sinkin
awk '{print $1" "$2" "$(14+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Silas
awk '{print $1" "$2" "$(15+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=SanJoaquin
awk '{print $1" "$2" "$(16+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=SanDimas
awk '{print $1" "$2" "$(17+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Sagehen
awk '{print $1" "$2" "$(18+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=PriestRiver
awk '{print $1" "$2" "$(22+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=PikeBay
awk '{print $1" "$2" "$(23+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Paoli
awk '{print $1" "$2" "$(26+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=OnionCreek
awk '{print $1" "$2" "$(27+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Manitou
awk '{print $1" "$2" "$(132+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=LowerPeninsula
awk '{print $1" "$2" "$(133+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=LongValley
awk '{print $1" "$2" "$(134+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Manitou
awk '{print $1" "$2" "$(135+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Kane
awk '{print $1" "$2" "$(138+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=HubbardBrook
awk '{print $1" "$2" "$(139+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Howland
awk '{print $1" "$2" "$(140+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=HJAndrews
awk '{print $1" "$2" "$(141+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=GreatBasin
awk '{print $1" "$2" "$(144+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Glacier
awk '{print $1" "$2" "$(145+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Fraser
awk '{print $1" "$2" "$(146+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Entiat
awk '{print $1" "$2" "$(152+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Desert
awk '{print $1" "$2" "$(159+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Deception
awk '{print $1" "$2" "$(160+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Cutfoot
awk '{print $1" "$2" "$(161+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Crossett
awk '{print $1" "$2" "$(162+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Coulee
awk '{print $1" "$2" "$(163+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Coram
awk '{print $1" "$2" "$(164+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Challenge
awk '{print $1" "$2" "$(165+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Caspar
awk '{print $1" "$2" "$(166+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=BlackMountain                                                                                                                 
awk '{print $1" "$2" "$(172+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=BlackHills
awk '{print $1" "$2" "$(173+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Bartlett
awk '{print $1" "$2" "$(179+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Argonne
awk '{print $1" "$2" "$(182+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Sierra
awk '{print $1" "$2" "$(183+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Austin
awk '{print $1" "$2" "$(184+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Calhoun
awk '{print $1" "$2" "$(191+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Santee
awk '{print $1" "$2" "$(192+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Hitchiti
awk '{print $1" "$2" "$(194+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=ALumCreek
awk '{print $1" "$2" "$(195+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Koen
awk '{print $1" "$2" "$(196+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Tallahatchie
awk '{print $1" "$2" "$(197+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Sylamore
awk '{print $1" "$2" "$(198+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Chipola
awk '{print $1" "$2" "$(199+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Escambia                                                                                                        
awk '{print $1" "$2" "$(204+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Delta
awk '{print $1" "$2" "$(207+2)}' ../representativeness/${RCASE}.representativeness >temp
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

site=Harrison                                                                                            
awk '{print $1" "$2" "$(208+2)}' ../representativeness/${RCASE}.representativeness >temp                                                    
r.in.xyz in=temp out=${site}.netrep x=1 y=2 z=3 type=FCELL fs=space --o
r.mapcalc "${site}.netrep_norm'=if('${site}.netrep'>${lim},0,1-${site}.netrep'/${lim})"

#Multipart Sites



fi
