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
  theme_classic() + coord_flip()
dev.off()


#drivers, poors rep, by region plot
driver_netrep<-read.delim("./driver_netrep", sep="",header=FALSE)
colnames(driver_netrep)<-c("lat","long","max","max_val","netrep","region")

driver_netrep$regionName<-ifelse(driver_netrep$region==1, paste0("NRS: Poor Representation"),
                                ifelse(driver_netrep$region==2, paste0("PNW: Poor Representation"),
                                       ifelse(driver_netrep$region==3, paste0("PSW: Poor Representation"),
                                              ifelse(driver_netrep$region==4, paste0("RMRS: Poor Representation"), paste0("SRS: Poor Representation")))))
driver_netrep$regionName<-factor(driver_netrep$regionName, levels=c("PNW: Poor Representation","RMRS: Poor Representation","NRS: Poor Representation",
									"PSW: Poor Representation","SRS: Poor Representation"))

driver_netrep$poor_rep<-ifelse(driver_netrep$netrep<=0.77, paste0("1"), paste0("0"))
driver_netrep$Category<-ifelse(driver_netrep$max>=18, paste0("Structure"),
                                 ifelse(driver_netrep$max<=6, paste0("Temperature"),
                                        ifelse(driver_netrep$max==7, paste0("Precipitation"),
                                        ifelse(driver_netrep$max==8, paste0("Precipitation"),
                                        ifelse(driver_netrep$max==9, paste0("Precipitation"),
                                        ifelse(driver_netrep$max==10, paste0("Precipitation"),
                                        ifelse(driver_netrep$max==11, paste0("Precipitation"),
                                        ifelse(driver_netrep$max==12, paste0("Precipitation"), paste0("Soil")))))))))
#driver_netrep$max<-as.factor(driver_netrep$max)
driver_netrep$Category <- factor(driver_netrep$Category, levels = c("Temperature", "Precipitation", "Soil", "Structure"))


png(file="../figures/drivers_poorrep_region_hist.png", width=10, height=4, units = "in", res=300) 
ggplot(data=subset(driver_netrep, poor_rep==1), aes(fill=as.factor(max), x=max)) + 
  geom_histogram(binwidth=1, alpha=0.8)+ 
  scale_fill_manual(values = c("#ff9ea0","#fd8a83","#fa7767","#f8634a","#f64f2e","#f33c11",
				"#659bc9","#3da2dc","#3291c5","#2780ae","#1b6f96","#105f7f",
				"#754b07", "#805a1d","#8b6a33","#967949",
				"#248622", "#3a9b22","#65b12a","#91c633","#bcdc3c"))+
  facet_wrap(.~regionName, scales = "free", ncol=3) + 
  scale_x_continuous(breaks = seq(1,21,2), 
			 #labels = c("Mean Temp","Diurnal","Isothermality","TempSeasonality",
                         # "Temp Warm Qtr","Temp Cold Qtr","Annual Precip","Precip Seasonality","Precip Dry Qtr",
                         # "Precip Wet Qtr","Precip Warm Qtr","Precip Cold Qtr","Water Capacity","Bulk Density",
                         # "Nitrogen","pH","Carbon","Forest Height","Biomass","GPP Variation","GPP Cumulative"),
		    # guide = guide_axis(angle = 45),
		     limits=c(0.5,21.5), expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
#  theme(axis.text.x = element_text(angle=45, vjust=0.5, hjust=0.5))+ 
#  xlab("Environmental Condition Causing Greatest Differences")+ ylab("Frequency")+
  theme_classic() + 
  theme(text = element_text(size = 16),
	axis.title.x=element_blank()) +
  theme(legend.position = "None")
dev.off()

#Netrep density plot
xd <- data.frame(density(driver_netrep$netrep)[c("x", "y")])
quantile <- quantile(driver_netrep$netrep, prob=0.25)

png(file="../figures/netrep_hist.png", width=10, height=3, units = "in", res=300) 
ggplot(data=driver_netrep, aes(x=netrep)) + 
  geom_density() + 
  geom_area(data = subset(xd, x < quantile), aes(x=x, y=y), fill = "#220a8f", alpha=0.75) +
  geom_vline(xintercept = median(driver_netrep$netrep), linetype=2, col="#3291c5") +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
  ylab("Frequency")+ theme_classic()
dev.off()

png(file="../figures/netrep_hist_small.png", width=4, height=1.5, units = "in", res=300) 
ggplot(data=driver_netrep, aes(x=netrep)) + 
  geom_density() + 
  geom_area(data = subset(xd, x < quantile), aes(x=x, y=y), fill = "#8d2aaf", alpha=0.75) +
  geom_vline(xintercept = median(driver_netrep$netrep), linetype=2, col="#3291c5") +
  scale_x_continuous(expand = c(0,0), limits=c(0,1)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
  ylab("Frequency")+ theme_classic()
dev.off()

png(file="../figures/netrep_hist_noshade.png", width=10, height=3, units = "in", res=300) 
ggplot(data=driver_netrep, aes(x=netrep)) + 
  geom_density() + 
  geom_area(data = subset(xd, x < quantile), aes(x=x, y=y), fill = "#f9634a", alpha=0) +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
  ylab("Frequency")+ theme_classic()
dev.off()


#var density for top 3 drivers by region

driver_vars<-read.delim("./vars_netrep_region_efs", sep="",header=FALSE)
colnames(driver_vars)<-c("lat","long","MeanAnnTemp","DiurnalRange","Isothermality","TempSeasonality",
                          "TempWarmQtr","TempColdQtr","AnnPrecip","PrecipSeasonality","PrecipDryQtr",
                          "PrecipWetQtr","PrecipWarmQtr","PrecipColdQtr","WaterCapacity","BulkDensity",
                          "Nitrogen","pH","Carbon","CanopyHeight","Biomass","GPPVariation","GPPCumulative",
                         "netrep","region","ef")
driver_vars<-melt(driver_vars, id=c("lat","long","netrep","region","ef"))
driver_vars$in_ef<-ifelse(driver_vars$ef>0, paste0(1), paste0(0))
driver_vars<-subset(driver_vars, ef<1)

head(driver_vars)
str(driver_vars)

drivers_ef_mean<-read.delim("./exp_forests_phase1_byregion.mean.vect.out", sep="",header=FALSE)
colnames(drivers_ef_mean)<-c("MeanAnnTemp","DiurnalRange","Isothermality","TempSeasonality",
                          "TempWarmQtr","TempColdQtr","AnnPrecip","PrecipSeasonality","PrecipDryQtr",
                          "PrecipWetQtr","PrecipWarmQtr","PrecipColdQtr","WaterCapacity","BulkDensity",
                          "Nitrogen","pH","Carbon","CanopyHeight","Biomass","GPPVariation","GPPCumulative",
                          "region","ef")
head(drivers_ef_mean)
str(drivers_ef_mean) 

drivers_ef_mean<-melt(drivers_ef_mean, id=c("region","ef"))
head(drivers_ef_mean)
str(drivers_ef_mean) 
drivers_ef_mean<-cast(drivers_ef_mean, ef+region~variable, mean)
head(drivers_ef_mean)
str(drivers_ef_mean) 
drivers_ef_mean<-melt(drivers_ef_mean, id=c("ef","region"))
drivers_ef_mean$driver_vars<-ifelse(drivers_ef_mean$region==1, paste0("NRS region"),
                                 ifelse(drivers_ef_mean$region==2, paste0("PNW region"),
                                        ifelse(drivers_ef_mean$region==3, paste0("PSW region"),
                                               ifelse(drivers_ef_mean$region==4, paste0("RMRS region"), paste0("SRS region")))))
head(drivers_ef_mean)
str(drivers_ef_mean)

driver_vars$driver_vars<-ifelse(driver_vars$region==1, paste0("NRS region"),
                                 ifelse(driver_vars$region==2, paste0("PNW region"),
                                        ifelse(driver_vars$region==3, paste0("PSW region"),
                                               ifelse(driver_vars$region==4, paste0("RMRS region"), paste0("SRS region")))))
driver_vars$poor_rep<-ifelse(driver_vars$netrep<=0.77, paste0("1"), paste0("0"))
head(driver_vars)

driver_vars_sub<-subset(driver_vars, driver_vars=="NRS region" & variable=="MeanAnnTemp" |
                          driver_vars=="NRS region" & variable=="Nitrogen" |
                          driver_vars=="NRS region" & variable=="Carbon" |
                          driver_vars=="PNW region" & variable=="MeanAnnTemp" |
                          driver_vars=="PNW region" & variable=="CanopyHeight" |
                          driver_vars=="PNW region" & variable=="Biomass" |
                          driver_vars=="PSW region" & variable=="MeanAnnTemp" |
                          driver_vars=="PSW region" & variable=="CanopyHeight" |
                          driver_vars=="PSW region" & variable=="Biomass" |
                          driver_vars=="RMRS region" & variable=="MeanAnnTemp" |
                          driver_vars=="RMRS region" & variable=="DiurnalRange" |
                          driver_vars=="RMRS region" & variable=="WaterCapacity" |
                          driver_vars=="SRS region" & variable=="TempWarmQtr" |
                          driver_vars=="SRS region" & variable=="WaterCapacity" |
                          driver_vars=="SRS region" & variable=="Nitrogen" )

drivers_ef_mean_sub<-subset(drivers_ef_mean, driver_vars=="NRS region" & variable=="MeanAnnTemp" |
                          driver_vars=="NRS region" & variable=="Nitrogen" |
                          driver_vars=="NRS region" & variable=="Carbon" |
                          driver_vars=="PNW region" & variable=="MeanAnnTemp" |
                          driver_vars=="PNW region" & variable=="CanopyHeight" |
                          driver_vars=="PNW region" & variable=="Biomass" |
                          driver_vars=="PSW region" & variable=="MeanAnnTemp" |
                          driver_vars=="PSW region" & variable=="CanopyHeight" |
                          driver_vars=="PSW region" & variable=="Biomass" |
                          driver_vars=="RMRS region" & variable=="MeanAnnTemp" |
                          driver_vars=="RMRS region" & variable=="DiurnalRange" |
                          driver_vars=="RMRS region" & variable=="WaterCapacity" |
                          driver_vars=="SRS region" & variable=="TempWarmQtr" |
                          driver_vars=="SRS region" & variable=="WaterCapacity" |
                          driver_vars=="SRS region" & variable=="Nitrogen" )


head(drivers_ef_mean_sub)
drivers_ef_mean_sub$in_ef<-1
#table(drivers_ef_mean$ef~drivers_ef_mean$region)
subset(drivers_ef_mean_sub, driver_vars=="PSW region", variable=="MeanAnnTemp") 
head(driver_vars_sub)

driver_vars_sub<-rbind(driver_vars_sub[,c(5,4,7,6,9,8)],drivers_ef_mean_sub)

driver_vars_sub$value[driver_vars_sub$value >500 & driver_vars_sub$variable == 'Nitrogen'] <- NA
driver_vars_sub$value[driver_vars_sub$value >1100 & driver_vars_sub$variable == 'Carbon'] <- NA

str(driver_vars_sub)

png(file="../figures/var_hists.png", width=9, height=11, units = "in", res=300) 
ggplot(data=driver_vars_sub, alpha=0.55, aes(fill=in_ef, col=in_ef, x=value)) + 
  geom_density(alpha=0.55) + 
  scale_color_manual(values = c("#138a2c","#88422F"), labels = c("Outside EFRN sites","In EFRN sites"))+
  scale_fill_manual(values = c("#138a2c","#88422F"), labels = c("Outside EFRN sites","In EFRN sites"))+
  facet_wrap(driver_vars~variable, scales="free", ncol=3) + theme_classic() +
  ylab("Density") + xlab("Value") +
  theme(legend.position = "top")+ 
  theme(text = element_text(size = 16)) + 
  theme(legend.title= element_blank())
dev.off()
