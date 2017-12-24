## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("reshape2")) {
        install.packages("reshape2")
}

require("data.table")
require("reshape2")

# 1. Reading Tables
activity_labels <- read.table("~/Desktop/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("~/Desktop/UCI HAR Dataset/features.txt")[,2]

X_test <- read.table("~/Desktop/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("~/Desktop/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("~/Desktop/UCI HAR Dataset/test/subject_test.txt")

y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")

X_train <- read.table("~/Desktop/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("~/Desktop/UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("~/Desktop/UCI HAR Dataset/train/subject_train.txt")

y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

names(subject_test) = "subject"
names(X_train) = features
names(X_test) = features

# 2. Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)
X_test = X_test[,extract_features]
X_train = X_train[,extract_features]

# 3. Merge data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)
data = rbind(test_data, train_data)

# 4. Label Columms
id_labels   = c("Subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# 5. Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, Subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "~/Desktop/UCI HAR Dataset/tidy_data.txt")
