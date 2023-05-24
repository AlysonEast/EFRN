from sklearn.decomposition import IncrementalPCA
import csv
import sys
import numpy as np
import pandas as pd
from progress.bar import Bar
import pickle as pk

datafilename = "../obs.ascii.pca_phase1"
ncols=21
nrows=11306599

chunksize=100000

nchunks=int(nrows/chunksize)


cdata = pd.read_csv(datafilename, delimiter=" ", header=None, usecols=range(1,ncols+1), chunksize=chunksize)
sklearn_pca = IncrementalPCA(n_components=ncols)

bar = Bar('Incremental PCA Fit', max=nchunks+1)

# fit incremental PCA
done=0
for chunk in pd.read_csv(datafilename, delimiter=" ", header=None, usecols=range(1,ncols+1), chunksize=chunksize):
	sklearn_pca.partial_fit(chunk)
	done = done + chunksize
	if nrows-done < chunksize:
		chunksize = nrows-done
	print("\nDone %d [%d] of %d [%f]  "%(done, chunksize, nrows, (done*100.0/nrows)))
	bar.next()
bar.finish()
#
pk.dump(sklearn_pca, open("pca.pkl", "wb"))
print(sklearn_pca.explained_variance_ratio_)
np.savetxt("explained_variance_ratio.northamerica_forcasts_pc", sklearn_pca.explained_variance_ratio_, delimiter=" ")
np.savetxt("components.northamerica_forcasts_pc", sklearn_pca.components_, delimiter=" ")

chunksize=100000
# reload pickle file and keep going 
sklearn_pca_reload = pk.load(open("pca.pkl", "rb"))
print(sklearn_pca_reload.explained_variance_ratio_)
print(sklearn_pca_reload.components_)
#
bar = Bar('Incremental PCA Transform', max=nchunks)
pcafilename="pca.northamerica_forcasts_pc"
pcafile = open(pcafilename, "ba")
done=0
# apply transform to each chunk
for chunk in pd.read_csv(datafilename, delimiter=" ", header=None, usecols=range(1,ncols+1), chunksize=chunksize):
	transformed_chunk = sklearn_pca_reload.transform(chunk)
	np.savetxt(pcafile, transformed_chunk)
	done = done + chunksize
	if nrows-done < chunksize:
		chunksize = nrows-done
	print("\nDone %d [%d] of %d [%f]  "%(done, chunksize, nrows, (done*100.0/nrows)))
	bar.next()
bar.finish()


