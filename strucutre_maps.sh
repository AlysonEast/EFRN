#!/bin/bash                                                                     

export GISRC=/home/1te/.grassrc6.data

g.region rast=conus_forest_ownership
g.region res=0:00:30
r.mask -r
 variable_rast=("Forest_height_2019_CONUS_30sec" "Leaf_Area_per_Leaf_Dry_Mass_1km_v1_clean" "Leaf_Dry_Mass_per_Leaf_Fresh_Mass_1km_v1_clean" "Leaf_Nitrogen_per_Leaf_Dry_Mass_1km_v1_clean" "Leaf_Phosphorous_per_Leaf_Dry_Mass_1km_v1_clean" "aboveground_biomass_carbon_2010_Spawn2020" "belowground_biomass_carbon_2010_Spawn2020" "root_biomass_Huang_ESSD_2021")

d.mon x2
for((v=0; v<9; v++)) do
d.rast ${variable_rast[v]} 
d.legend ${variable_rast[v]} 
d.title -ds map=${variable_rast[v]} size=3
d.out.file output=./graphs/structure/${variable_rast[v]} format=png --o
d.erase -f
done
