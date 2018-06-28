# Author (s)    : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-06
# Date Modified : 2018-05-02
# Description   : Script that reads in undersampled data and builds an
#     LDA classifier and tests its accuracy
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
library("MASS")
library("caret")#install.packages("caret")
library("gridExtra")
library("tictoc") #install.packages("tictoc")
library("viridis")#install.packages("viridis")
#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------
source("login.r") # get login info
source("functions/databaseFunctions.r")
#--------------------------------------------------------------------
#                           Functions
#--------------------------------------------------------------------


#--------------------------------------------------------------------
#                         Read in the data
#--------------------------------------------------------------------
getUnderSampledData <- function(fname){
  output <- list()
  df <- read.table(fname,sep= ",",stringsAsFactors = F,header = T)
  df$X <- NULL
  labels <- df$group
  df$group <- NULL
  # center and scale the data
  df.scaled <- as.data.frame(scale(df, center = T,scale = T))
  # sample the data
  trainInd <- sample(1:nrow(df),size = round(0.8*nrow(df)),replace = F)
  train <- df.scaled[trainInd,]
  test <- df.scaled[-trainInd,]
  # add labels back to data
  train$group <- labels[trainInd]
  test.actual <- labels[-trainInd]
  #put outputs in list
  output[[1]] <- train
  output[[2]] <- test
  output[[3]] <- test.actual

  return(output)
}
testLDA <- function(data,title,saveTitle){
  train <- data[[1]]
  test <- data[[2]]
  test.actual <- data[[3]]
  lda.model <- lda(group ~.,data = train)
  prediction <- predict(lda.model,newdata = test)
  test.predict <- prediction$class

  confMat <- as.data.frame(table(test.predict,test.actual))

  gg <- ggplot(data = confMat, aes(x = test.actual,y=test.predict)) + geom_tile(aes(fill = Freq)) +
    theme(axis.text.x = element_text(angle = 90,hjust = 1)) + scale_fill_viridis() +
    ggtitle(title) + xlab("True") + ylab("Predicted")
  x11()
  plot(gg)
  ggsave(saveTitle,plot = gg,width = 10,height = 10)
  print(confusionMatrix(table(test.predict,test.actual)))
}
#--------------------------------------------------------------------
#                 train model and make confusion matrix
#--------------------------------------------------------------------
output <- getUnderSampledData("data/UnderSampled.csv")
testLDA(output,"LDA Confusion matrix","figs/lda/LDAscaledUndersampled.pdf")

output <- getUnderSampledData("data/ScaledUnderSampled.csv")
testLDA(output,"LDA Confusion matrix","figs/lda/LDAScaledUndersampledkmeans.pdf")

output <- getUnderSampledData("data/ReconstructedUnderSampled.csv")
testLDA(output,"LDA Confusion matrix","figs/lda/LDAReconstructedUndersampledkmeans.pdf")
