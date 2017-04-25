
setwd("~/breeding/results/pca/")
filelist = list.files(pattern = "pcs.*.txt")

#assuming tab separated values with a header     
data_list = lapply(filelist, read.table, header=FALSE)
names(data_list) <- sub("pcs.", "", filelist)
names(data_list) <- sub(".txt", "", names(data_list))

#read in variation explained
filelist = list.files(pattern = "pve.*.txt")
pve_list = lapply(filelist, read.table, header=FALSE)
names(pve_list) <- sub("pve.", "", filelist)
names(pve_list) <- sub(".txt", "", names(pve_list))

setwd("~/breeding/variants")
namelist = list.files(pattern = "*thinned.fam")
name_list = lapply(namelist, read.table, header=FALSE)

names(data_list)<-filelist
colnames <- c("CHR", "BP", "fst")
data_list <- lapply(data_list, setNames, colnames)

#add sample labels, pop labels, sex

for (i in 1:length(data_list)){
	data_list[[i]]$label <- name_list[[i]]$V1
	data_list[[i]]$cross <- substr(name_list[[i]]$V1,1,9)
	pop <- rep("offspring", length(data_list[[i]]$label))
	pop[grepl("PP", data_list[[i]]$label)] <- c("PP")
	pop[grepl("PL", data_list[[i]]$label)] <- c("PL")
	data_list[[i]]$pop <- pop
	sex <- rep("offspring", length(data_list[[i]]$label))
	data_list[[i]]$sex <- substr(data_list[[i]]$label, 14,14)
	data_list[[i]]$sex <- gsub("^$", "offspring", data_list[[i]]$sex)
}


#######
####### All parents
#######

col.plot <- c( "red", "blue")
shape <- c(1, 19)
#png("~/shm/results/pca_all.png", h=1000, w=1000, pointsize=20)
plot(x=data_list[[1]]$V1[which(data_list[[1]]$sex != "offspring")], 
	y=data_list[[1]]$V2[which(data_list[[1]]$sex != "offspring")],
	col=col.plot[as.factor(data_list[[1]]$pop[which(data_list[[1]]$sex != "offspring")])], 
	pch=shape[as.factor(data_list[[1]]$sex[which(data_list[[1]]$sex != "offspring")])], 
	xlab=paste("PC1:  ", round((pve_list[[1]]*100), 2)[1,1], "%", sep=""), 
	ylab=paste("PC2:  ", round((pve_list[[1]]*100), 2)[2,1], "%", sep=""),
	cex=1, main="All parents")
legend(x="bottomleft", legend = unique(data_list[[1]]$pop)[2:3], col=c("red", "blue"), pch=19)
legend(x="topleft", legend = c("male", "female"), col=c("black", "black"), pch=c(19,1) )


#######
####### BW-Combo1
#######

col.plot <- c("purple", "red", "blue")
shape <- c(1, 19, 19)

for(i in names(data_list)[2:10]){
	pdf(paste(i, ".pdf", sep=""))

	plot(x=data_list[[i]]$V1,
	y=data_list[[i]]$V2,
	col=col.plot[as.factor(data_list[[i]]$pop)],
	pch=shape[as.factor(data_list[[i]]$pop)],
	xlab=paste("PC1:  ", round((pve_list[[i]]*100), 2)[1,1], "%", sep=""),
	ylab=paste("PC2:  ", round((pve_list[[i]]*100), 2)[2,1], "%", sep=""),
	cex=1, main=i)

	dev.off()
}

plot(x=data_list[['BW-Combo1']]$V1,
	y=data_list[['BW-Combo1']]$V2,
	col=col.plot[as.factor(data_list[['BW-Combo1']]$pop)],
	pch=shape[as.factor(data_list[['BW-Combo1']]$pop)],
	xlab=paste("PC1:  ", round((pve_list[['BW-Combo1']]*100), 2)[1,1], "%", sep=""),
	ylab=paste("PC2:  ", round((pve_list[['BW-Combo1']]*100), 2)[2,1], "%", sep=""),
	cex=1, main="BW-Combo1")

legend(x="bottomright", legend = unique(data_list[['BW-Combo1']]$pop), col=c("purple", "red", "blue"), pch=c(1,19,19))




