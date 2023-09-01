setwd("C:/Users/zjy52/Desktop/重测序/CNV/data/vcf")
library(dplyr)
library(data.table)
library(ggplot2)
file=list.files('./',pattern = 'new.vcf')
for(l in 1:length(file)){
name=strsplit(file[l],'_')[[1]][1]
name=gsub('-1','',name)
data=fread(file[l])
df=data.frame(matrix(nrow=1,ncol=4))
colnames(df)=c('position','REF_AD','ALT_AD','DP')
for(i in 1:nrow(data)){
  pos=paste0(data$`#CHROM`[i],'-',data$POS[i])
  test=data[,10][i]
  test=as.character(test[1,1])
  ref=strsplit(strsplit(test,':')[[1]][2],',')[[1]][1]
  alt=strsplit(strsplit(test,':')[[1]][2],',')[[1]][2]
  dp=strsplit(test,':')[[1]][3]
  temp=data.frame('position'=pos,
                  'REF_AD'=ref,
                  'ALT_AD'=alt,
                  'DP'=dp)
  df=rbind(df,temp)
}
df=df[-1,]
df$reference=as.numeric(df$REF_AD)/as.numeric(df$DP)
df$variant=as.numeric(df$ALT_AD)/as.numeric(df$DP)                                            
dt=df[,c(1,5:6)]
chr=unique(data$`#CHROM`)
for(k in 1:length(chr)){
tee=dt[grep(chr[k],dt$position),]
plot=reshape2::melt(tee)
order=c('reference','variant')
colnames(plot)=c('position','Type','frequence')
plot$Type=factor(plot$Type,levels = order)
plot$group=paste0(name,'(',chr[k],')')
p1=ggplot(plot)+
  geom_bar(aes(y=position,x=frequence,fill=Type),
           position = 'stack',stat = 'identity')+
  scale_fill_manual(values = c('#3D3D3D','#EE3B3B'))+
  scale_x_continuous(expand = c(0,0),position = 'top')+
  ylab('Position(Scaffold,Base)')+
  xlab('Frequence')+
  theme(axis.text.y = element_blank(),
        axis.ticks = element_blank())+
  facet_grid(.~group)
  
  
pdf(paste0('../../plot/pdf/stack/',name,'_',chr[k],'_frequence_stack.pdf'),width = 8,height = 12)
print(p1)
dev.off()

png(paste0('../../plot/png/stack/',name,'_',chr[k],'_frequence_stack.'),width = 800,height = 600)
print(p1)
dev.off()



##bar
ref=tee[,c(1,2)]
ref$group=paste0(name,'(',chr[k],')')
p2=ggplot(ref)+
  geom_histogram(aes(x=reference),bins=50,fill='red')+
  scale_x_continuous(expand = c(0,0))+
  scale_y_continuous(expand = c(0,0))+
  ylab('SNP numbers')+
  xlab('Frequency of reference allele ')+
  facet_grid(.~group)

p2

pdf(paste0('../../plot/pdf/reference/',name,'_',chr[k],'_reference_frequence.pdf'),width = 8,height = 6)
print(p2)
dev.off()

png(paste0('../../plot/png/reference/',name,'_',chr[k],'_reference_frequence.png'),width = 800,height = 600)
print(p2)
dev.off()

alt=tee[,c(1,3)]
alt$group=paste0(name,'(',chr[k],')')
p3=ggplot(alt)+
  geom_histogram(aes(x=variant),bins=50,fill='red')+
  scale_x_continuous(expand = c(0,0))+
  scale_y_continuous(expand = c(0,0))+
  ylab('SNP numbers')+
  xlab('Frequency of non-reference allele ')+
  facet_grid(.~group)

p3

pdf(paste0('../../plot/pdf/non-reference/',name,'_',chr[k],'_non-reference_frequence.pdf'),width = 8,height = 6)
print(p3)
dev.off()

png(paste0('../../plot/png/non-reference/',name,'_',chr[k],'_non-reference_frequence.png'),width = 800,height = 600)
print(p3)
dev.off()
}
write.csv(df,paste0('../../statistic/',name,'_summary.csv'),row.names = F,quote = F)
}


