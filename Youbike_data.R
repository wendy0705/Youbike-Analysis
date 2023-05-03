getwd()
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
setwd("C:/Users/Administrator.DESKTOP-JG1NPFA/Desktop/課業/1102/R")

#載入EXCEL資料，分別為「只有借車在大安」、「只有還車在大安」及「借還車都在大安」
only_rent <- read_excel('第四組_資料_廖珮媗、江馥羽、嚴怡詠、江彤恩(4).xlsx','rent_daan')
only_return <- read_excel('第四組_資料_廖珮媗、江馥羽、嚴怡詠、江彤恩(5).xlsx','return_daan')
both <- read_excel('第四組_資料_廖珮媗、江馥羽、嚴怡詠、江彤恩(3).xlsx','both_daan')

#去除?及NA值、分別取得大安區各站的借車及還車數據、按照站名及時間依序排列
arr_rent <- rbind(only_rent,both)%>% arrange(rent_station, rent_time)
arr_rent$rent_station <- gsub("[?]", "???", arr_rent$rent_station)
arr_rent[is.na(arr_rent)] <- 0
arr_return <- rbind(only_return,both)%>% arrange(return_station, return_time)
arr_return$return_station <- gsub("[?]", "???", arr_return$return_station)
arr_return$holidays[is.na(arr_return$holidays)] <- 0

#將時間資料合併為2小時為一區間，並計算大安區各站各時段的借車及還車總數
rent <- arr_rent %>% select(rent_time, rent_station, holidays) %>% mutate(rent_time = as.POSIXct(rent_time), value = rep(1, nrow(arr_rent))) %>% group_by(rent_station,holidays, rent_time_2hr = floor_date(rent_time, "2 hour")) %>% summarize(rent_value = sum(value)) 
return <- arr_return %>% select(return_time, return_station, holidays) %>% mutate(return_time = as.POSIXct(return_time), value = rep(1, nrow(arr_return))) %>% group_by(return_station,holidays, return_time_2hr = floor_date(return_time, "2 hour")) %>% summarize(return_value = sum(value)) 

#為了將rent 和return的資料作成同張table，
#抓出rent和return資料的站名和時間，做出所有站名和時間的總表，
#並刪除重複值
rent_part <- rent %>% select(rent_station, rent_time_2hr,holidays)
colnames(rent_part) <- c("station", "time", "holidays")
rent_part
return_part <- return %>% select(return_station, return_time_2hr, holidays)
colnames(return_part) <- c("station", "time", "holidays")
return_part
full_test <- rbind(rent_part, return_part)
full_station_time <- full_test[!(duplicated(full_test[c("station","time")]) | duplicated(full_test[c("station","time")])), ]  %>% arrange(station,time)
#full_station_time 是rent 和return裡面出現的所有站名和時間的table

#利用總表join rent和return的資料
full_join_rent <- left_join(full_station_time, rent, by = c("station" = "rent_station", "time" = "rent_time_2hr"))
full_join_all <- left_join(full_join_rent, return, by = c("station" = "return_station", "time" = "return_time_2hr"))

#加上是否鄰近捷運、學校等資料並將NA改為0
variables <- read_excel('第四組_資料_廖珮媗、江馥羽、嚴怡詠、江彤恩.xlsx', 'return_') %>% select(station, quan, mrt, park, school, elementary, junior, senior, university)
full <- left_join(full_join_all, variables, by = "station")
full[is.na(full)] <- 0
full <- subset(full, select = -holidays.y)
full <- full %>% select(-holidays.x)

#將time的日期和時段分開
full <- separate(full, time, c("date", "time"), " ")
full$time <- gsub('.{3}$', '', full$time)

lack <- ifelse(full$rent_value - full$return_value > full$quan * 0.6, 1, 0)
full <- full %>%  ungroup() %>% mutate(lack)
write.csv(full,'Youbike_data.csv',row.names = FALSE)
