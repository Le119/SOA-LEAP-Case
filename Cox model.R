library(readxl)
library(dplyr)
library(survival)
library(ranger)
library(ggplot2)
library(dplyr)
library(ggfortify)
library(survminer)
install.packages("SurvRegCenCov")
library(SurvRegCensCov) 

data<-read.csv("C:/Users/cheng/Desktop/SOA/2024-srcsc-superlife-inforce-dataset.csv")

# Convert some text data to numerical

data$Policy.type <- ifelse(data$Policy.type == "SPWL", 0, 
                         ifelse(data$Policy.type == "T20", 1, data$Policy.type))

data$Sex <- ifelse(data$Sex == "F", 0, 
                           ifelse(data$Sex == "M", 1, data$Sex))

data$Smoker.Status <- ifelse(data$Smoker.Status == "NS", 0, 
                   ifelse(data$Smoker.Status == "S", 1, data$Smoker.Status))

data$Underwriting.Class <- ifelse(data$Underwriting.Class == "very low risk", 0, 
                           ifelse(data$Underwriting.Class == "low risk", 1, 
                                  data$Underwriting.Class))
data$Underwriting.Class <- ifelse(data$Underwriting.Class == "moderate risk", 2, 
                                  ifelse(data$Underwriting.Class == "high risk", 3, 
                                         data$Underwriting.Class))

data$Urban.vs.Rural <- ifelse(data$Urban.vs.Rural == "Rural", 0, 
                                  ifelse(data$Urban.vs.Rural == "Urban", 1, 
                                         data$Urban.vs.Rural))

data$Distribution.Channel <- ifelse(data$Distribution.Channel == "Agent", 0, 
                                  ifelse(data$Distribution.Channel == "Telemarketer", 1, 
                                         data$Distribution.Channel))




data$Death.indicator[is.na(data$Death.indicator)] <- 0


data$Lapse.Indicator[is.na(data$Lapse.Indicator)] <- 0

data$time <- with(data, ifelse(data$Death.indicator == 2, 
                               data$Year.of.death - data$Issue.year, 
                               2024 - data$Issue.year))


# To make sure our data will be useful, so we just use the data with death


# Cox model

#cox <- coxph(Surv(data$time, data$Death.indicator) ~ Policy.type + Sex + Smoker.Status
#             + Underwriting.Class + Urban.vs.Rural + Issue.age , data = data)


cox <- coxph(Surv(data$time, data$Death.indicator) ~ Sex + Policy.type + Smoker.Status 
            + Underwriting.Class, data = data)
summary(cox)


cox_fit <- survfit(cox,data = data)
#plot(cox_fit, main = "cph model", xlab="Days")
autoplot(cox_fit)

# Plot the baseline survival function
# 
ggsurvplot(cox_fit, color = "#2E9FDF",
           ggtheme = theme_minimal(),data = data)
# Here is the diagnostic for cox model
# The function cox.zph() [in the survival package] provides a convenient solution 
# to test the proportional hazards assumption for each covariate included in a Cox refression model fit.

# For each covariate, the function cox.zph() correlates the corresponding set of scaled Schoenfeld residuals with time, to test for independence between residuals and time. Additionally, it performs a global test for the model as a whole.
test.ph <- cox.zph(cox)
test.ph

# Unfortunately, we observe there exists the relation between time and survival data
# so the cox model may not be a good choice

weibull<-WeibullReg(Surv(data$time, data$Death.indicator) ~Sex + Policy.type + Smoker.Status 
                    + Underwriting.Class, data=data)
# We also provide the diagnostic
# If the Weibull model has adequate fit, then the plots for each of the
#covariates should be roughly linear and parallel.
diag<-WeibullDiag(Surv(data$time, data$Death.indicator) ~Sex , data=data)
