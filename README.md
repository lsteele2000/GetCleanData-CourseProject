# Get and Clean Data Course Project 

## Intro
This readme (and the whole repository) is for those random folks which were choosen to peer review and should be read as such ...


This repository is for the course project of the May 2015 section of the Getting and Cleaning coursera source. The two files of most interest would be the run\_analysis.R script along with a copy of it's output in a file non-creatively named tidyTable.txt. 

The TidyTbl.txt file should be identical to the file submitted to the coursera project page which can be directly loaded into R via the following code, *note the use of check.names=FALSE to prevent the load from mucking with the column label*.

``` 
address<-"http://s3.amazonaws.com/coursera-uploads/user-7e5a904cf39689231a956e28/973501/asst-3/720bfe90ff7611e4a99a8f160649743a.txt"
data<-read.table(url(address), header=T, check.names=F)
View(data)
```

## Why did you (meaning I)  ... 
* Q: Not comment the script sufficiently
* A: I seldom comment my code, preferring to let the code speak for itself. I had planned to make an exception for the peer reviewing but honestly forgot about it until right this moment and doubt I'll have time to go back and add them.

* Q: only select columns from the original table that had mean() or std() in the label, other fields looked like means
* A: the requirements were abstract and I took the easy way out, seriously though that seems most appropriate ...

* Q: Use such abominable column labels
* A: See the 'Is tidyTbl.txt tidy?' section

## Is tidyTbl.txt tidy?
I would argue it meets the critria. 
* Columns labels are names only. 
* Each column relates to one and only one variable. 
* No variables are repeated across rows or columns. 
* The table holds no unrelated variables.   

Objections will likely be made about my choice of labels for the columns, in particular the use/retention of mixed/camel case and non-alpha characters. It's understood that this goes against the party line from the class however 
* the original labels, of which most columns of the tidy table are means, have a consistent naming convention which conveys meaning well
* it was considered worthwhile to maintain easy of back reference to the original columns, particularly taking scripting into account
* all renaming conventions envision made the label much more obscure
* (as an aside) the argument that variables should be changed to be all lowercase and underscores/hypens removed so that bugs are reduced is an (imo) arbitrary and misguided attempt to patch weakness in R which allow room for such.

## Is the transform from the original dataset to the tidyTbl.txt correct ?
I'm glad you asked. R seems to have traps for the unwary. I believe it's correct. 
* All steps in the script were implemement so that each stage could be independently examined and validated. 
* Checks were made against raw data both within R and by external scripting, (at least one such perl script should be in the repo. 
* as an aside, I've yet to hear R and unit test framework mentioned in the same sentence but probably because I haven't been hanging out in the right crowds.
        
## Analysis script (run\_analysis.R) implementation notes
run\_analysis() is the standard entry point for generating the output table specified in the assignment. The flow is basically
- validate that the required data source files are present. 
  - note the code is intended to auto download on demand or if the required files are missing though as of this writing is not and likely will not be implemented by the project due date.
- sequentially load the test and the training sets via the following steps
  - read the observations summary table X_test/train.txt
  - set the observation column names according to features.txt file
  - remove all but the required max() and std() columns
  - add a column for the associated subject to each observation
  - add a column for the associated activity to each observation in text format
- the two tables are then combined via rbind
- finally the required output table is generated and saved to disk

The transform process is broken down into numerous small functions within the script file, most of which can be called directly to evaluate or test different stages of the process.
To allow access to the shaped and target table for further evaluation this function returns a list of two named functions for retriving the tables. The tables can be retrived via

```
    results <- run_analysis()
    reshaped <- results$get_reshaped()
    tidy    <- results$get_tidy()

```

