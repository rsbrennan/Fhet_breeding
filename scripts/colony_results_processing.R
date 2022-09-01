library(ggplot2)

setwd("~/Documents/Breeding_2015/colony/results")

paternitylist = list.files(pattern = "*PairwisePaternity")
maternitylist = list.files(pattern = "*PairwiseMaternity")

pat_list = lapply(paternitylist, read.table, header=TRUE, sep=",")
mat_list = lapply(maternitylist, read.table, header=TRUE, sep=",")

#set column names
names(pat_list)<-paternitylist
colnames <- c("offspring", "father", "confidence")
pat_list <- lapply(pat_list, setNames, colnames)
names(mat_list)<-maternitylist
colnames <- c("offspring", "mother", "confidence")
mat_list <- lapply(mat_list, setNames, colnames)



#####################
#
# all analyzed together
#
#####################

all.dat <- merge(x = pat_list[[1]],
	  y = mat_list[[1]],
	  by="offspring", all=TRUE)
nrow(all.dat)
#2338

# parse down so they have both parents:

all.dat <- (all.dat[(!is.na(all.dat$father)),])
nrow(all.dat)
#2337
all.dat <- (all.dat[(!is.na(all.dat$mother)),])
nrow(all.dat)
#2278


#remove any unassigned indivs
#parentage<- new
parentage <- all.dat

for (i in 1:nrow(parentage)){
	parentage$father_combo[i] <- substr(parentage$father[i], 1,9)
	parentage$mother_combo[i] <- substr(parentage$mother[i], 1,9)
	parentage$offspring_combo[i] <- substr(parentage$offspring[i], 1,9)
	parentage$mother.pop[i] <- substr(parentage$mother[i], 11,12)
	parentage$father.pop[i] <- substr(parentage$father[i], 11,12)
}

which(parentage$father_combo != parentage$mother_combo)
# 0

length(which(parentage$father_combo != parentage$offspring_combo))
# 25 impossible parents.

25/nrow(parentage)

parentage[which(parentage$father_combo != parentage$offspring_combo),]


#look at prop of assignments for each

cross <- unique(parentage$offspring_combo)
parentage$mother.ind <- substr(parentage$mother, 11,16)
parentage$father.ind <- substr(parentage$father, 11,16)
parentage$cross.dir <- paste(parentage$mother.pop, parentage$father.pop, sep="x")
parentage$cross <- paste(parentage$mother.ind, parentage$father.ind, sep="x")

write.table(file="~/Documents/Breeding_2015/colony/results/parentage.assignment.txt", parentage, 
	col.names=TRUE, row.names=FALSE, quote=FALSE)



##### how many parents represented

length(unique(parentage$father))
# 63
length(unique(parentage$mother))
# 74




### separated analysis

#setting names, creating empty litsts, etc.
dat <- substr(paternitylist, 1, 9)
dat[1] <- c("all")
dat.merged <- list()
all.dat <- as.data.frame(matrix(ncol=5))
all.dat <- all.dat[!1,]
colnames(all.dat) <- c("offspring","father", "confidence.x","mother", "confidence.y")



####
#### combine maternity and paternity assignments
#### note that this will only include individuals with sucessful assignments for at least 1 parent.

# combine individual maternity and paternity assignments, by combo
for (i in 2:10){
	 dat.merged[[i]] <- merge(x = pat_list[[paste(dat[i],".colony.PairwisePaternity", sep="")]],
	  y = mat_list[[paste(dat[i],".colony.PairwiseMaternity", sep="")]],
	  by="offspring", all=TRUE)
	 all.dat <- rbind(all.dat, dat.merged[[i]])
}

nrow(all.dat)
#[1] 2296 out of original have at least 1 parent assigned

# parse down so they have both parents:

all.dat <- (all.dat[(!is.na(all.dat$father)),])
nrow(all.dat)
#2233
all.dat <- (all.dat[(!is.na(all.dat$mother)),])
nrow(all.dat)
#2138

####
#### add in all individuals so I can see assignment rate
####
####
# 2638 total indivs that I started with

#this file also includes avg read depth/individual
reads <- read.table("~/Documents/Breeding_2015/all_indivs.avg_depth", header=TRUE)
colnames(reads) <- c("offspring", "depth")

### merge  with reads
#merge combo specific with reads
reads.merged <- merge(x=all.dat, y=reads, by="offspring", all=T)
#merge all together with reads
#reads.all.merged <- merge(x=all.merged, y=reads, by="offspring", all=T)

##assign successful assignments
##

#combo sep
reads.merged$assigned.pat[is.na(reads.merged$father)] <- 0
reads.merged$assigned.pat[!is.na(reads.merged$father)] <- 1
reads.merged$assigned.mat[is.na(reads.merged$mother)] <- 0
reads.merged$assigned.mat[!is.na(reads.merged$mother)] <- 1


#then, assign parentage success (1=success, 0=failure)
reads.merged$assigned.both <- NA
for (i in 1:nrow(reads.merged)){
	if((reads.merged$assigned.pat[i] == 1) &
		(reads.merged$assigned.mat[i] == 1)){
			reads.merged$assigned.both[i] <- 1
	}
	else{reads.merged$assigned.both[i] <- 0}
}

#remove the low indivs I took out
low.rm <- reads.merged[!(as.numeric(reads.merged$depth) < 5),]
new <- low.rm
#new <- low.rm[!grepl("PP",low.rm$offspring),]
#nrow(new)
# 2463
# 88 from PP
##new <- new[!grepl("PL",new$offspring),]
#nrow(new)
# 2367
# 96 from PL
# then
# 2367 remain; 878 have low coverage and were removed.

# how many are assigned?
sum(new$assigned.both ==0)
# 385 No assignments
sum(new$assigned.both ==1)
# [1] 2138
sum(new$assigned.mat ==0)
# 322
sum(new$assigned.pat ==0)
# [1] 290

sum(new$assigned.pat ==0 | new$assigned.mat ==0)
# 385

#median(reads.merged$depth[which(reads.merged$assigned.both ==0)])
#median(reads.merged$depth[which(reads.merged$assigned.both ==1)])

median(new$depth[which(new$assigned.both ==0)])
median(new$depth[which(new$assigned.both ==1)])
mean(new$depth[which(new$assigned.both ==0)])
mean(new$depth[which(new$assigned.both ==1)])

ggplot(reads.merged, aes(x=depth, fill=as.factor(assigned.both), color=as.factor(assigned.both)))+
    geom_histogram(alpha = 0.2, binwidth=2, position="identity") + 
	theme_bw() +
	scale_fill_manual(values=c('red', 'blue'))+
	scale_color_manual(values=c('red', 'blue'))


#plot histogram
a <- ggplot(new, aes(x=depth, fill=as.factor(assigned.both), color=as.factor(assigned.both)))+
    geom_histogram(alpha = 0.2, binwidth=2, position="identity") + 
	theme_bw() +
	scale_fill_manual(values=c('red', 'blue'))+
	scale_color_manual(values=c('red', 'blue'))



#scale_x_continuous(breaks = seq(0, 140, 10))

ggsave("~/Documents/Breeding_2015/figures/assignment_reads_hist.pdf", width=10, height=7, units="in",
	plot=a)


#remove any unassigned indivs
#parentage<- new
parentage <- all.dat

for (i in 1:nrow(parentage)){
	parentage$father_combo[i] <- substr(parentage$father[i], 1,9)
	parentage$mother_combo[i] <- substr(parentage$mother[i], 1,9)
	parentage$offspring_combo[i] <- substr(parentage$offspring[i], 1,9)
	parentage$mother.pop[i] <- substr(parentage$mother[i], 11,12)
	parentage$father.pop[i] <- substr(parentage$father[i], 11,12)
}


#look at prop of assignments for each

cross <- unique(parentage$offspring_combo)
parentage$mother.ind <- substr(parentage$mother, 11,16)
parentage$father.ind <- substr(parentage$father, 11,16)
parentage$cross.dir <- paste(parentage$mother.pop, parentage$father.pop, sep="x")
parentage$cross <- paste(parentage$mother.ind, parentage$father.ind, sep="x")

write.table(file="~/Documents/Breeding_2015/colony/results/parentage.assignment.txt", parentage, 
	col.names=TRUE, row.names=FALSE, quote=FALSE)



##### how many parents represented

length(unique(parentage$father))
# 63
length(unique(parentage$mother))
# 74

# 137 total. out of... 187

length(c(unique(parentage$father),unique(parentage$mother)))
