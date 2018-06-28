# Author (s)    : Jonathan Hunt, Joseph Hadley
# Date Created  : 2018-04-25
# Date Modified : 2018-04-25
# Description   : Unsupervised Learning on Music Data

#--------------------------------------------------------------------
#                   Clear environment and set wd
#--------------------------------------------------------------------

rm(list = ls())
# setwd("Google Drive/UB MS/Spring2018/STA546/sta546-project")
set.seed(1)

#--------------------------------------------------------------------
#                         Load Libraries
#--------------------------------------------------------------------

library(DBI)
library(RMySQL)
library(ggplot2)
library(gridExtra)
library(tictoc)
library(reshape)
library(kohonen)
library(gridGraphics)
library(tempR)
library(cluster)

#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------

source("login.r") # get login info
source("functions/databaseFunctions.r")
source("functions/SOMfunctions.r")
source("functions/HCfunctions.r")

#--------------------------------------------------------------------
#               Get Data for DB, load in SOM model
#--------------------------------------------------------------------

df <- getAllData()
load("analysis/SOM_data/RDS/som_model_37.RDS")
train_graph <- data.frame(som_model$changes)
folder <- 'analysis/SOM_data/'

#--------------------------------------------------------------------
#                     Training Progress Plot
#--------------------------------------------------------------------

g <- ggplot(data = train_graph,
       aes(x = 1:100,y = som_model.changes))+
  geom_line()+
  labs(x='Iteration',y="Mean distance to closest unit")+
  ggtitle('SOM Training Progress, 37 x 37')+
  theme(plot.title = element_text(size = 20, face = "bold"))

ggsave(paste0(folder,'figs/train_graph_37.pdf'),g,height = 3, width = 10)

#--------------------------------------------------------------------
#                     Node Frequency Plot
#--------------------------------------------------------------------

pdf(paste0(folder,'figs/counts_graph_37.pdf'))
plot(som_model,type='counts',
     palette.name=coolBlueHotRed,
     heatkeywidth = 1.5,
     main = '',
     shape='straight')
title('SOM Node Frequency, 37 x 37', line = -.5,cex.main=2)
dev.off()

#--------------------------------------------------------------------
#                         U-Matrix Plot
#--------------------------------------------------------------------

pdf(paste0(folder,'figs/neighbours_graph_37.pdf'))
plot(som_model,type='dist.neighbours',
     palette.name=coolBlueHotRed,
     heatkeywidth = 1.5,
     main = '',
     shape='straight')
title('SOM Neighbour Distance, 37 x 37', line = -.5,cex.main=2)
dev.off()

#--------------------------------------------------------------------
#                       WSS K-Means Plot
#--------------------------------------------------------------------

k_range = 1:15
wss <- sapply(k_range,
              function(k){kmeans(som_model$codes[[1]],
                                 k, nstart=25,iter.max = 15 )$tot.withinss})

wss_df <- data.frame(k_range,wss)

g <- ggplot(data = wss_df,aes(x = k_range, y = wss))+
  geom_line()+
  geom_point(size=2, shape=21, fill="black", colour="white", stroke=1.5)+
  labs(x='Number of Clusters K',y="Total Within-Clusters Sum of Squares (wss)")+
  ggtitle('WSS Statistic K-Choice, SOM 37 x 37')+
  theme(plot.title = element_text(size = 18, face = "bold"))+
  geom_point(data=wss_df, aes(x=4, y=wss_df[4,2]), colour="red", size=5, shape =1)+
  geom_point(data=wss_df, aes(x=12, y=wss_df[12,2]), colour="red", size=5, shape =1)

ggsave(paste0(folder,'figs/k_choice_wss.pdf'),g,height = 4, width = 6.5)

#--------------------------------------------------------------------
#                   Gap Statistic K-Means Plot
#--------------------------------------------------------------------

tic('Gap Stat')
gap_stat <- clusGap(som_model$codes[[1]], FUN = kmeans, nstart = 25,
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

#--------------------------------------------------------------------
#                       K-Means Clustering
#--------------------------------------------------------------------

k <- 4
k_model <- kmeans(som_model$codes[[1]],k,iter.max = 50)
pdf(paste0(folder,'figs/node_k_means_4.pdf'),height = 7)
par(oma=c(0,0,6,0))
plot(som_model, type="mapping",pchs=NA,
     bgcol = pretty_palette(length(k_model$cluster))[k_model$cluster],
     main = '',
     shape='straight')
title('Node Clustering \n K-Means, K= 4 \n 37 x 37 SOM', outer=TRUE ,cex.main=2)
add.cluster.boundaries(som_model, k_model$cluster)
dev.off()

k <- 12
k_model <- kmeans(som_model$codes[[1]],k,iter.max = 50)
pdf(paste0(folder,'figs/node_k_means_12.pdf'),height = 7)
par(oma=c(0,0,6,0))
plot(som_model, type="mapping",pchs=NA,
     bgcol = pretty_palette(length(k_model$cluster))[k_model$cluster],
     main = '',
     shape='straight')
title('Node Clustering \n K-Means, K=12 \n 37 x 37 SOM', outer=TRUE ,cex.main=2)
add.cluster.boundaries(som_model, k_model$cluster)
dev.off()

#--------------------------------------------------------------------
#                   K-Means
#--------------------------------------------------------------------

som_grid <- somgrid(xdim = 37, ydim = 37, topo="hexagonal")
train_ind <- sample(nrow(df), 400)
train_df <- scale(df[train_ind,-1])
target <- df$parent[train_ind]

som <- xyf(train_df, target, som_grid, rlen = 100)
genre_prediction <- predict(som, newdata = train_df)
table(df[-training_indices, "Pos"], pos.prediction$prediction)

xyf.test <- xyf(as.matrix(train_df),
                 target,
                 grid = somgrid(5, 5, "hexagonal"))
xyf.prediction <- predict(xyf.test, newdata = train_df)
table(target, xyf.prediction$prediction)

data(wines)
training <- sample(nrow(wines), 120)
Xtraining <- scale(wines[training, ])
Xtest <- scale(wines[-training, ],
               center = attr(Xtraining, "scaled:center"),
               scale = attr(Xtraining, "scaled:scale"))
trainingdata <- list(measurements = Xtraining,
                     vintages = vintages[training])
testdata <- list(measurements = Xtest, vintages = vintages[-training])
mygrid = somgrid(5, 5, "hexagonal")
som.wines <- supersom(trainingdata, grid = mygrid)

som.prediction <- predict(som.wines, newdata = testdata[1])
table(vintages[-training], som.prediction$predictions[["vintages"]])

for (i in 1:ncol(som_model$data[[1]])){
  z[,i] = som_model$data[,i][som_model$unit.classif==n] * y[i]+x[i]
}
som_model$unit.classif
