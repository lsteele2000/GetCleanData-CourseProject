# GetCleanData-CourseProject

## Intro
This repository is for the class project of the May 2015 section of the Getting and Cleaning coursera couse. The two files of most interest would be the run\_analysis.R script along with a copy of it's output in a file non-creatively named tidyTable.txt. This files should be identical to the file submitted to the coursera project page which can be directly loaded into R via;

``` 
address<-"http://s3.amazonaws.com/coursera-uploads/user-7e5a904cf39689231a956e28/973501/asst-3/720bfe90ff7611e4a99a8f160649743a.txt"
data<-read.table(url(address), header=T, check.names=F)
View(data)
```

## Full disclosure
In all honesty, this readme (and the whole repository) is for those random peers which were assigned to review the fruits of my labor and should be read as such.

## Why did you (meaning I)  ... 
Q. only select columns from the original table that had mean() or std() in the label when other fields looked like means ? 
A. the goal project is abstract and I took the easy way out, seriously though that seems most appropriate ...

Q. Use such abominable column labels
A. See the 'Is tidyTbl.txt tidy?' section

## Is tidyTbl.txt tidy?
I would argue it meets the critria. Columns labels are names only. Each column relates to one and only one variable. No variables are repeated across rows or columns. The table holds no unrelated variables.   

Objections will likely be made about my choice of labels for the columns, in particular the use/retention of mixed/camel case and non-alpha characters. It's understood that this goes against the party line from the class however 
  1 the original labels, of which most columns of the tidy table are means, have a consistent naming convention which conveys meaning well
  2 the benefit of maintaining simplified back reference to the original columns outweighed any perceived benefits from reformatting, particularly taking scripting into account
  3 all renaming conventions envision made the label much more obscure
  99 (as an aside) the argument that variables should be changed to be all lowercase and underscores/hypens removed so that bugs are reduced is an (imo) arbitrary and misguided attempt to patch weakness in R which allow room for such.

## Is the transform from the original dataset to the tidyTbl.txt correct ?
I'm glad you asked. R seems to have traps for the unwary. I believe it's correct. All steps were implemented within the script so that each stage could be examined and validated. Checks were made against raw data both within R and by external scripting, (at least one such perl script should be in the repo. I've yet to hear R and unit test framework mentioned in the same sentence but probably because I haven't been hanging out in the right crowds.
        
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

