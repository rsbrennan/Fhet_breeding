library(ggplot2)
library(arm)
library(lme4)
library(aod)
library(sjPlot)
library(lsmeans)
library(effects)


######################################################
######################################################
######################################################
##
## NO CHOICE EXPERIMENT
##
######################################################
######################################################
######################################################

############
##
## fertilization- no choice
##
############


dat <-read.csv("~/Documents/Breeding_2015/no_choice/fert.data.binom.csv", header=TRUE)
dat$total <- dat$fert+dat$fail
# calc proportion
dat$prop <- dat$fert/dat$total

#  data are binomial, 
  #  predicting k successes vs n−k failures provided as (k,n−k) tuples
count <- cbind(dat$fert, dat$fail)

# k success, vs n-k success
#here we are modeling the probabliity of fert vs not fert
dat$total <- dat$fert + dat$fail

#######
# get some basic summary stats
# mean and SE
mean(dat$fert/dat$total)
# [1] 0.8978365

sd(dat$fert/dat$total)/sqrt(nrow(dat))
# [1] 0.01057402

# rough plot of data
ggplot(dat, aes(x=Cross, y=total, color=Cross))+
    geom_point() + facet_wrap(~salinity)

##########################
# set up models
m <- glm(count ~ salinity*Cross, 
  data=dat, family=binomial("logit")) 

m2 <- glm(count ~ salinity+Cross, 
  data=dat, family=binomial("logit")) 

m3 <- glm(count ~ Cross, 
  data=dat, family=binomial("logit")) 

anova(m2, m, test = "Chisq")
# p=0.048, so little interaction
anova(m2, m3, test = "Chisq")
# p = 0.06

summary(m); anova(m)
binnedplot(predict(m), resid(m), cex.pts=1, col.int="black") # looks fine
plot(m)

######
# test for main effects here
######
confint(m)
# The order in which the coefficients are given in the table of coefficients is the same as the order of the terms in the model. 

# salinity
wald.test(b = coef(m), Sigma = vcov(m), Terms = 2)
#### X2 = 2.9, df = 1, P(> X2) = 0.086

# cross effect
wald.test(b = coef(m), Sigma = vcov(m), Terms = 3:5)
#X2 = 32.2, df = 3, P(> X2) = 4.8e-07

# interaction
wald.test(b = coef(m), Sigma = vcov(m), Terms = 6:8)
#X2 = 7.8, df = 3, P(> X2) = 0.05

### nice to see that this interactino agree with the anova comparison of the models above.


# plot the model results and output table. 
sjPlot::plot_model(m)
sjPlot:: tab_model(m, show.reflvl = TRUE)

######
# calculate post-hoc differences between groups
######

## effect of cross only:
lsm <- lsmeans(m, ~ Cross)
summary(lsm, type = "response")
plot(lsm, by = "Cross", intervals = TRUE, type = "response")
# can get differences in proportions, rather than log odds, which can be nice.
pairs(regrid(lsm))

## interaction
lsm <- lsmeans(m, ~ salinity*Cross)
summary(lsm, type = "response")
plot(lsm, by = "Cross", intervals = TRUE, type = "response")
# differences in terms of proportions
pairs(regrid(lsm))
pairs(regrid(lsm), by="Cross") # this tells us the interaction effect most clearly.
pairs(regrid(lsm), by="salinity")

# salinity
lsm <- lsmeans(m, ~ salinity)
summary(lsm, type = "response")
plot(lsm, intervals = TRUE, type = "response")
# can get differences in proportions, rather than log odds.
pairs(regrid(lsm))



#############
#plotting results
#############

#Plot model estimates WITH data
effects_est <- effects::effect(term= "salinity*Cross", mod= m)
summary(effects_est) #output of what the values are

# Save the effects values as a df:
effects_df <- as.data.frame(effects_est)

effects_cross <- effects::effect(term= "Cross", mod= m)
summary(effects_cross) #output of what the values are

# Save the effects values as a df:
effects_df <- as.data.frame(effects_est)
effects_cross_df <- as.data.frame(effects_cross)
# change order of x axis

effects_df$Cross <- factor(effects_df$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))
effects_cross_df$Cross <- factor(effects_cross_df$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))
dat$Cross <- factor(dat$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))

#
## calculate max percent reduction here
#### in effects_cross_df, 
(effects_cross_df$fit[1]-effects_cross_df$fit[3])/effects_cross_df$fit[1]
#### to get actual reduction, see lsmeans results from "effect of cross only", above

p1 <- ggplot() +
  # plot group values
 geom_errorbar(data=effects_df,
      aes(x=Cross, ymin=lower, ymax=upper, 
          group=salinity),
           colour="black", width=.2, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_df, aes(x=Cross, y=fit, 
        group=salinity, fill= salinity,shape=salinity),
    position=position_dodge(width=0.7), 
    color="black", size=4)+
  # plot indiv points
  geom_point(data=dat, aes(Cross,prop, fill= salinity,shape=salinity),
        position=position_jitterdodge(dodge.width=0.7, jitter.width=0.2),
        size=2.5, alpha=0.2, show.legend = F)+
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_shape_manual(values=c(21, 22))+
  #plot total cross avg.
 geom_errorbar(data=effects_cross_df,
      aes(x=Cross, ymin=lower, ymax=upper), 
           colour="black", width=.1, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_cross_df, aes(Cross,fit),
        fill="grey45", shape=24,
        position=position_dodge(width=0.7),
        size=3, show.legend = F) +
  theme_bw() +
  labs(y="proportion fertilized", x="") +
  guides(colour=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylim(0.55, 1)

p1

ggsave("~/Documents/Breeding_2015/Figures/revised/fertilization_prop.png",
        p1, h=3, w=5)

########################################################################
########################################################################
######### hatch data. NO choice
########################################################################
########################################################################

dat <-read.csv("~/Documents/Breeding_2015/no_choice/hatch.data.binom.csv", header=TRUE)

count <- cbind(dat$hatch, (dat$total-dat$hatch))
dat$prop <- dat$hatch/dat$total
mean(dat$hatch/dat$total)
# [1] 0.8407171
sd(dat$hatch/dat$total)/sqrt(nrow(dat))
# [1] 0.02010307

# reoder levels so things are easier to interpret
dat$Cross <- as.factor(dat$Cross)
dat$Cross <- factor(dat$Cross, 
        levels = c("PLxPL", "PPxPP", "PLmXPPf" ,"PPmXPLf"))

m <- glm(count ~ salinity*Cross, 
  data=dat, family=binomial("logit")) 

m2 <- glm(count ~ salinity+Cross, 
  data=dat, family=binomial("logit")) 

anova(m2, m, test = "Chisq")
# p = 0.02338, so interaction.

summary(m); anova(m)
binnedplot(predict(m), resid(m), cex.pts=1, col.int="black") # looks fine
plot(m)

# viaualize results
sjPlot::plot_model(m)
sjPlot:: tab_model(m)


# which main effects are sig?
confint(m) # gives order

# salinity
wald.test(b = coef(m), Sigma = vcov(m), Terms = 2)
# X2 = 46.9, df = 1, P(> X2) = 7.5e-12
# cross
wald.test(b = coef(m), Sigma = vcov(m), Terms = 3:5)
#X2 = 17.1, df = 3, P(> X2) = 0.00066
# interaction
wald.test(b = coef(m), Sigma = vcov(m), Terms = 6:8)
# X2 = 8.8, df = 3, P(> X2) = 0.032

######
# calculate post-hoc differences between groups
######

# interaction
lsm <- lsmeans(m, ~ salinity*Cross)
summary(lsm, type = "response")
plot(lsm, by = "Cross", intervals = TRUE, type = "response")
# can get differences in proportions, rather than log odds, which can be nice.
pairs(regrid(lsm))
pairs(regrid(lsm), by="Cross")
pairs(regrid(lsm), by="salinity")

# cross
lsm <- lsmeans(m, ~ Cross)
#lsm <- lsmeans(m, pairwise ~ Cross | salinity)
summary(lsm, type = "response")
plot(lsm, intervals = TRUE, type = "response")
# can get differences in proportions, rather than log odds.
pairs(regrid(lsm))

# salinity
lsm <- lsmeans(m, ~ salinity)
summary(lsm, type = "response")
plot(lsm, intervals = TRUE, type = "response")
# can get differences in proportions, rather than log odds.
pairs(regrid(lsm))


#############
#plotting results
#############

#Plot model estimates WITH data
effects_est <- effects::effect(term= "salinity*Cross", mod= m)
summary(effects_est) #output of what the values are

# Save the effects values as a df:
effects_df <- as.data.frame(effects_est)

effects_cross <- effects::effect(term= "Cross", mod= m)
summary(effects_cross) #output of what the values are

# Save the effects values as a df:
effects_df <- as.data.frame(effects_est)
effects_cross_df <- as.data.frame(effects_cross)

# Use the effects value df (created above) to plot the estimates
dat$prop <- dat$hatch/(dat$total)
## calculate max percent reduction here
#### in effects_cross_df, 
(effects_cross_df$fit[1]-effects_cross_df$fit[3])/effects_cross_df$fit[3]
#### to get actual reduction, see lsmeans results from "effect of cross only", above


# change order of x axis

effects_df$Cross <- factor(effects_df$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))
effects_cross_df$Cross <- factor(effects_cross_df$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))
dat$Cross <- factor(dat$Cross, levels = c("PLxPL", "PLmXPPf", "PPmXPLf","PPxPP"))

# plot

p2 <- ggplot() +
  # plot group values
 geom_errorbar(data=effects_df,
      aes(x=Cross, ymin=lower, ymax=upper, 
          group=salinity),
           colour="black", width=.2, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_df, aes(x=Cross, y=fit, 
        group=salinity, fill= salinity,shape=salinity),
        position=position_dodge(width=0.7),
        color="black", size=4)+
  # plot indiv points
  geom_point(data=dat, aes(Cross,prop, fill= salinity,shape=salinity),
        position=position_jitterdodge(dodge.width=0.7, jitter.width=0.2),
        size=2.5, alpha=0.2, show.legend = F)+
    scale_fill_manual(values=c("firebrick3", "dodgerblue4"))+
    scale_shape_manual(values=c(21, 22))+
  #plot total cross avg.
 geom_errorbar(data=effects_cross_df,
      aes(x=Cross, ymin=lower, ymax=upper), 
           colour="black", width=.1, 
           position=position_dodge(width=0.7)) +
  geom_point(data=effects_cross_df, aes(Cross,fit),
        fill="grey45", shape=24,
        position=position_dodge(width=0.7),
        size=3, show.legend = F) +
  theme_bw() +
  labs(y="proportion hatched", x="") +
  guides(colour=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ylim(0.55, 1)

ggsave("~/Documents/Breeding_2015/Figures/revised/hatching_prop.png",
        p2, h=3, w=5)


# save combined figure

ggsave(filename="~/Documents/Breeding_2015/Figures/revised/no_choice.pdf",
        ggarrange(p1,p2, labels=c("A", "B"), common.legend=T, legend="bottom"),
          height=3.5, width=7)




############################################################################################################
######################################################
######################################################
##
##  CHOICE EXPERIMENT
##
######################################################
######################################################
############################################################################################################

# here, we want to make sure that all individuals are reproducing so that we can be sure that the choice epxeirment actually had potential for reproduction

dat <- read.csv("~/Documents/Breeding_2015/BreedingExpPlottingData.csv")

# mean and SE
mean(dat$Total.Fertilized/dat$Total.Eggs)
# [1] 0.8719661

sd(dat$Total.Fertilized/dat$Total.Eggs)/sqrt(nrow(dat))
# [1] 0.0152863

# mean and SE
mean(dat$Total.Hatch/dat$Total.Fertilized)
# [1] 0.8719661

sd(dat$Total.Hatch/dat$Total.Fertilized)/sqrt(nrow(dat))
# [1] 0.0152863

mean(dat$Total.Eggs)
sd(dat$Total.Eggs)/sqrt(nrow(dat))


std_mean <- function(x) sd(x)/sqrt(length(x))

dat$Pop <- as.factor(dat$Pop)

dat %>% group_by(as.factor(Pop), as.factor(Salinity)) %>%
  summarize(Mean = mean(Hatching.Success), std_mean(Hatching.Success))


idx <- which(dat$Pop == "PP")
mean(dat$Fertilization.Success[idx])
#[1] 0.829409
sd(dat$Fertilization.Success[idx])/sqrt(length(idx))
#[1] 0.03715401

idx <- which(dat$Pop == "PL")
mean(dat$Fertilization.Success[idx])
#[1] 0.8495635
sd(dat$Fertilization.Success[idx])/sqrt(length(idx))
#[1] 0.0228749

idx <- which(dat$Pop == "Combo")
mean(dat$Fertilization.Success[idx])
#[1] 0.9152724
sd(dat$Fertilization.Success[idx])/sqrt(length(idx))
# 0.01194578

idx <- which(dat$Pop == "PP")
mean(dat$Hatching.Success[idx])
#[1] 0.7633333
sd(dat$Hatching.Success[idx])/sqrt(length(idx))
#[1] 0.057658

idx <- which(dat$Pop == "PL")
mean(dat$Hatching.Success[idx])
#[1] 0.7433333
sd(dat$Hatching.Success[idx])/sqrt(length(idx))
#[1] 0.05771578

idx <- which(dat$Pop == "Combo")
mean(dat$Hatching.Success[idx])
#[1] 0.7355556
sd(dat$Hatching.Success[idx])/sqrt(length(idx))
# 0.03325454
