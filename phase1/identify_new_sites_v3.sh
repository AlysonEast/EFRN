#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MACHINE=theseus
STANDARDIZE=/home/jbk/bin/standardize.${MACHINE}
NETWORK_REPRESENTATIVENESS=/home/jbk/bin/network_representativeness


MAP_POOR_REP=0
ID_NEW_SITES=0
CALC_NETREP=1
CALCULATE_REPRESENTATIVENESS_TOPSITE=0
IMPORT_REPRESENTATIVENESS_MAPS=0

#g.region rast=wc2.0_bio_30s_01_ann_temp
# r.mask conus_forest_1km_NA --o
#r.quantile input=exp_forests_phase1.netrep_norm percentile=25,50

#CASE=exp_forests_phase1
#lim=`r.quantile input=${CASE}.netrep_norm percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`


#############################################################
if [ $MAP_POOR_REP -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 r.mask USFS_regions --o

 r.reclass input=exp_forests_phase1.netrep_norm_int output=conus_poor_rep rules=poor_rep_lims.txt --o
 r.mask conus_forest_1km_NA --o
 r.mapcalc "conus_poor_rep = conus_poor_rep"

d.mon x3
d.rast conus_poor_rep

CASE=conus_poor_rep
RCASE=northamerica_forcasts_phase1
 
 r.mask conus_poor_rep --o
 
 r.stats -1gn input=wc2.0_bio_30s_01_ann_temp,wc2.0_bio_30s_02_diurnal_range,wc2.0_bio_30s_03_isothermality,wc2.0_bio_30s_04_temp_seasonality,wc2.0_bio_30s_10_meant_warmqtr,wc2.0_bio_30s_11_meant_coldqtr,wc2.0_bio_30s_12_ann_precip,wc2.0_bio_30s_15_precip_seasonality,wc2.0_bio_30s_16_precip_dry_qtr,wc2.0_bio_30s_17_precip_wet_qtr,wc2.0_bio_30s_18_precip_warm_qtr,wc2.0_bio_30s_19_precip_cold_qtr,available_water_capacity_until_wilting_point_0-100cm_30sec,bulk_density_0-100cm_mean_30sec,nitrogen_0-100cm_mean_30sec,ph_0-100cm_mean_30sec,soil_organic_carbon_0-100cm_mean_30sec,Forest_height_2019_CONUS_30sec,aboveground_biomass_carbon_2010_Spawn2020,gpp_dhi_coeffvariation,gpp_dhi_cumulative >data.out

 awk '{$1=$2=""}1' data.out >obs.raw.${CASE}
 awk '{print $1" "$2}' data.out >coords.${CASE}
 ROWS=`wc -l obs.raw.${CASE} | awk '{print $1}'`
 COLS=`head -n 1 obs.raw.${CASE}| wc -w`
 time ${STANDARDIZE} -v -t -r ${ROWS} -c ${COLS} -M mean.${RCASE}.orig -S stddev.${RCASE}.orig -o obs.ascii.${CASE} obs.raw.${CASE}


fi
#############################################################################3
if [ $ID_NEW_SITES -eq 1 ]
then


CASE=prospective_exp_forests

g.region rast=wc2.0_bio_30s_01_ann_temp
r.mask conus_poor_rep --o

v.to.rast input=PADUS_Forested type=area output=PADUS_Forested use=attr column=cat --o
r.mask conus_poor_rep --o
r.mapcalc "PADUS_Forested = PADUS_Forested"


r.mask -r
r.cats PADUS_Forested >site_nums

sites=`awk '{print $1}' site_nums | paste -s -d, `
v.extract input=PADUS_Forested output=${CASE} type=area list=${sites} --o
v.to.rast input=${CASE} type=area output=${CASE} use=attr column=cat --o

variable_rast=("wc2.0_bio_30s_01_ann_temp" "wc2.0_bio_30s_02_diurnal_range" "wc2.0_bio_30s_03_isothermality" "wc2.0_bio_30s_04_temp_seasonality" "wc2.0_bio_30s_10_meant_warmqtr" "wc2.0_bio_30s_11_meant_coldqtr" "wc2.0_bio_30s_12_ann_precip" "wc2.0_bio_30s_15_precip_seasonality" "wc2.0_bio_30s_16_precip_dry_qtr" "wc2.0_bio_30s_17_precip_wet_qtr" "wc2.0_bio_30s_18_precip_warm_qtr" "wc2.0_bio_30s_19_precip_cold_qtr" "available_water_capacity_until_wilting_point_0-100cm_30sec" "bulk_density_0-100cm_mean_30sec" "nitrogen_0-100cm_mean_30sec" "ph_0-100cm_mean_30sec" "soil_organic_carbon_0-100cm_mean_30sec" "Forest_height_2019_CONUS_30sec" "aboveground_biomass_carbon_2010_Spawn2020" "gpp_dhi_coeffvariation" "gpp_dhi_cumulative")

echo "Extracting variable 1"
r.univar -t map=${variable_rast[1]} zones=${CASE} output=./UNIVAR/1univar.vect.out
cut -d '|' -f1,2,3,4,5,6,7,8,9,10,11,12 ./UNIVAR/1univar.vect.out >./univar_prospective.vect.out

for((v=1; v<21; v++)) do
 echo "Extracting variable $((v+1))"
   r.univar -t map=${variable_rast[v]} zones=${CASE} output=./UNIVAR/full_$((v+1))univar_prospective.vect.out
#Removing unessisary columsn
   cut -d '|' -f5,6,7,8,9,10,11,12 ./UNIVAR/full_$((v+1))univar_prospective.vect.out >./UNIVAR/$((v+1))univar_prospective.vect.out

#Changin Col names
   sed -i -e "1s/min|max|range|mean|mean_of_abs|stddev|variance|coeff_var/v$((v+1))min|v$((v+1))max|v$((v+1))range|v$((v+1))mean|v$((v+1))mean_of_abs|v$((v+1))stddev|v$((v+1))variance|v$((v+1))coeff_var/" ./UNIVAR/$((v+1))univar_prospective.vect.out

#Paste together all of the temp univar files
   paste ./univar_prospective.vect.out ./UNIVAR/$((v+1))univar_prospective.vect.out -d "|" > univar_scratch.vect.out
   mv univar_scratch.vect.out univar_prospective.vect.out
done


RCASE=northamerica_forcasts_phase1

#Create ascii file of exp forest polygon means
awk 'BEGIN { FS="|"; }
 {print $8" "$16" "$24" "$32" "$40" "$48" "$56" "$64" "$72" "$80" "$88" "$96" "$104" "$112" "$120" "$128" "$136" "$144" "$152" "$160" "$168}' univar_prospective.vect.out > ${CASE}.mean.vect.out
sed '1d' ${CASE}.mean.vect.out > temp
mv temp ${CASE}.mean.vect.out

## Standardize means
  echo "Standardizing data"
  ROWS=`wc -l ${CASE}.mean.vect.out | awk '{print $1}'`
  COLS=`head -n 1 ${CASE}.mean.vect.out | wc -w`
  time ${STANDARDIZE} -v -t -r ${ROWS} -c ${COLS} -M mean.${RCASE}.orig -S stddev.${RCASE}.orig -o ${CASE}.mean.vect.out.std ${CASE}.mean.vect.out


fi 
###########################################################################
if [ $CALC_NETREP -eq 1 ]
then
 
 r.mask USFS_regions --o
 r.stats -1gn input=conus_poor_rep_0,exp_forests_phase1.netrep>Site_selection_reference

 RCASE=northamerica_forcasts_phase1
 OldCASE=prospective_exp_forests
 CASE=prospective_exp_forests_v3

#pick out the first col

#sed -n '1'p  ${OldCASE}.mean.vect.out.std >seed
 sed -n '1,1000'p  ${OldCASE}.mean.vect.out.std >seed

 indatafilename=obs.ascii.${RCASE}
 sitefilename=seed
 coordsfilename=coords.${RCASE}
 outfilename=../representativeness/${CASE}.representativeness

 nrows=`wc -l ${indatafilename} | awk '{print $1}'`
 ncols=`head -n 1 ${indatafilename}| wc -w`

 nsites=`wc -l ${sitefilename} | awk '{print $1}'`

# ${NETWORK_REPRESENTATIVENESS} -infile ${indatafilename} \
#                               -nrows ${nrows} \
#                               -ncols ${ncols} \
#                               -sitefile ${sitefilename} \
#                               -nsites ${nsites} \
#                               -coordsfile ${coordsfilename} \
#                               -outfile ${outfilename} \
#    			      -allsitesrep 

#r.mapcalc "'${CASE}.netrep_norm'=if('${CASE}.netrep'>${lim},0,1-'${CASE}.netrep'/${lim})"
# Poor rep cutoff = 0.765405
# 99% lim for scaling= 42.191788
# 0.765405 = 1 - ( x / 42.191788)
# x=9.897982506

# paste -d' ' Site_selection_reference ../representativeness/${CASE}.representativeness >tmp

# awk '$3 > 1' tmp >tmp2

 lim=`awk ' { print $4 } ' tmp2 | sort -n | sed -n '1'p`

 
 awk -v lim="${lim}" '$7 <= lim' tmp2 | 
	wc -l >PADUS_counts_v3
 awk -v lim="${lim}" '$7 <= lim' tmp2 | 
	awk '{ sum += $7; n++ } END { if (n > 0) print sum / n; else print "NA"; }' >PADUS_values_v3

 for((v=1; v<1001; v++)) do
  echo "processing $((v+1))"
  awk -v col="$((v+7))" lim="${lim}" '$col <= lim' tmp2 | 
	wc -l >>PADUS_counts_v3 |
  awk -v col="$((v+7))" lim="${lim}" '$col <= lim' tmp2 | 
	awk '{ sum += $col; n++ } END { if (n > 0) print sum / n; else print "NA"; }' >>PADUS_values_v3

 done
#t2=`date`
#echo "$t2-$t1"

#n=`wc -l ${OldCASE}.mean.vect.out.std | awk '{print $1}'`
#
#for((v=1; v<${n}; v++)) do
#echo "processing $((v+1)) of ${n}"
#sed -n "$((v+1))"p  ${OldCASE}.mean.vect.out.std >seed

#${NETWORK_REPRESENTATIVENESS} -infile ${indatafilename} \
#                              -nrows ${nrows} \
#                              -ncols ${ncols} \
#                              -sitefile ${sitefilename} \
#                              -nsites ${nsites} \
#                              -coordsfile ${coordsfilename} \
#                              -outfile ${outfilename} \

#awk '$3 <= 9.897982506' ../representativeness/${CASE}.representativeness | wc -l >>PADUS_counts_v2
#awk '$3 <= 9.897982506' ../representativeness/${CASE}.representativeness | awk '{ sum += $3; n++ } END { if (n > 0) print sum / n; else print "NA"; }' >>PADUS_values_v2
#awk ' {print $3} ' ../representativeness/${CASE}.representativeness | sort -n | awk ' { a[i++]=$1; } END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }' >>PADUS_values

#done

#r.cats ${OldCASE} >site_nums
#paste -d' ' site_nums PADUS_counts_v2 PADUS_values_v2 PADUS_values >PADUS_list_v2

#v.out.ogr input=${CASE} type=area dsn=./export format=ESRI_Shapefile --o

fi
#############################################################################
if [ $CALCULATE_REPRESENTATIVENESS_TOPSITE -eq 1 ]
then

 RCASE=northamerica_forcasts_phase1
 CASE=Top_site

 g.region rast=wc2.0_bio_30s_01_ann_temp
 g.region n=52:06N s=24:19:30N e=62:05W w=130:18W
 r.mask -r

 v.in.ogr dsn=../data/ layer=Top_site output=Top_site --o
 v.to.rast input=Top_site type=area output=Top_site use=attr column=cat --o

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

cp exp_forests_phase1.mean.vect.out.std tmp
cat ${CASE}.mean.vect.out.std >>tmp
mv tmp ${CASE}.mean.vect.out.std



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
##########################################################################
 if [ $IMPORT_REPRESENTATIVENESS_MAPS -eq 1 ]
 then
 g.region rast=wc2.0_bio_30s_01_ann_temp
 CASE=Top_site
 OldCASE=exp_forests_phase1
 r.mask -r
 
 awk '{print $1" "$2" "$(NF-22)}' ../representativeness/${CASE}.representativeness >temp
 r.in.xyz in=temp out=${CASE}.netrep x=1 y=2 z=3 type=FCELL fs=space --o

 r.mask conus_forest_1km_NA --o

 lim=`r.quantile input=${OldCASE}.netrep percentile=99 | awk 'BEGIN {FS=":"}; {print $3}'`
 r.mask -r

 r.mapcalc "'${CASE}.netrep_norm'=if('${CASE}.netrep'>${lim},0,1-'${CASE}.netrep'/${lim})"
 rm temp

 r.mask conus_forest_1km_NA --o
 r.stats -1gn input=${OldCASE}.netrep,${CASE}.netrep>${CASE}_change
 awk '$3 <= 9.897982506' ./${CASE}_change | wc -l
 awk '$4 <= 9.897982506' ./${CASE}_change | wc -l

 fi
 

