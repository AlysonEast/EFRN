#!/usr/bin/env Rscript
#install.packages("gtools", repos="http://cran.us.r-project.org")
#install.packages("magick", repos="http://cran.us.r-project.org")

df1<-read.delim("./exp_forests_phase1.netrep_drivers", sep=" ", header=FALSE)
n<-ncol(df1)
df1$min<-apply(df1[,c(3:n)], 1, which.min)
df1$max<-apply(df1[,c(3:n)], 1, which.max)
df1$max_val<-apply(df1[,c(3:n)], 1, max)

write.csv(df1, "./temp.csv")