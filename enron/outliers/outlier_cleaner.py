#!/usr/bin/python


def outlierCleaner(predictions, ages, net_worths):
    """
        Clean away the 10% of points that have the largest
        residual errors (difference between the prediction
        and the actual net worth).

        Return a list of tuples named cleaned_data where 
        each tuple is of the form (age, net_worth, error).
    """
    import numpy as np
    cleaned_data = []
    error = abs(predictions - net_worths)
    q = np.percentile(error, 90)
    i = 0
    for i in np.arange(len(predictions)):
        if error[i] > q:
            np.delete(predictions, i)
            np.delete(ages, i)
            np.delete(net_worths, i)
        else:
            tup = (ages[i], net_worths[i], error[i])
            cleaned_data.append(tup)

    return cleaned_data

