eigen <- data.frame(read.table("~/Documents/Breeding_2015/all.parent.eigenvec", header=TRUE, skip=0, sep=" "))
rownames(eigen) <- eigen[,2]

eigen$pop <- substring(as.character(eigen$FID),11,12)

# get % variance explained

eigenval <- data.frame(read.table("~/Documents/Breeding_2015/all.parent.eigenval", header=FALSE, skip=0, sep=" "))
eigenval$V1[1]/sum(eigenval$V1)
eigenval$V1[2]/sum(eigenval$V1)


col.plot <- c( "firebrick3", "dodgerblue4")

png("~/breeding/figures/pca.png", h=3.15, w=3.15, units="in", res=300)

#par(mar=c(1,1,1,1))
par(mar=c(3, 3, 1.7, 1), mgp=c(3, 1, 0), las=0)
plot(x = eigen$PC1, y = eigen$PC2,
	bg=col.plot[as.factor(eigen$pop)],
	xlab="",
	ylab="",
	pch=c(21, 24)[as.factor(eigen$pop)],
	main="", 
	cex=1.4,
	lwd=1,     xaxt="n",yaxt="n")

axis(1, mgp=c(2, .5, 0), cex.axis=0.7) # second is tick mark labels
axis(2, mgp=c(2, .5, 0), cex.axis=0.7)

title(xlab="PC1: 28%", line=2, cex.lab=0.9)
title(ylab="PC2: 5%", line=2, cex.lab=0.9)

legend(x="topright", legend = c( "BW-native", "FW-native"), 
	pch=c(21, 24),
	pt.bg=col.plot,
	pt.cex=1.6, cex=0.9)
dev.off()
# pl = red, pp = blue

