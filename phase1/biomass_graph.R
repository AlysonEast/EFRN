#!/usr/bin/env Rscript
library(gridExtra)
library(grid)
library(ggplot2)
df1<-read.delim("./quantile_data",sep=" ", header=FALSE)

colnames(df1)<-c("lat","long","quarter","biomass","region")
df1$quarter<-as.factor(df1$quarter)
df1$regionName<-ifelse(df1$region==1, paste0("NRS"),
                                ifelse(df1$region==2, paste0("PNW"),
                                       ifelse(df1$region==3, paste0("PSW"),
                                              ifelse(df1$region==4, paste0("RMRS"), paste0("SRS")))))


ag<-aggregate(df1$biomass, list(df1$quarter), FUN=sum)
ag$pct<-(ag$x/(sum(ag$x))*100)
ag

cbbPalette <- c( "#220a8f", "#e3c81c", "#b0cf33", "#1ca753")

png(file="../figures/biomass_hist.png",width=6, height=6, units="in", res=300)
ggplot(data=df1, aes(x=biomass, fill=quarter)) +
	geom_histogram(aes(fill=quarter), alpha=0.5,  position="identity") + theme_classic()
dev.off()

png(file="../figures/biomass_hist_region.png",width=10, height=6, units="in", res=300)
ggplot(data=df1, aes(x=biomass, fill=quarter)) +
	geom_histogram(aes(fill=quarter), alpha=0.5,  position="identity") + theme_classic() +
	scale_fill_discrete(name="",labels = c("Bottom 25th","25-50th","50-75th","Top 25%"))  +
	facet_wrap(~regionName, scales = "free_y", nrow=1) +
	theme(legend.position = c(0.8, 0.15))
dev.off()

png(file="../figures/biomass_bar.png",width=6, height=6, units="in", res=300)
ggplot(data=ag, aes(y=x, x=Group.1)) +
	geom_bar(stat="identity") + theme_classic() +
	scale_x_discrete(labels=c("Bottom 25th","25-50th","50-75th","Top 25%")) +
	xlab("Percentile") +
	ylab("Mg Carbon")
dev.off()

df1$compname<-paste0(df1$quarter,df1$region)
ag<-aggregate(df1$biomass, list(df1$compname), FUN=sum)
ag$quarter<-paste0(substr(ag$Group.1,1,1))
ag$region<-paste0(substr(ag$Group.1,2,2))
ag$regionName<-ifelse(ag$region==1, paste0("NRS"),                                                                                           
                                ifelse(ag$region==2, paste0("PNW"),
                                       ifelse(ag$region==3, paste0("PSW"),
                                              ifelse(ag$region==4, paste0("RMRS"), paste0("SRS")))))

png(file="../figures/biomass_bar_region.png",width=10, height=6, units="in", res=300)
ggplot(data=ag, aes(y=x, x=quarter)) +
	geom_bar(stat="identity") + theme_classic() +
	scale_x_discrete(labels=c("Bottom 25th","25-50th","50-75th","Top 25%")) +
	xlab("Percentile") +
	ylab("Mg Carbon") +
	facet_wrap(~regionName, nrow=1)
dev.off()

library(plyr)

mu <- ddply(df1, c("quarter","regionName"), summarise, grp.mean=median(biomass))
mu$quarter<-as.factor(mu$quarter)
mu$regionName<-as.factor(mu$regionName)

ag$Mg<-(ag$x*100)

p1<-ggplot(data=df1, aes(x=biomass)) +
        geom_density(aes(fill=quarter, alpha=quarter), col="#504B49") + theme_classic() +
        geom_vline(data= mu, aes(xintercept = grp.mean, col=quarter)) +
	scale_fill_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_color_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_alpha_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=c(0.5,0.9,0.6,0.5)) +
	scale_x_continuous(expand=c(0,0), limits=c(0,max(df1$biomass)), guide=guide_axis(angle = 45)) +
	scale_y_continuous(expand=c(0,0)) +
	labs(x=expression(paste("Aboveground Biomass (MgC ",ha^-1,")")), y="Frequency") +
        facet_wrap(~regionName, scales = "free_y", nrow=1) +
	theme(text = element_text(size = 14)) +
        theme(legend.position = c(.733,.7),
	      legend.text=element_text(size=9),
	      legend.background = element_rect(fill=NA)) +
	labs(title = "a)") + 
 	theme(plot.title.position = "plot",
	      plot.title = element_text(size=20))
	
p2<-ggplot(data=ag, aes(y=x, x=quarter, fill=quarter, alpha=quarter)) +
        geom_bar(stat="identity", col="#504B49") + theme_classic() +
	scale_fill_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=cbbPalette)  +
	scale_alpha_manual(name=NULL,labels = c("Bottom 25th","25-50th","50-75th","Top 25th"),values=c(0.5,0.9,0.6,0.5)) +
        scale_x_discrete(labels=c("Bottom 25th","25-50th","50-75th","Top 25th"), guide = guide_axis(angle = 45)) +
        xlab("Quartile") +
        ylab("Total Carbon (Mg)") +
	theme(legend.position = "none") +
        facet_wrap(~regionName, nrow=1) + 
        theme(text = element_text(size = 15)) +
        labs(title = "b)") +
        theme(plot.title.position = "plot",
	      plot.title = element_text(size=20))


png(file="../figures/biomass_grid.png",width=10, height=6, units="in", res=300)
grid.arrange(p1,p2,nrow=2)
dev.off()
