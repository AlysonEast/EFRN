#!/usr/bin/env Rscript
library(ggplot2)
library(reshape)
library(dplyr)

#Area vs netrep box/bar plot
#area data
constit_area<-read.delim("./constit_area", sep="", header = FALSE)
colnames(constit_area)<-c("constit","Area")
#netrep data
constit_netrep<-read.delim("./constit_netrep", sep="", header=FALSE)
colnames(constit_netrep)<-c("lat","long","netrep","region","constit")

#add ef names to those data....
site_id<-read.delim("../coweeta/site_key", sep="", header = TRUE)
site_id<-site_id[,-1]
site_id<-site_id[!duplicated(site_id), ]
site_id
constit_area<-merge(constit_area, site_id, by.x="constit",by.y="FID", all.y=FALSE)
write.csv(constit_area, "./constit_area.csv")

constit_area$Area<-as.numeric(constit_area$Area)
str(constit_area)

constit_netrep<-merge(constit_netrep, site_id, by.x="constit",by.y="FID", all.y=FALSE)

#create netrep scaled by area..
constit_netrep$netrep_scaled<-constit_netrep$netrep*max(constit_area$Area)
str(constit_netrep)

png(file="../figures/contit_box_area.png", width=6, height=12, units = "in", res=300) 
ggplot(data=constit_area, aes(x=reorder(NAME, +Area), y=Area)) + 
  geom_bar(stat='identity') + 
  scale_y_continuous(breaks = seq(0,50000000,10000000), labels = seq(0,50,10),
               #      limits = c(0,max(constit_area$Area)), expand = c(0,0),
                     sec.axis = sec_axis(trans = ~ . * max(constit_area$Area), name="Representativness") ) + #,
                #                         breaks = seq(0,max(constit_area$Area),max(constit_area$Area)/4),
                 #                        labels = seq(0,1,0.25))) +
  geom_boxplot(data = constit_netrep, aes(x=NAME, y=netrep_scaled), outlier.shape=1) +
  theme_bw() + coord_flip()
dev.off()


#drivers, poors rep, by region plot
driver_netrep<-read.delim("./driver_netrep", sep="",header=FALSE)
colnames(driver_netrep)<-c("lat","long","max","max_val","netrep","region")

driver_netrep$regionName<-ifelse(driver_netrep$region==1, paste0("NRS"),
                                ifelse(driver_netrep$region==1, paste0("PNW"),
                                       ifelse(driver_netrep$region==1, paste0("PSW"),
                                              ifelse(driver_netrep$region==1, paste0("RMRS"), paste0("SRS")))))
driver_netrep$poor_rep<-ifelse(driver_netrep$netrep<=0.77, paste0("1"), paste0("0"))
driver_netrep$Catagory<-ifelse(driver_netrep$max>=18, paste0("Structure"),
                                 ifelse(driver_netrep$max<=6, paste0("Temperature"),
                                        ifelse(driver_netrep$max==7, paste0("Precip"),
                                        ifelse(driver_netrep$max==8, paste0("Precip"),
                                        ifelse(driver_netrep$max==9, paste0("Precip"),
                                        ifelse(driver_netrep$max==10, paste0("Precip"),
                                        ifelse(driver_netrep$max==11, paste0("Precip"),
                                        ifelse(driver_netrep$max==12, paste0("Precip"), paste0("Soil")))))))))

png(file="../figures/drivers_poorrep_region_hist.png", width=10, height=6, units = "in", res=300) 
ggplot(data=subset(driver_netrep, poor_rep==1), aes(fill=Catagory, col=Catagory, x=Max)) + 
  geom_histogram() + 
  scale_color_manual(values = c("#3291c5","#977552","#65b12a","#f9634a"))+
  scale_x_continuous(breaks = seq(1,21,1), labels = c("Mean Ann Temp","Diurnal","Isothermality","TempSeasonality",
                          "Temp Warm Qtr","Temp Cold Qtr","Ann Precip","Precip Seasonality","Precip Dry Qtr",
                          "Precip Wet Qtr","Precip Warm Qtr","Precip Cold Qtr","Water Capacity","Bulk Density",
                          "Nitrogen","pH","Carbon","Forest Height","Biomass","GPP Variation","GPP Cumulative")) +
  facet_wrap(.~regionName, scales = "free") + theme_bw() +
  theme(legend.position = c(0.8,0.15))
dev.off()

#Netrep density plot
xd <- data.frame(density(driver_netrep$netrep)[c("x", "y")])
quantile <- quantile(dt$y, prob=0.25)

png(file="../figures/netrep_hist.png", width=10, height=3.5, units = "in", res=300) 
ggplot(data=driver_netrep, aes(x=netrep)) + 
  geom_density() + 
  geom_area(data = subset(xd, x < quantile), fill = "#f9634a") +
  geom_vline(xintercept = median(driver_netrep$netrep), linetype=2, col="#3291c5") +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
  theme_bw()
dev.off()

#var density for top 3 drivers by region

driver_vars<-read.delim("./vars_netrep_region_efs", sep="",header=FALSE)
colnames(driver_vars)<-c("lat","long","MeanAnnTemp","DiurnalRange","Isothermality","TempSeasonality",
                          "TempWarmQtr","TempColdQtr","AnnPrecip","PrecipSeasonality","PrecipDryQtr",
                          "PrecipWetQtr","PrecipWarmQtr","PrecipColdQtr","WaterCapacity","BulkDensity",
                          "Nitrogen","pH","Carbon","CanopyHeight","Biomass","GPPVariation","GPPCumulative",
                         "netrep","region","ef")
driver_vars<-melt(driver_vars, id=c("lat","long","netrep","region","ef"))

driver_vars$driver_vars<-ifelse(driver_vars$region==1, paste0("NRS"),
                                 ifelse(driver_vars$region==1, paste0("PNW"),
                                        ifelse(driver_vars$region==1, paste0("PSW"),
                                               ifelse(driver_vars$region==1, paste0("RMRS"), paste0("SRS")))))
driver_vars$poor_rep<-ifelse(driver_vars$netrep<=0.77, paste0("1"), paste0("0"))

driver_vars_sub<-subset(driver_vars$driver_vars=="NRS" & variable=="MeanAnnTemp" |
                          driver_vars$driver_vars=="NRS" & variable=="Nitrogen" |
                          driver_vars$driver_vars=="NRS" & variable=="Carbon" |
                          driver_vars$driver_vars=="PNW" & variable=="Carbon" |
                          driver_vars$driver_vars=="PNW" & variable=="CanopyHeight" |
                          driver_vars$driver_vars=="PNW" & variable=="Biomass" |
                          driver_vars$driver_vars=="PSW" & variable=="MeanAnnTemp" |
                          driver_vars$driver_vars=="PSW" & variable=="Carbon" |
                          driver_vars$driver_vars=="PSW" & variable=="Biomass" |
                          driver_vars$driver_vars=="RMRS" & variable=="MeanAnnTemp" |
                          driver_vars$driver_vars=="RMRS" & variable=="DiurnalRange" |
                          driver_vars$driver_vars=="RMRS" & variable=="WaterCapacity" |
                          driver_vars$driver_vars=="SRS" & variable=="TempWarmQtr" |
                          driver_vars$driver_vars=="SRS" & variable=="WaterCapacity" |
                          driver_vars$driver_vars=="SRS" & variable=="Nitrogen" )

png(file="../figures/var_hists.png", width=10, height=6, units = "in", res=300) 
ggplot(data=driver_vars_sub, alpha=0.55, aes(fill=ef, col=ef, x=value)) + 
  geom_density() + 
  scale_color_manual(values = c("#0E5C1E","#88422F"), labels = c("Outside Experimental Forests","In Experimental Forests"))+
  scale_fill_manual(values = c("#0E5C1E","#88422F"), labels = c("Outside Experimental Forests","In Experimental Forests"))+
  scale_x_continuous(breaks = seq(1,21,1), labels = c("Mean Ann Temp","Diurnal","Isothermality","TempSeasonality",
                                                      "Temp Warm Qtr","Temp Cold Qtr","Ann Precip","Precip Seasonality","Precip Dry Qtr",
                                                      "Precip Wet Qtr","Precip Warm Qtr","Precip Cold Qtr","Water Capacity","Bulk Density",
                                                      "Nitrogen","pH","Carbon","Forest Height","Biomass","GPP Variation","GPP Cumulative"),
                     hjust=1, vjust=1, rotate=45) +
  facet_wrap(regionName~variable, scales="free") + theme_bw() +
  theme(legend.position = "top")
dev.off()
