setwd("C:/Users/zjy52/Desktop/重测序/hapcut/hapcut")
library(dplyr)
library(data.table)
library(ggplot2)
library(RColorBrewer)
file=list.files('./')
ss=data.frame(matrix(nrow=1,ncol=5))
colnames(ss)=c('HalotypeA_number',
              'HalotypeB_number',
              'length_BP',
              'Total number of heterozygous variants',
              'Variants successfully phased')
for(l in 1:length(file)){
name=strsplit(file[l],'_')[[1]][1]
name=gsub('-1','',name)
data=readLines(file[l])
df=grep('BLOCK',data)
max(df)
pos=data.frame('start'=df,
               'end'=c(df[2:length(df)],length(data)+1))
dt=data.frame(matrix(nrow=1,ncol=6))
colnames(dt)=c('HalotypeA','HalotypeB','length','position','location_HA','location_HB')
for(i in 1:(nrow(pos))){
  start=pos$start[i]+1
  end=pos$end[i]-1
  le=as.numeric(strsplit(data[pos$start[i]],' ')[[1]][9])
  temp=data[start:end]
  p1=0
  p2=0
  for(j in 1:length(temp)){
    tt=strsplit(temp[j],'\t')[[1]]
    if(length(tt)>1 & tt[2]!='-' & tt[3]!='-'){
      p1=p1+as.numeric(tt[2])
      p2=p2+as.numeric(tt[3])
    }
  }
  A=''
  B=''
  for(j in 1:length(temp)){
    tt=strsplit(temp[j],'\t')[[1]]
    if(length(tt)>1 & tt[2]!='-' & tt[3]!='-'){
      if(as.numeric(tt[2]==1)){
        A=paste0(A,'(',tt[4],'-',tt[5],')')
      }
      if(as.numeric(tt[3]==1)){
        B=paste0(B,'(',tt[4],'-',tt[5],')')
      }
    }
    
    
    
  }
  td=data.frame(matrix(nrow=1,ncol=6))
  colnames(td)=c('HalotypeA','HalotypeB','length','position','location_HA','location_HB')
  td$HalotypeA=p1
  td$HalotypeB=p2
  td$length=le
  td$position=paste0('block_',i)
  td$location_HA=A
  td$location_HB=B
  dt=rbind(dt,td)
}
dt=dt[-1,]
dt$perA=dt$HalotypeA/dt$length*100
dt$perB=dt$HalotypeB/dt$length*100
dm=dt[dt$length>=100,]
for(k in 1:nrow(dm)){
  dm$position[k]=paste0('block_',k)
}
plot=dm[,c(4,7,8)]
colnames(plot)=c('position','HalotypeA','HalotypeB')
plot=reshape2::melt(plot)
colnames(plot)=c('Position(scaffold,base)','Type','percentage')          

plot$group=name
p1=ggplot(plot)+geom_point(aes(x=`Position(scaffold,base)`,y=percentage,
                               color=Type),size=0.7)+
  theme(axis.text.x= element_blank(),axis.ticks = element_blank(),
        legend.position = 'top')+
  facet_grid(.~group)
p1
pdf(paste0('../plot/',name,'_halotype.pdf'),width = 17,height = 8)
print(p1)
dev.off()

png(paste0('../plot/',name,'_halotype.png'),width = 800,height = 600)
print(p1)
dev.off()

##statistic
ha=sum(dt$HalotypeA)
hb=sum(dt$HalotypeB)
lentt=sum(dt$length)
to=0
ph=0
for(i in 1:nrow(pos)){
  temp=strsplit(data[pos$start[i]],' ')[[1]]
  if(temp[9]>=100){
  to=to+as.numeric(temp[5])
  ph=ph+as.numeric(temp[7])
  }
}
sa=data.frame('HalotypeA_number'=ha,
               'HalotypeB_number'=hb,
                'length_BP'=lentt,
                'Total number of heterozygous variants'=ph,
              'Variants successfully phased'=ha+hb)
colnames(ss)=colnames(sa)
ss=rbind(ss,sa)
write.csv(dm,paste0('../statistic/',name,'_statistic.csv'),quote = F,row.names = F)
}
ss=ss[-1,]
rn=file
for(i in 1:length(rn)){
  rn[i]=strsplit(rn[i],'[.]')[[1]][1]
}
rownames(ss)=rn
ss$`Percentage of successfully pharsed variant halotype`=ss$Variants.successfully.phased/ss$Total.number.of.heterozygous.variants
ss$`Percentage of successfully pharsed variant halotype`=round(ss$`Percentage of successfully pharsed variant halotype`,4)*100
sp=data.frame(t(ss))
write.csv(sp,paste0('../statistic/halotype_summary.csv'),quote = F)
