Readme
================

Intro and requirements
----------------------

The dataset was downloaded from <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> <br> The script requires the hardcoded filepaths to be manually changed. <br> Script uses the DPLYR library for summarising the data

Data format
-----------

Two dataset (Test and training), each set contains three files, example from training set below <br>

-   X\_train.txt - contains all the meassured data
-   Y\_train.txt - contains a value of 1-6 whichs corresponds to the activity performed
-   subject\_train.txt - IDs for the subjects

The data also contains the file features.txt which contains all the feature names for the X\_train file <br> <br> Mergin all the data together into a dataframe it will look like below. ![Data frame example](C:\MachineLearning\Courses\Data%20science%20track\Month%203\Week%204\Project\Capture.PNG)

### Load librarys

``` r
library(dplyr)
```

### Tidy up the features names

Read all the lines in the features file and have a peek at the first five elements

``` r
file_path <- "C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\features.txt"
file_con <- file(file_path, open = 'r')

read_file <- readLines(file_con)

read_file[1:5]
```

    ## [1] "1 tBodyAcc-mean()-X" "2 tBodyAcc-mean()-Y" "3 tBodyAcc-mean()-Z"
    ## [4] "4 tBodyAcc-std()-X"  "5 tBodyAcc-std()-Y"

Go Through each line and remove the number and whitespace and save it in a new vector

``` r
n_lines = length(read_file)
feature_vector <- character(n_lines)

for (line_index in 1:n_lines) {
  current_line <- read_file[line_index]                       
  string_to_replace <- paste0(line_index, " ")                
  current_line <- sub(string_to_replace, "", current_line)    
  feature_vector[line_index] <- current_line                  
}

feature_vector[1:5]
```

    ## [1] "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z"
    ## [4] "tBodyAcc-std()-X"  "tBodyAcc-std()-Y"

### Read the training and test set

One line looks like "2.5717778e-001 -2.3285230e-002 -1.4653762e-002....." so reading it in with as a CSV with the sep = "" switch it uses all whitespace as a separator, which solves the issues of all negative numbers only having one whitespace (the - sign taking up one space), while all positive are separated by two

``` r
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\X_train.txt'
raw_training_set <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\X_test.txt'
raw_test_set <- read.csv(test_file_path, sep = "", header = FALSE)
```

### Read in the activites files

``` r
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\Y_train.txt'
raw_training_activites <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\Y_test.txt'
raw_test_activites <-  read.csv(test_file_path, sep = "", header = FALSE)
```

### Read in the test subjects

``` r
training_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\train\\subject_train.txt'
raw_training_subjects <- read.csv(training_file_path, sep = "", header = FALSE)

test_file_path <- 'C:\\MachineLearning\\Courses\\Data science track\\Month 3\\Week 4\\Project\\Data\\test\\subject_test.txt'
raw_test_subjects <-  read.csv(test_file_path, sep = "", header = FALSE)
```

### Join all the datasets together.

Make the labels more descriptive always starting with the training set as the first vector on joining

``` r
all_subjects <- rbind(raw_training_subjects, raw_test_subjects)
colnames(all_subjects) <- 'SubjectId'

all_activities <- rbind(raw_training_activites, raw_test_activites)
colnames(all_activities) <- 'ActivityId'

all_data_set <- rbind(raw_training_set, raw_test_set)
colnames(all_data_set) <- feature_vector


#Merge them all together into a dataframe
raw_master_data <- cbind(all_subjects, all_activities, all_data_set)
```

### STEP 2 - Extract only the measurements on the mean and standard deviation for each measurement.

``` r
#Extract all the feature names to a vector
feature_names <- colnames(raw_master_data)                             

#Grep for our subject, activityId and any feature containing the words mean or std, value = false gives us the column index number for easy filtering
column_filter <- grep('SubjectId|ActivityId|mean|std', feature_names, value = FALSE, ignore.case = TRUE)  

#Select all relevant columns based on out filter
df_mean_std_features <- raw_master_data[, column_filter]
```

### STEP 3 Add activity labels instead of IDs

From the activity features.txt, the ID's correspond to...

-   1 WALKING
-   2 WALKING\_UPSTAIRS
-   3 WALKING\_DOWNSTAIRS
-   4 SITTING
-   5 STANDING
-   6 LAYING

``` r
df_mean_std_features$ActivityId <- sub('1', 'Walking', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('2', 'Walking_upstairs', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('3', 'Walking_downstairs', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('4', 'Sitting', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('5', 'Standing', df_mean_std_features$ActivityId)
df_mean_std_features$ActivityId <- sub('6', 'Laying', df_mean_std_features$ActivityId)

#All columns are already nicely named except ActivityId so it gets renamed to Activity since it no longer refers to a  ID
colnames(df_mean_std_features) [2] <- 'Activity'
```

### Use DPLYR to group by Subject ID and Activity and summarise the mean for all columns not included in the group by

``` r
tidy_data_set <- df_mean_std_features %>%
  group_by(SubjectId, Activity) %>%
    summarise_all(funs(mean))
```

### Save Tidy dataset as CSV

``` r
write.csv(tidy_data_set, 'final_tidy_data.csv', row.names = FALSE)
```
