library(readr)
library(tidyr)
library(dplyr)
library(irr)

rawTags <- read_csv("/Users/xxx/Documents/Domestic_Space/CompositeAnnotationTable_Stacked.csv")

# taggers <- unique(rawTags$annotator)
# 
# passageIDs <- unique(rawTags$passage_id)
# 
# #
# tagsForKA <- as.data.frame(matrix(ncol = length(passageIDs), nrow = length(taggers)))
# rownames(tagsForKA) <- taggers
# colnames(tagsForKA) <- passageIDs
# 
# tagsForKA[5,18]

#just make it look like a format for Krippendorff's alpha
tagsForKA <- select(rawTags, -passage) %>%
pivot_wider(names_from = annotator, values_from = spaceClass) %>%
  t()

#on 8-24, some issues with the passage IDs
#find the duplicates
duplicates <- rawTags %>% 
  group_by(passage_id, annotator) %>%
  dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
  dplyr::filter(n > 1L) 
#this was for when we had ambiguous IDs--fixed now
#get the passage IDs causing issues
# problemPassageIDs <- unique(duplicates$passage_id)
# #remove them for the table
# problemColumns <- unlist(lapply(problemPassageIDs, function(x) {grep(x, tagsForKA[1,])}))
# partialTagsForKA <- tagsForKA[,-problemColumns] 

#but now check for multiple tags of the same passage (caused by Shiny)
cleanTagsForKA <- matrix(as.character(lapply(tagsForKA, function(x){return(x[1])})), nrow = 8)
cleanTagsForKA <- cleanTagsForKA[-1,]
rownames(cleanTagsForKA) <- rownames(tagsForKA)[-1]
cleanTagsForKA[cleanTagsForKA == "NULL"] <- NA
overallKA <- kripp.alpha(cleanTagsForKA, method = "nominal")

#find the IAA if we exclude IDK tags--treat those as abstentions from voting
noIDKs <- cleanTagsForKA
noIDKs[noIDKs == "idk"] <- NA
noIDKsKA <- kripp.alpha(noIDKs, method = "nominal")

#this was for the bad passage IDs
# #calculate Krippendorff's alpha, after a bit more cleaning
# partialTagsForKA <- partialTagsForKA[-1,]
# #partialTagsForKA[partialTagsForKA == "NULL"] <- NA
# #major headaches in making it into a matrix, but this works
# partialTagsAsMatrix <- matrix(as.character(partialTagsForKA), nrow = 7)
# partialTagsAsMatrix[partialTagsAsMatrix == "NULL"] <- NA
# #get the overall Krippendorff's alpha
# overallKA <- kripp.alpha(partialTagsAsMatrix, method = "nominal")

#and the pairwise
agreementMat <- matrix(nrow = nrow(cleanTagsForKA), ncol = nrow(cleanTagsForKA))
for(i in 1:nrow(cleanTagsForKA)){
  for(j in 1:nrow(cleanTagsForKA)){
    agreementMat[i,j] <- (kripp.alpha(cleanTagsForKA[c(i,j),], method = "nominal")$value)
  }
}
pairwiseAgreement <- as.data.frame(agreementMat)
names(pairwiseAgreement) <- rownames(cleanTagsForKA)
rownames(pairwiseAgreement) <- rownames(cleanTagsForKA)

