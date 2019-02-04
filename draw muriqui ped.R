library(kinship2)
library(xlsx)

d <- read.xlsx(file="~/Dropbox/My Dropbox/Muriqui Paternity/muriqui paternity.xlsx",sheetIndex=1)
d
p <- pedigree(id=d$OFFSPRING,dadid=d$DAD,momid=d$MOM, sex=d$SEX)

ped<-plot.pedigree(p, mar = c(2, 1, 8.5, 1))

kin <- kinship(p)
