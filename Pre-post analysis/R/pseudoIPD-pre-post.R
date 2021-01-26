#-------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load libraries

library(metafor)
library(nlme)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load data
data.AD <- read.table("dataWang.txt", header=TRUE) # load dataset
# data.AD <- read.table("dataSleepApnea.txt", header=TRUE) # load dataset

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
# Generation of pseudo baselines/outcomes

# Generate the pseudo IPD 
data.IPD <- data.frame(study         = rep(data.AD$ID, data.AD$NCFB),
                       group         = rep(data.AD$group, data.AD$NCFB),
                       meanBaseline  = rep(data.AD$MeanBaseline, data.AD$NCFB),
                       sdBaseline    = rep(data.AD$sdBaseline, data.AD$NCFB),
                       meanPost      = rep(data.AD$MeanPostBaseline, data.AD$NCFB),
                       sdPost        = rep(data.AD$sdPostBaseline, data.AD$NCFB),
                       correlation   = rep(data.AD$Correlation,data.AD$NCFB))

set.seed(123456)
data.IPD$ytmp1 <- rnorm(nrow(data.IPD),0,1)
set.seed(7891011)
data.IPD$ytmp2 <- rnorm(nrow(data.IPD),0,1)

# Standardize ytmp1 and ytmp2, calculate correlation between ytmp1 and ytmp2, 
# and the residuals of regressing ytmp2 on ytmp1
# per study and group

data.IPD2 <- NULL
for(study in unique(data.IPD$study))
{   for (group in unique(data.IPD$group))
{     datatmp <- data.IPD[data.IPD$study==study & data.IPD$group==group,]
     # standardized y1tmp
      datatmp$ytmp1 <- (datatmp$ytmp1-mean(datatmp$ytmp1))/sd(datatmp$ytmp1)
      # standardized y2tmp
      datatmp$ytmp2 <- (datatmp$ytmp2-mean(datatmp$ytmp2))/sd(datatmp$ytmp2)
      # correlation between y1tmp and y2tmp
      cor.ytmp      <- cor(datatmp$ytmp1, datatmp$ytmp2)
      # residuals of regression of ytmp2 on ytmp1
      resid         <- residuals(lm(ytmp2 ~ ytmp1 - 1 , data = datatmp))
   # coefficient beta of regression of ytmp2 on ytmp1
      coef          <- coef(lm(ytmp2 ~ ytmp1 - 1 , data = datatmp))
      data.IPD2     <- rbind( data.IPD2, data.frame(datatmp,cor.ytmp,resid,coef))
}  
} 
head(data.IPD2)  

# temporary variable needed to generate the pseudo baseline and pseudo follow-up outcomes
data.IPD2$ytmp3 <- data.IPD2$ytmp1*data.IPD2$correlation + sqrt(1-data.IPD2$correlation^2)*data.IPD2$resid/sqrt(1-data.IPD2$cor.ytmp^2)
# generate pseudo baseline and pseudo follow-up outcomes
data.IPD2$y1    <- data.IPD2$ytmp1*data.IPD2$sdBaseline + data.IPD2$meanBaseline
data.IPD2$y2    <- data.IPD2$ytmp3*data.IPD2$sdPost + data.IPD2$meanPost

# make new dataset, with only relevant variables
data.pseudoIPD <- data.IPD2[,c("study", "group", "y1", "y2")]
#View(data.pseudoIPD) # final pseudo IPD dataset 
rm(data.IPD2,data.IPD)

# Check the mean and sd of y1 and y2, and correlation y1, y2
check <- cbind(aggregate(y1~group+study, data=data.pseudoIPD, mean), 
              aggregate(y2~group+study, data=data.pseudoIPD, mean)[3],
              aggregate(y1~group+study, data=data.pseudoIPD, sd)[3],
              aggregate(y2~group+study, data=data.pseudoIPD, sd)[3],
              as.vector(cbind(by(data.pseudoIPD, data.pseudoIPD[,c("group","study")], function(x) {cor(x$y1,x$y2)}))))

colnames(check) <- c(colnames(check)[1:2], "meany1", "meany2","sdy1", "sdy2","cory1y2")
check
rm(check)

# Pre-step to calculate centered baseline values by study
data.pseudoIPD$meany1bystudy <- ave(data.pseudoIPD$y1, data.pseudoIPD$study)
data.pseudoIPD$y1center      <- data.pseudoIPD$y1 - data.pseudoIPD$meany1bystudy
data.pseudoIPD$groupcenter   <- data.pseudoIPD$group - 0.5
data.pseudoIPD$arm           <- 1000*data.pseudoIPD$study + data.pseudoIPD$group

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
# ANCOVA per study on pseudo IPD for subsequent two-stage MA

coef_ancova <- NULL
se_ancova   <- NULL

for (i in unique(data.pseudoIPD$study ))
     {         fit = lm(y2~ y1 + group, data.pseudoIPD[data.pseudoIPD$study==i,])
       coef_ancova = rbind(coef_ancova,fit$coefficients) 
         se_ancova = rbind(se_ancova,sqrt(diag(vcov(fit))))
  }
     
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
# Prepare data for two stage MA
two_stageMA <- data.frame(study=unique(data.pseudoIPD$study), coef_group=coef_ancova[,"group"],
                          secoef_group = se_ancova[,"group"])

#--------------------------------------------------------------------------------------------------------------------------------------------------------------
# Run aggregate meta-analysis 
MA <- rma(yi=coef_group, sei=secoef_group, slab=study, method="REML", data=two_stageMA)
summary(MA); forest(MA)
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# Ancovas per study with interaction of baseline and treatment effect on pseudo IPD for subsequent two-stage MA

coef_ancova_int <- NULL
se_ancova_int   <- NULL

for (i in unique(data.pseudoIPD$study ))
{         fit     = lm(y2~ y1center + group + y1center*group, data.pseudoIPD[data.pseudoIPD$study==i,])
  coef_ancova_int = rbind(coef_ancova_int,fit$coefficients) 
    se_ancova_int = rbind(se_ancova_int,sqrt(diag(vcov(fit))))
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Prepare data for two stage MA
two_stageMA_int <- data.frame(study=unique(data.pseudoIPD$study), coef_group=coef_ancova_int[,"y1center:group"],
                          secoef_group = se_ancova_int[,"y1center:group"])

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Run aggregate meta-analysis for interaction effect
MA_int <- rma(yi=coef_group,sei=secoef_group, slab=study, method="REML", data=two_stageMA_int)
summary(MA_int) ; forest(MA_int)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
# Mixed effects approach

ctrl <- lmeControl(opt="optim", msMaxIter=100)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Study stratified intercept and random treatment effect ANCOVA + ANCOVA with interaction 

# arm and study specific variances estimated  

FRstudyarm <- lme(fixed=y2 ~ y1center + group + as.factor(study) + y1center*as.factor(study), random= ~ -1 + groupcenter|study,
                  weights =varIdent(form=~study|arm), control=ctrl, data=data.pseudoIPD, method='REML')

# estimated fixed effects
# note, the error warning is because of the way the df are calculated 
summary(FRstudyarm)$tTable
# 95% CI based on the standard Wald CI, in contrast to SAS
intervals(FRstudyarm, which="fixed")
# estimated tau2 and tau (groupcenter) 
VarCorr((FRstudyarm))

# the a*b interaction term includes also the main effects a and b
# note, the error warning is because of the model is overparametrised
FRstudyarmInt <- lme(fixed=y2 ~ y1center*as.factor(study) + y1center*group + meany1bystudy:group, random= ~ -1 + groupcenter + y1center*groupcenter|study,
                 weights =varIdent(form=~study|arm), control=ctrl, data=data.pseudoIPD, method='REML')
# estimated fixed effects
summary(FRstudyarmInt)$tTable
# 95% CI based on the standard Wald CI, in contrast to SAS
intervals(FRstudyarmInt, which="fixed")
# estimated tau2 and tau (groupcenter) 
VarCorr((FRstudyarmInt))

# study specific variances estimated 
FRstudy   <-  lme(fixed=y2 ~ y1center+ group + as.factor(study) + y1center*as.factor(study) , random= ~ -1 + groupcenter|study,
                  weights =varIdent(form=~1|study), control=ctrl, data=data.pseudoIPD, method='REML')
summary(FRstudy)$tTable
intervals(FRstudy, which="fixed")
VarCorr((FRstudy))

FRstudyInt <-   lme(fixed=y2 ~ y1center*as.factor(study) + y1center*group + meany1bystudy:group , random= ~ -1 + groupcenter + y1center*groupcenter|study,
                  weights =varIdent(form=~1|study), control=ctrl, data=data.pseudoIPD, method='REML')
summary(FRstudyInt)$tTable
intervals(FRstudyInt, which="fixed")
VarCorr((FRstudyInt))

#group specific variances estimated
FRgroup   <-   lme(fixed=y2 ~ y1center + group+ as.factor(study) + y1center*as.factor(study) , random= ~ -1 + groupcenter|study,
                  weights =varIdent(form=~1|group), control=ctrl, data=data.pseudoIPD, method='REML')
summary(FRgroup)$tTable
intervals(FRgroup, which="fixed")
VarCorr((FRgroup))

FRgroupInt   <-   lme(fixed=y2 ~ y1center*as.factor(study) + y1center*group + meany1bystudy:group, random= ~ -1 + groupcenter + y1center*groupcenter|study,
                  weights =varIdent(form=~1|group), control=ctrl, data=data.pseudoIPD, method='REML')
summary(FRgroupInt)$tTable
intervals(FRgroupInt, which="fixed")
VarCorr((FRgroupInt))

#one residual variance estimated
FRone        <-   lme(fixed=y2 ~ y1center + group + as.factor(study) + y1center*as.factor(study) , random= ~-1 + groupcenter|study,
                  control=ctrl, data=data.pseudoIPD, method='REML')
summary(FRone)$tTable
intervals(FRone, which="fixed")
VarCorr((FRone))

FRoneInt     <-   lme(fixed=y2 ~ y1center*as.factor(study) + y1center*group +meany1bystudy:group , random= ~ -1 + groupcenter + y1center*groupcenter|study,
                  control=ctrl,data=data.pseudoIPD, method='REML')
summary(FRoneInt)$tTable
intervals(FRoneInt, which="fixed")
VarCorr((FRoneInt))

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Random study intercept and random treatment effect ANCOVA + ANCOVA with interaction 

# arm and study specific variances estimated  
RRstudyarm    <-  lme(fixed=y2 ~ y1center  + group, random=~ y1center + groupcenter|study, weights =varIdent(form=~study|arm), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRstudyarm)$tTable
intervals(RRstudyarm, which="fixed")
VarCorr((RRstudyarm))

RRstudyarmInt <-  lme(fixed=y2 ~ y1center*group + meany1bystudy:group, random=~ y1center + groupcenter + y1center*groupcenter|study, weights =varIdent(form=~study|arm), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRstudyarmInt)$tTable # y1center:groupcenter is the estimate of interest and it is appropriately estimated; the remaining coefficients are unstable
intervals(RRstudyarmInt, which="fixed")
VarCorr((RRstudyarmInt))

#study specific variances estimated
RRstudy       <-  lme(fixed=y2 ~ y1center  + group, random=~ y1center + groupcenter|study, weights =varIdent(form=~1|study), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRstudy)$tTable
intervals(RRstudy, which="fixed")
VarCorr((RRstudy))

RRstudyInt    <-  lme(fixed=y2 ~  y1center*group + meany1bystudy:group, random= ~ y1center + groupcenter + y1center*groupcenter|study, weights =varIdent(form=~1|study), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRstudyInt)$tTable # y1center:groupcenter is the estimate of interest and it is appropriately estimated; the remaining coefficients are unstable
intervals(RRstudyInt, which="fixed")
VarCorr((RRstudyInt))

# group specific variances estimated 
RRgroup       <-  lme(fixed=y2 ~ y1center  + group, random= ~ y1center + groupcenter|study, weights =varIdent(form=~1|group), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRgroup)$tTable
intervals(RRgroup, which="fixed")
VarCorr((RRgroup))

RRgroupInt    <-  lme(fixed=y2 ~ y1center*group + meany1bystudy:group, random= ~ y1center + groupcenter + y1center*groupcenter|study, weights =varIdent(form=~1|group), control=ctrl,
                  data=data.pseudoIPD, method='REML')
summary(RRgroupInt)$tTable # y1center:groupcenter is the estimate of interest and it is appropriately estimated; the remaining coefficients are unstable
intervals(RRgroupInt, which="fixed")
VarCorr((RRgroupInt))

#one residual variance estimated
RRone         <-  lme(fixed=y2 ~ y1center  + group, random= ~ y1center + groupcenter|study,  control=ctrl, data=data.pseudoIPD, method='REML')
summary(RRone)$tTable
intervals(RRone, which="fixed")
VarCorr((RRone))

RRoneInt    <-  lme(fixed=y2 ~ y1center*group + meany1bystudy:group, random=~ y1center + groupcenter + y1center*groupcenter|study, control=ctrl,
                      data=data.pseudoIPD, method='REML')
summary(RRoneInt)$tTable
intervals(RRoneInt, which="fixed")
VarCorr((RRoneInt))
