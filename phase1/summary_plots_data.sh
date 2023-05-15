#!/bin/bash

export GISRC=/home/1te/.grassrc6.data


r.report exp_forests_phase1.constituency units=a -h | awk 'BEGIN {FS="|"}; {print $2" "$4}' | head -n -4 | sed -e '1,4d' >constit_area

r.stats -1gn input=exp_forests_phase1.netrep_norm,USFS_regions,exp_forests_phase1.constituency >constit_netrep

r.stats -1gn input=exp_forests_phase1.netrep_normexp_forests_phase1.netrep_drivers_max,exp_forests_phase1.netrep_drivers_max_value,exp_forests_phase1.netrep_norm,USFS_regions >driver_netrep


r.stats -1gn input=wc2.0_bio_30s_01_ann_temp,wc2.0_bio_30s_02_diurnal_range,wc2.0_bio_30s_03_isothermality,wc2.0_bio_30s_04_temp_seasonality,wc2.0_bio_30s_10_meant_warmqtr,wc2.0_bio_30s_11_meant_coldqtr,wc2.0_bio_30s_12_ann_precip,wc2.0_bio_30s_15_precip_seasonality,wc2.0_bio_30s_16_precip_dry_qtr,wc2.0_bio_30s_17_precip_wet_qtr,wc2.0_bio_30s_18_precip_warm_qtr,wc2.0_bio_30s_19_precip_cold_qtr,available_water_capacity_until_wilting_point_0-100cm_30sec,bulk_density_0-100cm_mean_30sec,nitrogen_0-100cm_mean_30sec,ph_0-100cm_mean_30sec,soil_organic_carbon_0-100cm_mean_30sec,Forest_height_2019_CONUS_30sec,aboveground_biomass_carbon_2010_Spawn2020,gpp_dhi_coeffvariation,gpp_dhi_cumulative,exp_forests_phase1.netrep_norm,region,exp_forests_binary >vars_netrep_region_efs
