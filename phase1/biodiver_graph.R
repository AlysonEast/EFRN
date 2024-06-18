#!/usr/bin/env Rscript
library(gridExtra)
library(grid)
library(ggplot2)
df1<-read.delim("./quantile_data_biodiver",sep=" ", header=FALSE)

colnames(df1)<-c("lat","long","quarter","spp","region")
df1$quarter<-as.factor(df1$quarter)
df1$regionName<-ifelse(df1$region==1, paste0("NRS"),
                                ifelse(df1$region==2, paste0("PNW"),
                                       ifelse(df1$region==3, paste0("PSW"),
                                              ifelse(df1$region==4, paste0("RMRS"), paste0("SRS")))))


cbbPalette <- c( "#220a8f", "#e3c81c", "#b0cf33", "#1ca753")

df1$compname<-paste0(df1$quarter,df1$region)

library(plyr)
mu <- ddply(df1, c("quarter","regionName"), summarise, grp.mean=median(spp))
mu$quarter<-as.factor(mu$quarter)
mu$regionName<-as.factor(mu$regionName)

p1<-ggplot(data=df1, aes(x=spp)) +
        geom_density(aes(fill=quarter, alpha=quarter), col="#504B49") + theme_bw() +
        geom_vline(data= mu, aes(xintercept = grp.mean, col=quarter)) +
	scale_fill_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_color_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_alpha_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=c(0.5,0.9,0.6,0.5))  +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0)) +
	xlab("Species Richness") +
        facet_wrap(~regionName, scales = "free", nrow=1) +
        #theme(legend.position = c(0.73, 0.73))
        theme(legend.position = "none")

png(file="../figures/bidiver_hist_region.png",width=12, height=3, units="in", res=300)
p1
dev.off()


mu <- ddply(df1, c("quarter"), summarise, grp.mean=median(spp))
mu$quarter<-as.factor(mu$quarter)

mu

p2<-ggplot(data=df1, aes(x=spp)) +
        geom_density(aes(fill=quarter, alpha=quarter), col="#504B49") + theme_bw() +
        geom_vline(data= mu, aes(xintercept = grp.mean, col=quarter)) +
	scale_fill_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_color_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_alpha_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=c(0.5,0.9,0.6,0.5))  +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0)) +
	xlab("Species Richness") +
        theme(legend.position = c(0.15, 0.8))
        #theme(legend.position = "left")
png(file="../figures/biodiver_hist.png",width=6, height=6, units="in", res=300)
p2
dev.off()

png(file="../figures/biodiver_hist_grid.png",width=8, height=6, units="in", res=300)
grid.arrange(p2,p1,nrow=2,heights=c(3,1.5))
dev.off()
