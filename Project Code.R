#Importing the data
auto.mpg<- read.table("./auto-mpg.data", header = TRUE)
missing_dat<- auto.mpg

#Libraries
library("tidyverse")
library("splines")
library("car")
library("mice")
library("lawstat")
library("gridExtra")

#First look at the data
str(missing_dat)
summary(missing_dat)

#Removing the covarites not needed for analysis
missing_dat <- missing_dat%>%select(-name,-cylinders,-model_year,-origin)

#Imputing missing values 
dat<-mice(missing_dat, m=5, maxit = 50, method = 'pmm', seed = 18008373)
dat<-complete(dat,4)
summary(dat)
source("Project Functions.R")

#Intial plots 
p <- ggplot(dat)
p1 <- p+geom_histogram(aes(mpg), fill = "lightblue", colour = "white", binwidth = 2,
                 alpha = 0.9) + xlab("Mpg") + ggtitle("Figure 2:Histogram: Mpg ") + theme_classic()
p2 <- p+geom_point(aes(mpg,displacement),colour = "lightcoral", size = 3, alpha = 0.4)+ 
  ggtitle("Figure 1.1: MPG-Displacement ") + theme_classic()
p3 <-p+geom_point(aes(mpg,horsepower),colour = "deeppink4", size = 3, alpha = 0.4)+
  ggtitle("Figure 1.2:MPG-Horsepower ") + theme_classic()
p4 <-p+geom_point(aes(mpg,weight),colour = "darkslateblue", size = 3, alpha = 0.4)+
  ggtitle("Figure 1.3:MPG-Horsepower ") + theme_classic()
p5 <-p+geom_point(aes(mpg,acceleration),colour = "darkseagreen", size = 3, alpha = 0.4)+
  ggtitle("Figure 1.4:MPG-Acceleration ") + theme_classic()
scatterp <- grid.arrange(p2,p3,p4,p5)


#Models
#Polynomial
##Displacement
par(mfrow = c(1,2))
ms1 <- modelselectionreg(dat$displacement,dat$mpg,20)
polyregdis <- lm(mpg~poly(displacement, degree = 10), data = dat)
par(mfrow = c(1,1))
q <- ggplot(dat, aes(y=mpg, x=displacement)) 
poly1<-q + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 4.1: Displacement") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ poly(x,10), colour = "lightcoral")


##Horsepower
par(mfrow = c(1,2))
ms2 <- modelselectionreg(dat$horsepower,dat$mpg,19)
polyreghp <- lm(mpg~poly(horsepower, degree = 17), data = dat)
r <- ggplot(dat, aes(y=mpg, x=horsepower)) 
poly2 <- r + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 4.2: Horsepower") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ poly(x,17), colour = "deeppink4")


##Weight 
par(mfrow = c(1,2))
ms3 <- modelselectionreg(dat$weight,dat$mpg,20)
polyregwt <- lm(mpg~poly(weight, degree = 2), data = dat)
par(mfrow = c(1,1))
s <- ggplot(dat, aes(y=mpg, x= weight))
poly3 <- s + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 4.3: Weight") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ poly(x,2), colour = "darkslateblue")



##Acceleration
par(mfrow = c(1,2))
ms4<-modelselectionreg(dat$acceleration,dat$mpg,10)
polyregacc <- lm(mpg~poly(acceleration, degree = 4), data = dat)
par(mfrow = c(1,1))
t <- ggplot(dat, aes(y=mpg, x= acceleration))
poly4 <- t + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 4.4: Acceleration") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ poly(x,4), colour = "darkseagreen")

##Final
Table2 <- rbind(ms1,ms2,ms3,ms4)
rownames(Table2) <- c("Displacement","Horsepower","Weight","Acceleration")
polyp <-  grid.arrange(poly1,poly2,poly3,poly4)

lm1 <- q + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 3.1: Displacement") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ x, colour = "lightcoral")
lm2 <- r + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 3.2: Horsepower") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ x, colour = "deeppink4")
lm3 <- s + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 3.3: Weight") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ x, colour = "darkslateblue") 
lm4 <- t + geom_point( size = 2, alpha = 0.4)+ 
  ggtitle("Figure 3.4: Acceleration") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ x, colour = "darkseagreen")

lmp <- grid.arrange(lm1,lm2,lm3,lm4)

#Bspline 
#Autoselect knots
bsdis <- lm(mpg ~ bs(displacement), data = dat)
bs1<-q + geom_point(size = 2,alpha = .5) + 
  ggtitle("Figure 6.1: BSpline- Auto-Select") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x), colour = 'lightcoral')

#Placing knots at the mean
bsdis1 <- lm(mpg ~ bs(displacement,degree = 2, knots = mean(displacement)), data = dat)
bs2 <-q + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 6.2: BSpline- Knots at the Mean") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 2, knots = mean(x)), 
              colour = 'lightcoral')
 
#Placing knots at the quantile
bsdis2<- lm(mpg ~ bs(displacement, degree = 3,knots = 
                       quantile(displacement[displacement > min(displacement)])[2:3]), 
            data = dat)
bs3 <-q+ geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 6.3: BSpline- Knots at the Quantiles") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 3,knots = 
                                                quantile(x[ x > min(x)])[2:3]),
              colour = "lightcoral")

#By visualization
quantile(dat$displacement[dat$displacement > min(dat$displacement)])[2:3]
bsdis3 <-lm(mpg ~ bs(displacement, degree = 3, knots = c(100,150,350,400)), 
            data = dat)
bs4 <- q+ geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 6.4: BSpline- Knots by Visualization") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x, degree = 3,knots = c(105,151,350,400)), colour = "lightcoral")

#Model Selection 
aic1<- AIC(bsdis,bsdis1,bsdis2, bsdis3)
RSS1<- c(rss(bsdis),rss(bsdis1),rss(bsdis2),rss(bsdis3)) 
Degree1 <- c(2,2,3,3)
Adjusted.R.Squared1 <- c(summary(bsdis)$adj.r.squared,summary(bsdis1)$adj.r.squared,
                        summary(bsdis2)$adj.r.squared, summary(bsdis3)$adj.r.squared)
Table3 <- cbind(Degree = Degree1,AIC= aic1$AIC,Adjusted.R.Squared = Adjusted.R.Squared1,RSS = RSS1)


#With Horsepower
#Auto
bshp <- lm(mpg ~ bs(horsepower), data = dat)
bs5 <- r + geom_point(size = 2,alpha = .5) + 
  ggtitle("Figure 7.1: BSpline - Auto Select BSpline") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x), colour = 'deeppink4')

#Placing knots at the mean
bshp1 <- lm(mpg ~ bs(horsepower,degree = 2, knots = mean(horsepower)), data = dat)
bs6 <- r + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 7.2: BSpline- Knots at the Mean") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x, degree = 2, knots = mean(x)),
              colour = "deeppink4")

#Placing knots at the quantile
bshp2<- lm(mpg ~ bs(horsepower,degree = 3, knots = 
                       quantile(horsepower[horsepower > min(horsepower)])[2:3]), 
            data = dat)
bs7 <- r + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 7.3: BSpline- Knots at the Quantiles") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 3,knots = 
                                                quantile(x[ x > min(x)])[2:3]),
              colour = "deeppink4")

#Knots by visualisation
quantile(dat$horsepower[dat$horsepower > min(dat$horsepower)])[2:3]
bshp3<- lm(mpg ~ bs(horsepower, degree = 5, knots = c(50,185,200)), data = dat)
bs8 <- r + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 7: BSpline- Knots by visualization") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree=4,knots = c(50,185,200)),
              colour = "deeppink4")

#Model Selection 
aic2 <- AIC(bshp,bshp1,bshp2,bshp3)
RSS2<- c(rss(bshp),rss(bshp1),rss(bshp2),rss(bshp3)) 
Degree2 <- c(2,2,3,4)
Adjusted.R.Squared2 <- c(summary(bshp)$adj.r.squared,summary(bshp1)$adj.r.squared,
                         summary(bshp2)$adj.r.squared, summary(bshp3)$adj.r.squared)
Table4 <- cbind(Degree = Degree2,AIC= aic2$AIC,Adjusted.R.Squared = Adjusted.R.Squared2,RSS = RSS2)
grid.arrange(bs5,bs6,bs7)

#With Weight
#Autoselect knots
bswt <- lm(mpg ~ bs(weight), data = dat)
bs9<-s + geom_point(size = 2,alpha = .5) + 
  ggtitle("Figure 8.1: BSpline - Auto Select") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x), colour = 'darkslateblue')

#Placing knots at the mean
bswt1 <- lm(mpg ~ bs(weight, degree = 2, knots = mean(weight)), data = dat)
bs10<-s + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 8: BSpline - Knots at the Mean") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 2,knots = mean(x)),
              colour = "darkslateblue")

#Placing knots at the quantile
bswt2<- lm(mpg ~ bs(weight, degree = 3, knots = 
                      quantile(weight[weight> min(weight)])[2:3]), 
           data = dat)
bs11 <- s + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 8.2: BSpline- Knots at the Quantiles") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree=2,knots = 
                                                quantile(x[ x > min(x)])[2:3]),
              colour = "darkslateblue")

#Knots by visualisation
quantile(dat$weight[dat$weight > min(dat$weight)])[2:3]
bswt3<- lm(mpg ~ bs(weight, degree = 4, knots = c(2800,4000,4800)), data = dat)
bs12<- s + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 8.3: BSpline - Knots at the Quantiles") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree=3,knots = c(2800,4000,4800)),
              colour = "deeppink4")


#Model Selection 
aic3 <- AIC(bswt,bswt1,bswt2,bswt3)
RSS3<- c(rss(bswt),rss(bswt1),rss(bswt2),rss(bswt3)) 
Degree3 <- c(2,2,3,4)
Adjusted.R.Squared3 <- c(summary(bswt)$adj.r.squared,summary(bswt1)$adj.r.squared,
                         summary(bswt2)$adj.r.squared, summary(bswt3)$adj.r.squared)
Table5 <- cbind(Degree = Degree3,AIC= aic3$AIC,Adjusted.R.Squared = Adjusted.R.Squared3,RSS = RSS3)
grid.arrange(bs9,bs11,bs12)



#Acceleration B-spline
#auto
bsacc <- lm(mpg ~ bs(acceleration), data = dat)
bs13<-t + geom_point(size = 2,alpha = .5) + 
  ggtitle("Figure 9.1: BSpline - Auto Select") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x), colour = 'darkseagreen')

#Placing knots at the mean
bsacc1 <- lm(mpg ~ bs(acceleration,degree = 2, knots = mean(acceleration)), data = dat)
bs14 <- t + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 9.2: BSpline - Knots at the Mean BSpline") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 2, knots = mean(x)),
              colour = "darkseagreen")

#Placing knots at the quantile
bsacc2<- lm(mpg ~ bs(acceleration, degree = 3, knots = 
                       quantile(acceleration[acceleration> min(acceleration)])[2:3]), 
            data = dat)
bs15<-t + geom_point(alpha = .5, size = 2) + 
  ggtitle("Figure 9: BSpline - Knots at the Quantiles") + theme_classic() + 
  stat_smooth(method = "lm", formula = y ~ bs(x,degree = 3,knots = 
                                                quantile(x[ x > min(x)])[2:3]),
              colour = "darkseagreen")

#Model Selection 
aic4 <- AIC(bsacc,bsacc1,bsacc2)
aic4
RSS4<- c(rss(bsacc),rss(bsacc1),rss(bsacc2)) 
Degree4 <- c(2,2,3)
Adjusted.R.Squared4 <- c(summary(bsacc)$adj.r.squared,summary(bsacc1)$adj.r.squared,
                         summary(bsacc2)$adj.r.squared)
Table6 <- cbind(Degree = Degree4,AIC= aic4$AIC,Adjusted.R.Squared = Adjusted.R.Squared4,RSS = RSS4)

grid.arrange(bs13,bs14)


#FINAL BSPLINE SELECTION 
Table7 <- rbind(Table3[4,],Table4[4,],Table5[1,], Table6[2,])
rownames(Table7) <- c("Displacement","Horsepower","Weight","Acceleration")


##Binsmooth
#Displacement
par(mfrow = c(1,1))
binsmoothdis <-  binsmoothREG(dat$displacement,dat$mpg,94, opt = 1)

#Horsepower
par(mfrow = c(1,1))
binsmoothhp <- binsmoothREG(dat$horsepower,dat$mpg,30, opt = 1)

#Weight
##binsmooth
par(mfrow = c(1,1))
binsmoothwt <- binsmoothREG(dat$weight,dat$mpg,48, opt = 1)


#Acceleration 
par(mfrow = c(1,1))
binsmoothacc <- binsmoothREG(dat$acceleration,dat$mpg, 10, opt = 1)

#Model Selection
#Assumption testing 
#Normality
p+geom_histogram(aes(residuals(binsmoothdis$Reg)))
qqnorm(residuals(binsmoothdis$Reg))
qqline(residuals(binsmoothdis$Reg))
shapiro.test(residuals(binsmoothdis$Reg))

#Correlation
runs.test(residuals(binsmoothdis$Reg, type = "pearson"))
acf(residuals(binsmoothdis$Reg, type = "pearson"))

#modelfit
#Assumption testing 
#Normality
p+geom_histogram(aes(residuals(bsdis3)))
qqnorm(residuals(bsdis3))
qqline(residuals(bsdis3))
shapiro.test(residuals(bsdis3))

#Correlation
runs.test(residuals(bsdis3, type = "pearson"))
acf(residuals(bsdis3, type = "pearson"))

#Assumption testing 
#Normality
p+geom_histogram(aes(residuals(polyregwt)))
qqnorm(residuals(polyregwt))
qqline(residuals(polyregwt))
shapiro.test(residuals(polyregwt))

#Correlation
runs.test(residuals(polyregwt, type = "pearson"))
acf(residuals(polyregwt, type = "pearson"))

#Measure of generalisation Error

Table9 <- rbind(epe(dat$mpg,polyregwt),
                epe(dat$mpg,binsmoothdis$Reg),
                epe(dat$mpg,bsdis3))
rownames(Table9) <- c("PolyReg","Bin-Smooth","B-Spline")

