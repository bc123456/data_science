#####################################
#   Common Imports
#####################################

import os
import numpy as np
import pandas as pd
from astropy.io import fits
import math
from scipy import interpolate
from __future__ import division
from multiprocessing import Pool
import time
import functools
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style("white")
from scipy import interpolate
from scipy.optimize import curve_fit

from astropy.cosmology import FlatLambdaCDM
cosmo = FlatLambdaCDM(H0=70., Om0=0.3)
from astropy import constants as const


#   matplotlib style control

import matplotlib.pyplot as plt
font = {'family' : 'normal',
        'weight' : 'bold',
        'size'   : 40}
plt.rc('xtick', labelsize=16)
plt.rc('ytick', labelsize=16)

%matplotlib inline

#####################################
###      String Operation: 
#####################################
new_string = ' '.join(['A', 'B', 'C'])   # join the strings with spacebar as delimeter
new_string = string.split(str="", num=string.count(str))  #split the string with str as the delimeter
new_string = string.replace(old, new)

word.isupper()   #return true or false depends on whether it is an uppercase word or not.

'This is the target string'[::-1]    # return the reverse of this string

"Hello" > "Hella"  #returns True

import string
table = string.maketrans('ABC','123')
f = 'A+B==C'
f.translate(table)

import re
word1 = " ".join(re.findall("[a-zA-Z]+", s)) # find out all letters in a string s



#####################################
###      List Operation
#####################################
ls = ['A'] + 88*['B']     #becomes ['A', 'B', 'B', 'B', 'B',....]

#####################################
###      Tuple Operation
#####################################

(7,6,3) > (7,5,6)  # evaluates True

from collections import namedtuple   # a tuple with nametags

state = namedtuple('state', 'p me you pending')




#####################################
# Fast Array Operation
#####################################
# Use xrange whenever possible.

arr.item(i,j)  # find an item in an array
arr.itemset((i,j), 1) # set 1 to the value at the position of i,j



#####################################
# Array Operation
#####################################

A = np.array([1,2,3,4,5])   # Create an Array
A = np.zeros((2,3)) # Create zeros array
A = np.full((3,5), 7) # Create an array of dimension 3,5   and filled with value 7

A.T # transpose
np.linalg.inv(A)  # inverse

array.shape   # The dimension of an array

m = A.max()   #Get the max value of an array: 

i = A.argmax()   # return the index of the max value of an array.

np.vstack((A,B))   # concatenate vertically
np.hstack((A,B))   # concatenate horizontally

v = v[np.newaxis].T      # change row vector to column vector

#####################################
# Input
#####################################
from sys import argv

script, first, second, third = argv

python ex13.py apple orange grapefruit # type this in terminal

first == apple
second == orange
third == grapefruit


#####################################
# Read a text file
#####################################
from numpy import loadtxt
catalog = loadtxt(catalog_dir, comments="#")    ### read a text file to array



#####################################
# Write a text file
#####################################

new_file = open('/../../', "w+")    # many flags, check online documentation
new_file.write('fkdjkaj')

np.savetxt(new_file, A, fmt='%.5f', delimiter=',')   # an example to write an array to a text file


new_file.close()                    # always close the file after use 



#####################################
# fits manupulation
#####################################
###   Open the fits file
hdu_list = fits.open('image_file_directory') #open the fits file
hdu_list.info() # print the information of the fits file
image_data = hdu_list[0].data  # The data is an array like item.
print(image_data.shape) # print the dimension of the file
hdu_list.close() #close the fits file to release memory


###   View the fits file
plt.imshow(image_data, cmap='gray')
plt.colorbar()
# use logrithm color scale:
from matplotlib.colors import LogNorm
plt.imshow(image_data, cmap='gray', norm=LogNorm())
cbar.ax.set_yticklabels(['5,000','10,000','20,000'])   #set the label of the color axis

###   Write a fits image
outfile = 'stacked_M13_blue.fits'

hdu = fits.PrimaryHDU(image)
hdu.writeto(outfile, clobber=True)

### Quick way to show a fits file

fig = plt.imshow(mass_diff, cmap='gray')
plt.colorbar()
plt.show()


#####################################
# Dictionary
#####################################

dic["person"]   # refer to the value by the key

for key, values in dic.iteritems():   # iterate through a dictionary
    ...
    ,,,

#####################################
# Pandas
#####################################

## DataFrame

(row, column) = df.shape

# Access Data in DataFrame
df['col']                  # access a whole column of data by name
df[0]                      # access a whole column of data by position
df.loc['1.1']              # access a whole row of data by index
df.iloc[0]                 # access a whole row of data by position
df = df['A'].astype(str)   # change the data type of a whole column
df[df.column_name > 10]    # access the dataframe with conditions on the column

### for iterations
for index, item in df.iterrows():
    ...


# Groupby functions

df.groupby('col')          # group the data according to the values in 'col'
df.groupby('col')['A', 'B', 'C']     # extract only column 'A', 'B', 'C' out
df.groupby('col').get_group('1')  # get the grouped data with 'col' value '1'

# Common operations
df = df.drop('column_name', axis=1)   # delete columns in the dataframe
df.apply(numpy.mean).  # take the mean of individual columns of data



# Iterate through DataFrame


for idx in df.index:       # iterate through rows
	df.ix[idx]['a']
	...

for column in df:          # iterate through columns
	...

#####################################	
# Basic plotting routine
#####################################

fig = plt.figure(figsize=(10,8))
plt.tight_layout(pad=2, w_pad=2, h_pad=2)  # a small space buffer at the margin
ax = fig.add_subplot(111)
curve1 = ax.plot(x, y1, 'b:', label = 'The first curve')        #plot a blue dotted line with legend label
curve2 = ax.plot(x, y2, 'b--', label = 'The first curve')       #plot a blue dashed line with legend label
ax2 = ax.twinx()
curve3 = ax2.plot(x, y3, 'r-', label = r'$g_k$')    #plot a curve with different y-axis
lns = curve1 + curve2 + curve3
labs = [l.get_label() for l in lns]
ax.legend(lns, labs, loc=0)
ax.grid()       # add grid if necessary
ax.set_xlabel(r'The label in x', fontsize = 18)
ax.set_ylabel(r'The label of first y axis', color = 'b')
ax2.set_ylabel(r'The label of second y axis', color='r')
ax.set_ylim(-20,100)
ax2.set_ylim(0, 35)
for tl in ax.get_yticklabels():
    tl.set_color('b')
for tl in ax2.get_yticklabels():
    tl.set_color('r')
plt.savefig('/Users/chanmingyan/Desktop/python_figures/magnification_z_%s' %source, dpi = 500)    #optional save figure command
plt.show()

# plot a vertical line
ax.axvline(np.mean(z2), color='r', linestyle='--')

# plot a vertically span block
ax.axvspan(xmin, xmax, alpha=0.5)


# plot an image

imgplot = plt.imshow(img)

#####################################
# multiprocessing
#####################################

def easy_parallize(f, sequence):
    # I didn't see gains with .dummy; you might
    from multiprocessing import Pool
    pool = Pool(processes=8)
    #from multiprocessing.dummy import Pool


    # f is given sequence. guaranteed to be in order
    result = pool.map(f, sequence)
    cleaned = [x for x in result if not x is None]
    cleaned = np.asarray(cleaned)
    # not optimal but safe
    pool.close()
    pool.join()
    return cleaned

#####################################
# Calculate the running time of program
#####################################

#simple one
t0= time.clock()

//// some codes you want to measure the running time

print 'time', time.clock() - t0

# more statistical one

import time

def timedcall(fn, *args):
    "Call function with args; return the time in seconds and result."
    t0 = time.clock()
    result = fn(*args)
    t1 = time.clock()
    return t1-t0, result

def average(numbers):
    "Return the average (arithmetic mean) of a sequence of numbers."
    return sum(numbers) / float(len(numbers)) 

def timedcalls(n, fn, *args):
    """Call fn(*args) repeatedly: n times if n is an int, or up to
    n seconds if n is a float; return the min, avg, and max time"""
    if isinstance(n, int):
        times = [timedcall(fn, *args)[0] for _ in range(n)]
    else:
        times = []
        while sum(times) < n:
            times.append(timedcall(fn, *args)[0])
    return min(times), average(times), max(times)


# To evaluate the total run time of a program

$ python -m  cProfile crypt.py     # run this command in the terminal

# Or do this
import cProfile
cProfile.run('test()')


#####################################
# sklearn
#####################################

# Gaussian Naive Bayes
from sklearn.naive_bayes import GaussianNB
X = np.array([[-1, -1], [-2, -1], [-3, -2], [1, 1], [2, 1], [3, 2]])
Y = np.array([1, 1, 1, 2, 2, 2])
clf = GaussianNB()
clf.fit(X, Y)
print(clf.predict([[-0.8, -1]]))

# Check the accuracy of a machine learning algorithm
from sklearn.metrics import accuracy_score
y_pred = [0, 2, 1, 3]
y_true = [0, 1, 2, 3]
accuracy_score(y_true, y_pred)

#####################################
# Pickle
#####################################
import pickle

a = ['test value','test value 2','test value 3']

file_Name = "testfile"
# open the file for writing
fileObject = open(file_Name,'wb') 

# this writes the object a to the
# file named 'testfile'
pickle.dump(a,fileObject)   

# here we close the fileObject
fileObject.close()
# we open the file for reading
fileObject = open(file_Name,'r')  
# load the object from the file into var b
b = pickle.load(fileObject)  
b
['test value','test value 2','test value 3']
a==b
True

#####################################
# Check the validity of a program
#####################################

assert func(args) == answer    # if the result is not true, the program will print out an error message.


#####################################
# Run Shell Scripts
#####################################

import subprocess

subprocess.call(['ls','-l'], shell=False)

#####################################
# itertools
#####################################
import itertools

## some very handy functions

print list(itertools.combination([1,2,3,4],2))
>>> [(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)]

print list(itertools.product(['1','2','3','4'],['A','B','C','D']))
>>> [('1', 'A'),('1', 'B'),('1', 'C'),('1', 'D'),('2', 'A'),('2', 'B'),('2', 'C'),('2', 'D'),('3', 'A'),('3', 'B'),('3', 'C'),('3', 'D'),('4', 'A'),('4', 'B'),('4', 'C'),('4', 'D')]

#####################################
# generator expression
#####################################

def sq(x):
    print 'sq called', x
    return x ** 2

g = (sq(x) for x in range(10) if x%2 == 0)
>>> next(g)
sq called 0
0
>>> next(g)
sq called 2
4
>>> next(g)
sq called 4
16

#####################################
# testing
#####################################
import doctest

class Test:
    """
    >>> function(x,y)
    [result1, result2, ...]

    >>> function (a,b)
    [result3, result4,...]
    """
print(doctest.testmod())


#####################################
# Other common knowledge
#####################################

eval(code)   # evaluate any string as if it is a code
ord(<one-letter string>)  ---> number
chr(<Number>)   -----> one letter string

if 7:
    print "yes"    # A number can be used as a true value

if Englishman is red:  # check whether the two things are exactly the same object.
    ...

'''any number with a leading zero is interpreted as octo digits'''
ie: 012 == 10

any(iterable) #Return True if any element of the iterable is true. If the iterable is empty, return False.

dis.dis(function)  # Show the overall number of function calls.

# The finally statement is also executed in the loop
try:
    ...
finally:
    ...


#####################################
# Debug
#####################################

# for ASCII encoding issues, add this to the beginning of the python file
# -*- coding: utf-8 -*-

#get documentation of a function:
# type these in terminal
pydoc raw_input
pydoc np.sqrt

#####################################
# jupyter notebook
#####################################

# display beautiful dataframes
import qgrid
qgrid_widget = qgrid.show_grid(ir_df, show_toolbar=True, grid_options={'forceFitColumns': False})
qgrid_widget

# hide codes
from IPython.display import HTML
HTML('''<script>code_show=true; function code_toggle() {if (code_show){$('div.input').hide();} else {$('div.input').show();}code_show = !code_show}$( document ).ready(code_toggle);</script>The raw code for this IPython notebook is by default hidden for easier reading. toggle on/off the raw code, click <a href='javascript:code_toggle()'>here</a>.''')