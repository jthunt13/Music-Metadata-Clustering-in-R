library(tictoc)

#----------------------------------------------------------------------------------
#                         Self-Organizing Map Functions
#----------------------------------------------------------------------------------

SOMHeatmapper <- function(df,folder,stat){
  som_grid <- somgrid(xdim = 10, ydim = 10, topo="hexagonal")
  tic('Training Map and Plotting')
  som_model <- som(scale(df[,-1]), 
                   grid=som_grid, 
                   rlen=100, 
                   alpha=c(0.05,0.01), 
                   keep.data = TRUE)
  n <- ncol(df)-1
  lay_vec <- c((1:n),0,0,0,0,0,0)
  pdf(paste0(folder,'/SOMHeatmap_',stat,'.pdf'),height=50,width=50)
  layout(matrix(lay_vec, nrow = 10, ncol = 8, byrow = TRUE))
  
  for(i in 1:n){
    plot(som_model, type = "property", property = som_model$codes[[1]][,i],
         main=colnames(som_model$codes[[1]])[i], palette.name=coolBlueHotRed)
  }
  dev.off()
  toc()
  return(som_model)
}

SOMTrainer <- function(df,sizes){
  som_models <- list()
  ind = 1
  for(i in sizes){
    file <-  paste0("Analysis/SOM_data/RDS/som_model_",i,".RDS")
    if(!(file.exists(file))){
      tic('Training and saving SOM')
      som_grid <- somgrid(xdim = i, ydim = i, topo="hexagonal")
      som_model <- som(scale(df[,-1]), 
                       grid=som_grid, 
                       rlen=100, 
                       alpha=c(0.05,0.01), 
                       keep.data = TRUE)
      save(som_model,file=file)
      toc()
    }else{
      print(paste0('Model already exists: ',i))
    }
    som_models[[ind]] <- readRDS(file)
    ind = ind + 1
  }
  return(som_models)
}

SOMPlotter <- function(df,model){
  n <- ncol(df)-1
  lay_vec <- c(1:6)
  dim <- model$grid['xdim']
  pdf(paste0('Analysis/SOM_data/figs/SOM_Kmeans_',dim,'.pdf'),height=6,width=8)
  layout(matrix(lay_vec, nrow = 2, ncol = 3, byrow = TRUE))
  plot(model, type="changes",palette.name=coolBlueHotRed)
  plot(model, type="counts", palette.name=coolBlueHotRed)
  plot(model, type="dist.neighbours",palette.name=coolBlueHotRed)

  for(k in c(3,6,12)){
    k_model <- kmeans(model$codes[[1]],k,iter.max = 50)
    plot(model, type="mapping",
         bgcol = pretty_palette(length(k_model$cluster))[k_model$cluster],
         main = paste0("Clusters k=",k),pchs=NA)
    add.cluster.boundaries(model, k_model$cluster)
  }
  dev.off()
}

coolBlueHotRed <- function(n, alpha = 1) {rainbow(n, end=4/6, alpha=alpha)[n:1]}


kmeansPlotter <- function(df,label,centroids){
  
  k <- kmeans(df,centers = centroids,iter.max = 20)
  
  # make a datframe from cluster output and add actual labels
  tmp <- as.data.frame(k$cluster) 
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
    theme(axis.text.x = element_text(angle = 60,hjust = 1)) + scale_fill_viridis() + 
    ggtitle(paste0("K = ",centroids))
  
  return(gg) 
}