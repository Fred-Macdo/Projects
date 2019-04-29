from scipy.cluster.hierarchy import dendrogram, linkage
from Cluster import Cluster
import numpy as np
import pandas as pd



infile = input('Enter filename or filepath if input is in different directory: ') # type in ma_pickle
DF = pd.read_pickle(infile)
print(DF.head(5))  # make sure file loaded properly

# Function splits the dataframe into a list of dataframes by fdid, our clustering variable


def split_df(df):
    fdid_list = []
    for region, df_fdid in df.groupby('fdid'):
        fdid_list.append(df_fdid)
    return fdid_list


def prep(df):
    out_list = []
    for index, row in df.iterrows():
        out_list.append([row.lat, row.lon])
    array = np.array(out_list)
    return array


def hierarchicalCluster(array):
    if len(array) < 12:
        pass
    else:
        Z = linkage(array, 'single')
        return Z


def pruning(df):
    print("Df length is " + str(len(df)))
    #if len(df) >= 12:
    prepped = prep(df)
    Z = hierarchicalCluster(prepped)
    den = dendrogram(Z, truncate_mode='lastp', p=5)
    #print(den)
    ivl = den['ivl']
    print(ivl)
    for i, x in enumerate(ivl):
        try:
            ivl[i] = int(x)
        except ValueError:
            pass
    droplist = [x for x in ivl if isinstance(x, int)]
    #print(droplist)
    pruned = df.drop(df.index[droplist])
    print("The output df length is: " + str(len(pruned)))
    return [pruned, droplist, ivl]


in_list = split_df(DF)
del DF


def main():
    out_list = []
    for i in in_list:
        clus = Cluster(i)
        fdid = clus.df.iloc[0,2]

        clus.set_fdid(fdid)
        print(clus.get_fdid())

        clus.set_n = len(clus.df)
        if clus.get_fdid() == 25035:  # skipping boston because it maxed out my memory and script broke
            pass
        else:
            if clus.count_incidents() >= 12:
                prunedOut = pruning(clus.df)
                out_list.append(prunedOut[0])
                del i
            else:
                out_list.append(clus.df)

    outDF = pd.concat(out_list)
    outDF.to_csv("PrunedData.csv", sep='\t', index=False)


main()

	
