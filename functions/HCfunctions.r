library(tictoc)

#----------------------------------------------------------------------------------
#                           My Heirarchical Clustering
#----------------------------------------------------------------------------------

myHC <- function(df,linkage,k,stat){
  tic('Clustering')
  clusters <- hclust(dist(df[,-1]),method=linkage)
  i <- 1
  g <- list()
  for(x in k){
    clusterCut <- cutree(clusters,x)
    tbl <- table(clusterCut,df$parent)
    melt_tbl <- melt(tbl)
    g[[i]] <- ggplot(data = melt_tbl, aes(x = Var.2, y = clusterCut)) +
      geom_tile(aes(fill = value)) +
      theme(axis.text.x = element_text(angle=90)) +
      ggtitle(paste0(stat,', ',linkage,' linkage, ','k=',x)) + 
      ylab('Cluster') + 
      xlab('Genre')
    i = i + 1
  }
  toc()
  return(g)
}

#----------------------------------------------------------------------------------
#                               HC Plotter
#----------------------------------------------------------------------------------

HCplotter <- function(gr,folder,k){
  tic('Plotting')
  i = 1
  for(x in k){
    filepath <- paste0(folder,'/HRGrid_',x,'_',stat,'.pdf')
    pdf(filepath,height=10,width=10)
    grid.arrange(gr[[1]][[i]],gr[[2]][[i]],gr[[3]][[i]],
                 gr[[4]][[i]],gr[[5]][[i]],gr[[6]][[i]],
                 gr[[7]][[i]],nrow=3,ncol=3,
                 top='Heirarchical Heatmaps')
    dev.off()
    print()
    i = i + 1
  }
  toc()
}

#----------------------------------------------------------------------------------
#                               Genre Balancer
#----------------------------------------------------------------------------------
genreBalancer <- function(df){
  tic('Balancing')
  tbl <- table(df$parent)
  genres <- names(tbl)
  obs <- min(tbl)
  counts <- rep(0,length(genres))
  drop <- c()
  for(i in seq_len(nrow(df))){
    ind <- which(genres %in% df[i,'parent'])
    if(counts[ind] < obs){
      counts[ind] <- counts[ind] + 1
    }
    else{
      drop <- c(drop,i)
      counts[ind] <- counts[ind] + 1
    }
  }
  df <- df[-drop,]
  toc()
  return(df)
}

#----------------------------------------------------------------------------------
#                               Column Dropper
#----------------------------------------------------------------------------------

columnDropper <- function(df,cols){
  tic('Dropping Genres')
  df <- df[!(df$parent %in% cols),]
  toc()
  return(df)
}
