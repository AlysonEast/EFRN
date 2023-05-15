#!/usr/bin/env Rscript

df1<-read.delim("./temp", sep=" ", header=FALSE)

head(df1)

df<-subset(df1, V3<=7.8833924)

table(df$V4)

write.table(table(df$V4), "./competing_table", sep=" ", row.names=FALSE)
