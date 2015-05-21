# GetCleanData-CourseProject

## Intro
This repository is for the class project of the May 2015 section of the Getting and Cleaning coursera couse. The two files of most interest would be the run\_analysis.R script along with a copy of it's output in a file non-creatively named tidyTable.txt. This files should be identical to the file submitted to the coursera project page which can be directly loaded into R via;

``` 
address<-"http://s3.amazonaws.com/coursera-uploads/user-7e5a904cf39689231a956e28/973501/asst-3/720bfe90ff7611e4a99a8f160649743a.txt"
data<-read.table(url(address), header=T, check.names=F)
View(data)
```

## run\_analysis.R implementation notes
run\_analysis() is the standard entry point for generating the output table specified in the assignment. The flow is basically
- validate that the required data source files are present. 
  - note the code is intended to auto download on demand or if the required files are missing though as of this writing is not and likely will not be implemented by the project due date.
- sequential load the test and the training sets via the following steps
  - read the observations summary table X_test/train.txt
  - set to column names according to features.txt file
  - remove all but the max() and std() columns
  - add a column for the associated subject of the observation
  - add a column for the associated activity, with the conversion from enum to text
- the two tables are then combined via rbind
- finally the required output table is generated and saved to disk

The transform process is broken down into numerous small functions within the script file, most of which can be called directly to evaluate or test different stages of the process.
To allow access to the shaped and target table for further evaluation this function returns a list of two named functions for retriving the tables. The tables can be retrived via

``` results <- run_analysis()
    reshaped <- results$get_reshaped()
    tidy    <- results$get_tidy()
```

## 
