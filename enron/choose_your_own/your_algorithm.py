#!/usr/bin/python

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns


from prep_terrain_data import makeTerrainData
from class_vis import prettyPicture

from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


features_train, labels_train, features_test, labels_test = makeTerrainData()


### the training data (features_train, labels_train) have both "fast" and "slow"
### points mixed together--separate them so we can give them different colors
### in the scatterplot and identify them visually
grade_fast = [features_train[ii][0] for ii in range(0, len(features_train)) if labels_train[ii]==0]
bumpy_fast = [features_train[ii][1] for ii in range(0, len(features_train)) if labels_train[ii]==0]
grade_slow = [features_train[ii][0] for ii in range(0, len(features_train)) if labels_train[ii]==1]
bumpy_slow = [features_train[ii][1] for ii in range(0, len(features_train)) if labels_train[ii]==1]


#### initial visualization
plt.xlim(0.0, 1.0)
plt.ylim(0.0, 1.0)
plt.scatter(bumpy_fast, grade_fast, color = "b", label="fast")
plt.scatter(grade_slow, bumpy_slow, color = "r", label="slow")
plt.legend()
plt.xlabel("bumpiness")
plt.ylabel("grade")
plt.show()
################################################################################


### your code here!  name your classifier object clf if you want the 
### visualization code (prettyPicture) to show you the decision boundary

accuracy_curve_k_neigh = []
for k in np.arange(5,50):
	clf = KNeighborsClassifier(n_neighbors = k)
	clf = clf.fit(features_train, labels_train)
	pred = clf.predict(features_test)
	acc = accuracy_score(labels_test, pred)
	accuracy_curve_k_neigh.append(acc)
	print "The accuracy of %s nearest neighbour is: %s" %(k, acc)

accuracy_curve_adaboost = []
#for k in np.arange(5,50):
clf = AdaBoostClassifier()
clf = clf.fit(features_train, labels_train)
pred = clf.predict(features_test)
acc = accuracy_score(labels_test, pred)
print "The accuracy of Adaboost: %s" %(acc)

accuracy_curve_random_forest = []
for k in np.arange(5,50):
	clf = RandomForestClassifier()
	clf = clf.fit(features_train, labels_train)
	pred = clf.predict(features_test)
	acc = accuracy_score(labels_test, pred)
	accuracy_curve_random_forest.append(acc)
	print "The accuracy of Random Forest, n_estimator =  %s is: %s" %(k, acc)

x = np.arange(5,50)
fig = plt.figure(figsize=(10,8))
ax = fig.add_subplot(121)
curve1 = ax.plot(x, accuracy_curve_k_neigh, 'b', label = 'K Nearest Neighbors Accuracy')
lns = curve1
labs = [l.get_label() for l in lns]
ax.legend(lns, labs)
ax = fig.add_subplot(122)
curve2 = ax.plot(x, accuracy_curve_random_forest, 'r', label = 'Random Forest Accuracy')
lns = curve2
labs = [l.get_label() for l in lns]
ax.legend(lns, labs)
plt.show()






try:
    prettyPicture(clf, features_test, labels_test)
except NameError:
    pass
