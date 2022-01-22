library(readr)
library(stringr)
library(dplyr)
library(tidyr)
datafile <- file.choose()
alldata <- read_tsv(datafile, col_names = TRUE, col_types = NULL,
         locale = default_locale(), na = c("", "NA"), comment = "",
         trim_ws = TRUE, skip = 0, n_max = -1, progress = interactive())
d <- unique(alldata)
d <- d[,c(1:15,17,30)]
# correct mispellings
d$`Sample File` <- str_replace(d$`Sample File`,"negavite","negative")
# shorten unique names
d$`Sample File` <- str_replace(d$`Sample File`,"M-AD-RP2-","M")
# str(d)
# head(d,200)
# separate out individual names
d$Individual <- str_to_upper(word(d$`Sample File`, start = 1L, sep = "[-|_]"))
individuals <- as.data.frame(unique(d$Individual))
d <- arrange(d, `Individual`, `Marker`)
d$ID<-seq.int(nrow(d))
d <- d[c("ID", "Individual", "Sample File", "Sample Name", "Panel", "Marker", "Dye",
         "Allele 1", "Size 1", "Height 1", "Peak Area 1",
         "Allele 2", "Size 2", "Height 2", "Peak Area 2",
         "AE", "GQ")]
markers <- as.data.frame(unique(d$Marker))
write_csv(markers, "~/Desktop/markers.csv", na = "NA", append = FALSE, col_names = TRUE)
write_csv(individuals, "~/Desktop/individuals.csv", na = "NA", append = FALSE, col_names = TRUE)
write_csv(d, "~/Desktop/genotypes.csv", na = "NA", append = FALSE, col_names = TRUE)

d <- select(d,-c(`Sample File`,`Panel`, `Dye`, `AE`, `GQ`))
d <- group_by(d, `Individual`, `Marker`)
d <- na.omit(d)
d$A1 <- d$`Allele 1`
d$A2 <- d$`Allele 2`
d <- unite(d, `Genotype`, A1, A2, sep = "/")
d <- select(d,-c(`Size 1`, `Size 2`, `Height 1`, `Height 2`, `Peak Area 1`, `Peak Area 2`))

# genotype counts by individual
g <- select(d, -c(`Allele 1`,`Allele 2`))
g <- group_by(g, `Individual`, `Marker`, `Genotype`)
g <- arrange(g, `Individual`, `Marker`, `Genotype`)
g <- summarise(g, count=n())

# allele counts by individual
i <- gather(d, Allele, Value, `Allele 1`, `Allele 2`)
i <- group_by(i, `Individual`, `Marker`, `Value`)
i <- arrange(i, `Individual`, `Marker`, `ID`)
i <- summarise(i, count=n())
