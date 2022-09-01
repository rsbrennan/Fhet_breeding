parentage <- read.table("~/Documents/Breeding_2015/colony/results/parentage.assignment.txt", header=T)
cross <- unique(parentage$offspring_combo)

# making empty df
out <- as.data.frame(matrix(nrow=(length(unique(parentage$mother)) + length(unique(parentage$father))),
							ncol=9))
colnames(out) <- c("tank", "salinity","indiv", "sex", "pop", "like", "unlike", "like.num", "unlike.num")

# going through and, for each parent, assigning number of like and unlike matings.
for (i in 1:length(cross)){
	combo <- parentage[which(parentage$offspring_combo == cross[i]),]
	mothers <- unique(combo$mother)
	fathers <- unique(combo$father)
	start <- which(is.na(out$tank))[1]-1

	for (indiv in 1:length(mothers)){
		a <- combo[which(combo$mother== mothers[indiv]),]
		like.mate <- which(a$mother.pop == a$father.pop)
		prop.like <- length(like.mate)/nrow(a) 
		unlike.mate <- which(a$mother.pop != a$father.pop)
		prop.unlike <- length(unlike.mate)/nrow(a) 
		out$tank[start+indiv] <- paste(a$mother_combo[1])
		out$salinity[start+indiv] <- substr(a$mother_combo[1], 1,2)
		out$indiv[start+indiv] <- as.character(mothers[indiv])
		out$sex[start+indiv] <- c("f")
		out$pop[start+indiv] <- paste((a$mother.pop[1]))
		out$like[start+indiv] <- prop.like 
		out$unlike[start+indiv] <- prop.unlike
		out$like.num[start+indiv] <- length(like.mate)
		out$unlike.num[start+indiv] <- nrow(a) - length(like.mate)


	}

	print(paste("done with mothers combo ", i ))
	start <- which(is.na(out$tank))[1]-1

	for (indiv in 1:length(fathers)){
		a <- combo[which(combo$father == fathers[indiv]),]
		like.mate <- which(a$father.pop == a$mother.pop)
		prop.like <- length(like.mate)/nrow(a) 
		unlike.mate <- which(a$father.pop != a$mother.pop)
		prop.unlike <- length(unlike.mate)/nrow(a) 
		out$tank[start+indiv] <- paste(a$father_combo[1])
		out$salinity[start+indiv] <- substr(a$father_combo[1], 1,2)
		out$indiv[start+indiv] <- as.character(fathers[indiv])
		out$sex[start+indiv] <- c("m")
		out$pop[start+indiv] <- paste(a$father.pop[1])
		out$like[start+indiv] <- prop.like 
		out$unlike[start+indiv] <- prop.unlike
		out$like.num[start+indiv] <- length(like.mate)
		out$unlike.num[start+indiv] <- nrow(a) - length(like.mate)
	}
	print(paste("done with fathers combo ", i ))

}

# 137 indivs remain...
out$total <- out$like.num + out$unlike.num

nrow(out[which(out$total > 4),])
# 94


write.table(file="~/Documents/Breeding_2015/colony/results/parentage.plotting.txt", out, 
	col.names=TRUE, row.names=FALSE, quote=FALSE)

# number of offspring per individual:

a <- ggplot(out, aes(x=total, fill=as.factor(sex)))+
   geom_histogram(aes(y=..density..),alpha = 0.2, binwidth=2, position="identity", color="black") + 
    #geom_density(alpha = 0.2, binwidth=2, position="identity", color="black") + 
	theme_bw() +
	facet_wrap(~pop, nrow=2) +
	scale_fill_manual(values=c('red', 'blue'))+
	scale_color_manual(values=c('red', 'blue'))

ggsave("~/Documents/Breeding_2015/figures/num_offspring_hist.pdf", width=10, height=7, units="in",
	plot=a)

mean(out$total)
std_mean <- function(x) sd(x)/sqrt(length(x))
std_mean(out$total)

out %>% group_by(sex) %>%
	summarize(Mean = mean(total), std_mean(total))

t.test(out$total[out$sex=="f"],out$total[out$sex=="m"])
# family size:

head(parentage)
unique(parentage$cross)
table(parentage$cross)

mate_ct <- parentage %>% group_by(father, mother) %>% tally()

hist(mate_ct$n, breaks=100)

table(mate_ct$n)
range(mate_ct$n)
mean(mate_ct$n)

std_mean(mate_ct$n)

ggplot(data=mate_ct, aes(x=n, fill=salinity, color=salinity))+
  geom_density( alpha=0.7)

##########
# find number of matings/indiv

mother <- unique(parentage$mother)
father <- unique(parentage$father)

f_df <- as.data.frame(matrix(nrow= length(mother), ncol=2))
colnames(f_df) <- c("id", "num")

for( i in 1:length(mother)){
	tmpdf <- parentage[which(parentage$mother == mother[i]),]
	f_df$id[i]  <- as.character(mother[i])
	f_df$num[i] <- length(unique(tmpdf$father))

}

f_df$salinity <- substr(f_df$id, 1,2)
f_df$pop      <- substr(f_df$id, 11,12)
f_df$tank     <- substr(f_df$id, 4,9)

m_df <- as.data.frame(matrix(nrow= length(father), ncol=2))
colnames(m_df) <- c("id", "num")

for( i in 1:length(father)){
	tmpdf <- parentage[which(parentage$father == father[i]),]
	m_df$id[i] <- as.character(father[i])
	m_df$num[i] <- length(unique(tmpdf$mother))

}

m_df$salinity <- substr(m_df$id, 1,2)
m_df$pop      <- substr(m_df$id, 11,12)
m_df$tank     <- substr(m_df$id, 4,9)

m_df$sex <- c("male")
f_df$sex <- c("female")

both_df <- rbind(m_df, f_df)

range(both_df$num)

both_df %>% group_by(sex) %>%
	summarize(Mean = mean(num), std_mean(num))
both_df %>%
	summarize(Mean = mean(num), std_mean(num))

t.test(m_df$num, f_df$num)

p1 <- ggplot(data=both_df,
      aes(num, group=salinity, color=salinity, fill=salinity),) +
  # plot group values
 geom_histogram(position=position_dodge()) +
 facet_wrap(~sex)
p1
