# Music-Metadata-Clustering-in-R
A project and slideshow focused on using statistical metadata to cluster music tracks into genres.  A general project work flow is shown below.

<img src="figs/EDA/project_outline.jpg" alt="Project Flow" width="450" height="350">

## Scope of Data
The data was acquired from [FMA: A Dataset For Music Analysis](https://github.com/mdeff/fma). Description pulled from the FMA git page:
>We introduce the Free Music Archive (FMA), an open and easily accessible dataset suitable for evaluating several tasks in MIR, a field concerned with browsing, searching, and organizing large music collections. The community's growing interest in feature and end-to-end learning is however restrained by the limited availability of large audio datasets. The FMA aims to overcome this hurdle by providing 917 GiB and 343 days of Creative Commons-licensed audio from 106,574 tracks from 16,341 artists and 14,854 albums, arranged in a hierarchical taxonomy of 161 genres. It provides full-length and high-quality audio, pre-computed features, together with track- and user-level metadata, tags, and free-form text such as biographies. We here describe the dataset and how it was created, propose a train/validation/test split and three subsets, discuss some suitable MIR tasks, and evaluate some baselines for genre recognition.

To summarize:
* 917 GB
* 343 days of audio
* 106,547 tracks
* 161 genres

The tracks aren't evenly distributed among genres. Shown below is a breakdown of the relative genre frequencies for the entire dataset.

![Genre Frequencies](figs/EDA/genre_frequency.jpg)

Each track contains data of measurable musical descriptors:
* Chroma
* MFCC
* Spectral Bandwidth
* Spectral Centroid
* Spectral Contrast
* Spectral Rolloff
* Tonnetz
* ZCR

## Project Motivation
As music recommender software becomes more popular, so to does the demand for better recommender algorithms to cluster music that a user may enjoy. This project was motivated by an interest in understanding how music metadata can be used to cluster similar tracks together.
#### Existing Recommender Methods
* Manual Curation
* Manual Attribute Tagging
* Collaborative Filtering
* Natural Language Processing
* *Raw Audio Modeling(this project)*

## Pre-Processing
#### How to deal with this size of data?
* Store data from raw .csv’s as MySQL database tables
* Only read in attributes from merged tables that are relevant for clustering using sql queries.
#### How much noise exists within the data?
* We chose to remove outlying genres such as Old-Time/Historic, Spoken, Easy Listening and Experimental.  This was done either because these tracks would not generally be considered music or were extreme outliers.
* ~100 columns were dropped from after applying a variance filter to help reduce the amount of noise in the data.

<img src="figs/EDA/dimension_reduction.jpg" alt="Dimension reduction" width="300" height="100">

## Dimension Reduction
Data was split into 2 additional subsets to test the effect of dimension reduction in clustering and classification, leaving  3 distinct, but related data sets:
* Full Dataset
* Principal Component Analysis (PCA)
* Self Organizing Map (SOM)
#### Self Organizing Map
<img src="figs/EDA/SOM.jpg" alt="SOM" width="430" height="330"> <img src="figs/EDA/SOM2.jpg" alt="SOM2" width="430" height="330">

#### Principal Component Analysis
<img src="figs/EDA/PCA.jpg" alt="PCA" width="430" height="330">

## Analysis
#### K-Means Clustering
<img src="figs/EDA/kmeans.jpg" alt="K-Means" width="430" height="330">

#### Deep Neural Network
<img src="figs/EDA/DNN.jpg" alt="DNN" width="430" height="330"> <img src="figs/EDA/DNN2.jpg" alt="DNN2" width="430" height="330">

#### Linear Discriminant Analysis(LDA)
<img src="figs/EDA/LDA.jpg" alt="LDA" width="430" height="330"> <img src="figs/EDA/LDA2.jpg" alt="LDA2" width="430" height="330">


## Conclusion
#### What we learned
* Raw audio does not separate easily into clusters (genres).
* Dimension reduction using PCA helped when clustering.
* Subjective genre labeling may not accurately represent similarities in the tracks raw audio.

#### Moving Forward
* Feature engineering by combining metrics may present better results.
* Test our clusters by forming playlists from the clusters and compare those to creating playlists from the actual genre labels.

<img src="figs/EDA/trackview.jpg" alt="trackview" width="400" height="100">
