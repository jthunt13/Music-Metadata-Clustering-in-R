#--------------------------------------------------------------------
#                   Clear environment and set wd
#--------------------------------------------------------------------
rm(list = ls())
setwd("Google Drive/UB MS/Spring2018/STA546/sta546-project")
#--------------------------------------------------------------------
#                         Load Libraries
#--------------------------------------------------------------------

library("RMySQL")
library("ggplot2")
library("gridExtra")
library("plyr")
library("tictoc")
library("factoextra")
library("cluster")
library("viridis")
library("reshape2")
system('free -m')

#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------

source("login.r") # get login info
source("functions/databaseFunctions.r")

#------------------------------------------------------------------------
#                 do stuff with full table
#------------------------------------------------------------------------
df <- getAllData()

mu <- colMeans(df[,-1])
pca1 <- prcomp(df[,-1],center = T,scale. = T)
pc1N2 <- as.data.frame(pca1$x[,1:2])

#------------------------------------------------------------------------
#                       PCA Scree
#------------------------------------------------------------------------

pdf('figs/PCA_scree.pdf')
fviz_eig(pca1, geom="bar", width=0.8, addlabels=T,hjust=0.5,
         main = 'PCA Scree Plot', xlab = 'Principal Component',
         ylab = 'Variance Explained')+
  theme(plot.title = element_text(size = 18, face = "bold"))
dev.off()

#------------------------------------------------------------------------
#                       WSS PCA Plot
#------------------------------------------------------------------------

k_range = 1:15
wss <- sapply(k_range, 
              function(k){kmeans(pc1N2,
                                 k, nstart=25,iter.max = 15 )$tot.withinss})

wss_df <- data.frame(k_range,wss)
g <- ggplot(data = wss_df,aes(x = k_range, y = wss))+
  geom_line()+
  geom_point(size=2, shape=21, fill="black", colour="white", stroke=1.5)+
  labs(x='Number of Clusters K',y="Total Within-Clusters Sum of Squares (wss)")+
  ggtitle('WSS K-Choice, PCA 3 Components')+
  theme(plot.title = element_text(size = 18, face = "bold"))+
  geom_point(data=wss_df, aes(x=4, y=wss_df[4,2]), colour="red", size=5, shape =1)+
  geom_point(data=wss_df, aes(x=12, y=wss_df[12,2]), colour="red", size=5, shape =1)

ggsave('figs/k_choice_wss_pca.pdf',g,height = 4, width = 6.5)

#------------------------------------------------------------------------
#                       GAP PCA Plot
#------------------------------------------------------------------------

tic('Gap Stat')
gap_stat <- clusGap(pc1N2, FUN = kmeans, nstart = 25,
                    K.max = 15, B = 5)
toc()
saveRDS(gap_stat,file=paste0(folder,'/RDS/gap_stat.RDS'))
#gap_stat <- readRDS(paste0(folder,'/RDS/gap_stat.RDS'))

gap_df <- data.frame(gap_stat[[1]])

g<- ggplot(data = gap_df,aes(x = k_range, y = gap))+
  geom_line()+
  geom_point(size=2, shape=21, fill="black", colour="white", stroke=1.5)+
  labs(x='Number of Clusters K',y="Gap")+
  ggtitle('Gap Statistic K-Choice, SOM 37 x 37')+
  theme(plot.title = element_text(size = 18, face = "bold"))+
  geom_point(data=gap_df, aes(x=4, y=gap_df[4,3]), colour="red", size=5, shape =1)+
  geom_point(data=gap_df, aes(x=12, y=gap_df[12,3]), colour="red", size=5, shape =1)

ggsave(paste0(folder,'figs/k_choice_gap.pdf'),g,height = 4, width = 6.5)

#------------------------------------------------------------------------
#                       Genre PCA Plot
#------------------------------------------------------------------------

pc1N2 <- data.frame(pca1$x[,1:2],df$parent)

g <- ggplot(data = pc1N2,aes(x = PC1, y = PC2,col=as.factor(df$parent)))+
  geom_point()+
  labs(x='PC1',y="PC2")+
  scale_color_discrete('Genre')+
  ggtitle('Principal Components and Genre')+
  theme(plot.title = element_text(size = 18, face = "bold"))+
  theme(legend.text=element_text(size=12))

ggsave('figs/pca_genres.jpg',g,height = 4, width = 6.5)
