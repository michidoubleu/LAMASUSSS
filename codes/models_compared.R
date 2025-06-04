# Load packages
library(ggplot2)
library(nnet)
library(dplyr)
library(gridExtra)

set.seed(123)

n <- 500  # sample size

### LINEAR MODEL SECTION
# ----------------------

# Explanation:
# We simulate a simple linear relationship: Y = a + b * X + noise
# Let's compare how different noise levels affect model performance

X <- rnorm(n)
a <- 2
b <- 3

noise_levels <- c(0.5, 2)  # Low noise = stronger signal; High noise = weaker signal

par(mfrow = c(1, 2))
plot_list <- list()

rmse_list <- c()

for (i in 1:2) {
  sigma <- noise_levels[i]
  Y <- a + b * X + rnorm(n, sd = sigma)
  model <- lm(Y ~ X)
  pred <- predict(model)

  RMSE <- sqrt(mean((Y - pred)^2))
  rmse_list[i] <- RMSE

  df <- data.frame(X = X, Y = Y, Pred = pred)
  p <- ggplot(df, aes(x = X, y = Y)) +
    geom_point(alpha = 0.5) +
    geom_line(aes(y = Pred), color = "blue", size = 1) +
    ggtitle(paste("σ =", sigma, "RMSE =", round(RMSE, 2))) +
    theme_minimal()
  plot_list[[i]] <- p
}

# Show both fits side-by-side
grid.arrange(grobs = plot_list, nrow = 1,
             top = "Linear Model: Effect of Noise (σ) on Fit")


# Explanation:
# When noise increases, RMSE goes up and predictions deviate more from the true data.




### LOGIT MODEL SECTION
# ----------------------

# Explanation:
# In logistic regression, the "signal strength" refers to how sharply the probability shifts
# between 0 and 1 depending on X. We'll vary the slope b.

X <- rnorm(n)
a <- -0.5
b_vals <- c(1, 4)  # Low vs high slope = weaker vs stronger signal

plot_list <- list()
acc_list <- c()

for (i in 1:2) {
  b <- b_vals[i]
  p <- 1 / (1 + exp(-(a + b * X)))
  Y <- rbinom(n, 1, p)
  model <- glm(Y ~ X, family = binomial)
  pred_p <- predict(model, type = "response")
  pred_class <- ifelse(pred_p > 0.5, 1, 0)
  acc <- mean(pred_class == Y)
  acc_list[i] <- acc

  df <- data.frame(X = X, Y = Y, Pred = pred_p)
  p <- ggplot(df, aes(x = X, y = Y)) +
    geom_jitter(height = 0.01, alpha = 0.8) +
    geom_line(aes(y = Pred), color = "red") +
    ggtitle(paste("b =", b_vals[i], "Accuracy =", round(acc, 2))) +
    theme_minimal()
  plot_list[[i]] <- p
}

grid.arrange(grobs = plot_list, nrow = 1,
             top = "Logit Model: Effect of Slope (b) on Fit")

# Explanation:
# A larger slope results in sharper separation and higher accuracy.

### MULTINOMIAL LOGIT SECTION
# ----------------------------

# Explanation:
# In a multinomial logit model, we predict categories (e.g., class1, class2, class3)
# based on input features. Stronger signals (i.e., larger coefficients) result in more
# distinct class boundaries and higher prediction accuracy.

scale_factors <- c(0.5, 2)  # Low vs high signal strength

plot_list <- list()
accuracy_list <- numeric(length(scale_factors))

for (i in seq_along(scale_factors)) {
  s <- scale_factors[i]

  # Generate features
  X1 <- rnorm(n)
  X2 <- rnorm(n)

  # Coefficients for class2 and class3 (baseline = class1)
  beta_class2 <- c(s * 0.5, s * 1.5, s * -1)   # intercept, X1, X2
  beta_class3 <- c(s * -0.2, s * -1, s * 2)    # intercept, X1, X2

  # Linear predictors
  lp2 <- beta_class2[1] + beta_class2[2]*X1 + beta_class2[3]*X2
  lp3 <- beta_class3[1] + beta_class3[2]*X1 + beta_class3[3]*X2

  # Convert to probabilities using softmax
  exp1 <- 1
  exp2 <- exp(lp2)
  exp3 <- exp(lp3)
  sum_exp <- exp1 + exp2 + exp3

  probs <- cbind(
    class1 = exp1 / sum_exp,
    class2 = exp2 / sum_exp,
    class3 = exp3 / sum_exp
  )

  # Sample class labels from probability distributions
  Y <- apply(probs, 1, function(p) sample(1:3, 1, prob = p))
  Y <- factor(Y, levels = 1:3, labels = c("class1", "class2", "class3"))

  # Prepare data and fit MNL
  data_mnl <- data.frame(Y = Y, X1 = X1, X2 = X2)
  model_mnl <- multinom(Y ~ X1 + X2, data = data_mnl, trace = FALSE)

  # Predict classes and compute accuracy
  Y_pred <- predict(model_mnl)
  acc <- mean(Y_pred == data_mnl$Y)
  accuracy_list[i] <- acc
  data_mnl$Pred <- Y_pred

  # Plot true and predicted labels
  p_true <- ggplot(data_mnl, aes(x = X1, y = X2, color = Y)) +
    geom_point(alpha = 0.5) +
    labs(title = paste("True Classes (scale =", s, ")")) +
    theme_minimal()

  p_pred <- ggplot(data_mnl, aes(x = X1, y = X2, color = Pred)) +
    geom_point(alpha = 0.5) +
    labs(title = paste("Predicted (acc =", round(acc, 2), ", scale =", s, ")")) +
    theme_minimal()

  plot_list[[2*i - 1]] <- p_true
  plot_list[[2*i]] <- p_pred
}

# Show plots side-by-side
grid.arrange(grobs = plot_list, ncol = 2,
             top = "Multinomial Logit: Effect of Coefficient Scale on Prediction Accuracy")


