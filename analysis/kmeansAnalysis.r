# Author (s)    : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-06
# Date Modified : 2018-05-02
# Description   : Script that reads in full table and does k-means
#   clustering for various cluster sizes and makes plots
#--------------------------------------------------------------------
#                   Clear environment and set wd
#--------------------------------------------------------------------
rm(list = ls())
setwd("~/Documents/Programs/sta546-project")
#setwd("Google Drive/UB MS/Spring2018/STA546/sta546-project")
#--------------------------------------------------------------------
#                         Load Libraries
#--------------------------------------------------------------------
library("RMySQL") #install.packages("RMySQL")
library("ggplot2")
library("gridExtra")
library("plyr")
library("tictoc") #install.packages("tictoc")
library("factoextra") #install.packages("factoextra")
library("cluster")
library("viridis")#install.packages("viridis")
library("reshape2")
system('free -m')
#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------
source("login.r") # get login info
source("functions/databaseFunctions.r")
#--------------------------------------------------------------------
#                           Functions
#--------------------------------------------------------------------
kmeansPlotter <- function(df,label,centroids,figs,listStart,pc1N2){

  k <- kmeans(df,centers = centroids,iter.max = 20)

  # make a datframe from cluster output and add actual labels
  tmp <- as.data.frame(k$cluster)

  n = gsub("df.","",deparse(substitute(df)))
  #print(paste0("data/tmp/",centroids,"clusters",n,".csv"))
  write.csv(tmp,file = paste0("data/tmp/",centroids,"clusters",n,".csv"))

  names(tmp)[1] <- "cluster"
  tmp$parentGenre <- label

  df2 <- as.data.frame(table(tmp))
  totals <- aggregate(Freq ~ parentGenre,data = df2,FUN = sum)

  df2.sumNormalized <- df2

  for(i in 1:dim(totals)[1]){
    genre <- totals$parentGenre[i]
    for(j in 1:nrow(df2)){
      if(df2.sumNormalized$parentGenre[j] == genre){
        df2.sumNormalized$Freq[j] = df2.sumNormalized$Freq[j]/totals$Freq[i]
      }
    }
  }
  gg <- ggplot(data = df2.sumNormalized, aes(x = parentGenre,y=cluster)) + geom_tile(aes(fill = Freq)) +
    theme(axis.text.x = element_text(angle = 60,hjust = 1),axis.title.x=element_blank(),text = element_text(size=20)) +
    scale_fill_viridis() + ggtitle(paste0("Cluster Assignment for"," K = ",centroids))

  # add labels to pc's 1 & 2
  pc1N2$cluster <- as.factor(k$cluster)

  gg2 <- ggplot(data = pc1N2,aes(x = PC1,y = PC2, colour = cluster)) + geom_point()+stat_ellipse()+
    ggtitle("2D-PCA Clustering")+ theme(text = element_text(size=20))

  # add ggplots to list
  figs[[listStart]] <-gg
  figs[[listStart+1]] <- gg2

  return(figs)
}
#------------------------------------------------------------------------
#                 do stuff with full table
#------------------------------------------------------------------------
df <- getAllData()

mu <- colMeans(df[,-1])
pca1 <- prcomp(df[,-1],center = T,scale. = T)
pc1N2 <- as.data.frame(pca1$x[,1:2])
# make a scree plot from the pca
#x11()
#pdf("figs/fulldataScree.pdf",width = 10,height = 10)
screeplot(pca1)
scree <- as.data.frame((pca1$sdev^2)/sum(pca1$sdev^2)*100)
colnames(scree) <- "Variance"
scree$pc <- c(1:nrow(scree))

screePlot <- ggplot(data = scree[1:15,],aes(x = pc,y = Variance))+geom_point()+geom_line()+
  ggtitle("Scree Plot")+ ylab("% Variance Explained") + xlab("Principal Component")

x11()
plot(screePlot)
ggsave("figs/screePlot.pdf",plot = screePlot,width = 10,height = 10)

#dev.off()
# plot says pick 4 pc's
nComp = 4
# reconstruct matrix
df.reconstructed <- pca1$x[,1:nComp] %*% t(pca1$rotation[,1:nComp])
df.reconstructed = as.data.frame(scale(df.reconstructed, center = -mu, scale = FALSE))
#df.reconstructed$parentGenre <- df[,1]
# make a scaled version of the data
df.scaled <- scale(df[,-1])
#----------------------------------------------------------------------------------------
#                           find how many clusters to use
#----------------------------------------------------------------------------------------
k.max <- 15
wss.scaled <- c()
for(k in 1:k.max){
  tmp <- kmeans(df.scaled,k,iter.max = 20)
  print(tmp$tot.withinss)
  wss.scaled <- c(wss.scaled,tmp$tot.withinss)
}
wss.reconstructed <- c()
for(k in 1:k.max){
  tmp <- kmeans(df.reconstructed,k,iter.max = 20)
  print(tmp$tot.withinss)
  wss.reconstructed <- c(wss.reconstructed,tmp$tot.withinss)
}

wss <- as.data.frame(wss.scaled)
wss$wss.scaled <- NULL
wss$scaled <- wss.scaled
wss$PCAreconstructed <- wss.reconstructed
wss.melted <- melt(wss)
wss.melted$cluster <-c(1:15,1:15)

ggWss <- ggplot(data = wss.melted,aes(x = cluster,y = value,colour =variable))+ geom_line()+ geom_point() +
  ylab("Within-cluster sum of squares (WSS)")+ ggtitle("K-means WSS")+theme(text = element_text(size=14))
x11()
plot(ggWss)

ggsave("figs/wssKmeans.pdf",plot = ggWss,width = 10,height = 10)
#--------------------------------------------------------------------------------------
#                               Make plots for scaled data
#--------------------------------------------------------------------------------------
figs <- list()
figs <- kmeansPlotter(df.scaled,df[,1],12,figs,1,pc1N2)
figs <- kmeansPlotter(df.scaled,df[,1],4,figs,3,pc1N2)

pdf("figs/kmeans/rawScaledkmeans.pdf",width = 15,height = 15)
grid.arrange(grobs = figs,ncol = 2)
dev.off()

if(F){
figs <- list()
figs <- kmeansPlotter(df.scaled,df[,1],5,figs,1,pc1N2)
figs <- kmeansPlotter(df.scaled,df[,1],6,figs,3,pc1N2)

pdf("figs/kmeans/rawScaledkmeansP2.pdf",width = 15,height = 15)
grid.arrange(grobs = figs,ncol = 2)
dev.off()
}
#--------------------------------------------------------------------------------------
#                               Make plots for reconstructed data
#--------------------------------------------------------------------------------------
figs <- list()
figs <- kmeansPlotter(df.reconstructed,df[,1],12,figs,1,pc1N2)
figs <- kmeansPlotter(df.reconstructed,df[,1],4,figs,3,pc1N2)

pdf("./figs/kmeans/PCAReconstructed.pdf",width = 15,height = 15)
grid.arrange(grobs = figs,ncol = 2)
dev.off()

if(F){
figs <- list()
figs <- kmeansPlotter(df.reconstructed,df[,1],5,figs,1,pc1N2)
figs <- kmeansPlotter(df.reconstructed,df[,1],6,figs,3,pc1N2)

pdf("./figs/kmeans/PCAReconstructedP2.pdf",width = 15,height = 15)
grid.arrange(grobs = figs,ncol = 2)
dev.off()
}
#--------------------------------------------------------------------------------------
#                               Make csv for labels
#--------------------------------------------------------------------------------------
# get kmeans labels for cluster size 4
tmp <- read.csv("data/tmp/4clustersscaled.csv",header = T)
clusterAssignments <- as.data.frame(tmp$k.cluster)
colnames(clusterAssignments) <- "scaled"
tmp <- read.csv("data/tmp/4clustersreconstructed.csv",header = T)
clusterAssignments$reconstructed <- tmp$k.cluster

write.csv(clusterAssignments,file = "data/4clusterLabels.csv")
