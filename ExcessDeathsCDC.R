#############################################################################################
# Analyses of excess deaths during the COVID-19 Pandemic
#############################################################################################
# RStudio Version 1.3.1093
# R version 4.0.3 (2020-10-10)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 18363)
#############################################################################################
# This program reads in weekly provisional and historic (final) mortality data
# from 2014 to date, and applies algorithms to estimate the numbers of excess
# deaths occurring by jurisdiction of occurrence and week since the week ending Feb 1, 2020. 
# For more detail about the data and methods, see: 
#      https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm
# NOTE: estimates produced here may differ slightly from published estimates due to differences
# in the data sources, timing of data extraction, and years of data included. Previously 
# published estimates used historical data from 2013 to date, while the publicly available
# data files used in this program include data from 2014 to date. 
# 
# Date: March 24, 2021
##############################################################################################


##############################################################################################
## Uncomment below code to check if packages are installed and install them if needed
##############################################################################################
# 
# packages <- c("reshape", "tidyr", "magrittr","forecast","lubridate","dplyr","surveillance","readr","MMWRweek")
# if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
#   install.packages(setdiff(packages, rownames(installed.packages())))
# }
##############################################################################################

rm(list=ls())

# Load required packages (install by uncommenting above section, if necessary)
library(reshape) 
library(tidyr)
library(magrittr)
library(forecast)
library(lubridate)
library(dplyr) 
library(surveillance)
library(readr)
library(MMWRweek)


# Provisional weekly counts, weighted for incomplete reporting
provurl<-"https://data.cdc.gov/resource/xkkf-xrst.csv?$limit=1000000"

# Historical final weekly counts, complete data, from 2014-2019
histurl<-"https://data.cdc.gov/resource/3yf8-kanr.csv?$limit=1000000"


provdat<-read_csv(url(provurl))
histdat<-read_csv(url(histurl))

# Subset provisional data to weeks including 2020 data
provdat<- provdat %>%
  filter(week_ending_date>="2019-12-15",type=="Predicted (weighted)",outcome=="All causes") %>%
  dplyr::select(state,week_ending_date,observed_number) %>%
  rename(num=observed_number,
         weekendingdate=week_ending_date)

mmwrdate<-MMWRweek(provdat$weekendingdate)
names(mmwrdate)<-c("MMWRyear","MMWRweek","mmwrday")

provdat<-cbind(provdat,mmwrdate[,c(1:2)])

# Subset historical data to 2019 and earlier, ensuring that we have full weeks counts for the end of the year, when 
# MMWR weeks cross years and that the weeks do not overlap with the provisional data above

histdat<- histdat %>%
  filter(weekendingdate<"2019-12-15") %>%
  dplyr::select(jurisdiction_of_occurrence,mmwryear,mmwrweek,weekendingdate,allcause) %>%
  rename(state=jurisdiction_of_occurrence,
         num=allcause,
         MMWRyear=mmwryear,
         MMWRweek=mmwrweek)

# Append historical and provisional counts         
datacomb<-rbind(as.data.frame(histdat),as.data.frame(provdat))

# Create data frame for states
states<- datacomb %>%
  dplyr::select(-weekendingdate) %>%
  filter(state!="United States") %>%
  arrange(state,MMWRyear,MMWRweek) %>%
  spread(state,num)
states<- as.data.frame(states)
states<-states[,c("MMWRyear"  ,           "MMWRweek", "Alabama"      ,     "Alaska"         ,     "Arizona"             , "Arkansas"         ,    "California"       ,    "Colorado"        ,   
                  "Connecticut"  ,     "Delaware"       ,     "District of Columbia", "Florida"          ,    "Georgia"          ,    "Hawaii"          ,   
                  "Idaho"       ,      "Illinois"      ,      "Indiana"            ,  "Iowa"            ,     "Kansas"          ,     "Kentucky"       ,    
                  "Louisiana"   ,      "Maine"         ,      "Maryland"           ,  "Massachusetts"   ,     "Michigan"        ,     "Minnesota"      ,    
                  "Mississippi" ,      "Missouri"      ,      "Montana"            ,  "Nebraska"        ,     "Nevada"          ,     "New Hampshire"  ,    
                  "New Jersey"  ,      "New Mexico"    ,      "New York"           ,  "New York City"   ,     "North Carolina"  ,     "North Dakota"   ,    
                  "Ohio"        ,      "Oklahoma"      ,      "Oregon"             ,  "Pennsylvania"    ,     "Rhode Island"    ,     "South Carolina" ,    
                  "South Dakota",      "Tennessee"     ,      "Texas"              ,  "Utah"            ,     "Vermont"         ,     "Virginia"       ,    
                  "Washington"  ,      "West Virginia" ,      "Wisconsin"          ,  "Wyoming"         ,     "Puerto Rico")]


# Dates included
dates<-as.Date(MMWRweek2Date(MMWRyear=states$MMWRyear,MMWRweek=states$MMWRweek,MMWRday=7))

# sts object needed for the Farrington algorithm
datsts<-sts(
  observed=states[,c(3:55)],
  start=c(2014, 01),frequency=52,epochAsDate=T,
  epoch=as.numeric(dates) ) 


# Create object for today's date to exclude 2020 forward from the baseline estimates
today<-lubridate::today()
#########################################################################################
# Parameters for models
control1 <- list(range = NULL, noPeriods=10,reweighting=T,
                 w = 2, b = 4,  
                 weightsThreshold = 2.58,
                 verbose = FALSE, glmWarnings = TRUE,
                 trend = T, alpha = 0.05, 
                 powertrans="2/3",
                 pastWeeksNotIncluded = as.numeric(round((52+(today-as.Date("2021-01-01"))/7),0)),
                 pThresholdTrend = .1,
                 thresholdMethod = "muan")

# Models for states
flex.farrington <- farringtonFlexible(datsts, control1)


# Create data frame for US
us<- datacomb %>%
  filter(state=="United States") %>%
  dplyr::select(-weekendingdate,-state) %>%
  arrange(MMWRyear,MMWRweek) 
us<- as.data.frame(us)


# Models for US
datsts.us<-sts(
  observed=us[,c(3)],
  start=c(2014, 01),frequency=52,epochAsDate=T,
  epoch=as.numeric(dates))
flex.farrington.us <- farringtonFlexible(datsts.us, control1)

# Plot US output
stsplot_time(flex.farrington.us)

###############################################
# Format dates for output
datesincl<-as.Date(flex.farrington@epoch,"%Y-%m-%d",origin="1970-01-01")
start<-min(as.Date(datesincl))
end<-max(as.Date(datesincl))


########################################
# observed values and upper bound threshold

longdf_obs<-as.data.frame(cbind(as.data.frame(datesincl),
                                round(flex.farrington@observed,0) ))
colnames(longdf_obs)[1]<-"date"   
longdf_obs$date<-as.Date(as.character(longdf_obs$date),"%Y-%m-%d")

longdf_obs <- longdf_obs %>%
  pivot_longer(cols=2:54,names_to="State") %>%
  dplyr::rename(obs=value) 


longdf_thresh<-as.data.frame(cbind(as.data.frame(datesincl),
                                   flex.farrington@upperbound ))
colnames(longdf_thresh)[1]<-"date"   
longdf_thresh$date<-as.Date(as.character(longdf_thresh$date),"%Y-%m-%d")

longdf_thresh <- longdf_thresh %>%
  pivot_longer(cols=2:54,names_to="State") %>%
  dplyr::rename(thresh=value) 


longdf_alarm<-as.data.frame(cbind(as.data.frame(datesincl),
                                  flex.farrington@alarm ))
colnames(longdf_alarm)[1]<-"date"   
longdf_alarm$date<-as.Date(as.character(longdf_alarm$date),"%Y-%m-%d")

longdf_alarm <- longdf_alarm %>%
  pivot_longer(cols=2:54,names_to="State") %>%
  dplyr::rename(alarm=value)

#######################################################################################################
# expected values

longdf_exp<-as.data.frame(cbind(as.data.frame(datesincl),
                                flex.farrington@control$expected ))
colnames(longdf_exp)[1]<-"date"   
longdf_exp$date<-as.Date(as.character(longdf_exp$date),"%Y-%m-%d")
names(longdf_exp)<-c("date",colnames(flex.farrington@state[,1:53]))

longdf_exp <- longdf_exp %>%
  pivot_longer(cols=2:54,names_to="State") %>%
  dplyr::rename(exp=value) 


# merge observed, expected, upper bound, alarm flag

combdf<-merge(longdf_obs,longdf_thresh,by=c("date","State"),all=T)

combdf<-merge(combdf,longdf_alarm,by=c("date","State"),all=T)

combdf<-merge(combdf,longdf_exp,by=c("date","State"),all=T)

combdf$obs<-as.numeric(as.character(combdf$obs))
combdf$thresh<-as.numeric(as.character(combdf$thresh))
combdf$exp<-as.numeric(as.character(combdf$exp))

#######################################################################################################33333
# create additional variables 

combdf <- combdf %>%
  mutate(excess=ifelse((obs>=thresh)==T,(obs-thresh),0),
         overexpno0=ifelse((obs>=exp)==T,(obs-exp),0),
         year=as.Date(date),
         t2020=ifelse(year>=as.Date("02/01/2020","%m/%d/%Y"),1,0)) %>%
  group_by(State) %>%
  mutate(totexcess=sum(excess*t2020,na.rm=T),
         pctex=100*excess/thresh,
         totoverexpno0=sum(overexpno0*t2020,na.rm=T),
         pctoverexpno0=100*overexpno0/exp) 


combdf$date<-format.Date(as.Date(combdf$date,"%Y-%m-%d"),"%m/%d/%Y")

combdf$Type<-"Predicted (weighted)"

#################US Output

usdatwt<-cbind(as.data.frame(datesincl),round(flex.farrington.us@observed,0),flex.farrington.us@upperbound,flex.farrington.us@alarm,flex.farrington.us@control$expected)
usdatwt$State<-"United States"
names(usdatwt)<-c("date","obs","thresh","alarm","exp","State")
usdatwt$obs<-as.numeric(as.character(usdatwt$obs))
usdatwt$thresh<-as.numeric(as.character(usdatwt$thresh))
usdatwt$exp<-as.numeric(as.character(usdatwt$exp))

usdatwt <- usdatwt %>%
  mutate(excess=ifelse((obs>=thresh)==T,(obs-thresh),0),
         overexpno0=ifelse((obs>=exp)==T,(obs-exp),0),
         year=as.Date(date),
         t2020=ifelse(year>=as.Date("02/01/2020","%m/%d/%Y"),1,0),
         totexcess=sum(excess*t2020,na.rm=T),
         pctex=100*excess/thresh,
         totoverexpno0=sum(overexpno0*t2020,na.rm=T),
         pctoverexpno0=100*overexpno0/exp) 

usdatwt$date<-format.Date(as.Date(usdatwt$date,"%Y-%m-%d"),"%m/%d/%Y")

usdatwt$Type<-"Predicted (weighted)"

###################################################################################
# Append state and US output
outputdata<-rbind(combdf,usdatwt) %>%
         mutate(Outcome="All causes",
                exp=round(exp,0),
                overexpno0=round(overexpno0,0),
                totoverexpno0=round(totoverexpno0,0),
                year=lubridate::year(year),
                date=as.Date(date,"%m/%d/%Y")) %>%
  arrange(State,date) %>%
  dplyr::select(-t2020) 

names(outputdata)<-c("Week Ending Date","State","Observed Number",
                     "Upper Bound Threshold","Exceeds Threshold", 
                  "Average Expected Count","Excess Lower Estimate",
                  "Excess Higher Estimate","Year", 
                  "Total Excess Lower Estimate","Percent Excess Lower Estimate",
                  "Total Excess Higher Estimate","Percent Excess Higher Estimate",
                  "Type","Outcome")

write.csv(outputdata,paste0("./excessdeaths_",today,".csv"),row.names=F,na="")

