getwd()
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
setwd("C:/Users/Administrator.DESKTOP-JG1NPFA/Desktop/�ҷ~/1102/R")

#���JEXCEL��ơA���O���u�u���ɨ��b�j�w�v�B�u�u���٨��b�j�w�v�Ρu���٨����b�j�w�v
only_rent <- read_excel('�ĥ|��_���_���\�šB���L�СB�Y�ɵ��B���ͮ�(4).xlsx','rent_daan')
only_return <- read_excel('�ĥ|��_���_���\�šB���L�СB�Y�ɵ��B���ͮ�(5).xlsx','return_daan')
both <- read_excel('�ĥ|��_���_���\�šB���L�СB�Y�ɵ��B���ͮ�(3).xlsx','both_daan')

#�h��?��NA�ȡB���O���o�j�w�ϦU�����ɨ����٨��ƾڡB���ӯ��W�ήɶ��̧ǱƦC
arr_rent <- rbind(only_rent,both)%>% arrange(rent_station, rent_time)
arr_rent$rent_station <- gsub("[?]", "???", arr_rent$rent_station)
arr_rent[is.na(arr_rent)] <- 0
arr_return <- rbind(only_return,both)%>% arrange(return_station, return_time)
arr_return$return_station <- gsub("[?]", "???", arr_return$return_station)
arr_return$holidays[is.na(arr_return$holidays)] <- 0

#�N�ɶ���ƦX�֬�2�p�ɬ��@�϶��A�íp��j�w�ϦU���U�ɬq���ɨ����٨��`��
rent <- arr_rent %>% select(rent_time, rent_station, holidays) %>% mutate(rent_time = as.POSIXct(rent_time), value = rep(1, nrow(arr_rent))) %>% group_by(rent_station,holidays, rent_time_2hr = floor_date(rent_time, "2 hour")) %>% summarize(rent_value = sum(value)) 
return <- arr_return %>% select(return_time, return_station, holidays) %>% mutate(return_time = as.POSIXct(return_time), value = rep(1, nrow(arr_return))) %>% group_by(return_station,holidays, return_time_2hr = floor_date(return_time, "2 hour")) %>% summarize(return_value = sum(value)) 

#���F�Nrent �Mreturn����Ƨ@���P�itable�A
#��Xrent�Mreturn��ƪ����W�M�ɶ��A���X�Ҧ����W�M�ɶ����`���A
#�çR�����ƭ�
rent_part <- rent %>% select(rent_station, rent_time_2hr,holidays)
colnames(rent_part) <- c("station", "time", "holidays")
rent_part
return_part <- return %>% select(return_station, return_time_2hr, holidays)
colnames(return_part) <- c("station", "time", "holidays")
return_part
full_test <- rbind(rent_part, return_part)
full_station_time <- full_test[!(duplicated(full_test[c("station","time")]) | duplicated(full_test[c("station","time")])), ]  %>% arrange(station,time)
#full_station_time �Orent �Mreturn�̭��X�{���Ҧ����W�M�ɶ���table

#�Q���`��join rent�Mreturn�����
full_join_rent <- left_join(full_station_time, rent, by = c("station" = "rent_station", "time" = "rent_time_2hr"))
full_join_all <- left_join(full_join_rent, return, by = c("station" = "return_station", "time" = "return_time_2hr"))

#�[�W�O�_�F�񱶹B�B�Ǯյ���ƨñNNA�אּ0
variables <- read_excel('�ĥ|��_���_���\�šB���L�СB�Y�ɵ��B���ͮ�.xlsx', 'return_') %>% select(station, quan, mrt, park, school, elementary, junior, senior, university)
full <- left_join(full_join_all, variables, by = "station")
full[is.na(full)] <- 0
full <- subset(full, select = -holidays.y)
full <- full %>% select(-holidays.x)

#�Ntime������M�ɬq���}
full <- separate(full, time, c("date", "time"), " ")
full$time <- gsub('.{3}$', '', full$time)

lack <- ifelse(full$rent_value - full$return_value > full$quan * 0.6, 1, 0)
full <- full %>%  ungroup() %>% mutate(lack)
write.csv(full,'Youbike_data.csv',row.names = FALSE)