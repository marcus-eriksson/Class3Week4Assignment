#--------------------------------------------------------------------
#STEP 1 Merge the training and the test sets to create one data set.
#--------------------------------------------------------------------

# Read the feature file and make a character vector with nicer names
#Feature file is in below format
# 1 tBodyAcc-mean()-X
# 2 tBodyAcc-mean()-Y
# 3 tBodyAcc-mean()-Z
# So as its added to a character vector I strip out the line number and the following whitespace

file_path <- "C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\features.txt"
file_con <- file(file_path, open = 'r')

read_file <- readLines(file_con)
n_lines = length(read_file)

feature_vector <- character(n_lines)

for (line_index in 1:n_lines) {
  current_line <- read_file[line_index]                       #Read whater line_index we are at
  string_to_replace <- paste0(line_index, " ")                #Make a string that looks like "2 " if lineindex is 2
  current_line <- sub(string_to_replace, "", current_line)    #Replace the "X " with nothing so only the feature name remains
  feature_vector[line_index] <- current_line                  
}

#Read the training and test set
#One line looks like "2.5717778e-001 -2.3285230e-002 -1.4653762e-002....." so reading it in with as a CSV with the sep = "" switch it uses all whitespace as a
# separator, which solves the issues of all negative numbers only having one whitespace (the - sign taking up one space), while all positive are separated by two 
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\X_train.txt'
raw_training_set <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\X_test.txt'
raw_test_set <- read.csv(test_file_path, sep = "", header = FALSE)


#Read in the activites files
#Each row corresponds to an activity, sitting walking etc
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\Y_train.txt'
raw_training_activites <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\Y_test.txt'
raw_test_activites <-  read.csv(test_file_path, sep = "", header = FALSE)

#Read in the test subjects
# Each row corresponds to a subject ID 
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\subject_train.txt'
raw_training_subjects <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\subject_test.txt'
raw_test_subjects <-  read.csv(test_file_path, sep = "", header = FALSE)

#Join all the datasets together.
#Make the labels more descriptive
#Always starting with the training set as the first vector on joining

all_subjects <- rbind(raw_training_subjects, raw_test_subjects)
colnames(all_subjects) <- 'SubjectId'

all_activities <- rbind(raw_training_activites, raw_test_activites)
colnames(all_activities) <- 'ActivityId'

all_data_set <- rbind(raw_training_set, raw_test_set)
colnames(all_data_set) <- feature_vector


#Merge them all together into a dataframe
raw_master_data <- cbind(all_subjects, all_activities, all_data_set)


#--------------------------------------------------------------------
#STEP 2 - Extract only the measurements on the mean and standard deviation for each measurement. 
#--------------------------------------------------------------------

#Extract all the feature names to a vector
feature_names <- colnames(raw_master_data)                             

#Grep for our subject, activityId and any feature containing the words mean or std, value = false gives us the column index number for easy filtering
column_filter <- grep('SubjectId|ActivityId|mean|std', feature_names, value = FALSE, ignore.case = TRUE)  

#Select all releval columnd based on out filter-
df_mean_std_features <- raw_master_data[, column_filter]


#--------------------------------------------------------------------
# STEP 3 Uses descriptive activity names to name the activities in the data set
#From the activity features.txt
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

#--------------------------------------------------------------------

df_mean_std_features$ActivityId <- sub('1', 'Walking', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('2', 'Walking_upstairs', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('3', 'Walking_downstairs', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('4', 'Sitting', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('5', 'Standing', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('6', 'Laying', df_mean_std_features$ActivityId)

#--------------------------------------------------------------------
#STEP 4 Appropriately label the data set with descriptive variable names.
#--------------------------------------------------------------------
#All columns are already nicely named except ActivityId so it gets renamed to Activity since it no longer refers to a  ID
colnames(df_mean_std_features) [2] <- 'Activity'



#--------------------------------------------------------------------
# STEP 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#--------------------------------------------------------------------

library(dplyr)

tidy_data_set <- df_mean_std_features %>%
  group_by(SubjectId, Activity) %>%
  summarise_all(funs(mean))


write.csv(tidy_data_set, 'final_tidy_data.csv', row.names = FALSE)






