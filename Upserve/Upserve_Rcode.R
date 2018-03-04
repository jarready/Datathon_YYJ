# install packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(MASS)
library(reshape)
library(readr)

# Import dataset
setwd("/Users/yangxiaofei/Desktop/datathon/Upserve")

overall <- read.csv("Brown Datathon - Store Overall.csv")

category <- read.csv("Brown Datathon - Store by Category.csv")

# Change to class "Date"
overall$date <- as.Date(overall$date)


overall <- overall %>% mutate(Month=as.numeric(format(overall$date,"%m")), # Create new column month (decimal number)
                              price = total_sales/total_items_sold) # Calculate average price


# Monthly Average Sales Trend by Shift_bin

overall %>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d"))%>%
  dplyr::group_by(Month2, shift_bin, region)%>%
  dplyr::summarise(avg_total_sales = mean(total_sales))%>% # Calculate monthly sales
  ggplot(aes(x = Month2, y = avg_total_sales, colour = shift_bin)) + # Show sales trend of different shift_bin
  geom_line()+
  facet_wrap(~region,scales="free_y")+
  theme_bw()+
  labs(title = "Monthly Average Sales Trend by Shift_bin",
       x="Time",
       y="Monthly Average Sales")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_date(date_labels = "%b")

ggsave("MonthlyAverageSales.png")

# Monthly Average Total Items Trend

overall %>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d"))%>%
  dplyr::group_by(Month2, shift_bin, region)%>%
  dplyr::summarise(avg_total_items = mean(total_items_sold))%>%
  ggplot(aes(x = Month2, y = avg_total_items, colour = shift_bin)) +
  geom_line()+
  facet_wrap(~region,scales="free_y")+
  theme_bw()+
  labs(title = "Monthly Average Total Items Trend",
       x="Time",
       y="Monthly Average Items")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_date(date_labels = "%b")

ggsave("MonthlyAverageItems.png")

# heatmap_AvgPrice
catehm <- category
catehm$region_time <- paste(category$region, category$shift_bin)

c<-catehm%>%
  filter(total_sales!=0)%>% 
  dplyr::group_by(region_time, item_category)%>%
  dplyr::summarise(avg_price = mean(total_sales/total_items_sold))

avg_price_hm<-ggplot(c, aes(item_category, region_time)) + 
  theme_bw()+
  geom_tile(aes(fill = avg_price),colour = "white") + 
  scale_fill_gradient(low = "white",high = "steelblue")

avg_price_hm

ggsave("heatmap_AvgPrice.png")

# heatmap_AvgPrice_adjust
expensive_liquor <- catehm%>%
  filter(region_time == "South Breakfast" & item_category == "liquor" & total_sales!=0)%>%
  mutate(avg_price = total_sales/total_items_sold)

delete_outlier <- expensive_liquor$avg_price[!expensive_liquor$avg_price %in% boxplot.stats(expensive_liquor$avg_price)$out]

outlier_num <- dim(expensive_liquor)[1] - length(delete_outlier)

c_adjust <- c

c_adjust$avg_price[52] <- mean(delete_outlier)

ggplot(c_adjust, aes(item_category, region_time)) + 
  theme_bw()+
  geom_tile(aes(fill = avg_price),colour = "white") + 
  scale_fill_gradient(low = "white",high = "steelblue")

ggsave("heatmap_AvgPrice_adjust.png")

# Plot heatmap showing average items
avg_items_hm<-catehm%>%
  filter(total_sales!=0)%>% # delete free item
  dplyr::group_by(region_time, item_category)%>%
  dplyr::summarise(avg_items = mean(total_items_sold))%>%
  ggplot(aes(item_category, region_time)) + 
  theme_bw()+
  geom_tile(aes(fill = avg_items),colour = "white") + 
  scale_fill_gradient(low = "white",high = "steelblue")

avg_items_hm

ggsave("heatmap_AvgItem.png")



category$date <- as.Date(category$date)

clean_data2 <- category%>%
  mutate(Month=as.numeric(format(category$date,"%m")))


category$Month_Yr <- format(as.Date(category$date), "%Y-%m")

cate_trend <- clean_data2 %>% 
  dplyr::group_by(Month,region,item_category)%>%
  dplyr::summarise(avg_sale = mean(total_sales))

# Monthly Average Sales Trend by Category
clean_data2%>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d")) %>%
  dplyr::group_by(Month2,region,item_category)%>%
  dplyr::summarise(avg_sale = mean(total_sales))%>%
  ggplot(aes(x = Month2, y = avg_sale, colour = item_category))+
  geom_line()+
  facet_wrap(~region,scales="free_y")+
  theme_bw()+
  labs(title = "Monthly Average Sales Trend by Category",
       x="Time",
       y="Monthly Average Sales")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_date(date_labels = "%b")

ggsave("Monthly_Average_Sales_Category.png")

# Monthly Average Items Trend by Category
clean_data2%>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d")) %>%
  dplyr::group_by(Month2,region,item_category)%>%
  dplyr::summarise(avg_items = mean(total_items_sold))%>%
  ggplot(aes(x = Month2, y = avg_items, colour = item_category))+
  geom_line()+
  facet_wrap(~region,scales="free_y")+
  theme_bw()+
  labs(title = "Monthly Average Items Trend by Category",
       x="Time",
       y="Monthly Average Items")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_date(date_labels = "%b")

ggsave("Monthly_Average_Items_Category.png")

# Analyze free item

free <- category%>%
  filter(total_sales==0)%>%
  dplyr::group_by(region,shift_bin,item_category)%>%
  dplyr::summarise(free_num = sum(total_items_sold))

free$region_time <- paste(free$region, free$shift_bin)

ggplot(free, aes(item_category, region_time)) + 
  theme_bw()+
  geom_tile(aes(fill = free_num),colour = "white") + 
  scale_fill_gradient(low = "white",high = "steelblue")

ggsave("heatmap_FreeItem.png")

west <- clean_data2%>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d"))%>%
  filter(shift_bin=="Late Night"|shift_bin=="Dinner")%>%
  filter(region=="West"&total_sales==0&item_category=="food")%>%
  dplyr::group_by(Month2,shift_bin)%>%
  dplyr::summarise(avg_free_food=mean(total_items_sold))

west_sale <- clean_data2%>%
  mutate(Month2 = as.Date(paste0("2017-", Month,"-01"),"%Y-%m-%d"))%>%
  filter(shift_bin=="Late Night"|shift_bin=="Dinner")%>%
  filter(region=="West"&total_sales==0&item_category=="food"&total_items_sold >= 10)

west_sale_store <- unique(west_sale$store_id)


west%>%
  ggplot(aes(x = Month2, y = avg_free_food, colour = shift_bin))+
  geom_line()+
  theme_bw()+
  labs(title = "West Free Food",
       x="Time",
       y="Average Free Items")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_date(date_labels = "%b")

ggsave("WestFree.png")

# Restaurant Clustering
# Create Price_Level factor vector
Price_Level <- c("$9.24", "$$21.70","$$$52.17","$$$$103.24")

# Create a vector holding the number of restaurant in 
# Northeast - the number is calculated using the label from k-means clustering
Northeast <- c(67,22,11,0)

# Create a vector holding the number of restaurant in Midwest
Midwest <- c(81,17,0,2)

# Create a vector holding the number of restaurant in West
West<-c(85,13,2,0)

# Create a vector holding the number of restaurant in South
South<-c(74,20,2,4)

# Combine vectors and create a dataframe
R_level <- as.data.frame(cbind(Price_Level,Northeast, Midwest, West, South))

# Reshape dataframe
R_level1<-melt(R_level, id.vars = 1, value.name="Restaurant_Num", variable_name = "Region")

# Change factor to numeric
R_level1$value<-as.numeric(levels(R_level1$value))[R_level1$value]

# Change column name
colnames(R_level1)[3] <- "Number_of_Restaurant"

# Plot heatmap showing number of restaurants of different price levels in different regions
ggplot(R_level1, aes(Price_Level, Region)) + 
  theme_bw()+
  geom_tile(aes(fill = Number_of_Restaurant),colour = "white") + 
  scale_fill_gradient(low = "white",high = "steelblue")

ggsave("heatmap_PriceLevel.png")
