#!/usr/bin/python

""" 
    Starter code for exploring the Enron dataset (emails + finances);
    loads up the dataset (pickled dict of dicts).

    The dataset has the form:
    enron_data["LASTNAME FIRSTNAME MIDDLEINITIAL"] = { features_dict }

    {features_dict} is a dictionary of features associated with that person.
    You should explore features_dict as part of the mini-project,
    but here's an example to get you started:

    enron_data["SKILLING JEFFREY K"]["bonus"] = 5600000
    
"""

import pickle
import re

enron_data = pickle.load(open("../final_project/final_project_dataset.pkl", "r"))

#print enron_data["SKILLING JEFFREY K"]["bonus"]
print "Number of persons: %s" %len(enron_data)
print "Number of Features: %s" %len(enron_data["SKILLING JEFFREY K"])
number_of_poi = 0
quantified_salary_number = 0
valid_email_address = 0
valid_total_payments = 0
valid_total_payments_poi = 0
for person, features in enron_data.iteritems():
	#print person
	if features["poi"] == 1:
		number_of_poi += 1
	if features["salary"] != "NaN":
		quantified_salary_number += 1
	if features["email_address"] != "NaN":
		valid_email_address += 1
	if features["total_payments"] == "NaN":
		valid_total_payments += 1
	if features["total_payments"] == "NaN" and features["poi"] == 1:
		valid_total_payments_poi += 1
print valid_total_payments
print valid_total_payments_poi
#print quantified_salary_number
#print valid_email_address

print "Number of poi: %s" %number_of_poi
#print enron_data["LAY KENNETH L"]["total_payments"]
#print enron_data["SKILLING JEFFREY K"]["total_payments"]
#print enron_data["FASTOW ANDREW S"]["total_payments"]

#print enron_data["SKILLING JEFFREY K"]["poi"]
