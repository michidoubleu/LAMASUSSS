# Load required libraries
install.packages("devtools")
install.packages("ggplot2")
install.packages("nnet")
install.packages("dplyr")

library(ggplot2)
library(nnet)       # For multinomial logit
library(dplyr)

# just install the downscalr package
devtools::install_github("tkrisztin/downscalr", ref="HEAD", repos = "http://cran.us.r-project.org")

set.seed(42)        # For reproducibility

# Number of observations
n <- 500

### 1. LINEAR REGRESSION DGP AND ESTIMATION
# -----------------------------------------



# Simulate data
X_lin <- runif(n, 0,100)

a <- 10
b <- 2
e <- rnorm(n, sd=10)

Y_lin <- a + b * X_lin + e

# Fit linear model
model_lin <- lm(Y_lin ~ X_lin)

# Predict and plot
data_lin <- data.frame(X = X_lin, Y = Y_lin, Pred = predict(model_lin))

ggplot(data_lin, aes(x = X, y = Y)) +
  geom_point(alpha = 0.5) +
  geom_line(aes(y = Pred), color = "blue", size = 1) +
  labs(title = "Linear Regression",
       y = "Yield in ton/ha", x = "Fertilizer input in ton/ha") +
  xlim(0,100)+
  ylim(-10,250)+
  theme_bw()



ggplot(data_lin, aes(x = Y, y = predict(model_lin))) +
  geom_point(alpha = 0.5) +
  labs(title = "Linear Regression: Observed vs Predicted",
       y = "Predicted yield", x = "Observed yield") +
  geom_abline(intercept = 0, slope = 1, linewidth=1, color="red") +
  xlim(0,250)+
  ylim(0,250)+
  theme_bw()











### 2. LOGIT MODEL DGP AND ESTIMATION
# -----------------------------------



# Simulate data
X_logit <- rnorm(n, sd = 3)

a <- 0.5
b <- 2

logit_p <- 1 / (1 + exp(-(a + b * X_logit)))

Y_logit <- rbinom(n, 1, logit_p)

# Fit logistic regression
model_logit <- glm(Y_logit ~ X_logit, family = binomial)

# Predict probabilities
pred_logit <- predict(model_logit, type = "response")
data_logit <- data.frame(X = X_logit, Y = Y_logit, Pred = pred_logit, probs = logit_p)


ggplot(data_logit, aes(x = X)) +
  geom_point(aes(y = Y)) +
  geom_point(aes(y = probs), color = "blue") +
  geom_line(aes(y = Pred), color = "red", size = 1) +
  labs(title = "Logistic Regression: Observed vs Predicted Probability",
       y = "Probability (Y=1)", x = "X") +
  theme_bw()











### 3. MULTINOMIAL LOGIT (MNL) DGP AND ESTIMATION
# -----------------------------------------------

# Simulate two features and 3 classes
X1_mnl <- rnorm(n)
X2_mnl <- rnorm(n)
# Coefficients for 3 classes (baseline = class 1)
beta_mnl <- list(
  class2 = c(0.5, 1.5, -1),   # intercept, X1, X2
  class3 = c(-0.2, -1, 2)     # intercept, X1, X2
)

# Calculate linear predictors and softmax probabilities
lin_pred_2 <- beta_mnl$class2[1] + beta_mnl$class2[2]*X1_mnl + beta_mnl$class2[3]*X2_mnl
lin_pred_3 <- beta_mnl$class3[1] + beta_mnl$class3[2]*X1_mnl + beta_mnl$class3[3]*X2_mnl
exp_pred_1 <- 1
exp_pred_2 <- exp(lin_pred_2)
exp_pred_3 <- exp(lin_pred_3)
sum_exp <- exp_pred_1 + exp_pred_2 + exp_pred_3
probs <- cbind(
  class1 = exp_pred_1 / sum_exp,
  class2 = exp_pred_2 / sum_exp,
  class3 = exp_pred_3 / sum_exp
)

# Sample class labels
Y_mnl <- apply(probs, 1, function(p) sample(1:3, 1, prob = p))
Y_mnl <- factor(Y_mnl, labels = c("class1", "class2", "class3"))

# Fit MNL model
data_mnl <- data.frame(Y = Y_mnl, X1 = X1_mnl, X2 = X2_mnl)
model_mnl <- multinom(Y ~ X1 + X2, data = data_mnl, trace = FALSE)

# Predict class probabilities and labels
pred_probs <- predict(model_mnl, type = "probs")
pred_class <- predict(model_mnl)

# Confusion matrix
print("Confusion Matrix (MNL):")
print(table(True = data_mnl$Y, Predicted = pred_class))


data_mnl$Pred <- pred_class


# 2D Plot: Actual vs Predicted class
A <- ggplot(data_mnl, aes(x = X1, y = X2, color = Pred)) +
  geom_point(alpha = 0.8) +
  labs(title = "MNL: Predicted Classes", x = "X1", y = "X2") +
  theme_bw()

B <- ggplot(data_mnl, aes(x = X1, y = X2, color = Y)) +
  geom_point(alpha = 0.8) +
  labs(title = "MNL: True Classes", x = "X1", y = "X2") +
  theme_bw()

grid.arrange(A,B, nrow = 1,
             top = "Predicted (left) vs actual (right)")







###### compare DS


library(downscalr)
X <- as.matrix(model.matrix(model_mnl))


Y_matrix <- matrix(0, nrow = n, ncol = 3)
for (i in 1:n) {
  Y_matrix[i, which(levels(Y_mnl) == Y_mnl[i])] <- 1
}
Y_matrix <- as.matrix(Y_matrix)

res.MNL <- downscalr::mnlogit(X, Y_matrix, baseline = 1)

apply(res.MNL$postb,c(1,2),mean)