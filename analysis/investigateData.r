# Author (s)    : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-06
# Date Modified : 2018-04-06
# Description   : Investigate Data
#--------------------------------------------------------------------
#                   Clear environment and set wd
#--------------------------------------------------------------------
rm(list = ls())
setwd("~/Documents/Programs/sta546-project")
#--------------------------------------------------------------------
#                         Load Libraries
#--------------------------------------------------------------------
library("RMySQL") #install.packages("RMySQL")
library("ggplot2")
#--------------------------------------------------------------------
#               Get DB login info and DB functions
#--------------------------------------------------------------------
source("login.r") # get login info
source("functions/databaseFunctions.r")
#--------------------------------------------------------------------
#                           Investigate Data
#--------------------------------------------------------------------
q = "SELECT * FROM genre_key"
genre_key <- getData(q)
q = "SELECT genre_id, count(*) as cnt FROM track_key GROUP BY genre_id"
genre_counts <- getData(q)

boxplot(genre_counts$cnt)
# this shows that the vast majority of genres have a low amount entries
# to remedy this, try and merge into parent genres
#---------------------------------------------------------------------------
#                       Frequency of parent genres
#---------------------------------------------------------------------------
q = "SELECT S.top_level_parent, H.title,S.cnt
    FROM(SELECT G.top_level_parent,
        count(*) as cnt
        FROM track_key AS T,
                genre_key AS G
                WHERE T.genre_id = G.genre_id
                GROUP BY G.top_level_parent) AS S,
    genre_key AS H
    WHERE H.genre_id = S.top_level_parent"
parent_genre_cnt <- getData(q)

#"#76b139"

# might want to remove spoken
# investigate experimental further
g <- ggplot(data = parent_genre_cnt,aes(x = title, weight = cnt)) + geom_bar(fill = "steelblue")+
  theme(axis.text.x = element_text(angle = -60,hjust = 0)) + xlab("Genre Title") +
  ylab("Frequency") + ggtitle("Parent Genre Frequencies")
x11()
plot(g)
ggsave("figs/parentGenreFreq.pdf")

#---------------------------------------------------------------------------
#                     Time Line of parent genres
#---------------------------------------------------------------------------
q = "SELECT S.year,
U.title,
S.sum
FROM (SELECT YEAR(A.album_date_released) as year,
    G.top_level_parent,
    sum(album_tracks) as sum
    FROM album_key as A,
        genre_key as G,
        track_key as T
        WHERE YEAR(A.album_date_released) > 0
        AND T.album_id = A.album_id
        AND G.genre_id = T.genre_id
    GROUP BY YEAR(A.album_date_released),
    G.top_level_parent) AS S,
    genre_key AS U
WHERE S.top_level_parent = U.genre_id"

# this query takes some time (~1.25 minutes on my computer)
# only about 2/3 have a year associated with them
genre_time_line <- getData(q)

g2 <- ggplot(genre_time_line, aes(x = year, y = sum,fill = title)) + geom_area() +
  xlab("Year") + ylab("Sum of Frequencies") + ggtitle("Parent Genre Time Line")

x11()
plot(g2)
ggsave("figs/parentGenreTimeLine.pdf")
