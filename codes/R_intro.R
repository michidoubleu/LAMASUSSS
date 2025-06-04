#############################################################################################
##################################                         ##################################
##################################   BASE R INTRODUCTION   ##################################
##################################                         ##################################
#############################################################################################


############################   Working Directory and Workspace   ############################


#As with the standard R GUI, RStudio employs the notion of a global default working directory.
#Normally this is the user home directory (typically referenced using ~ in R).

#The current working directory is displayed by RStudio within the title region of the Console.
#Or you can ask R for the current working directory location using the command:

getwd()

#######################################   Packages   ########################################

#Packages are collections of R functions, data, and compiled code in a well-defined format.
#The directory where packages are stored is called the library. R comes with a standard set
#of packages. Others are available for download and installation. Once installed, they have
#to be loaded into the session to be used.

.libPaths() # get library location
library()   # see all packages installed
search()    # see packages currently loaded

#Adding Packages:
#You can expand the types of analyses you do be adding other packages. A complete list of
#contributed packages is available from CRAN.

#List of commonly used packages:

#To manipulate data:
## dplyr - Essential shortcuts for subsetting, summarizing, rearranging, and joining
#together data sets. dplyr is our go to package for fast data manipulation.
## tidyr - Tools for changing the layout of your data sets. Use the gather and spread
#functions to convert your data into the tidy format, the layout R likes best.

#To visualize data:
## ggplot2 - R's famous package for making beautiful graphics. ggplot2 lets you use the
#grammar of graphics to build layered, customizable plots.




####################################   Help Functions   #####################################

# R includes extensive facilities for accessing documentation and searching for help.
#The "help()" function and "?"-help operator in R provide access to the documentation pages
#for R functions, data sets, and other objects, both for packages in the standard R
#distribution and for contributed packages. To access documentation for the standard lm
#(linear model) function, for example, enter the command:

help(lm) #or
help("lm")#, or
?lm


#######################################   Functions   ########################################

#One of the great strengths of R is the user's ability to add functions. In fact, many of the
#functions in R are actually functions of functions. The structure of a function is given below.

#myfunction <- function(arg1, arg2, ... ){
#statements
#return(object)
#}

# For example:


#setting up a funtion with two arguments:

myfu <- function(arg1,arg2) {
  A <- paste(arg1,arg2,sep=" ")
  return(A)
}

#running the self written function
myfu(arg1 = "hello", arg2 = "world")


#######################################   Data Types   ########################################


#R has a wide variety of data types including scalars, vectors (numerical, character, logical),
#matrices, data frames, and lists.

###############
### Vectors ###
###############

a <- c(1,2,5.3,6,-2,4) # numeric vector
b <- c("one","two","three") # character vector
c <- c(TRUE,TRUE,TRUE,FALSE,TRUE,FALSE) #logical vector

#Refer to elements of a vector using subscripts.

a[c(2,4)] # 2nd and 4th elements of vector


################
### Matrices ###
################

#All columns in a matrix must have the same mode(numeric, character, etc.) and the same length.
#The general format is:

# mymatrix <- matrix(vector, nrow=r, ncol=c, byrow=FALSE,
#                    dimnames=list(char_vector_rownames, char_vector_colnames))

#byrow=TRUE indicates that the matrix should be filled by rows. byrow=FALSE indicates that the
#matrix should be filled by columns (the default). dimnames provides optional labels for the
#columns and rows.


# generates 5 x 4 numeric matrix
y<-matrix(1:20, nrow=5,ncol=4)

# another example
cells <- c(1,26,24,68)
rnames <- c("R1", "R2")
cnames <- c("C1", "C2")
mymatrix <- matrix(cells, nrow=2, ncol=2, byrow=TRUE,
                   dimnames=list(rnames, cnames))

#Identify rows, columns or elements using subscripts.

y[,4] # 4th column of matrix
y[3,] # 3rd row of matrix
y[2:4,1:3] # rows 2,3,4 of columns 1,2,3

##############
### Arrays ###
##############

#Arrays are similar to matrices but can have more than two dimensions.
#See help(array) for details.


###################
### Data Frames ###
###################

#A data frame is more general than a matrix, in that different columns can have different modes
#(numeric, character, factor, etc.). This is similar to SAS and SPSS datasets.

d <- c(1,2,3,4)
e <- c("red", "white", "red", NA)
f <- c(TRUE,TRUE,TRUE,FALSE)

myframe <- data.frame(d,e,f)
names(myframe) <- c("ID","Color","Passed") # variable names

#There are a variety of ways to identify the elements of a data frame .

myframe[1:2] # columns 1,2 of data frame
myframe[c("ID","Passed")] # columns ID and Passed from data frame
myframe$ID # variable ID in the data frame


#############
### Lists ###
#############

#An ordered collection of objects (components). A list allows you to gather a variety of
#(possibly unrelated) objects under one name.

# example of a list with 4 components -
# a string, a numeric vector, a matrix, and a scaler
mylist <- list(name="Fred", mynumbers=a, mymatrix=y, age=5.3)

# example of a list containing two lists
# v <- c(list1,list2)

#Identify elements of a list using the [[]] convention.

mylist[[2]] # 2nd component of the list
mylist[["mynumbers"]] # component named mynumbers in list


###############
### Factors ###
###############

#Tell R that a variable is nominal by making it a factor. The factor stores the nominal
#values as a vector of integers in the range [ 1... k ] (where k is the number of unique
#values in the nominal variable), and an internal vector of character strings (the original
#values) mapped to these integers.

# variable gender with 20 "male" entries and 30 "female" entries
# (the rep command replicates a given argument a given number of times)

gender <- c(rep("male",20), rep("female", 30))
gender <- factor(gender)

# stores gender as 20 1s and 30 2s and associates
# 1=female, 2=male internally (alphabetically)
# R now treats gender as a nominal variable
summary(gender)

#R will treat factors as nominal variables in statistical proceedures and graphical analyses.


########################
### Useful Functions ###
########################

length(object) # number of elements or components
str(object)    # structure of an object
class(object)  # class or type of an object
names(object)  # names

c(object,object,...)       # combine objects into a vector
cbind(object, object, ...) # combine objects as columns
rbind(object, object, ...) # combine objects as rows

object     # prints the object

ls()       # list current objects
rm(object) # delete an object


#####################################   Importing Data   ######################################

#Importing data into R is fairly simple. For Stata and Systat, use the foreign package. For
#SPSS and SAS I would recommend the Hmisc package for ease and functionality.

######### From R Data File ########

mydata <- readRDS(file="./data/mydata.rds")


######### From Excel ########

#One of the best ways to read an Excel file is to export it to a comma delimited file and import
#it using the method above. Alternatively you can use the xlsx package to access Excel files.
#The first row should contain variable/column names.

# read in the first worksheet from the workbook myexcel.xlsx
# first row contains variable names
library(xlsx)
mydata <- read.xlsx("../Data/myexcel.xlsx", 1)

# read in the worksheet named mysheet
mydata <- read.xlsx("../Data/myexcel.xls", sheetName = "mysheet")


######### From Stata ########


# input Stata file
library(foreign)
mydata <- read.dta("../Data/mydata.dta")


#####################################   Exporting Data   ######################################

#There are numerous methods for exporting R objects into other formats . For Stata, you will
#need to load the foreign packages. For Excel, you will need the xlsx package.


######### To an R Data File #########

saveRDS(mydata, file="../Data/mydata.rds")


######### To A Tab Delimited Text File ########

write.table(mydata, "../Data/mydata.txt", sep="\t")


######### To an Excel Spreadsheet ########

library(xlsx)
write.xlsx(mydata, "../Data/mydata.xlsx")


#####################################   Basic Commands   ######################################


####### R as calculator #######

# NUMERIC FUNCTIONS

3 + 3         #addition; code works regardless of the spaces, but it is recommended to use them
3 - 5         #subtraction
3 * 5         #multiplication
3 / 5         #division

3 ^ 5         #exponentiation
sqrt(81)      #square root
243 ^ (1/5)   #a-th root
sin(pi/2)     #sine
cos(0)        #cosine
tan(0)        #tangent
log(1)        #natural logarithm
exp(1)        #e^x

ceiling(1.2)  #next higher integer
floor(1.2)    #next lower integer
abs(-1)       #absolute value
round(2.45,1) #rounds given number of digits


# CHARACTER FUNCTIONS

toupper("Test")                     #returns string of uppercase letters
tolower("Test")                     #returns string of lowercase letters
substr("Test", start=2, stop=3)     #returns string from start to stop
strsplit("Test", split="")          #splits string given the split character
paste("T", "e", "s", "t", sep="")   #combines strings with given seperator


# STATISTICAL PROBABILITY FUNCTIONS

rnorm(1,0,1)        #generates 1 random number from the standard normal distribution
dnorm(0)            #normal density function (for standard normal on default)
pnorm(0)            #cumulative normal probability (area ander PDF left from defined value)
qnorm(0.8)          #normal quantile (value at the p percentile of normal distribution)

#r-, d-, p-, q- always evoke the above described commands for a given distributen
#Other distributions may vary in their parametrization.

#commonly used distributions:

#Normal:    -norm
#Uniform:   -unif
#Beta:      -beta
#gamma:     -gamma
#Binomial:  -binom
#Poisson:   -pois
#Weibull:   -weibull


# OTHER STATISTICAL FUNCTIONS


x <- seq(1:10)

mean(x)	        #arithmetic mean
sd(x)	          #standard deviation
var(x)          #variance
median(x)	      #median
quantile(x)	    #quantiles (quartiles on default)
range(x)	      #range
sum(x)	        #sum
min(x)	        #minimum
max(x)	        #maximum

# OTHER USEFUL FUNCTIONS


#seq(from , to, by)	          #generate a sequence
#rep(x, ntimes)	              #repeat x n times
#cut(x, n)	                  #divide continuous variable in factor with n levels



##################################   Repeating Calculations  ###################################


#In R you have multiple options when repeating calculations: vectorized operations, loops,
#and apply functions.

###############
### Looping ###
###############

#The most commonly used loop is the "for" loop. It is used to apply the same function calls
#to a collection of objects. HIn R, for loops take an interator variable and assign it successive
#values from a sequence or vector. For loops are most commonly used for iterating over the
#elements of an object (list, vector, etc.)

for(i in 1:10) {
  print(i)
  Sys.sleep(0.5)
}

#This loop takes the "i" variable and in each iteration of the loop gives it values 1, 2, 3, …,
#10, executes the code within the curly braces, and then the loop exits.

#Another example:

x <- c("a", "b", "c", "d")

for(j in seq_along(x)){
  print(x[j])
}

#This loop takes the "j" varibale and in each iteration of the loop (based on the length of x),
#it executes the code within the curly braces (print the j-th element of x), and then exits
#the loop.

#Other typs of loop:

#while-loop:  #While loops begin by testing a condition. If it is true, then they execute the
#loop body.Once the loop body is executed, the condition is tested again, and
#so forth, until the condition is false, after which the loop exits.

#repeat-loop: #repeat initiates an infinite loop right from the start. These are not commonly
#used in statistical or data analysis applications but they do have their uses.
#The only way to exit a repeat loop is to call break.
################################################################################################
################################################################################################
################################################################################################