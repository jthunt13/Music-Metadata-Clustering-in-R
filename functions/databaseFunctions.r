# Author (s)    : Joseph Hadley
# Date Created  : 2018-04-06
# Date Modified : 2018-04-28
# Description   : Database Functions
#------------------------------------------------------------------------------
getData <- function(query){
  # make connection to database
  con <- dbConnect(RMySQL::MySQL(),user = LocalMySQLLogin$user,
                   password = LocalMySQLLogin$password,
                   dbname = 'sta546',
                   host = LocalMySQLLogin$host,
                   port = LocalMySQLLogin$port)
  
  df <- dbGetQuery(con,query)
  # close database connection
  dbDisconnect(con)
  return(df)
}# end of getData

parentGenreAndData <- function(table){
  topParentToTitle = "(SELECT A.title as parent,B.genre_id FROM (SELECT top_level_parent, title FROM genre_key as G WHERE G.genre_id = G.top_level_parent) AS A JOIN genre_key AS B ON A.top_level_parent = B.top_level_parent)"
  trackIdToGenre = paste("(SELECT T.track_id, H.* FROM track_key AS T JOIN ",topParentToTitle," AS H ON T.genre_id = H.genre_id)",sep = "")
  q = paste("SELECT S.parent, C.* FROM ", trackIdToGenre, " AS S JOIN ", table, " AS C ON C.trackID = S.track_id" ,sep = "")
  df <- getData(q)
  df$trackID <- NULL
  return(df)
}

getTableCols <- function(table){
  df <- getData(paste("SELECT * FROM ",table," LIMIT 1",sep = ""))
  n <- names(df)
  return(n)
}

getTableNames <- function(){
  df <- getData(paste("SHOW TABLES",sep = ""))
  tables <- df[1:nrow(df),]
  return(tables)
}

singleGenreAndData <- function(table,genre){
  q0 <- paste0("SELECT top_level_parent FROM genre_key WHERE title = ",'"',genre,'"')
  df <- getData(q0)
  val <- df[1:nrow(df),]
  q = paste0("SELECT S.title, C.* ",
                "FROM (SELECT T.track_id, H.title ",
                  "FROM track_key AS T JOIN (SELECT G.genre_id, G.title ",
                    "FROM genre_key AS G WHERE G.top_level_parent = ",val, ") AS H ",
                      "ON T.genre_id = H.genre_id) AS S ",
                        "JOIN ",table," AS C ",
                          "ON C.trackID = S.track_id;")

  df <- getData(q)
  df$trackID <- NULL
  return(df)
}

# function that return the legend
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  legend
}

confusionMatrixFromDF <- function(df){
  # make an empty matrix
  matrx <- matrix(ncol = length(unique(df$parentGenre)),
                  nrow = length(unique(df$cluster)))
  # rename columns
  colnames(matrx) <- c(unique(df$parentGenre))
  # make a dataframe from the matrix
  df2 <- as.data.frame(matrx)
  n <- names(df2)

  aggregate(cluster~parentGenre,data = df,FUN = function(x){NROW(x)})
  
  for( i in 1:dim(df2)[2]){
    #subset data
    tmp <- subset(df,parentGenre == n[i])
    cnt <- count(tmp,vars = "cluster")

    for(j in 1:dim(cnt)[1]){
      df2[cnt$cluster[j],n[i]] = cnt$freq[j]
    }# end nested for
  }# end outer for
  
  #fill in nas with zeros
  df2[is.na(df2)] <- 0
  return(df2)
}
                      
getAllData <- function(){
  tic('Getting data from sql')
  df <- parentGenreAndData('fullTable')
#  q <- "SELECT * FROM fullTable;"
  drop_cols <- c('Old-Time / Historic','Spoken','Easy Listening',
                 'Experimental') #,'Electronic','Rock')
#  df <- getData(q)
  df <- df[!(df$parent %in% drop_cols),]
  toc()
  return(df)
}
