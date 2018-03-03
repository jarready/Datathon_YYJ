#!/usr/local/bin/python3
from visualization import *



def main():
    print("this is main")
    filename_category = "../data/Upserve/BrownDatathon-StorebyCategory.csv"
    filename_overall = "../data/Upserve/BrownDatathon-StoreOverall.csv"
    #data_read_all("../data/Upserve/BrownDatathon-StoreOverall.csv")
    #plot_price_trend(filename_category,"Northeast")
    #plot_price_trend(filename_category,"West")
    #plot_price_trend(filename_category,"Midwest")
    plot_price_trend(filename_category,"South")
if __name__ == '__main__':
    main()
