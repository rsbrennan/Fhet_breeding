
dat <- read.table("~/Documents/Breeding_2015/Breeding_Experiment_ALL_DATA_cleaned.csv", header=TRUE, sep=",")
lib <- as.character(unique(dat$library)[!is.na(unique(dat$library))])
barcodes <- read.table("~/Documents/Breeding_2015/barcode_list.csv", header=TRUE, sep=",")
barcodes$well <- substr(barcodes$Index.ID, 9,11)

#make all indiv numbers 3 digits
dat$indiv<- sprintf("%03d", dat$indiv)
#reformat Label names
dat$Label <- paste(dat$salinity, dat$tank, dat$indiv, sep="-")

#remove indivs not in a library
dat <- (dat[!is.na(dat$library),])

#change wells in dat to match barcode wells.
dat$lib.row <- gsub("^1$", "01", dat$lib.row)
dat$lib.row <- gsub("^2$", "02", dat$lib.row)
dat$lib.row <- gsub("^3$", "03", dat$lib.row)
dat$lib.row <- gsub("^4$", "04", dat$lib.row)
dat$lib.row <- gsub("^5$", "05", dat$lib.row)
dat$lib.row <- gsub("^6$", "06", dat$lib.row)
dat$lib.row <- gsub("^7$", "07", dat$lib.row)
dat$lib.row <- gsub("^8$", "08", dat$lib.row)
dat$lib.row <- gsub("^9$", "09", dat$lib.row)

#add well column
dat$well <- paste(dat$lib.col, dat$lib.row, sep= "")

#create list of empty dataframes
libraries <- replicate(length(lib),(matrix(NA, nrow=96, ncol=7)), simplify=F)
names(libraries)<-lib
libraries <- lapply(libraries, as.data.frame)
libraries <- lapply(libraries, setNames, c("indiv", "lib", "Rad.ID", "rad_sequence", "well", "Rename_RA", "Rename_RB"))
#match wells and barcode, print rename command and write txt file
for (i in 1:length(lib)){
	library.name <- lib[i]
	#pull out the individuals from the library of interest
	indivs <- dat[which(dat$library == library.name),]
	#assign barcode to each individual based on well
	for (y in 1:nrow(indivs)){
		a <- which(indivs$well == barcodes$well[y] )
		libraries[[library.name]]$indiv[y] <- as.character(indivs$Label[a])
		libraries[[library.name]]$lib[y] <- library.name
		libraries[[library.name]]$rad_sequence[y] <- paste("GG", barcodes$Index.Sequence[y], sep="")
		libraries[[library.name]]$rad_sequence[y] <- paste(libraries[[library.name]]$rad_sequence[y], ".fastq", sep="")#add .fastq
		libraries[[library.name]]$well <- indivs$well[a]
		libraries[[library.name]]$Rad.ID <- barcodes$Index.ID[y]
	}
	#generate vector of 's/_RA_ and 's/_RB_
	ra <- rep("'s/_RA_", 96)
	rb <- rep("'s/_RB_", 96)
	read <- c(ra, rb)
	#generate vector of _RA.fastq/' and _RB.fastq/'
	ra.end <- rep("_RA.fastq/'", 96)
	ra.end <- paste(libraries[[library.name]]$indiv,ra.end, sep="") 
	rb.end <- rep("_RB.fastq/'", 96) 
	rb.end <- paste(libraries[[library.name]]$indiv,rb.end, sep="") 
	read.end <- c(ra.end, rb.end)
	#make file name for each
	file.a <- paste(rep("_RA_", 96),libraries[[library.name]]$rad_sequence, sep ="" )
	file.b <- paste(rep("_RB_", 96),libraries[[library.name]]$rad_sequence, sep ="" )
	file.n <- c(file.a, file.b)
	#vector of "rename"
	rn <- rep("rename", 192 )
	#paste together middle expression:
	mid.exp <- paste(read, libraries[[library.name]]$rad_seq, "/", read.end, sep="")
	#paste together all for full expression
	all <- paste(rn, mid.exp, file.n, sep=" ")
	#add to data frame
	libraries[[library.name]]$Rename_RA <- all[1:96]
	libraries[[library.name]]$Rename_RB <- all[97:192]

	#save table
	write.table( libraries[[library.name]], 
		paste("~/Documents/Breeding_2015/scripts/rename/", library.name, ".txt", sep=""),
		row.names=FALSE, quote=FALSE, sep= "\t")
	#save renaming file
	write.table(all, 
		paste("~/Documents/Breeding_2015/scripts/rename/", sub("-lib", "", library.name), ".rename.sh", sep=""),
		row.names=FALSE, quote=FALSE, sep= "\t", col.names=FALSE)
}

