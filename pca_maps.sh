#!/bin/bash                                                                     

export GISRC=/home/1te/.grassrc6.data

g.region rast=conus_forest_ownership
g.region res=0:00:30
r.mask -r
variable_rast=("conus_forcasts_pc.pc1" "conus_forcasts_pc.pc2" "conus_forcasts_pc.pc3" "conus_forcasts_pc.pc4" "conus_forcasts_pc.pc5" "conus_forcasts_pc.pc6" "conus_forcasts_pc.pc7" "conus_forcasts_pc.pc8" "conus_forcasts_pc.pc9" "conus_forcasts_pc.pc10")

d.mon x2
for((v=0; v<11; v++)) do
d.rast ${variable_rast[v]} 
d.legend ${variable_rast[v]} 
d.title -ds map=${variable_rast[v]} size=3
d.out.file output=./graphs/pca/${variable_rast[v]} format=png --o
d.erase -f
done
