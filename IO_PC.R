# *************************************************************************
#  Model PC + 3-industry input-output (IO-PC)
#  Source: Godley & Lavoie ch.4, extended with a 3-industry IO core
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods    <- 100         # Periods
nScenarios  <- 2           # 1 baseline, 2 higher government spending
nIndustries <- 3           # Industries (agriculture, manufacturing, services)
nIter       <- 100         # Iterations to solve the simultaneous equations
alpha10     <- 0.8         # Endogenous-MPC: autonomous part
alpha11     <- 8           # Endogenous-MPC: sensitivity to interest (minus sign)
alpha2      <- 0.4         # Propensity to consume out of wealth
lambda0     <- 0.635       # Portfolio: baseline share of bills
lambda1     <- 5           # Portfolio: sensitivity of bill share to interest rate
lambda2     <- 0.01        # Portfolio: sensitivity of bill share to income/wealth
theta       <- 0.2         # Tax rate (on income AND interest)
wage        <- 0.4         # Uniform wage rate
mu          <- 0.875       # Uniform mark-up
pr          <- c(3.5, 5, 2.2)         # Labour productivity by industry
betaC       <- c(0.15, 0.35, 0.50)    # Household consumption shares by industry
betaG       <- c(0.10, 0.30, 0.60)    # Government spending shares by industry
A <- matrix(c(0.11, 0.12, 0.10,       # Input-output technical coefficients
              0.21, 0.22, 0.20,       #  A[k, l] = units of product k to make
              0.15, 0.18, 0.10),      #  one unit of product l
            nrow = nIndustries, byrow = TRUE)
Leontief <- solve(diag(nIndustries) - A)   # (I - A)^-1, computed once (A is constant)
Gexog       <- 20          # Government spending (real)
rbase       <- 0.025       # Baseline policy interest rate
shockStart  <- 50          # Period at which government spending starts to rise (scenario 2)
Gmax        <- 23          # Government spending ceiling after the shock (scenario 2)

# Create the financial variables as matrices [scenario, period] ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income (nominal GDP)
C   <- matrix(0, nScenarios, nPeriods)  # Consumption (REAL)
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
TAX <- matrix(0, nScenarios, nPeriods)  # Taxes
V   <- matrix(0, nScenarios, nPeriods)  # Household wealth
B_h <- matrix(0, nScenarios, nPeriods)  # Bills held by households
H_h <- matrix(0, nScenarios, nPeriods)  # Cash held by households
B_s <- matrix(0, nScenarios, nPeriods)  # Bills supplied by government
B_cb<- matrix(0, nScenarios, nPeriods)  # Bills held by central bank
H_s <- matrix(0, nScenarios, nPeriods)  # Cash supplied by central bank
alpha1 <- matrix(alpha10 - alpha11 * rbase, nScenarios, nPeriods)  # Propensity to consume out of income
infl<- matrix(0, nScenarios, nPeriods)  # Inflation-tax term (no money illusion)
p_c <- matrix(1, nScenarios, nPeriods)  # Consumer price index
p_g <- matrix(1, nScenarios, nPeriods)  # Government price index

# Industry-level variables as arrays [scenario, period, industry] ####
x <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Gross output by industry (real)
d <- array(0, dim = c(nScenarios, nPeriods, nIndustries))  # Final demand by industry (real)
p <- array(1, dim = c(nScenarios, nPeriods, nIndustries))  # Unit prices by industry

# Exogenous variables ####
G <- matrix(Gexog, nScenarios, nPeriods)   # Government spending (real)
r <- matrix(rbase, nScenarios, nPeriods)   # Policy interest rate

# Loop over scenarios ####
for (j in 1:nScenarios) {
  
  # Time loop
  for (i in 2:nPeriods) {
    
    # Shock: government spending grows toward Gmax from shockStart (scenario 2)
    if (i >= shockStart && j == 2) G[j, i] <- min(G[j, i - 1] + 0.1, Gmax)
    
    # Solve the SIMULTANEOUS equations by iteration
    for (iter in 1:nIter) {
      
      # A) PRICES (cost-plus mark-up over intermediate inputs) ####
      p[j, i, 1] = wage / pr[1] + (p[j,i,1]*A[1,1] + p[j,i,2]*A[2,1] + p[j,i,3]*A[3,1]) * (1 + mu)  # eq. 17
      p[j, i, 2] = wage / pr[2] + (p[j,i,1]*A[1,2] + p[j,i,2]*A[2,2] + p[j,i,3]*A[3,2]) * (1 + mu)  # eq. 17
      p[j, i, 3] = wage / pr[3] + (p[j,i,1]*A[1,3] + p[j,i,2]*A[2,3] + p[j,i,3]*A[3,3]) * (1 + mu)  # eq. 17
      p_c[j, i]  = sum(p[j, i, ] * betaC)                                          # Consumer price (18)
      p_g[j, i]  = sum(p[j, i, ] * betaG)                                          # Government price (19)
      
      # B) INPUT-OUTPUT QUANTITIES ####
      d[j, i, ] = betaC * C[j, i] + betaG * G[j, i]                                # Final demand by industry (14)
      x[j, i, ] = Leontief %*% d[j, i, ]                                           # Gross output by industry (15)
      Y[j, i]   = sum(p[j, i, ] * d[j, i, ])                                       # Nominal GDP (1.A)
      
      # C) HOUSEHOLDS ####
      YD[j, i]  = Y[j, i] - TAX[j, i] + r[j, i - 1] * B_h[j, i - 1]                # Disposable income (2)
      TAX[j, i] = theta * (Y[j, i] + r[j, i - 1] * B_h[j, i - 1])                  # Taxes on total income (3)
      V[j, i]   = V[j, i - 1] + (YD[j, i] - p_c[j, i] * C[j, i])                   # Wealth accumulation (4)
      alpha1[j, i] = alpha10 - alpha11 * r[j, i - 1]                               # Endogenous MPC (12)
      C[j, i]   = alpha1[j, i] * ((YD[j, i] / p_c[j, i]) - infl[j, i]) +
        alpha2 * V[j, i - 1] / p_c[j, i]                                           # Real consumption (5.A.1)
      infl[j, i]= ((p_c[j, i] - p_c[j, i - 1]) / p_c[j, i - 1]) * (V[j, i - 1] / p_c[j, i])  # Inflation tax
      
      # D) PORTFOLIO ####
      B_h[j, i] = V[j, i] * (lambda0 + lambda1 * r[j, i]) - lambda2 * YD[j, i]     # Bill demand (7, simplified)
      H_h[j, i] = V[j, i] - B_h[j, i]                                              # Household cash (6)
      
      # E) GOVERNMENT ####
      B_s[j, i] = B_s[j, i - 1] + (p_g[j, i] * G[j, i] + r[j, i - 1] * B_s[j, i - 1]) -
        (TAX[j, i] + r[j, i - 1] * B_cb[j, i - 1])                                 # Bill supply (8)
      
      # F) CENTRAL BANK ####
      B_cb[j, i]= B_s[j, i] - B_h[j, i]                                            # Central bank residual (10)
      H_s[j, i] = H_s[j, i - 1] + (B_cb[j, i] - B_cb[j, i - 1])                    # Cash supply (9)
      r[j, i]   = rbase                                                            # Policy rate (11)
    }
  }
}

# Display the results ####
sfcGap <- max(abs(H_h[, 2:nPeriods] - H_s[, 2:nPeriods]))
cat(" ******************************")
cat("\n Industries =", nIndustries)
cat("\n Scenarios =", nScenarios)
cat("\n Iterations/t =", nIter)
cat("\n Max |H_h - H_s| =", sfcGap)
cat("\n ******************************")
cat("\n Baseline steady-state values: \n Y =", round(Y[1, nPeriods], 2),
    "\n V =", round(V[1, nPeriods], 2),
    "\n B_h =", round(B_h[1, nPeriods], 2),
    "\n H_h =", round(H_h[1, nPeriods], 2),
    "\n p_c =", round(p_c[1, nPeriods], 3))
cat("\n ******************************")

# Plot the results ####
indCol <- c("springgreen4", "orangered", "dodgerblue3")   # Industry colours
indLab <- c("Agriculture", "Manufacturing", "Services")   # Industry names

plotScenario <- function(j, ttl, per) {

  # a) Consistency check
  plot(H_h[j, per] - H_s[j, per], type = "l", col = "seagreen", lwd = 2, font.main = 1,
       main = "a) Consistency check: H_h - H_s", xlab = "", ylab = "B#", ylim = range(-1, 1))
  abline(h = 0, lty = 3)
  
  # b) Disposable income and (nominal) consumption
  plot(YD[j, per], type = "l", col = "red", lwd = 2, font.main = 1,
       main = "b) Income and consumption", xlab = "", ylab = "B#",
       ylim = range(C[j, per] * p_c[j, per], YD[j, per]))
  lines(C[j, per] * p_c[j, per], col = "purple", lwd = 2)
  legend("right", c("Disposable income", "Nom. consumption"), col = c("red", "purple"),
         lwd = 2, bty = "n")
  
  # c) Final demand by industry (nominal)
  nd <- p[j, per, ] * d[j, per, ]
  matplot(nd, type = "l", lty = 1, lwd = 2, col = indCol, font.main = 1,
          main = "c) Final demand by industry (nominal)", xlab = "", ylab = "B#")
  legend("right", indLab, col = indCol, lwd = 2, bty = "n")
  
  # d) Gross output by industry (real)
  matplot(x[j, per, ], type = "l", lty = 1, lwd = 2, col = indCol, font.main = 1,
          main = "d) Gross output by industry (real)", xlab = "", ylab = "index")
  legend("right", indLab, col = indCol, lwd = 2, bty = "n")
  
  # e) Unit prices by industry
  matplot(p[j, per, ], type = "l", lty = 1, lwd = 2, col = indCol, font.main = 1,
          main = "e) Unit prices by industry", xlab = "", ylab = "B#")
  legend("right", indLab, col = indCol, lwd = 2, bty = "n")
  
  # f) Price indexes
  plot(p_c[j, per], type = "l", col = "brown", lwd = 2, font.main = 1,
       main = "f) Price indexes", xlab = "", ylab = "B#", ylim = range(0.9, 1.1))
  lines(p_g[j, per], col = "gold3", lwd = 2)
  legend("topright", c("Consumer", "Government"), col = c("brown", "gold3"), lwd = 2, bty = "n")
  title(ttl, outer = TRUE)
}

op = par(mfrow = c(3, 2), mar = c(4, 4, 2, 1), oma = c(0, 0, 2, 0))

plotScenario(1, "Baseline scenario", 2:nPeriods)                  # baseline

plotScenario(2, "Alternative scenario: higher government spending", shockStart:nPeriods)

par(op)
