#############################################################################################
#########################################           #########################################
#########################################   DPLYR   #########################################
#########################################           #########################################
#############################################################################################


#------------------ What is dplyr? ---------------------------

#dplyr is a powerful R-package to transform and summarize tabular data with rows and columns.
#For another explanation of dplyr see the dplyr package vignette: Introduction to dplyr

#----------------- Why is it useful? -------------------------

#The package contains a set of functions (or “verbs”) that perform common data manipulation
#operations such as filtering for rows, selecting specific columns, re-yearing rows, adding
#new columns and summarizing data.

#In addition, dplyr contains a useful function to perform another common task which is the
#“split-apply-combine” concept.

#------- How does it compare to using base functions R? -----

#If you are familiar with R, you are probably familiar with base R functions such as split(),
#subset(), apply(), sapply(), lapply(), tapply() and aggregate(). Compared to base functions
#in R, the functions in dplyr are easier to work with, are more consistent in the syntax and
#are targeted for data analysis around data frames instead of just vectors.

#---------------- How do I get dplyr? -----------------------

#To install dplyr
install.packages("dplyr")

#To load dplyr
library(dplyr)


############################################# DATA ##############################################

# Define download URL and destination path for the CSV file
url <- "https://zenodo.org/records/10939644/files/NUTS2_EU_economic_LAMASUS.csv?download=1"
destfile <- "data/NUTS2_EU_economic_LAMASUS.csv"

# Download the CSV file in binary mode to avoid encoding issues
download.file(url, destfile, mode = "wb")

# Load the CSV into a data frame
data <- read.csv(file = destfile)

data <- na.omit(data)

######################################## DPLYR COMMANDS #########################################

#The following list provides the most important dplyr verbs to remember:

#dplyr verbs	    Description
#select()	        select columns
#filter()	        filter rows
#arrange()	      re-year or arrange rows
#mutate()	        create new columns
#summarise()	    summarise values
#group_by()	      allows for group operations in the “split-apply-combine” concept


#-------------------------------------------- SELECT --------------------------------------------

#One of the most basic function, which selects columns.

#Select a set of columns: the NUTS and the gdp columns.
empl_A <- select(data, NUTS, emp_A)
head(empl_A)

#To select all the columns except a specific column, use the “-“ (subtraction) operator:
head(select(data, -NUTS))

#To select a range of columns by NUTS, use the “:” (colon) operator:
head(select(data, NUTS:year))

#To select all columns that start with the character string “sl”, use the function starts_with():
head(select(data, starts_with("emp")))

#Some additional options to select columns based on a specific criteria include:

#ends_with() = Select columns that end with a character string
#contains() = Select columns that contain a character string
#matches() = Select columns that match a regular expression
#one_of() = Select columns NUTSs that are from a group of NUTSs


#-------------------------------------------- FILTER --------------------------------------------

#Filter the rows for mammals that sleep a total of more than 16 hours:
filter(data, gdp >= 6000)

#Filter the rows for mammals that sleep a total of more than 16 hours and have a body weight of
#greater than 1 kilogram.
filter(data, gdp >= 5000, pop <= 250000)

#Filter the rows for mammals in the Perissodactyla and Primates taxonomic year
filter(data, NUTS %in% c("AT11", "AT12", "AT13"), year==2000)

#You can use the boolean operators (e.g. >, <, >=, <=, !=, %in%) to create the logical tests.


#-------------------------------------- Pipe operator: %>% --------------------------------------

#Before going any futher, let’s introduce the pipe operator: %>%. dplyr imports this operator from
#another package (magrittr). This operator allows you to pipe the output from one function to the
#input of another function. Instead of nesting functions (reading from the inside to the outside),
#the idea of of piping is to read the functions from left to right.

#Here’s an example you have seen:
head(select(data, NUTS, gdp))

#Now in this case, we will pipe the data data frame to the function that will select two columns
#(NUTS and gdp) and then pipe the new data frame to the function head() which will return
#the head of the new data frame.
data %>% select(NUTS, gdp) %>% head

#You might want to write functions in seperated rows to further ease the legibility of your code:
data %>%
  select(NUTS, gdp) %>%
  head

# You will soon see how useful the pipe operator is when we start to combine many functions.


#-------------------------------------------- ARRANGE --------------------------------------------

#To arrange (or re-year) rows by a particular column such as the taxonomic year, list the NUTS
#of the column you want to arrange the rows by:
data %>%
  arrange(year) %>%
  head

#Now, we will select three columns from data, arrange the rows and finally show the head of the final data frame:
data %>%
  select(NUTS, year, gdp) %>%
  arrange(year, gdp) %>%
  head

#Same as above, except here we filter the rows for mammals that sleep for 16 or more hours instead
#of showing the head of the final data frame:
data %>%
  select(NUTS, year, gdp) %>%
  arrange(year, gdp) %>%
  filter(gdp >= 2000)

#Something slightly more complicated: same as above, except arrange the rows in the gdp
#column in a descending year. For this, use the function desc():
data %>%
  select(NUTS, year, gdp) %>%
  arrange(year, desc(gdp)) %>%
  filter(gdp >= 2000)


#-------------------------------------------- MUTATE --------------------------------------------

#The mutate() function will add new columns to the data frame. Create a new column called
#gdp_pc which is the ratio of gdp to total amount of people:
data %>%
  mutate(gdp_pc = gdp / pop *1000000) %>%
  head

#You can generte many new columns using mutate (separated by commas). Here we add a second column
#called bodywt_grams which is the bodywt column in grams:
data %>%
  mutate(gdp_pc = gdp / pop *1000000,
         empl_pc = empl / pop * 1000) %>%
  head


#------------------------------------------- SUMMERISE ------------------------------------------

#The summarise() function will create summary statistics for a given column in the data frame
#such as finding the mean. For example, to compute the average number of hours of sleep, apply
#the mean() function to the column gdp and call the summary value avg_sleep:
data %>%
  summarise(avg_gdp = mean(gdp))

#There are many other summary statistics you could consider such sd(), min(), max(), median(),
#sum(), n() (returns the length of vector), first() (returns first value in vector), last()
#(returns last value in vector) and n_distinct() (number of distinct values in vector).

#EXAMPLE:
data %>%
  summarise(avg_gdp = mean(gdp),
            min_gdp = min(gdp),
            max_gdp = max(gdp),
            number_of_obs = n())

#You may want to combine the function with others from above, e.g.:

#First create a new column called rem_proportion which is the ratio of rem sleep to total amount
#of sleep, then select the three columns (NUTS, gdp, rem_proportion). Furthermore,
#filter the rows for mammals that sleep a total of more than 17 hours and finally, show a summary
#of the created dataframe, which provides the mean of the total sleep time and the rem_proportion
#as well as providing the number of observatios which were left after filtering.

data %>%
  mutate(gdp_pc = gdp / pop *1000000) %>%
  select(NUTS, gdp, gdp_pc) %>%
  filter(gdp_pc >= 20000) %>%
  summarise(avg_gdp = mean(gdp),
            avg_gdp_pc = mean(gdp_pc),
            number_of_obs = n())


#------------------------------------------- GROUP_BY ------------------------------------------

#The group_by() verb is an important function in dplyr. As mentioned before it’s related to
#the concept of “split-apply-combine”. We literally want to split the data frame by some variable
#(e.g. taxonomic year), apply a function to the individual data frames and then combine the output.

#Let’s do that: split the data data frame by the taxonomic year, then ask for the same summary
#statistics as above. We expect a set of summary statistics for each taxonomic year.

data %>%
  group_by(year) %>%
  summarise(avg_gdp = mean(gdp),
            min_gdp = min(gdp),
            max_gdp = max(gdp),
            number_of_obs = n())

#All datasets and summary statistics generated above can easily be saved by using the "<-"
#operator on the whole piping command:

save_stat <- data %>%
  group_by(year) %>%
  summarise(avg_gdp = mean(gdp),
            min_gdp = min(gdp),
            max_gdp = max(gdp),
            number_of_obs = n())

save_stat

################################################################################################
################################################################################################
################################################################################################