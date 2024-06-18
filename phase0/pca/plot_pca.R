#!/usr/bin/env Rscript
library(ggplot2)
library(reshape)

df<-read.delim("./components.northamerica_forcasts_pc", sep=" ", header=FALSE)

df$x<-c(1:21)

df<-melt(df, id=c("x"))
head(df)
df$y<-rep(c(1:21), each=21)
df$abs_val<-abs(df$value)*10

ggplot(df, aes(x, y, col=value, size=abs_val)) + geom_point()+scale_color_gradient2(midpoint=0, low="blue", mid="white", high="red")
