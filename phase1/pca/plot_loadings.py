import pandas as pd 
#import plotly
import seaborn as sns
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
#import urllib.request 
from pyensae.graphhelper import Corrplot
#import xarray as xr
#import rioxarray as rio
#import cartopy.crs as ccrs
#from os import path

font = {'family' : 'normal',
        'weight' : 'bold',
        'size'   : 18}

matplotlib.rc('font', **font)

# read data
eigenvectors=pd.read_csv('/home/1te/efrn/polygons/pca/components.northamerica_forcasts_pc', header=None, delimiter=" ")

# corrplot 
mfig, ax = plt.subplots(1,1, figsize=(25,10), dpi=300, facecolor='white')
ax.set_aspect(1)

c = Corrplot(eigenvectors)
ytick_labels=["PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10", "PC11", "PC12", "PC13", "PC14", "PC15", "PC16", "PC17"]
xtick_labels=["Ann Temp", "Diurnal Range", "Isothermality", "Temp. Seas.", "Temp Warm Qtr", "Temp Cold Qtr", "Ann. Precip.", "Precip. Season.", "Precip Dry Qtr", "Precip Wet Qtr", "Precip Warm Qtr", "Precip Cold Qtr", "AWC", "Bulk Den.", "Nitrogen", "Ph", "SOC"]
print(len(ytick_labels))
print(len(xtick_labels))
ax = plt.subplot(1, 1, 1, aspect='equal', facecolor='white')
c = Corrplot(eigenvectors)
cplot = c.plot(order_method=None, ax=ax, method='circle')
ax.set_xticklabels(ytick_labels)
ax.set_yticklabels(xtick_labels)
mfig.savefig("eigen_vectors_corrplot_aly.png", dpi=300)
