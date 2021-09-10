#Project Functions
#Functions
rss <- function(model) {
  #Input - Model 
  #Output - rss 
  resid <- residuals(model)
  rss <- sum(resid^2)
  return(rss)
}

modelselectionreg<- function(x, y, iter){
  #Input: iter - number of iterations
  #Output: 
  dat <- data.frame(x,y)
  aic <- c()
  adjRsqr <- c()
  degree <- c()
  rss <- c()
  for (i in 1:iter) {
    model <- lm(y~poly(x, degree = i), data = dat)
    aic[i] <- AIC(model)
    adjRsqr[i]<- summary(model)$adj.r.squared
    degree[i] <- i
    rss[i] <- rss(model)
  }
  cals <- data.frame(Degree = degree, AIC = aic, Adjusted.R.Squared = adjRsqr, 
                     RSS = rss)
  pick <-which(cals$AIC == min(cals$AIC))
  selected <- cals[pick,]
  plot(1:iter,cals$Adjusted.R.Squared, type="l", main="Maximized adj. R-squared", 
       col="darkblue", pch=20, lwd=2, xlab="i", ylab="adj. R-squared")
  plot(1:iter,cals$AIC, type="l", main="Minimized AIC", col="darkblue", pch=20, 
       lwd=2, xlab="i", ylab="AIC")
  return(selected)
}

#Binsmooth 
#The function binsmoothREG performs a binsmooth regression with a user defined binlength
#Input Arguments:
#       x - vector containing the explonatory variable
#       y - vector containing the dependent variable
#       binlength - amount of x values per bin
#       ouptut - 1: delivers some output, 0: no output
#       opt   - 1: returns adj R-squared, 0: returns nothing
#       ploto - 1: Create new plot, 0: no new plot
binsmoothREG <- function(x, y, binlength=0, ploto=1, opt=1)
{
  #Sort x values in ascending order
  y <- y[order(x)]
  x <- sort(x)
  n <- length(x)
  #Devide data into bins
  bins = ceiling(length(x) / binlength)
  #Create Design Matrix without intercept
  DM <- matrix(1,length(x),bins)
  #Set all elements not corresponding to region j equal 0
  for(i in 1:bins)
  {
    if(i==1) { xstart = 1 }
    if(i>1) { xstart = (i-1)*binlength+1 }
    xend = min(xstart + binlength-1, length(x))
    binelements <- xstart:xend
    elements <- 1:length(x)
    elements[binelements] <- 0
    DM[elements,i] <- 0
  }
  
  #Perform Linear Regreesion
  reg <- lm(y~0+DM)
  #Calculate goodness of fit measures
  q <-as.numeric(bins)
  #Residual sum of squares
  rss <- as.numeric(sum(sapply(residuals(reg), function(x) { x^2 })))
  #Coefficient of determination: R^2
  R2 <- as.numeric(1 - (rss/ (t(y)%*%y-(mean(y)**2*n))))
  #Adjusted Coefficient of determination: R^2
  R2adj <-as.numeric(1 - ( (n-1)/(n-q) ) * (1-R2))   
  #AIC
  aic <- AIC(reg)
  
  
  #Graphic 
 if(ploto==1) plot(x,y, main="Binsmooth Regression", pch=20, col="black")
  
          j<-1
          for(i in 1:length(coef(reg)))
            {
    if(i>1) lines(c(x[xend],x[xend]), c(as.numeric(coef(reg)[i-1]), 
                                        as.numeric(coef(reg)[i])), col="red",
                  lwd=2)
    xstart = j
    if(i>1) lines(c(x[xend],x[xstart]), c(as.numeric(coef(reg)[i]),
                                          as.numeric(coef(reg)[i])), col="red",
                  lwd=2)
    xend = min(j+binlength-1, length(x))
    lines(c(x[xstart],x[xend]), rep(as.numeric(coef(reg)[i]), 2),
          col="red", lwd=2)
    j<-j+binlength
    
  }
  
  if(opt==1) return(list(Adjusted.R.Squared = R2adj,AIC = aic, RSS = rss,
                         numberofbins = bins, elementsperbin = binlength, Reg = reg))    
}


modelselectionsmooth<- function(x, y,iter){
  #Input: iter - number of iterations
  #Output: 
  aic <- c()
  adjRsqr <- c()
  bins <-c()
  RSS <- c()
  for (i in 1:iter) {
    model <- binsmoothREG(x,y,binlength = i,opt = 1, ploto = 0)
    aic[i] <- model$AIC
    adjRsqr[i]<- model$Adjusted.R.Squared
    bins[i]<-model$elementsperbin
    RSS[i]<- model$RSS
    }
  cals <- data.frame(Elements.Per.Bin = bins, AIC = round(aic,1), 
                     Adjusted.R.Squared = adjRsqr,RSS)
  cals<- na.omit(cals)
  pick <-which(cals$AIC == min(cals$AIC))
  selected <- cals[pick,]
  plot(1:nrow(cals),cals$Adjusted.R.Squared, type="l", main="Maximized adj. R-squared", 
       col="darkblue", pch=20, lwd=2, xlab="i", ylab="adj. R-squared")
  plot(1:nrow(cals),cals$AIC, type="l", main="Minimized AIC", col="darkblue", pch=20, 
       lwd=2, xlab="i", ylab="AIC")
  return(selected)
  }

#Measure of generalisation error
epe<- function(y,model){
  pred<- fitted(model)
  epe<- sum((y-pred)^2)
  return(epe)
}

