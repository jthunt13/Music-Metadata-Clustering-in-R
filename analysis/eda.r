# Author (s)    : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-06
# Date Modified : 2018-04-06
# Description   : Exploratory Data Analysis
#--------------------------------------------------------------------
#                   Clear environment and set wd
#--------------------------------------------------------------------
rm(list = ls())
setwd("~/Documents/Programs/sta546-project")
#--------------------------------------------------------------------
#                         Load Libraries
#--------------------------------------------------------------------
library("RMySQL") #install.packages("RMySQL")
#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------
source("login.r") # get login info
source("functions/databaseFunctions.r")
#--------------------------------------------------------------------
#                             EDA
#--------------------------------------------------------------------
