setwd('C:/Users/zjy52/Desktop/重测序/ptree')
library(dplyr)
library(ggtreeExtra) 
library(ggstar) 
library(ggplot2) 
library(ggtree) 
library(treeio)
library(ggnewscale)
library(reshape2)
library(aplot)
data=read.tree('snp.nwk')
group=read.csv('sample-metadata.csv')
tree_group=split(group$Sample,group$Group)
tr=groupOTU(data,tree_group)
p=ggtree(tr,branch.length = 'none',aes(color=group),linetype=1,size=0.8)+
  geom_tiplab(size=3.5)+
  scale_color_manual(values=c('#FF0000','#E066FF','#4EEE94','#0000EE'))+theme(legend.position = 'none')
p
