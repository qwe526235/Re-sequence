setwd("C:/Users/zjy52/Desktop/重测序/PCA")
library(dplyr)
library(data.table)
library(ggplot2)
library(RColorBrewer)
data=read.table('data/snp_filter.eigenvec')
data=data[,2:4]
colnames(data)=c('sample','PC1','PC2')
data$sample=gsub('-1','',data$sample)
meta=read.csv('sample-metadata.csv')
data=left_join(data,meta,by=c('sample'='Sample'))
go=read.table('data/snp_filter.eigenval')
data3<-go[c(1:(nrow(go)-1)),]
PC1contri<-round(data3[1]*100/sum(data3),digits=2)
PC2contri<-round(data3[2]*100/sum(data3),digits=2)
xlab<-paste("PC1(",PC1contri,"%)",sep="")
ylab<-paste("PC2(",PC2contri,"%)",sep="")
p<-ggplot(data,aes(x=PC1,y=PC2,color=Group)) + 
  geom_point() + labs(x=xlab,y=ylab)+ 
  stat_ellipse(level = 0.95, show.legend = F)+
  scale_color_manual(values=c('#FF0000','#E066FF','#4EEE94','#0000EE'))
p

pdf('plot/pca.pdf',width = 10,height = 10)
p
dev.off()

png('plot/pca.png',width = 480,height = 480)
p
dev.off()
