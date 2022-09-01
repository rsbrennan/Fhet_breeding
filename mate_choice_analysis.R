
########
# mate choice analysis
########

library(dplyr)
library(plyr)
library(ggplot2)
library(lme4)
library(aod)
library(sjPlot)
library(lsmeans)
library(effects)
library(car)


parentage <- read.table("~/Documents/Breeding_2015/colony/results/parentage.assignment.txt", header=T)

mate_ct <- parentage %>% group_by(father, mother) %>% tally()
mate_ct$salinity <- substr(mate_ct$father, 1,2)



# assign like vs unlike type matings for each parent
## this is just data wrangling. 
fathers <- unique(mate_ct$father)
mothers <- unique(mate_ct$mother)

father_matings <- ddply(mate_ct,.(father),nrow)
mother_matings <- ddply(mate_ct,.(mother),nrow)

father_matings$sex <- "male"
mother_matings$sex <- "female"

colnames(father_matings) <- c("parent", "number_matings", "sex")
colnames(mother_matings) <- c("parent", "number_matings", "sex")

num_matings <- rbind(father_matings,mother_matings)
num_matings$salinity <- substr(num_matings$parent, 1,2)
num_matings$pop <- substr(num_matings$parent, 11,12)


num_matings$like <- NA
num_matings$unlike <- NA


# fathers
for(i in fathers){
  tmp_like <- 0
  tmp_unlike <- 0
  tmpdf <- parentage[which(parentage$father == i),]
  tmp_mother <- unique(tmpdf$mother)
  for(j in tmp_mother){
    tmp_same <- tmpdf[which(tmpdf$mother == j),]
    if(sum(tmp_same$mother.pop == tmp_same$father.pop) > 0){
      tmp_like <- tmp_like +1
    }
    if(sum(tmp_same$mother.pop == tmp_same$father.pop) == 0){
      tmp_unlike <- tmp_unlike +1
    }
  }
  num_matings$like[which(num_matings$parent == i)] <- tmp_like
  num_matings$unlike[which(num_matings$parent == i)] <- tmp_unlike

}

# mothers
for(i in mothers){
  tmp_like <- 0
  tmp_unlike <- 0
  tmpdf <- parentage[which(parentage$mother == i),]
  tmp_father <- unique(tmpdf$father)
  for(j in tmp_father){
    tmp_same <- tmpdf[which(tmpdf$father == j),]
    if(sum(tmp_same$mother.pop == tmp_same$father.pop) > 0){
      tmp_like <- tmp_like +1
    }
    if(sum(tmp_same$mother.pop == tmp_same$father.pop) == 0){
      tmp_unlike <- tmp_unlike +1
    }
  }
  num_matings$like[which(num_matings$parent == i)] <- tmp_like
  num_matings$unlike[which(num_matings$parent == i)] <- tmp_unlike

}


(num_matings$like +num_matings$unlike) == num_matings$number_matings


###############
# stats
###############

parent <- read.table("~/Documents/Breeding_2015/data/parent_data.csv", sep=",", header=TRUE)

parent$indiv <- paste(parent$Salinity, parent$Combo, parent$Population, 
  parent$Sex, parent$Replicate, sep="-" )


parent_size <- merge(num_matings, parent, by.x="parent", by.y="indiv", all.x=T)

nrow(num_matings)
nrow(parent)
nrow(parent_size)

head(parent_size)

# plot number of matings per indiv, by sex
myp <- ggplot(data=parent_size, aes(x=sex, y=number_matings,fill=sex, color=sex))+
  geom_beeswarm(shape=21, color="black", alpha=0.7) +
  geom_boxplot(fill=NA) +
  facet_wrap(~salinity) +
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_color_manual(values=c("firebrick3", "dodgerblue4"))

ggsave("~/Documents/Breeding_2015/Figures/revised/number_matings.png",
        myp, h=3, w=5)

myp <- ggplot(data=parent_size, aes(x=Length.cm., y=number_matings,fill=sex, color=sex))+
  geom_point() +
   geom_smooth(method="lm", show.legend = FALSE) +

    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_color_manual(values=c("firebrick3", "dodgerblue4"))

summary(lm(parent_size$number_matings ~ parent_size$Length.cm.))

ggsave("~/Documents/Breeding_2015/Figures/revised/number_matings_size.png",
        myp, h=3, w=5)


##########
# running logit regression
##########
parent_size$indiv <- parent_size$parent

dat <- read.table("~/Documents/Breeding_2015/colony/results/parentage.plotting.txt", header=TRUE)
dat$indiv <- as.character(dat$indiv)
out <- merge(dat, parent_size, by="indiv")
nrow(out)
# 137 indivs

colnames(out) <- c("indiv", "tank", "salinity", "sex", "pop", colnames(out)[6:ncol(out)])

#remove low indivs:
#out <- out[which(out$total > 4),]
#nrow(out)

out <- out[!is.na(out$Weight.g.),]
nrow(out)
# 132 indivs

out$like.prop <- out$like.y/(out$number_matings)

hist(out$like.prop)
hist(out$total, breaks=50)
table(out$total)

 

myp <- ggplot(data=out, aes(x=Length.cm., y=like.prop,
        ))+
  geom_smooth(method="lm")+
  geom_point(aes(color=pop,fill=pop)) +
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_color_manual(values=c("firebrick3", "dodgerblue4"))

ggsave("~/Documents/Breeding_2015/Figures/revised/likeprop_size.png",
        myp, h=3, w=5)


count <- cbind(out$like.y, out$unlike.y)


# like successes vs unlike, so k success, vs n-k success
# adding in mass as fixed effect
# here we are modeling the probabliity of like vs unlike matings

m <- glmer(count ~ Length.cm.+salinity*pop*sex+(1|tank), 
  data=out, nAGQ=0, family=binomial("logit"), na.action = "na.fail") 
summary(m); anova(m)
#binnedplot(predict(m), resid(m), cex.pts=1, col.int="black") # looks fine
vif(m) # good - no major collinearity
plot(predict(m), resid(m))

# the random effect doesn't have an impact. remove it.

m <- glm(count ~ Length.cm.+salinity*pop*sex, 
  data=out, family=binomial("logit"), na.action = "na.fail") 
summary(m); anova(m)
binnedplot(predict(m), resid(m), cex.pts=1, col.int="black") # looks fine
vif(m) # good - no major collinearity
plot(predict(m), resid(m))

# Proporion of like matings + weights
m2 <- glm(count ~ salinity*pop*sex, 
    data=out, family=binomial("logit"), na.action = "na.fail") # totals are the weights

summary(m2); anova(m2)
vif(m2)
binnedplot(predict(m2), resid(m2), cex.pts=1, col.int="black")
plot(predict(m2), resid(m2))


# Compare with and without weights
anova(m, m2,test="LRT") # 
library(rcompanion)
compareGLM(m, m2)
# size doesn't have an effect
anova(m, m2, test="Chisq")

summary(m2)

#length
wald.test(b = coef(m), Sigma = vcov(m), Terms = 1)


#salinity
wald.test(b = coef(m), Sigma = vcov(m), Terms = 2)
# X2 = 0.00036, df = 1, P(> X2) = 0.98

# cross
wald.test(b = coef(m), Sigma = vcov(m), Terms = 3:5)
#X X2 = 5.5, df = 3, P(> X2) = 0.14
# interaction
wald.test(b = coef(m), Sigma = vcov(m), Terms = 6:8)
# X2 = 5.8, df = 3, P(> X2) = 0.12

#m <- m2
sjPlot::plot_model(m)
sjPlot:: tab_model(m,show.reflvl = TRUE)
sjPlot:: tab_model(m,show.reflvl = TRUE,prefix.labels = "varname", 
        file="~/Documents/Breeding_2015/Figures/revised/full_model.html")

##########
#
# plot results
#
##########

########
## size
########
hist(out$Length.cm, breaks=40) # good

std_mean <- function(x) sd(x)/sqrt(length(x))

out %>% group_by(sex,pop) %>%
  summarize(Mean = mean(Length.cm.), std_mean(Length.cm.))
#  sex   pop    Mean `std_mean(Length.cm.)`
#  <chr> <chr> <dbl>                  <dbl>
#1 f     PL     6.93                 0.0713
#2 f     PP     7.38                 0.0884
#3 m     PL     6.78                 0.0891
#4 m     PP     7.09                 0.112
out %>% group_by(pop) %>%
  summarize(Mean = mean(Length.cm.), std_mean(Length.cm.))
#  pop    Mean `std_mean(Length.cm.)`
#  <chr> <dbl>                  <dbl>
#1 PL     6.85                 0.0572
#2 PP     7.26                 0.0715

mean(out$Length.cm.)
std_mean(out$Length.cm.)

summary(lm(Length.cm. ~ sex*pop, data=out))

myp <- ggplot(data=out, aes(x=pop, y=Length.cm.,
        group=pop,fill=pop, color=pop))+
  geom_beeswarm(shape=21, color="black", alpha=0.7) +
  geom_boxplot(fill=NA) +
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_color_manual(values=c("firebrick3", "dodgerblue4"))

myp

ggsave("~/Documents/Breeding_2015/Figures/revised/length_pops.png",
        myp, h=3, w=5)


########
## rest of the results, salinity, pop, sex
########

#Plot model estimates WITH data
effects_all <- effects::effect(term= "salinity:pop:sex", mod= m)
summary(effects_all) #output of what the values are

effects_salXpop <- effects::effect(term= "salinity:pop", mod= m)
summary(effects_salXpop) #output of what the values are

effects_popXsex <- effects::effect(term= "pop:sex", mod= m)
summary(effects_salXpop) #output of what the values are

effects_cross <- effects::effect(term= "pop", mod= m)
summary(effects_cross) #output of what the values are

effects_sex <- effects::effect(term= "sex", mod= m)
summary(effects_sex) #output of what the values are

effects_salinity <- effects::effect(term= "salinity", mod= m)
summary(effects_salinity) #output of what the values are

# Save the effects values as a df:
effects_all_df <- as.data.frame(effects_all)
effects_salXpop_df <- as.data.frame(effects_salXpop)
effects_popXsex_df <- as.data.frame(effects_popXsex)
effects_cross_df <- as.data.frame(effects_cross)
effects_sex_df <- as.data.frame(effects_sex)
effects_salinity_df <- as.data.frame(effects_salinity)

#Use the effects value df (created above) to plot the estimates
out$prop.like <- out$like.y/(out$like.y + out$unlike.y)
p1 <- ggplot() +
  # plot group values
 geom_errorbar(data=effects_salXpop_df,
      aes(x=pop, ymin=lower, ymax=upper, 
          group=salinity),
           colour="black", width=.1, 
           position=position_dodge(width=0.6)) +
  geom_point(data=effects_salXpop_df, aes(x=pop, y=fit, 
        group=salinity, fill= salinity,shape=salinity),
    position=position_dodge(width=0.6), 
    color="black", size=4)+
  # plot indiv points
  geom_beeswarm(data=out, aes(x= pop,y=prop.like, 
        fill= salinity,shape=salinity, group=salinity),
        dodge.width=0.6,
        size=2.5, alpha=0.2, show.legend = F)+
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_shape_manual(values=c(21, 22))+
  #plot total cross avg.
 geom_errorbar(data=effects_cross_df,
      aes(x=pop, ymin=lower, ymax=upper), 
           colour="black", width=.1, 
           position=position_dodge(width=0.6)) +
  geom_point(data=effects_cross_df, aes(pop,fit),
        fill="grey45", shape=24,
        position=position_dodge(width=0.6),
        size=3, show.legend = F) +
  theme_bw() +
  labs(y="proportion like-type matings", x="") +
  guides(colour=FALSE) +
  ggtitle("Mate choice: salinity x pop")

p1


ggsave("~/Documents/Breeding_2015/Figures/revised/choice_salinity.png",
        p1, h=3, w=5)



## sex x pop


p1 <- ggplot() +
  # plot group values
 geom_errorbar(data=effects_popXsex_df,
      aes(x=pop, ymin=lower, ymax=upper, 
          group=sex),
           colour="black", width=.1, 
           position=position_dodge(width=0.6)) +
  geom_point(data=effects_popXsex_df, aes(x=pop, y=fit, 
        group=sex, fill= sex,shape=sex),
    position=position_dodge(width=0.6), 
    color="black", size=4)+
  # plot indiv points

  geom_beeswarm(data=out, aes(x= pop,y=prop.like, fill= sex,shape=sex, group=sex),
        dodge.width=0.6,
        size=2.5, alpha=0.2, show.legend = F)+
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+


    scale_shape_manual(values=c(21, 22))+
  #plot total cross avg.
 geom_errorbar(data=effects_cross_df,
      aes(x=pop, ymin=lower, ymax=upper), 
           colour="black", width=.1, 
           position=position_dodge(width=0.6)) +
  geom_point(data=effects_cross_df, aes(pop,fit),
        fill="grey45", shape=24,
        position=position_dodge(width=0.6),
        size=3, show.legend = F) +
  theme_bw() +
  labs(y="proportion like-type matings", x="") +
  guides(colour=FALSE) +
  ggtitle("Mate choice: sex x pop")

p1

ggsave("~/Documents/Breeding_2015/Figures/revised/choice_sex.png",
        p1, h=3, w=5)


############################
### need a plot for sex x pop x salinity. perhaps facet.

effects_all_df$sex <- as.character(effects_all_df$sex)
effects_all_df$sex[which(effects_all_df$sex == "f")] <- "Female"
effects_all_df$sex[which(effects_all_df$sex == "m")] <- "Male"
out$sex <- as.character(out$sex)
out$sex[which(out$sex == "f")] <- "Female"
out$sex[which(out$sex == "m")] <- "Male"

effects_all_df$pop <- as.character(effects_all_df$pop)
effects_all_df$pop[which(effects_all_df$pop == "PL")] <- "BW-native"
effects_all_df$pop[which(effects_all_df$pop == "PP")] <- "FW-native"
out$pop <- as.character(out$pop)
out$pop[which(out$pop == "PL")] <- "BW-native"
out$pop[which(out$pop == "PP")] <- "FW-native"
effects_salXpop_df$pop <- as.character(effects_salXpop_df$pop)
effects_salXpop_df$pop[which(effects_salXpop_df$pop == "PL")] <- "BW-native"
effects_salXpop_df$pop[which(effects_salXpop_df$pop == "PP")] <- "FW-native"


p1 <- ggplot() +
  # plot group values
  geom_beeswarm(data=out, aes(x= salinity,y=prop.like, fill= sex,shape=sex),
        dodge.width=0.7,
        size=2.5, alpha=0.2, show.legend = F, cex=2.5)+
 geom_errorbar(data=effects_all_df,
      aes(x=salinity, ymin=lower, ymax=upper, 
          group=sex),
           colour="black", width=.2, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_all_df, aes(x=salinity, y=fit, 
        group=sex, fill= sex,shape=sex),
    position=position_dodge(width=0.7), 
    color="black", size=4)+
  facet_wrap(~pop) +
  # plot indiv points

    scale_fill_manual(values=c("darkorange1", "darkorchid3"))+
    scale_shape_manual(values=c(21, 22))+
  #plot total cross avg.
 geom_errorbar(data=effects_salXpop_df,
      aes(x=salinity, ymin=lower, ymax=upper), 
           colour="black", width=.1, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_salXpop_df, aes(salinity,fit),
        fill="grey45", shape=24,
        position=position_dodge(width=0.7),
        size=3, show.legend = F) +
  theme_bw() +
  labs(y="proportion like-type matings", x="Salinity") +
  guides(colour=FALSE) 

p1

ggsave("~/Documents/Breeding_2015/Figures/revised/choice_all.pdf",
        p1, h=3, w=6)

ggsave("~/Documents/Breeding_2015/Figures/revised/choice_all.png",
        p1, h=3, w=6)

