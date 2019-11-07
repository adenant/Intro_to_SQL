#################################################################################################
# Basic R and Intro to Data Manipulation and Visualization                                                           #
# SAPPK - Institut Teknologi Bandung                                                            #
#                                                                                               #
# Script names  : Basic_SQL                                                                      #
# Purpose       : This script contains line commands that performs basic tasks, and             #
#                 introduction to data manipulation and visualization for Urban Analytics       #
# Programmer    : Adenantera Dwicaksono                                                         #
# First Created : 10/29/2019 12:08 PM                                                            #
# Last updated  : 10/29/2019                                                                     #
#################################################################################################

################################################################################################# 
# Note: This comment provides information about any requirements that need to be met before
#       running the script. It tells other users important requirements to execute the script
#       without errors.
#
# Requirements:
#     - R and R studio are properly install in the desktop
#
################################################################################################# 


#################################################################################################
# Note:  This comments describes any processes that will be performed by the script
#
# This script performs the following steps:
#   Step 1: Install packages, load required library packages, and set working directories
#
# 
# Learning Objectives By the end of this practical lab you will be able to:
# - Understand the basics of SQL syntax to select, update and remove records from a table
# - How to use SQL to create and drop tables
# - Join tables of data using SQL
# - Use an R interface to Carto to enable spatial queries
#
################################################################################################# 

##################
# 1: Install packages, load required library packages, and set working directories
##################

#The following packages are essential for running the following processes, and have been installed
#in my machine and therefore no need to reinstall them. It the script is run in other
#machine, these packages must have been installed 

#install.packages("stringr")



# open libraries of spatial utilities
library(stringr)
library(sqldf)


# set working directory
wd <- 'D:/Gdrive/ITB/Teaching/2019-2020/PL3102/02_Basic_SQL' # a string object containing
# the location of the main working directory
setwd(wd) # This set the working directory

#set data folder
input.dir <- paste0(wd,"/",'Data')

#specify output folder
output.dir <- paste0(wd,"/",'Output')

# check folder contents
dir()

##############################################
# 2. Demo of R as an over-powered calculator
##############################################

#Read data
tract_311 <- read.csv("./Data/311_Tract_Coded.csv")

#The content includes the tract code and the category of the 311 call
head(tract_311)

#Read in the WAC data
WAC <- read.csv("./Data/ca_wac_SI03_JT00_2014.csv")
head(WAC)


options(scipen = 999)

#read crosswalk (original location: https://lehd.ces.census.gov/data/lodes/LODES7/ca/ca_xwalk.csv.gz)
crosswalk <- read.csv("./Data/ca_xwalk.csv")
crosswalk <- subset(crosswalk, select = c("tabblk2010","trct")) #Keep just the Block and Tract IDs
head(crosswalk)

# Select all of the rows and columns in the tract_311 table - the use of * means all; essentially, duplicates the table
tmp <- sqldf('SELECT * from tract_311')

# Select only the block ID and variable that relates to jobs in "Arts, Entertainment, and Recreation (CNS17)" from the WAC data frame
AER_311 <- sqldf('SELECT w_geocode, CNS17 FROM WAC')
head(AER_311) # Shows the head of the new data frame

# You can use an AS option to rename a variable - here CNS17 is presented as AER
AER_311 <- sqldf('SELECT w_geocode, CNS17 AS AER FROM WAC')
head(AER_311)

#Return all records where the Category is "Noise Report"
noise_311 <- sqldf('SELECT * from tract_311 WHERE Category = "Noise Report"')

# Left Join
AER_311_Tract <- sqldf("SELECT * from AER_311 AS A LEFT JOIN crosswalk AS B on A.w_geocode = B.tabblk2010")
#Show the top six rows of the table
head(AER_311_Tract)

# Left Join and group by
AER_311_Tract <- sqldf("SELECT sum(A.AER) AS AER, B.trct from AER_311 AS A LEFT JOIN crosswalk AS B on A.w_geocode = B.tabblk2010 GROUP BY trct")
#Show the top six rows of the table
head(AER_311_Tract)

#Group by with count
noise_311_tract <- sqldf("SELECT GEOID10, count(Category) as Noise_C FROM noise_311 GROUP BY GEOID10")

# Merge the two tables
noise_AER_tract <- merge(AER_311_Tract,noise_311_tract, by.x="trct",by.y = "GEOID10")
head(noise_AER_tract)
