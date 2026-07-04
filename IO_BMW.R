# *************************************************************************
#  Model BMW + 3-industry input-output (IO-BMW)
#  Source: Godley & Lavoie ch.7 (BMW), extended with a 3-industry IO core
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods    <- 150         # Periods
nScenarios  <- 2           # 1 baseline, 2 higher autonomous consumption
nIndustries <- 3           # Industries
nIter       <- 100         # Iterations to solve the simultaneous equations
alpha1      <- 0.75        # Propensity to consume out of income
alpha2      <- 0.1         # Propensity to consume out of wealth
delta       <- 0.1         # Depreciation rate
gamma       <- 0.15        # Speed of adjustment of capital to its target
wage        <- 0.4         # Uniform wage rate (a price/cost parameter)
mu          <- 0.875       # Uniform mark-up
pr          <- c(3.5, 5, 2.2)         # Labour productivity by industry
betaC       <- c(0.15, 0.35, 0.50)    # Consumption shares by industry
betaI       <- c(0.20, 0.50, 0.30)    # Investment shares by industry
kappaz      <- c(0.54, 0.54, 0.54)    # Capital-to-GROSS-output ratio by industry
# (calibrated so the steady state ~ aggregate BMW)
A <- matrix(c(0.11, 0.12, 0.10,
              0.21, 0.22, 0.20,
              0.15, 0.18, 0.10), nrow = nIndustries, byrow = TRUE)   # technical coefficients
Leontief <- solve(diag(nIndustries) - A)     # (I - A)^-1
rl_bar   <- 0.04           # Loan rate (= deposit rate)
alpha0base <- 25           # Autonomous consumption
alpha0shock<- 28           # Higher autonomous consumption (scenario 2)
shockStart <- 52

# Financial / aggregate variables as matrices [scenario, period] ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income (nominal GDP)
C   <- matrix(0, nScenarios, nPeriods)  # Consumption (REAL)
Ir  <- matrix(0, nScenarios, nPeriods)  # Investment (REAL, aggregate)
DAr <- matrix(0, nScenarios, nPeriods)  # Depreciation (REAL, aggregate)
WB  <- matrix(0, nScenarios, nPeriods)  # Household income from firms (residual)
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
M_h <- matrix(0, nScenarios, nPeriods)  # Deposits held by households (= wealth)
M_s <- matrix(0, nScenarios, nPeriods)  # Deposits supplied by banks
L   <- matrix(0, nScenarios, nPeriods)  # Bank loans to firms
p_c <- matrix(1, nScenarios, nPeriods)  # Consumer price index
p_i <- matrix(1, nScenarios, nPeriods)  # Investment price index

# Industry-level variables as arrays [scenario, period, industry] ####
x   <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Gross output
d   <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Final demand
p   <- array(1, dim = c(nScenarios, nPeriods, nIndustries))  # Unit prices
kz  <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Capital by industry
ktz <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Target capital by industry
idz <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Investment by industry
daz <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Depreciation by industry

# Exogenous variables ####
alpha0 <- matrix(0,      nScenarios, nPeriods)   # Autonomous consumption
rl     <- matrix(rl_bar, nScenarios, nPeriods)   # Loan rate
rm     <- matrix(rl_bar, nScenarios, nPeriods)   # Deposit rate

# Loop over scenarios ####
for (j in 1:nScenarios) {
  
  # Time loop
  for (i in 2:nPeriods) {
    
    # Shock
    alpha0[j, i] <- alpha0base
    if (i >= shockStart && j == 2) alpha0[j, i] <- alpha0shock
    
    # Solve the SIMULTANEOUS equations by iteration
    for (iter in 1:nIter) {
      
      # A) PRICES (cost-plus mark-up) ####
      p[j, i, 1] = wage / pr[1] + (p[j,i,1]*A[1,1] + p[j,i,2]*A[2,1] + p[j,i,3]*A[3,1]) * (1 + mu)
      p[j, i, 2] = wage / pr[2] + (p[j,i,1]*A[1,2] + p[j,i,2]*A[2,2] + p[j,i,3]*A[3,2]) * (1 + mu)
      p[j, i, 3] = wage / pr[3] + (p[j,i,1]*A[1,3] + p[j,i,2]*A[2,3] + p[j,i,3]*A[3,3]) * (1 + mu)
      p_c[j, i]  = sum(p[j, i, ] * betaC)
      p_i[j, i]  = sum(p[j, i, ] * betaI)
      
      # B) CAPITAL (per-industry accelerator, driven by gross output) ####
      ktz[j, i, ] = kappaz * x[j, i - 1, ]                        # Target capital by industry (gross output)
      daz[j, i, ] = delta * kz[j, i - 1, ]                        # Depreciation by industry
      idz[j, i, ] = gamma * (ktz[j, i, ] - kz[j, i - 1, ]) + daz[j, i, ]   # Investment by industry
      kz[j, i, ]  = kz[j, i - 1, ] + idz[j, i, ] - daz[j, i, ]    # Capital accumulation by industry
      Ir[j, i]  = sum(idz[j, i, ])                                # Aggregate real investment
      DAr[j, i] = sum(daz[j, i, ])                                # Aggregate real depreciation
      Inom  = p_i[j, i] * Ir[j, i]                                # Nominal investment
      DAnom = p_i[j, i] * DAr[j, i]                               # Nominal depreciation
      
      # C) INPUT-OUTPUT QUANTITIES ####
      d[j, i, ]  = betaC * C[j, i] + betaI * Ir[j, i]             # Final demand = consumption + investment
      x[j, i, ]  = Leontief %*% d[j, i, ]                         # Gross output
      Y[j, i]    = sum(p[j, i, ] * d[j, i, ])                     # Nominal GDP 
      
      # D) HOUSEHOLDS (BMW: household income is the residual) ####
      WB[j, i] = Y[j, i] - rl[j, i - 1] * L[j, i - 1] - DAnom     # Income from firms
      YD[j, i] = WB[j, i] + rm[j, i - 1] * M_h[j, i - 1]          # Disposable income
      C[j, i]  = alpha0[j, i] + alpha1 * (YD[j, i] / p_c[j, i]) +
        alpha2 * (M_h[j, i - 1] / p_c[j, i])                      # Real consumption
      M_h[j, i] = M_h[j, i - 1] + YD[j, i] - p_c[j, i] * C[j, i]  # Deposit accumulation
      
      # E) BANKS ####
      L[j, i]   = L[j, i - 1] + (Inom - DAnom)                    # Loans finance net investment
      M_s[j, i] = M_s[j, i - 1] + (L[j, i] - L[j, i - 1])         # Deposits from loans
      rm[j, i]  = rl[j, i] = rl_bar                               # Interest rates
    }
  }
}
# Display the results ####
sfcGap <- max(abs(M_h[, 2:nPeriods] - M_s[, 2:nPeriods]))
cat(" ******************************")
cat("\n Industries =", nIndustries)
cat("\n Scenarios =", nScenarios)
cat("\n Iterations/t =", nIter)
cat("\n Max |M_h - M_s| =", sfcGap)
cat("\n ******************************")
cat("\n Baseline steady-state values: \n Y =", round(Y[1, nPeriods], 2),
    "\n I =", round(Ir[1, nPeriods], 2),
    "\n K =", round(sum(kz[1, nPeriods, ]), 2),
    "\n M_h =", round(M_h[1, nPeriods], 2))
cat("\n ******************************")

# Plot the results ####
indCol <- c("springgreen4", "orangered", "dodgerblue3")
indLab <- c("Industry 1", "Industry 2", "Industry 3")
plotScenario <- function(j, ttl, per) {
  
  # a) Consistency check
  plot(M_h[j, per] - M_s[j, per], type = "l", col = "seagreen", lwd = 2, font.main = 1,
       main = "a) Consistency check: M_h - M_s", xlab = "", ylab = "", ylim = range(-1, 1))
  abline(h = 0, lty = 3)
  
  # b) Income and (nominal) consumption
  plot(Y[j, per], type = "l", col = "black", lwd = 2, font.main = 1,
       main = "b) Income and consumption", xlab = "", ylab = "",
       ylim = range(C[j, per] * p_c[j, per], Y[j, per]))
  lines(C[j, per] * p_c[j, per], col = "purple", lwd = 2)
  legend("right", c("Income Y", "Nom. consumption"), col = c("black", "purple"), lwd = 2, bty = "n")
  
  # c) Investment and depreciation (real)
  plot(Ir[j, per], type = "l", col = "orchid", lwd = 2, font.main = 1,
       main = "c) Investment & depreciation (real)", xlab = "", ylab = "",
       ylim = range(DAr[j, per], Ir[j, per]))
  lines(DAr[j, per], col = "gray50", lwd = 2, lty = 2)
  legend("right", c("Investment", "Depreciation"), col = c("orchid", "gray50"),
         lwd = 2, lty = c(1, 2), bty = "n")
  
  # d) Gross output by industry (real)
  matplot(x[j, per, ], type = "l", lty = 1, lwd = 2, col = indCol, font.main = 1,
          main = "d) Gross output by industry (real)", xlab = "", ylab = "")
  legend("right", indLab, col = indCol, lwd = 2, bty = "n")
  
  # e) Unit prices by industry
  matplot(p[j, per, ], type = "l", lty = 1, lwd = 2, col = indCol, font.main = 1,
          main = "e) Unit prices by industry", xlab = "", ylab = "")
  legend("right", indLab, col = indCol, lwd = 2, bty = "n")
  
  # f) Deposits and loans
  plot(M_h[j, per], type = "l", col = "steelblue", lwd = 2, font.main = 1,
       main = "f) Deposits and loans", xlab = "", ylab = "", ylim = range(L[j, per], M_h[j, per]))
  lines(L[j, per], col = "firebrick", lwd = 2, lty = 2)
  legend("right", c("Deposits M_h", "Loans L"), col = c("steelblue", "firebrick"),
         lwd = 2, lty = c(1, 2), bty = "n")
  title(ttl, outer = TRUE)
}

op = par(mfrow = c(3, 2), mar = c(4, 4, 2, 1), oma = c(0, 0, 2, 0))

# Set folder
setwd("C:/Users/marco/My Drive/New Conferences/Leeds 2026/Codes/Figures")

plotScenario(1, "Baseline scenario", 2:nPeriods)                  # baseline
dev.copy(png, "Fig1_IO_BMW.png", width = 3000, height = 2400, res = 300); dev.off()

plotScenario(2, "Alternative scenario: higher government spending", shockStart:nPeriods)
dev.copy(png, "Fig2_IO_BMW.png", width = 3000, height = 2400, res = 300); dev.off()

par(op)