import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
import csv
from datetime import datetime

def data_read_all(filename):
    data = []
    with open(filename,"r") as csvfile:
        fileread = csv.reader(csvfile,delimiter =",")
        first_row = 1
        for row in fileread:
            if first_row:
                data_names = row
                first_row = 0
            else:
                data.append(row)
    data = np.array(data)
    return data

    '''
    store_id_unique,store_id_unique_index = np.unique(np.sort(data[:,0].astype(np.float)),return_index=True)
    count = Counter(data[store_id_unique_index,1])
    print(count)
    total_sales_NE = data[data[:,1]=="Northeast"][:,4]
    '''

def time2int(date,shift_bin):
    #convert the string time and shift to a float
    '''
    datetime = np.int(date[0:4])*10000+np.int(date[5:7])*100+np.int(date[8:10])
    datetime = np.int(date[5:7])*31+np.int(date[8:10])
    if (shift_bin=="Breakfast"):
        datetime = datetime+0.2
    elif (shift_bin=="Lunch"):
        datetime = datetime+0.4
    elif (shift_bin=="Dinner"):
        datetime = datetime+0.6
    elif (shift_bin=="Late Night"):
        datetime = datetime+0.8
    '''
    datetime = np.int(date[5:7])
    return datetime

def price_time(filename,item,region):
    data = data_read_all(filename)
    #calculate the average price of a item in a region over time
    data_select = data[data[:,1] == region]
    data_select = data_select[data_select[:,4]==item]
    data_select_time = []
    for i in range(len(data_select)):
        data_select_time.append(time2int(data_select[i,2],data_select[i,3]))
    time_unique_list = np.sort(np.unique(data_select_time))

    # calculate the average and sd value at the specific time
    price_average_list = []
    price_sd_list = []
    for j in range(len(time_unique_list)):
        index = np.where(data_select_time == time_unique_list[j])[0]
        price_all_store = []
        for k in range(len(index)):
            total_sales = np.float(data_select[index[k],5])
            total_item_sold = np.float(data_select[index[k],6])
            price_all_store.append(total_sales/total_item_sold)
        price_average_list.append(np.average(price_all_store))
        price_sd_list.append(np.std(price_all_store)/np.sqrt(len(price_all_store)))
    return time_unique_list,price_average_list,price_sd_list

def plot_price_trend(filename,region):

    plt.figure()
    item_list = ["food","beer","wine","cocktail","liquor","undifferentiated alcohol"]
    for item in item_list:
        time_unique_list,price_average_list,price_sd_list = price_time(filename,item,region)
        #plt.plot(time_unique_list,price_average_list,"+",label=item)
        plt.errorbar(time_unique_list,price_average_list,yerr=price_sd_list,marker="x",linestyle="None",label=item)
    plt.legend()
    plt.savefig(filename[:-4]+"_"+region+".png",dpi=300)
    plt.close()
