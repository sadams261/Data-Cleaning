# This script produces a tidy data set per Course Assignment, using input from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# The script requires that the zip file be decompressed into a directory called /UCI HAR Dataset
# i.e., beneath UCI HAR Dataset are data files, and directories test and train
# UCI HAR Dataset needs to exist in the working directory

setwd("./UCI HAR Dataset")


# first read in the data from the test folder (X_test, Y_test, subjects_test)
setwd("./test")
read.table("X_test.txt") -> X_test
read.table("Y_test.txt") -> Y_test
subjects_test<- read.table("subject_test.txt")

# repeat for the data in the train folder (X_train, Y_train,subjects_train)
setwd("../train")
read.table("X_train.txt") -> X_train
read.table("Y_train.txt") -> Y_train 
subjects_train<- read.table("subject_train.txt")

setwd("..")

#now read the activity labels, and features

read.table("activity_labels.txt") ->activity_codes
features <- read.table("features.txt")
setwd("..")



# assemble X and Y and subjects into one dataset (Train followed by test)

X <- rbind(X_train,X_test)
Y <- rbind(Y_train,Y_test)
subjects <- rbind(subjects_train,subjects_test)

# Friendly names from feature.txt are used as column names in X
# add names for Y and subjects
colnames(X) <-features[,2]
colnames(Y) <-"Activity"
colnames(subjects) <- "Subjects"
# add friendly name for Activity. 

colnames(activity_codes) <-c("Activity","Activity_Label")

## now identify the measures that are mean or standard deviation by looking at their names
## Assumption is that these measures explicitly contain "std" and "-mean" in their names

data_codes <- features$V2[grep("std",features$V2,ignore.case=TRUE)]
data_codes2 <- features$V2[grep("-mean",features$V2,ignore.case=TRUE)]

# extract the columns that we want from X
data_we_want <- subset(X,,select=((colnames(X) %in% data_codes) | (colnames(X) %in%data_codes2)))

# add Y (activity) and the subjects to the right side of the X data
data2 <- cbind(data_we_want,Y,subjects)


# now add the friendly (text) labels for the activities, by joining based on the Activity code
library(plyr)
data2 <- join(data2,activity_codes,by='Activity')

# reshape the data by melting and using ddply to calculate means. This gives a long narrow data set
library(reshape2)
tmelt <- melt(data2,id=c("Subjects","Activity_Label","Activity"))
tidy <- ddply(tmelt,.(Subjects,Activity_Label,variable),summarize,mean=mean(value))

# Clean up Column names and output the data as specified
colnames(tidy) <- c("subject","activity","variable name","mean of variable")
write.table(tidy,"tidy.txt",row.names=FALSE)
