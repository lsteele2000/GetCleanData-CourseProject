
# run_analysis.R
#   Getting and Cleaning Data course project script
#   Project Instructions:
#   Create one R script called run_analysis.R that does the following: 
#       1.) Merges the training and the test sets to create one data set.
#       2.) Extracts only the measurements on the mean and standard deviation 
#           for each measurement. 
#       3.) Uses descriptive activity names to name the activities in the data set
#       4.) Appropriately labels the data set with descriptive variable names. 
#       5.) From the data set in step 4, creates a second, independent tidy data set 
#           with the average of each variable for each activity and each subject.
#
#   Raw dataset location:
#           "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#       
#   Pending:
#       automated download support pending investigation of unzipping within R.

require( dplyr )


# data set location defaults
data_set_url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
local_dir <- "UCI HAR Dataset"


run_analysis <- function() {
    validate_raw_dataset()
    test_set = load_and_shape_dataset("test")   # load and shape the test set
    train_set = load_and_shape_dataset("train") # load and shape the training set
    reshaped = rbind( test_set, train_set )     # combine into one table by appending the row (returning the rbind result)
    tidy = create_tidy( reshaped )
    write_tidy( tidy )

    get_reshaped <- function() reshaped
    get_tidy     <- function() tidy 
    list( get_reshaped = get_reshaped, get_tidy = get_tidy )
}

create_tidy <- function( x ) {
    tidy<-group_by( x, subjectid, activity ) %>% summarise_each(funs(mean), -(subjectid:activity) )
    reformat <- function(x) { 
        preface = ifelse( grepl("subject|activity",x), "", "meanof-")
        sprintf( "%s%s", preface, x )
    }
    colnames(tidy) <- sapply( colnames(tidy), reformat)
    tidy
}

write_tidy <- function( x, fileName="tidyTable.txt" ) {
    write.table( x, fileName, row.names=F )
}

load_and_shape_dataset <- function(type,root=local_dir) {
  t1 <- tbl_df( read.table( data_file_path( type, root) ) )
  t1 <- apply_source_column_names( t1 )
  t1 <- select_required_data_fields( t1 )
  t1 <- add_subjects( t1, type )
  t1 <- add_activities( t1, type )
}

# set the column names to the original labels
apply_source_column_names <- function( raw_tbl, root=local_dir ) {
  feature_names = load_feature_labels( root  )
  if ( length(feature_names) != ncol(raw_tbl) )
  {
    simpleError( "dimension of feature label set does not match the dimension of data set")
  }
  colnames(raw_tbl) <- feature_names    # [,2]
  raw_tbl
}

add_subjects <- function( tbl, dataSet, root=local_dir ) {
    subjects <- load_subjects( dataSet, root )
    colnames(subjects)<- 'subjectid'
    cbind(subjects, tbl)
}

add_activities <- function( tbl, dataSet, rool=local_dir ) {
    labels<-load_activity_labels()
    labels<-sapply( labels, function(x) tolower( sub("_"," ", x) ) ) 
    activity_set<- load_activities( dataSet )
    activity<- sapply( activity_set$V1, function(x) labels[x,2]) 
    cbind( activity, tbl )
}

select_required_data_fields <- function(raw_tbl) {
  raw_tbl[ grep('std\\(\\)|mean\\(\\)',names(raw_tbl)) ]
}

validate_raw_dataset <- function( root = local_dir, remote = data_set_url, force_download = FALSE ) {
    if ( force_download
         || !file.exists( root ) 
         || !file.exists( activity_labels_file_path( root ) )
         || !file.exists( features_labels_file_path( root ) )
         || !file.exists( subject_file_path("test", root) )
         || !file.exists( subject_file_path("train", root) )
         || !file.exists( activity_file_path("test", root) )
         || !file.exists( activity_file_path("train", root) )
         || !file.exists( data_file_path("test", root) )
         || !file.exists( data_file_path("train", root))
        )
    {
        simpleError( sprintf("Automated download pending implementation. Manually download \"%s\" and unzip into \"%s\" under the current directory", data_set_url, local_dir) )
    }
}

load_feature_labels <- function( workingdir = local_dir, original=TRUE ) {
    labels <- read.table( features_labels_file_path( workingdir  ),stringsAsFactors=FALSE)
# if not modifying use an id function, for return type consistency we'll always return the sapply result
    if ( original )
    {
        label_processor<-function(x) x      # id function
    }
    else
    {
        label_processor <- function(x) {
            # placeholder function, flush out to complete any label transforms desired
            if ( grepl( "mean\\(\\)|std\\(\\)", x) )
            {   # ignore unless it's a mean() or std() label
                x<-tolower(x)
            }
            x
        }
    }
    sapply(labels$V2,label_processor)
}

features_labels_file_path <- function( working_dir = local_dir ) {
    file.path( working_dir, "features.txt" )
}

load_activity_labels <- function( workingdir = local_dir ) {
    read.table( activity_labels_file_path( workingdir ) )
}

activity_labels_file_path <- function( working_dir = local_dir ) {
    file.path( working_dir, "activity_labels.txt" )
}

load_activities <- function( dataSet, working_dir=local_dir ) {
    read.table( activity_file_path(dataSet,working_dir) )
}

activity_file_path <- function( dataSet, working_dir=local_dir ) {
    file.path( working_dir, dataSet, sprintf("y_%s.txt",dataSet) )
}

load_subjects <- function( dataSet, working_dir=local_dir ) {
    read.table( subject_file_path( dataSet, working_dir ) )
}

subject_file_path <- function( dataSet, working_dir=local_dir ) {
    file.path( working_dir, dataSet, sprintf("subject_%s.txt",dataSet) )
}

data_file_path <- function( dataSet, working_dir=local_dir ) {
    file.path( working_dir, dataSet, sprintf("X_%s.txt",dataSet) )
}

# Exploratory function to validate that there's indices in the test and train subject
#   files are unique.
validate_unique_subjects<-function( working_dir=local_dir) {
    tbl <- read.table( subject_file_path( "test" ) )
    test_subjects <- group_by( tbl, V1 ) %>% summarize( n() ) 
    print( test_subjects, n=30 )
    tbl <- read.table( subject_file_path( "train" ) )
    train_subjects <- group_by( tbl, V1 ) %>% summarize( n() )
    print( train_subjects, n=30 )
    overlap <- intersect( test_subjects$V1, train_subjects$V1 )
    if ( length(overlap) != 0 )
    {
        print( "Overlap detected between training and test subject indices" )
        print( overlap )
    }
    print( "Test subject indices" )
    print( setdiff( test_subjects$V1, train_subjects$V1 ) )
    print( "Train subject indices" )
    print( setdiff( train_subjects$V1, test_subjects$V1 ) )

}
