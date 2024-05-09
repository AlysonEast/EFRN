#!/usr/bin/env Rscript
library(ggplot2)
library(reshape)
library(dplyr)

df<-read.delim("./constit_netrep_changephase1phase0", sep="", header = TRUE)

head(df)
str(df)




#Netrep density plot
#xd <- data.frame(density(driver_netrep$netrep)[c("x", "y")])
#quantile <- quantile(driver_netrep$netrep, prob=0.25)

#png(file="../figures/netrep_hist.png", width=10, height=3, units = "in", res=300) 
#ggplot(data=driver_netrep, aes(x=netrep)) + 
#  geom_density() + 
#  geom_area(data = subset(xd, x < quantile), aes(x=x, y=y), fill = "#f9634a", alpha=0.75) +
#  geom_vline(xintercept = median(driver_netrep$netrep), linetype=2, col="#3291c5") +
#  scale_x_continuous(expand = c(0,0)) +
#  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
#  ylab("Frequency")+ theme_bw()
#dev.off()

#png(file="../figures/netrep_hist_noshade.png", width=10, height=3, units = "in", res=300) 
#ggplot(data=driver_netrep, aes(x=netrep)) + 
#  geom_density() + 
#  geom_area(data = subset(xd, x < quantile), aes(x=x, y=y), fill = "#f9634a", alpha=0) +
#  scale_x_continuous(expand = c(0,0)) +
#  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
#  ylab("Frequency")+ theme_bw()
#dev.off()

#png(file="../figures/var_hists.png", width=9, height=11, units = "in", res=300) 
#ggplot(data=driver_vars_sub, alpha=0.55, aes(fill=in_ef, col=in_ef, x=value)) + 
#  geom_density(alpha=0.55) + 
#  scale_color_manual(values = c("#138a2c","#88422F"), labels = c("Outside EFRN sites","In EFRN sites"))+
#  scale_fill_manual(values = c("#138a2c","#88422F"), labels = c("Outside EFRN sites","In EFRN sites"))+
#  facet_wrap(driver_vars~variable, scales="free", ncol=3) + theme_bw() +
#  ylab("Frequency") + xlab("Value") +
#  theme(legend.position = "top")+ 
#  theme(text = element_text(size = 16)) + 
#  theme(legend.title= element_blank())
#dev.off()
