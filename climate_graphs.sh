#!/bin/bash                                                                     

export GISRC=/home/1te/.grassrc6.data

g.region rast=conus_forest_ownership
g.region res=0:00:30
r.mask USFS_regions --o
variable_rast=("wc2.0_bio_30s_01_ann_temp" "wc2.0_bio_30s_02_diurnal_range" "wc2.0_bio_30s_03_isothermality" "wc2.0_bio_30s_04_temp_seasonality" "wc2.0_bio_30s_10_meant_warmqtr" "wc2.0_bio_30s_11_meant_coldqtr" "wc2.0_bio_30s_12_ann_precip" "wc2.0_bio_30s_15_precip_seasonality" "wc2.0_bio_30s_16_precip_dry_qtr" "wc2.0_bio_30s_17_precip_wet_qtr" "wc2.0_bio_30s_18_precip_warm_qtr" "wc2.0_bio_30s_19_precip_cold_qtr" "available_water_capacity_until_wilting_point_0-100cm_30sec" "bulk_density_0-100cm_mean_30sec" "nitrogen_0-100cm_mean_30sec" "ph_0-100cm_mean_30sec" "soil_organic_carbon_0-100cm_mean_30sec" "Forest_height_2019_CONUS_30sec" "aboveground_biomass_carbon_2010_Spawn2020" "gpp_dhi_coeffvariation" "gpp_dhi_cumulative")

d.mon x1
for((v=1; v<22; v++)) do
d.rast ${variable_rast[v]} 
d.legend ${variable_rast[v]} 
d.title -ds map=${variable_rast[v]} size=3
d.out.file output=./graphs/environmental/${variable_rast[v]} format=png --o
d.erase -f

r.out.gdal in=${variable_rast[v]} out=./export/${variable_rast[v]}.tif type=Float64 format=GTiff --o
done
