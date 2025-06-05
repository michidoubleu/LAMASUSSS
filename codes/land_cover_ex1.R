set.seed(123)

library(raster)
library(ggplot2)
library(nnet)
library(gridExtra)

###### start with coordiates of a grid
long <-  rep(seq(0.5,19.5,1),20)
lat <- rep(seq(0.5,19.5,1),each=20)
xyz <- cbind(long,lat)

##### we want to plot the values of the longitude
plot.long <- rasterFromXYZ(xyz[,c(1,2,1)])
limits1 = c(0,20)
plot(plot.long,zlim=limits1)

X.art <- rnorm(nrow(xyz), mean = 10, sd=3)
xyz <- as.data.frame(cbind(xyz, X.art))

xyz <- xyz %>% mutate(X4=10/(abs(10-long)+abs(10-lat)))


plot.X4 <- rasterFromXYZ(xyz[,c(1,2,4)])
plot(plot.X4)


### 3. MULTINOMIAL LOGIT (MNL) DGP AND ESTIMATION
# -----------------------------------------------

# We have 3 features and assume 3 classes (forest, grassland & cropland)
X1_mnl <- long
X2_mnl <- lat
X3_mnl <- X.art
X4_mnl <- xyz[,4]

# Coefficients for 3 classes (baseline = class 1/Forest)
beta_mnl <- list(
  grass = c(0.2, -0.5, 0.3, 1),   # intercept, X1, X2
  crop = c(0.4, -0.2, 0.1, 1)     # intercept, X1, X2
)

# Calculate linear predictors and softmax probabilities

# Linear predictor for grass
pred_grass <- beta_mnl$grass[1]*X1_mnl + beta_mnl$grass[2]*X2_mnl + beta_mnl$grass[3]*X3_mnl + beta_mnl$grass[4]*X4_mnl

# How would the linar predictor for  crop look like?
pred_crop <- beta_mnl$crop[1]*X1_mnl + beta_mnl$crop[2]*X2_mnl + beta_mnl$crop[3]*X3_mnl + beta_mnl$crop[4]*X4_mnl


exp_forest <- 1 ##### why is this 1?
exp_grass <- exp(pred_grass)
exp_crop <- exp(pred_crop)


sum_exp <- exp_forest + exp_grass + exp_crop
probs <- cbind(
  forest = exp_forest / sum_exp,
  grass = exp_grass / sum_exp,
  crop = exp_crop / sum_exp
)

#we can now plot the probabilities for all



# Sample class labels
Y_mnl <- apply(probs, 1, function(p) sample(1:3, 1, prob = p))
Y_mnl <- factor(Y_mnl, labels = c("forest", "grass", "crop"))

# Fit MNL model
data_mnl <- data.frame(Y = Y_mnl, X1 = X1_mnl, X2 = X2_mnl, X3 = X3_mnl, X4 = X4_mnl)
model_mnl <- multinom(Y ~ X1 + X2 + X3 + X4 -1 , data = data_mnl, trace = FALSE)

# Predict class probabilities and labels
pred_probs <- predict(model_mnl, type = "probs")
pred_class <- predict(model_mnl)

# Confusion matrix
print("Confusion Matrix (MNL):")
TT <- print(table(True = data_mnl$Y, Predicted = pred_class))
round(TT/rowSums(TT)*100,0)


# Create a data frame with the values you want to plot — in this case, longitude
df <- data.frame(
  long = long,
  lat  = lat,
  pred = pred_class,  # use longitude as the value
  actual = data_mnl$Y
)

land_colors <- c(
  forest = "#006400",   # dark green
  grass  = "#90ee90",   # light green
  crop   = "#EEBB14"    # beige
)



# Plot predicted values
A <- ggplot(df, aes(x = long, y = lat, fill = pred)) +
  geom_tile() +
  scale_fill_manual(values = land_colors) +
  coord_equal() +
  labs(x = "Longitude",
       y = "Latitude",
       fill = "Land Cover") +
  theme_bw() +
  theme(legend.position = "bottom")

# Plot actual values
B <- ggplot(df, aes(x = long, y = lat, fill = actual)) +
  geom_tile() +
  scale_fill_manual(values = land_colors) +
  coord_equal() +
  labs(x = "Longitude",
       y = "Latitude",
       fill = "Land Cover") +
  theme_bw() +
  theme(legend.position = "bottom")

grid.arrange(A,B, nrow = 1,
             top = "Predicted (left) vs actual (right)")







X_new <- as.matrix(cbind(X1_mnl,X2_mnl,X3_mnl))
Y <- matrix(0, nrow = nrow(X_new), ncol = ncol(probs))

for (i in 1:nrow(Y)) {
  Y[i, which(levels(Y_mnl) == Y_mnl[i])] <- 1
}
Y <- as.matrix(Y)

res.lc <- downscalr::mnlogit(X_new, Y, baseline = 1)
beta <- apply(res.lc$postb,c(1,2),mean)

