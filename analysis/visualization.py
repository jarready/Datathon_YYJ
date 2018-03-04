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

def data_time(filename,item,region):
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
    sold_num_average_list = []
    sold_num_sd_list = []
    for j in range(len(time_unique_list)):
        index = np.where(data_select_time == time_unique_list[j])[0]
        price_all_store = []
        sold_num_all_store = []
        for k in range(len(index)):
            total_sales = np.float(data_select[index[k],5])
            total_item_sold = np.float(data_select[index[k],6])
            price_all_store.append(total_sales/total_item_sold)
            sold_num_all_store.append(total_item_sold)
        price_average_list.append(np.average(price_all_store))
        price_sd_list.append(np.std(price_all_store)/np.sqrt(len(price_all_store)))
        sold_num_average_list.append(np.average(sold_num_all_store))
        sold_num_sd_list.append(np.std(sold_num_all_store)/np.sqrt(len(sold_num_all_store)))
    return time_unique_list,price_average_list,price_sd_list,sold_num_average_list,sold_num_sd_list

def plot_price_trend(filename,region):

    item_list = ["food","beer","wine","cocktail","liquor","undiff alcohol"]
    time_unique_list,price_average_list,price_sd_list,sold_num_average_list,sold_num_sd_list = [],[],[],[],[]
    for item in item_list:
        time_unique_list_buff,price_average_list_buff,price_sd_list_buff,sold_num_average_list_buff,sold_num_sd_list_buff= data_time(filename,item,region)
        time_unique_list.append(time_unique_list_buff)
        price_average_list.append(price_average_list_buff)
        price_sd_list.append(price_sd_list_buff)
        sold_num_average_list.append(sold_num_average_list_buff)
        sold_num_sd_list.append(sold_num_sd_list_buff)
        #plt.plot(time_unique_list,price_average_list,"+",label=item)
    plt.figure()
    for i in range(len(time_unique_list)):
        plt.errorbar(time_unique_list[i],price_average_list[i],yerr=price_sd_list[i],marker="x",linestyle="None",label=item_list[i])
    plt.ylim(0,25)
    plt.xlabel("Month")
    plt.ylabel("price")
    plt.legend(loc="upper left",ncol=3)
    plt.title(region)
    plt.savefig(filename[:-4]+"_"+region+"_price.png",dpi=300)
    plt.close()

    plt.figure()
    for i in range(len(time_unique_list)):
        plt.errorbar(time_unique_list[i],sold_num_average_list[i],yerr=sold_num_sd_list[i],marker="x",linestyle="None",label=item_list[i])
    plt.ylim(0,30)
    plt.xlabel("Month")
    plt.ylabel("sold number")
    plt.legend(loc="upper left",ncol=3)
    plt.title(region)
    plt.savefig(filename[:-4]+"_"+region+"_sold_num.png",dpi=300)
    plt.close()

def consume_time(filename,shift,region):
    data = data_read_all(filename)
    #calculate the average price of a item in a region over time
    data_select = data[data[:,1] == region]
    data_select = data_select[data_select[:,3]==shift]
    data_select_time = []
    for i in range(len(data_select)):
        data_select_time.append(time2int(data_select[i,2],data_select[i,3]))
    time_unique_list = np.sort(np.unique(data_select_time))

    # calculate the average and sd value at the specific time
    consume_average_list = []
    consume_sd_list = []
    for j in range(len(time_unique_list)):
        index = np.where(data_select_time == time_unique_list[j])[0]
        consume_all_store = []
        for k in range(len(index)):
            total_sales = np.float(data_select[index[k],4])
            num_tickets = np.float(data_select[index[k],6])
            consume_all_store.append(total_sales/num_tickets)
        consume_average_list.append(np.average(consume_all_store))
        consume_sd_list.append(np.std(consume_all_store)/np.sqrt(len(consume_all_store)))
    return time_unique_list,consume_average_list,consume_sd_list
def plot_consumption_trend(filename,region):
    shift_list = ["Breakfast","Lunch","Dinner","Late Night"]
    plt.figure()
    for shift in shift_list:
        time_unique_list,consume_average_list,consume_sd_list = consume_time(filename,shift,region)
        plt.errorbar(time_unique_list,consume_average_list,yerr=consume_sd_list,marker="x",linestyle="None",label=shift)
    plt.xlabel("Month")
    plt.ylabel("Consumption per ticket")
    plt.legend(ncol=4)
    plt.title(region)
    plt.savefig(filename[:-4]+"_"+region+"_cpt.png",dpi=300)
    plt.close()

def plot_all_consumption_trend(filename,region):
    data = data_read_all(filename)
    #calculate the average price of a item in a region over time
    data_select = data[data[:,1] == region]
    shift_list = ["Breakfast","Lunch","Dinner","Late Night"]
    plt.figure()
    for shift in shift_list:
        data_select = data_select[data_select[:,3]==shift]
        time_select = np.array([np.int(x[5:7]) for x in data_select[:,2]])
        plt.plot(time_select,marker="x",linestyle="None",label=shift)
    plt.xlabel("Month")
    plt.ylabel("Consumption per ticket")
    plt.legend(ncol=4)
    plt.title(region)
    plt.savefig(filename[:-4]+"_"+region+"_cptall.png",dpi=300)
    plt.close()
