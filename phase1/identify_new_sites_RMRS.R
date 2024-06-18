#!/usr/bin/env Rscript

df1<-read.delim("./RMRS_list_v2", sep="", header=FALSE)
head(df1)
#site_nums PADUS_counts_v2 PADUS_values_v2 PADUS_values
colnames(df1)<-c("ID","Count","Mean_Dist_ofCount", "Med_Dist")
#r.mapcalc "'${CASE}.netrep_norm'=if('${CASE}.netrep'>${lim},0,1-'${CASE}.netrep'/${lim})"
df1$Mean_netrep_ofCount<-(1-(df1$Mean_Dist_ofCount/42.191788 ))
df1$Med_netrep<-(1-(df1$Med_Dist/42.191788 ))
df1$Med_netrep<-ifelse(df1$Med_netrep<=0, paste0(0), paste0(df1$Med_netrep))
df1$Med_netrep<-as.numeric(df1$Med_netrep)

write.csv(df1, "./RMRS_list_v2.csv", row.names=FALSE)
