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

#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------

source("login.r") # get login info
source("functions/databaseFunctions.r")
source("functions/HCfunctions.r")

#--------------------------------------------------------------------
#         Get List of Tables, Get DataFrame of Chosen Table
#--------------------------------------------------------------------

atts <- getTableNames()
stats <- atts[3:9]
#stats <- c('maxStat','minStat')

drop_cols <- c('Old-Time / Historic','Spoken','Easy Listening',
               'Experimental') #,'Electronic','Rock')
linkage <- 'complete'
k <- c(10,12)
clusterGraphs <- list()

j <- 1
for(stat in stats){
  print(stat)

  tic('Getting data from mySQL...')
  df <- parentGenreAndData(stat)
  toc()

  df <- columnDropper(df,drop_cols)

  df <- genreBalancer(df)

  newGraph <- myHC(df, linkage, k, stat)
  clusterGraphs[[j]] <- newGraph
  j = j + 1
}

folder <- 'figs/HRPlots/Test'
HCplotter(clusterGraphs,folder,k)
