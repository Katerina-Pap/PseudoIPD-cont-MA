
# R code supplementing One-stage random effects meta-analysis using linear mixed models for aggregate continuous outcome data
# Author: Katerina Papadimitropoulou
# Date: October 2019
#-----------------------------------------------------------------------------------------------------------------------------

# Load data: example iron levels 
data.wide <- read.table("iron.txt", header=TRUE)

# Make long format
data.long <- reshape(data.wide, direction='long', 
                             varying = list(
                                  c('m1i',	'm2i'),
                                  c('sd1i','sd2i'),
                                  c('n1i',	'n2i')),
                             timevar='group',
                             times=c(0,1),
                             v.names=c('mean','sd','n'),
                             idvar='study')
#-----------------------------------------------------------------------------------------------------------------------------

# Generate IPD
# First expand dataset and generate observations from a standard N(0,1) distribution.

data.IPD <- data.frame(study = rep(data.long$study, data.long$n),
                       mean  = rep(data.long$mean, data.long$n),
                       sd    = rep(data.long$sd, data.long$n),
                       group = rep(data.long$group, data.long$n))

set.seed(64870236)
data.IPD$ytmp <- rnorm(nrow(data.IPD),0,1)
head(data.IPD)

# Now generate from Y* IPD data with exactly the same mean and sd as in the summary data.
# Calculate mean and sd of Ystar by study and arm.

mean.IPDtmp  <- aggregate(ytmp~group+study, data =data.IPD, mean)
sd.IPDtmp    <- aggregate(ytmp~group+study, data =data.IPD, sd)
names(mean.IPDtmp)[names(mean.IPDtmp) == 'ytmp'] <- 'ytmpmean'
names(sd.IPDtmp)[names(sd.IPDtmp) == 'ytmp']     <- 'ytmpsd'

data.IPD <- merge(data.IPD, mean.IPDtmp, by = c("study", "group"))
data.IPD <- merge(data.IPD, sd.IPDtmp, by= c("study", "group"))

# generate the outcome
data.IPD$y <- data.IPD$mean + (data.IPD$ytmp -data.IPD$ytmpmean) * (data.IPD$sd/data.IPD$ytmpsd)
data.IPD$arm <-  1000* data.IPD$study+ data.IPD$group

#-----------------------------------------------------------------------------------------------------------------------------
# Mixed effects approach
library(nlme)
ctrl <- lmeControl(opt="optim", msMaxIter=100)

#--------------------------------------------------
#         STUDY FIXED AND GROUP FIXED 
#--------------------------------------------------
# model 1
# study and group both fixed
# arm specific variances estimated
m1 <- gls(y~ group + as.factor(study), correlation=corCompSymm(form=~arm|study), weights=varIdent(form=~1|arm), control=ctrl, data.IPD)
summary(m1); intervals(m1)

# model 2
# study and group both fixed
# trial specific variances estimated
m2 <- gls(y~ group + as.factor(study), correlation=corCompSymm(form=~arm|study), weights=varIdent(form=~1|study), control=ctrl, data.IPD)
summary(m2); intervals(m2)

# model 3
# study and group both fixed
# group specific variances estimated
m3 <- gls(y~ group + as.factor(study), correlation=corCompSymm(form=~group|study), weights=varIdent(form=~1|group), control=ctrl, data.IPD)
summary(m3); intervals(m3, which="fixed")

# model 4
# study and group both fixed
# one residual variance
m4 <- gls(y~group +as.factor(study) ,correlation=corCompSymm(form=~1|study), data.IPD)
summary(m4); intervals(m4, which="fixed")

#--------------------------------------------------
#     STUDY FIXED AND GROUP RANDOM
#--------------------------------------------------
# model 1
# study ad group both random
# arm specific variances estimated
ctrl <- lmeControl(opt='optim');
m1 <- lme(y~ group + as.factor(study), random=~group|study, correlation=corCompSymm(form=~arm|study), weights=varIdent(form=~1|arm),control=ctrl, data.IPD)
summary(m1); VarCorr(m1); intervals(m1)

# model 2
# study and group both random
# trial specific variances estimated;
m2 <- lme(y~ group +as.factor(study), random=~ group|study, correlation=corCompSymm(form=~arm|study),weights=varIdent(form=~1|study),control=ctrl, data.IPD)
summary(m2); VarCorr(m2); intervals(m2)

# model 3
# study and group both random
# group specific variances estimated
m3<- lme(y~ group+as.factor(study), random=~ group|study, correlation=corCompSymm(form=~group|study),weights=varIdent(form=~1|group), data.IPD)
summary(m3); VarCorr(m3); intervals(m3)

# model 4
# study and group both random
# one residual variance
m4<- lme(y~ group + as.factor(study), random=~ group|study, correlation=corCompSymm(form=~1|study), data.IPD)
summary(m4); VarCorr(m4); intervals(m4)


#--------------------------------------------------
#     STUDY RANDOM AND GROUP RANDOM
#--------------------------------------------------
# model 1
# study ad group both random
# arm specific variances estimated
ctrl <- lmeControl(opt='optim');
m1 <- lme(y~ group, random=~group|study, correlation=corCompSymm(form=~arm|study), weights=varIdent(form=~1|arm), control=ctrl, data.IPD)
summary(m1); VarCorr(m1); intervals(m1)

# model 2
# study and group both random
# trial specific variances estimated;
m2 <- lme(y~ group, random=~ group|study, correlation=corCompSymm(form=~arm|study), weights=varIdent(form=~1|study), control=ctrl, data.IPD)
summary(m2); VarCorr(m2); intervals(m2)

# model 3
# study and group both random
# group specific variances estimated
m3<- lme(y~ group, random=~ group|study, correlation=corCompSymm(form=~group|study),weights=varIdent(form=~1|group), data.IPD)
summary(m3); VarCorr(m3); intervals(m3)

# model 4
# study and group both random
# one residual variance
m4<- lme(y~ group, random=~ group|study, correlation=corCompSymm(form=~1|study), data.IPD)
summary(m4); VarCorr(m4); intervals(m4)
