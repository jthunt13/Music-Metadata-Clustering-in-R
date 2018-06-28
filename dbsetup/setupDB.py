# Author        : Joseph Hadley, Jonathan Hunt
# Date Created  : 2018-04-01
# Date Modified : 2018-04-06
# Description   : Went through the data files and split data up to make it smaller.
#   Also made SQL scripts to put data into a MYSQL database. Scripts were modified
#   slightly after this script was run.
#-------------------------------------------------------------------------------
import pandas as pd
import os
import numpy as np
import json
import datetime
#------------------------------------------------------------------------------
#                               features csv
#------------------------------------------------------------------------------
#os.chdir("/media/jkhadley/Jkhadley/DataSets/fma_metadata/")
path = os.getcwd()
os.chdir("../sta546-project/data")
os.getcwd()

df = pd.read_csv("features.csv",nrows = 10)
dft = df.transpose()

df.head()

titles = list(df.columns.values)
statistic = list(df.iloc[0])
number = list(df.iloc[1])

for i in range(1,len(titles)):
    tmp = titles[i].split(".")
    titles[i] = tmp[0]

headers = []

for i in range(1,len(titles)):
    headers.append('_'.join([titles[i],statistic[i],number[i]]))

distinctStat = np.unique(statistic)


queryP1 = "LOAD DATA LOCAL INFILE 'features.csv' INTO TABLE "
queryP2 = r" FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '" + '"' +"' IGNORE 4 LINES ("

ctP1 = "CREATE TABLE "

for i in distinctStat:
    if i == "statistics":
        continue
    else:
        statLocs = np.where(dft[0] == str(i))
        colNames = "trackID ,"
        ctTables = "(trackID INT NOT NULL ,\n"
        for j in range(1,len(titles)):
            if j in statLocs[0]:
                tmpColName = titles[j] + '_' + number[j]
                colNames += tmpColName + " ,\n"
                ctTables += tmpColName + " DOUBLE DEFAULT NULL ,\n"
            else:
                colNames += "@ignore ,\n"

            loadDataQ = queryP1 + i + queryP2 + colNames + ");"
            ctQuery = ctP1 + i + ctTables + ');'

            loadDataQ.replace(",);",');')
            ctQuery.replace(",);",');')


            f = open("sqlQueries/" + i + ".txt","w")
            f.write("use sta546;")
            f.write("DROP TABLE IF EXISTS " + i + ";")

            f.write(ctQuery)
            f.write(loadDataQ)
            f.close()


os.chdir("../dbsetup")

dfDrop = pd.read_csv("colsToDrop.txt",header=None)
dfDrop = dfDrop.T
statDict = {}
for i in range(0,dfDrop.shape[1]):

    # drop nans and convert to np.array
    tmp = dfDrop[i][1:][~pd.isnull(dfDrop[i][1:])].as_matrix(columns = None)
    # add to dictionary
    statDict[dfDrop[i][0]] = tmp

colNames = "trackID ,"
ctTables = "(trackID INT NOT NULL ,\n"
stat1 = np.where(dft[0] != "statistics")
stat2 = np.where(dft[0] != "kurtosis")
k = np.where(dft[0] == "kurtosis")
statLocs = np.intersect1d(stat1,stat2)

for i in range(0,len(dft)):
    tmpColName = titles[i] + '_' + number[i]
    if i in statLocs:
        # get list
        tmpList = statDict[statistic[i]]
        if tmpColName in tmpList:
            # if in list to ignore, ignore it
            colNames += "@ignore ,\n"
        else:
            colNames += statistic[i] +"_"+ tmpColName + " ,\n"
            ctTables += statistic[i] +"_"+ tmpColName + " DOUBLE DEFAULT NULL ,\n"
    elif i in k[0]:
        colNames += "@ignore ,\n"
    else:
        print(statistic[i] + tmpColName)
        #colNames += "@ignore ,\n"
        #ctTables += tmpColName + " DOUBLE DEFAULT NULL ,\n"

f = open("sqlQueries/fullTable.sql","w")
f.write("use sta546;")
f.write("DROP TABLE IF EXISTS fullTable;")

loadDataQ = queryP1 + "fullTable" + queryP2 + colNames + ");"
ctQuery = ctP1 + "fullTable" + ctTables + ');'

f.write(ctQuery)
f.write(loadDataQ)
f.close()

#------------------------------------------------------------------------------
#                 look at other csv's to extract information
#------------------------------------------------------------------------------

df2 = pd.read_csv("genres.csv")
thingsToKeep = ["genre_id","parent","title","top_level"]
df2 = df2[thingsToKeep]
df2

df2.to_csv("genre_key.csv",index = False)

#Load this whole thing into RAM to save columns that we care about to CSV
df3 = pd.read_csv("raw_tracks.csv")
df3.head()
thingsToKeep = ["track_id","album_id",'artist_id','track_genres']
df3 = df3[thingsToKeep]

genreID = []
df3 = []
#hardcoded way to get the genre ID out of the json string
for i in range(len(df3)):
    try:
        genreID.append(df3["track_genres"][i].split(":")[1].split(",")[0].strip().replace("'",""))
    except:
        genreID.append("NA")

df3["genre_id"] = pd.Series(genreID,index = df3.index)
thingsToKeep = ["track_id","album_id",'artist_id','genre_id']
df3.to_csv("track_key.csv",index = False)

df4  = pd.read_csv("raw_albums.csv")


thingsToKeep = ["album_id","album_date_released","album_tracks","album_type"]
df4 = df4[thingsToKeep]
df4.to_csv("album_key.csv",index= False)


df4 = pd.read_csv("album_key.csv")

tmp = df4["album_date_released"].tolist()
# convert dates to a civilized format

for i in range(len(tmp)):
    try:
        tmpDate = datetime.datetime.strptime(tmp[i],"%m/%d/%Y")
        tmp[i] = datetime.datetime.strftime(tmpDate,"%Y-%m-%d")
    except TypeError:
        tmp[i] = ""

# replace dates
tmp = pd.Series(tmp)
df4["album_date_released"] = tmp

#write back to csv
df4.to_csv("album_key.csv",index= False)
