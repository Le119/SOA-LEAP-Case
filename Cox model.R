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
library(scales)
library(caret)
library(prcomp)
library(factoextra)

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










# I took a quick look at the case and here are some preliminary thoughts:
# I don't think you need to do fundamental mortality modeling. 
# My understanding is that you are provided with general population mortality rates, as well as inforce data (that's data from actual existing policyholders of the company). 
# So your first step should be to compare the mortality rates of the company's policyholders vs. general population. 
# I expect the company's policyholders to have an overall better mortality experience than general population due to underwriting effect. 
# The inforce data come with many useful variables: age, sex, smoking and underwriting classes, region, distributor, etc, so you can run a regression to see if any of those variables have any significant impact on mortality, and those significant variables should be your first entry points for intervention.
# You are also provided with both the costs and impact on mortality given each intervention, so your other task is to find a set of interventions that are most cost effective, and will have the most impact on mortality (something you mostly learned from the step before). You can quantify the NET benefits using the intervention data, and make your recommendations from there.



# Based on Vicki's comments, my thought is to compare the mortality rates of policyholders vs. genearal population

mortality<-read_xlsx("C:/Users/cheng/Desktop/SOA/srcsc-2024-lumaria-mortality-table.xlsx")


# This is the issue age from our policyholders
ages <- data$Issue.age

age_groups <- cut(ages, 
                  breaks = c(25, 34, 50, 64, 100),
                  labels = c("25-34", "35-50", "51-64", ">65"),
                  include.lowest = TRUE)

age_data <- data.frame(Age = ages, AgeGroup = age_groups)

ggplot(age_data, aes(x = AgeGroup)) +
  geom_bar() +
  theme_minimal() +
  labs(title = "Age Distribution",
       x = "Age Group",
       y = "Count") +
  scale_y_continuous(labels = label_number())

# calculate the death rate for different age
death_rates <- data %>%
  group_by(Issue.age) %>%
  summarise(Total = n(),
            Deaths = sum(Death.indicator),
            DeathRate = Deaths / Total)
death_rates <- death_rates %>%
  left_join(mortality, by = c("Issue.age" = "Age"))
# well, I should say the result is somehow suprised, the only thing I can get is that
# "unhealthy" people preferring the life product



death_rates_class <- data %>%
  group_by(Underwriting.Class) %>%
  summarise(
    DeathRate = sum(Death.indicator == 1) / n()
  )
# In addition, we check the death rate across different classes:
# the result shows that very low and low have similar death rate and
# moderate has the highest death rate (this is not very surprising) because 
# every result we get is "empirical"

death_rates_sex <- data %>%
  group_by(Sex) %>%
  summarise(
    DeathRate = sum(Death.indicator == 1) / n()
  )
# Male people have higher death rate

death_rates_face_amount <- data %>%
  group_by(Face.amount) %>%
  summarise(
    DeathRate = sum(Death.indicator == 1) / n()
  )
# Well this is not helpful

death_rates_smoking <- data %>%
  group_by(Smoker.Status) %>%
  summarise(
    DeathRate = sum(Death.indicator == 1) / n()
  )
# Obviously, the non-smoking have lower death rate



####
# Program Design: Health rater and customized intervention plan
####
# This is my idea about program design, based on my death rate investigation, I should
# say that the mortality rate is not as our imaging, so I believe a rater will be 
# helpful to categorize our clients.

# Need to remember that: the death rate is something we calculated it (empirical), it may be
# extreme and not align with the theoretical parameter (mortality rate provided), so my idea
# is about designing a rater (or model) to rate our clients individually based on several 
# key observations: like sex, smoke, etc. This process is more likely to the auto insurance:
# in auto insurance, we consider a driver based on several aspects and eventually assign the 
# driver to a risk group for future insurance cost

# Please keep in mind, this rater may not directly contributes to the pricing (I am not aim to 
# find the price for policyholder, but it will be helpful), I want to quantify the risk for 
# each policyholder and determine their real risk class

# In ideal, I think we'd better divide our rater into 2 parts: first part we use the regression
# model (no restriction, we will decide the most useful and reasonable model), but here is my
# assumption, we can divide our policyholder into several groups, for example: high risk and 
# low risk, intuitively, we can imagine the high risk people may be easy to be predicted under
# certain model, but how about low risk or normal people? If a person do not smoke, can we say
# he/she is very healthy? Well, that's the second part of the rater, we may want to design a model
# (might be non-intuitive or may request some industrial research) to model the low risk or 
# data-limited people.


####
# Idea of rater: in this rater, we will quantify the policyholder's risk by ourselves: 
# my thinking is about: we use several different model to fit on our data, then we should have 
# several different models: we can evaluate model performance and rank and give weight for each 
# model's result, overall we rating the policyholder.

# Here is a several 2 possible ways: 1. Model Ensemble, intuitively speaking we input several models then
# generate an ultimate model. 2. We can simply applied the weighted avg, we can go across different weights
# and check which one is the best (or we can use some metrics like AIC BIC to determine weights).
# Some candidtes model include: LDA, LR, RandomForest, PCA ...







# Based on Vicki's comment, I will start with finding which one is significant factor
data_pca <- select(data, Issue.age, Sex, Smoker.Status, Underwriting.Class, Urban.vs.Rural,
                    Death.indicator)
preproc_pca <- preProcess(data_pca[, -which(names(data_pca) == "Death.indicator")], 
                      method = c("center", "scale"))
data_normalized <- predict(preproc_pca, data_pca[, -which(names(data) == "Death.indicator")])

Region <- data[["Region"]]
features_normalized <- cbind(Region, data_normalized)

for (col_name in names(features_normalized)) {
  if (!is.numeric(features_normalized[[col_name]])) {
    # 尝试将列转换为数值类型
    features_normalized[[col_name]] <- as.numeric(as.character(features_normalized[[col_name]]))
  }
}
features_normalized <- features_normalized[ , -which(names(features_normalized) == "Death.indicator")]


# Now we can apply PCA
pca_result <- prcomp(features_normalized, center = TRUE, scale. = TRUE)
fviz_eig(pca_result)
summary(pca_result)

loadings <- pca_result$rotation
print(loadings)

fviz_pca_var(pca_result, col.var = "cos2", 
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE) 




