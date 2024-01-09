library(alloDataR) # remotes::install_github("OmniacsDAO/alloDataR")
library(readr)

## Get Round Data
rdata <- roundDF()
write_csv(rdata[rdata$chainId==42161,],"data/arbRoundsDF.csv")

## Get Project Data
pdata <- chainProjectData(42161)
write_csv(pdata,"data/arbProjectsDF.csv")

## Get Votes Data
vdata <- chainVoteData(42161)
write_csv(vdata,"data/arbVotesDF.csv")