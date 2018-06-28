# Author (s)    : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-06
# Date Modified : 2018-05-02
# Description   : Make a balanced dataset
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
library(tictoc)
library(plyr)
#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------
source("login.r") # get login info
source("functions/databaseFunctions.r")
#--------------------------------------------------------------------
#                       Read in the data
#--------------------------------------------------------------------
clusterLabels <- read.csv("data/4clusterLabels.csv")
clusterLabels$X <- NULL

clusterLabels <- clusterLabels-1

df <- getAllData()

mu <- colMeans(df[,-1])
pca1 <- prcomp(df[,-1],center = T,scale. = T)
nComp = 4
# reconstruct matrix
df.reconstructed <- pca1$x[,1:nComp] %*% t(pca1$rotation[,1:nComp])
df.reconstructed = as.data.frame(scale(df.reconstructed, center = -mu, scale = FALSE))
df.scaled <- as.data.frame(scale(df[,-1],center = T,scale = T))

underSampleData <- function(df,groupSize,label,s){
  set.seed(s)

  groups <- unique(label)

  dfSubSampled <- df[0,]

  df$group <- label

  for( i in 1:length(groups)){
    df1 <- subset(df,group == groups[i])
    if(dim(df1)[1] < groupSize){
      ind <- 1:nrow(df1)
    } else{
      ind <- sample(1:nrow(df1),size = groupSize,replace = F)
    }
    df1 <- df1[ind,]
    dfSubSampled <- rbind(dfSubSampled,df1)
  }
  return(dfSubSampled)
}
names(df)
df0 <- underSampleData(df[,-1],800,df[,1],123)
df1 <- underSampleData(df.scaled,800,df[,1],123)
df2 <- underSampleData(df.scaled,14000,clusterLabels[,1],123)
df3 <- underSampleData(df.reconstructed,18000,clusterLabels[,2],123)

write.csv(df0, "data/UnderSampledUnscaled.csv")
write.csv(df1, "data/UnderSampled.csv")
write.csv(df2, "data/ScaledUnderSampled.csv")
write.csv(df3, "data/ReconstructedUnderSampled.csv")
