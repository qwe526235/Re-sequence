setwd("C:/Users/zjy52/Desktop/重测序/LOH")
library(dplyr)
library(data.table)
library(ggplot2)
file=list.files('bed/',pattern = 'filter.bed')
ref=fread('length.txt')
colnames(ref)=c('scaffold','length')
dk=data.frame(matrix(nrow = 1,ncol = 4))
colnames(dk)=c('site','class','scaffold','group')
dll=data.frame(matrix(nrow = 1,ncol = 5))
colnames(dll)=c('position','site','mark','scaffold','group')
for( m in 1:length(file)){
bed=fread(paste0('bed/',file[m]))
gname=basename(file[m])
gname=strsplit(gname,'-1')[[1]][1]
colnames(bed)=c('scaffold','start','end')
ref=ref[order(-ref$length),]
ref=ref[1:8,]
bed=bed[bed$scaffold %in% ref$scaffold,]
color=c('LOH','HET')
ll=data.frame(matrix(nrow=1,ncol=3))
for(j in 1:nrow(ref)){
test1=ref[j,]
test2=bed[bed$scaffold %in% test1$scaffold,]
if(test2$start[1]==0){
test2$start[1]=1
}
t_data1=data.frame('position'=seq(1,test1$length,1),
                   'group'=rep('LOH',test1$length))
dt=data.frame(matrix(nrow = 1,ncol = 3))
colnames(dt)=c('position','group','mark')
k=2
for( i in 1:nrow(test2)){
  temp=test2[i,]
  tem=data.frame('position'=seq(temp$start,temp$end,1),
                 'group'=rep('HET',(temp$end-temp$start+1)),
                 'mark'=rep(k,(temp$end-temp$start+1)))
  
  dt=rbind(dt,tem)
  k=k+2
  
}
dt=dt[-1,]
dm=left_join(t_data1,dt,by='position')
dm=dm[,c(1,3,4)]
colnames(dm)=c('position','site','mark')
dm[is.na(dm$site),]$site='LOH'
dm[1:(test2$start[1]-1),]$mark=1
k=3
for(i in 2:nrow(test2)){
  spl=test2$start[i]-1
  sp=test2$end[i-1]+1
  dm[sp:spl,]$mark=k
  k=k+2
}
if(nrow(dm[is.na(dm$mark),])!=0){
dm[is.na(dm$mark),]$mark=max(dm$mark)+1
}
dm=dm[,1:2]
dm$scaffold=ref[j,]$scaffold
colnames(ll)=colnames(dm)
ll=rbind(ll,dm)
}
ll=ll[-1,]
ll$group=gname
ll$site=factor(ll$site,levels=color)
sc=unique(ll$scaffold)
for( s in 1:length(sc)){
tl=ll[ll$scaffold %in% sc[s],]
p2=ggplot(tl)+geom_tile(aes(x=position,y=0.1,fill=site))+ylab('')+xlab('')+
  scale_x_continuous(expand = c(0,0))+
  scale_y_continuous(expand = c(0,0))+
  scale_fill_manual(values = c('#EE2C2C','#CDCD00'))+
  theme_bw()+
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank())+
  facet_grid(group~ scaffold,space = 'free',scales = 'free',switch = 'y')
p2

pdf(paste0('plot/',gname,'(',sc[s],')','.pdf'),width=15,height=2)
print(p2)
dev.off()

png(paste0('plot/',gname,'(',sc[s],')','.png'),width=800,height=200)
print(p2)
dev.off()


}

}





