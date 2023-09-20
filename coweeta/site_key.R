#!/usr/bin/env Rscript

df1<-read.delim("./constit_reclass_1.txt", sep=" ", header=FALSE)
df2<-read.delim("./constit_reclass.txt", sep=",", header=FALSE)

colnames(df1)<-c("line_num","ID")
colnames(df2)<-c("ID","FID","NAME")

df2$NAME<- sub(" ", "_", df2$NAME)

#head(df1)
#head(df2)

df<-merge(df1, df2, by.x="ID", by.y="ID", all.y=FALSE)

df[,c(2:ncol(df))]

write.table(df[,c(2:ncol(df))], "./site_key", sep=" ", row.names=FALSE)
write.table(table(df[,c(2:ncol(df))]$NAME), "./site_count", sep=" ", row.names=FALSE)
