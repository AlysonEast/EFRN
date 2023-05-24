#!/bin/bash
RUN_PCA=1
EXTRACT_TOP10_PC=1
IMPORT_PC10=1
PCA_UNIVAR=0
PCA_SUBSET_CROPLANDS=0
EXPORT_PCS_BY_SITE=0


if [ $RUN_PCA -eq 1 ]
then
 python incremental_pca.py
fi

if [ $EXTRACT_TOP10_PC -eq 1 ]
then
 # Extract top 10 PCs that explain 90% of variability
 awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10}' pca.northamerica_forcasts_pc >pca.northamerica_forcasts_pc.10pcs
fi

if [ $IMPORT_PC10 -eq 1 ]
then

 grasscr global_latlon experimental_forests 
 CASE=northamerica_forcasts_pc
 g.region rast=wc2.0_bio_30s_01_ann_temp

 paste -d " " ../coords.northamerica_forcasts_pc pca.northamerica_forcasts_pc.10pcs >temp
 r.in.xyz in=temp x=1 y=2 z=3 fs=space out=northamerica_forcasts_pc.pc1
 r.in.xyz in=temp x=1 y=2 z=4 fs=space out=northamerica_forcasts_pc.pc2
 r.in.xyz in=temp x=1 y=2 z=5 fs=space out=northamerica_forcasts_pc.pc3
 r.in.xyz in=temp x=1 y=2 z=6 fs=space out=northamerica_forcasts_pc.pc4
 r.in.xyz in=temp x=1 y=2 z=7 fs=space out=northamerica_forcasts_pc.pc5
 r.in.xyz in=temp x=1 y=2 z=8 fs=space out=northamerica_forcasts_pc.pc6
 r.in.xyz in=temp x=1 y=2 z=9 fs=space out=northamerica_forcasts_pc.pc7
 r.in.xyz in=temp x=1 y=2 z=10 fs=space out=northamerica_forcasts_pc.pc8
 r.in.xyz in=temp x=1 y=2 z=11 fs=space out=northamerica_forcasts_pc.pc9
 r.in.xyz in=temp x=1 y=2 z=12 fs=space out=northamerica_forcasts_pc.pc10

fi

if [ $PCA_UNIVAR -eq 1 ]
then 

 grasscr global_latlon ltar_regionalization
 CASE=ltar_experiment_bndy_a_10142020_v2
 g.region rast=ltar_18sites_v1.netrep

#r.univar -et map=conus_forcasts.pc1 zones=ltar_experiment_bndy_a_10142020_v2.constituency_reclassed percentile=5,10,25,75,90,95 out=pc1_ltar.univar  
#r.univar -et map=conus_forcasts.pc2 zones=ltar_experiment_bndy_a_10142020_v2.constituency_reclassed percentile=5,10,25,75,90,95 out=pc2_ltar.univar  
#r.univar -et map=conus_forcasts.pc3 zones=ltar_experiment_bndy_a_10142020_v2.constituency_reclassed percentile=5,10,25,75,90,95 out=pc3_ltar.univar  

 r.univar -et map=conus_forcasts.pc1 zones=ltar_experiment_bndy_a_10142020_v2.croplands.constituency_reclassed percentile=5,10,25,75,90,95 out=pc1_ltar.croplands.univar  
 r.univar -et map=conus_forcasts.pc2 zones=ltar_experiment_bndy_a_10142020_v2.croplands.constituency_reclassed percentile=5,10,25,75,90,95 out=pc2_ltar.croplands.univar  
 r.univar -et map=conus_forcasts.pc3 zones=ltar_experiment_bndy_a_10142020_v2.croplands.constituency_reclassed percentile=5,10,25,75,90,95 out=pc3_ltar.croplands.univar  

 python plot_pc_boxplots.py
fi

if [ $PCA_SUBSET_CROPLANDS -eq 1 ]
then
 grasscr global_latlon ltar_regionalization
 g.region rast=conus_forcasts.pc1
 r.mask -r 
 r.mask croplands_2008_2019_1km maskcats=1
 r.mapcalc "'conus_forcasts.croplands.pc1'='conus_forcasts.pc1'" 
 r.mapcalc "'conus_forcasts.croplands.pc2'='conus_forcasts.pc2'" 
 r.mapcalc "'conus_forcasts.croplands.pc3'='conus_forcasts.pc3'"
 r.mask -r 
fi

if [ $EXPORT_PCS_BY_SITE -eq 1 ]
then
 echo "Export PCA for each sites"
 for((s=1; s<=18; s++)) do
  r.mask -r 
  r.mask ltar_experiment_bndy_a_10142020_v2.constituency_reclassed maskcats=${s}
  r.stats -1n conus_forcasts.pc1 fs=space >ltar_${s}.pc1 
  r.stats -1n conus_forcasts.pc2 fs=space >ltar_${s}.pc2 
  r.stats -1n conus_forcasts.pc3 fs=space >ltar_${s}.pc3 
  r.stats -1n conus_forcasts.croplands.pc1 fs=space >ltar_${s}.croplands.pc1 
  r.stats -1n conus_forcasts.croplands.pc2 fs=space >ltar_${s}.croplands.pc2 
  r.stats -1n conus_forcasts.croplands.pc3 fs=space >ltar_${s}.croplands.pc3 
  r.mask -r 
 done
fi

