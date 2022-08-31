library(ggplot2)

setwd("~/breeding/summary_files/coverage")
filelist = list.files(pattern = "*depth.txt")

#assuming tab separated values with a header     
data_list = lapply(filelist, read.table, header=FALSE)

names(data_list)<-filelist
colnames <- c("scaffold", "start", "stop", "depth", "num_bases", "size", "Percent")
data_list <- lapply(data_list, setNames, colnames)

#mean of depth for each individual
depth <- sapply(data_list, function(x) mean(x$depth, na.rm=TRUE))
dp <- data.frame(indiv=sapply(strsplit(names(depth), split='.', fixed=TRUE), function(x) (x[1])), depth=depth)

write.table(dp, "~/breeding/summary_files/all_indivs.avg_depth", row.names=FALSE, quote=FALSE)

#add in number of reads
reads <- read.table("~/breeding/summary_files/count.demultiplex.txt", sep=",", header=FALSE)
colnames(reads) <- c("file", "orig")
reads$indiv <- sapply(strsplit(as.character(reads$file), split='_', fixed=TRUE), function(x) (x[1]))
reads$num_reads <- reads$orig/4

all <- merge(reads, dp, by = "indiv", split='.', fixed=TRUE)
all$combo <- substring(all$indiv, 1,9)
all$shape <- c("Offspring")
all$shape[grep('PP', all$indiv)] <- c("Parent")
all$shape[grep('PL', all$indiv)] <- c("Parent")


combo.colors <- c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999")

ggplot(all, aes(x=num_reads, y=depth, color=combo))+
geom_point(aes(shape=all$shape), size=2)+theme_bw() +
scale_color_manual(values=c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999"))

ggsave("~/breeding/summary_files/depth_reads.pdf", width=7, height=7, units="in")

ggplot(all, aes(x=depth, color=combo, fill=combo))+
geom_histogram(binwidth=2)+theme_bw() +
scale_color_manual(values=c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999")) +
scale_fill_manual(values=c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999")) +
scale_x_continuous(breaks = seq(0, 140, 10))

ggsave("~/breeding/summary_files/depth_hist.pdf", width=10, height=7, units="in")


# write individuals to exclude to txt files

low <- dp$indiv[which(dp$depth<5)]
low <- low[grep('PP', low, invert=TRUE)]
low <- low[grep('PL', low, invert=TRUE)]

write.table(as.matrix(low[grep('FW-Combo1', low)]), "~/breeding/scripts/lists/exclude.FW-Combo1.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('FW-Combo2', low)]), "~/breeding/scripts/lists/exclude.FW-Combo2.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('FW-Combo4', low)]), "~/breeding/scripts/lists/exclude.FW-Combo4.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('FW-Combo5', low)]), "~/breeding/scripts/lists/exclude.FW-Combo5.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('BW-Combo1', low)]), "~/breeding/scripts/lists/exclude.BW-Combo1.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('BW-Combo2', low)]), "~/breeding/scripts/lists/exclude.BW-Combo2.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('BW-Combo3', low)]), "~/breeding/scripts/lists/exclude.BW-Combo3.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('BW-Combo4', low)]), "~/breeding/scripts/lists/exclude.BW-Combo4.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
write.table(as.matrix(low[grep('BW-Combo5', low)]), "~/breeding/scripts/lists/exclude.BW-Combo5.txt", row.names=FALSE, quote=FALSE, col.names=FALSE) 
