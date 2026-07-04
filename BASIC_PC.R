# *************************************************************************
#  Model PC (aggregate) 
#  Source: Godley & Lavoie, Monetary Economics, chapter 4
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods    <- 150         # Periods
nScenarios  <- 3           # 1 baseline, 2 rate rise, 3 rate rise + endogenous MPC
alpha1base  <- 0.6         # Propensity to consume out of income (baseline)
alpha11     <- 0.65        # Endogenous-MPC: autonomous part          (scenario 3)
alpha12     <- 2           # Endogenous-MPC: sensitivity to interest  (scenario 3)
alpha2      <- 0.4         # Propensity to consume out of wealth
lambda0     <- 0.635       # Portfolio: baseline share of bills
lambda1     <- 5           # Portfolio: sensitivity of bill share to interest rate
lambda2     <- 0.01        # Portfolio: sensitivity of bill share to income/wealth
theta       <- 0.2         # Tax rate (on labour AND interest income)
Gexog       <- 20          # Government spending (once switched on)
rbase       <- 0.025       # Baseline policy interest rate
rshock      <- 0.035       # Shocked policy rate
shockStart  <- 102         # Period at which the rate rises (scenarios 2 and 3)

# Create the variables as matrices, all starting at zero ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income
C   <- matrix(0, nScenarios, nPeriods)  # Consumption
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
TAX <- matrix(0, nScenarios, nPeriods)  # Taxes
V   <- matrix(0, nScenarios, nPeriods)  # Household wealth
B_h <- matrix(0, nScenarios, nPeriods)  # Bills held by households
H_h <- matrix(0, nScenarios, nPeriods)  # Cash held by households
B_s <- matrix(0, nScenarios, nPeriods)  # Bills supplied by government
B_cb<- matrix(0, nScenarios, nPeriods)  # Bills held by central bank
H_s <- matrix(0, nScenarios, nPeriods)  # Cash supplied by central bank

# Exogenous variables ####
G <- matrix(0,     nScenarios, nPeriods)   # Government spending
r <- matrix(rbase, nScenarios, nPeriods)   # Policy interest rate

# Shocks ####
G[, 2:nPeriods] <- Gexog                             # Spending switched on in period 2
r[2:nScenarios, shockStart:nPeriods] <- rshock       # Rate rise in scenarios 2 and 3

# Loop over scenarios ####
for (j in 1:nScenarios) {
  
  # Time loop 
  for (i in 2:nPeriods) {
    
    # Solve the SIMULTANEOUS equations by iteration
    for (iter in 1:100) {
      
      Y[j, i]   = C[j, i] + G[j, i]                                            # Output = demand (4.1)
      YD[j, i]  = Y[j, i] - TAX[j, i] + r[j, i - 1] * B_h[j, i - 1]            # Disposable income (4.2)
      TAX[j, i] = theta * (Y[j, i] + r[j, i - 1] * B_h[j, i - 1])              # Taxes on total income (4.3)
      V[j, i]   = V[j, i - 1] + (YD[j, i] - C[j, i])                           # Wealth accumulation (4.4)
      alpha1 = if (j == 3) alpha11 - alpha12 * r[j, i - 1] else alpha1base     # MPC
      C[j, i]   = alpha1 * YD[j, i] + alpha2 * V[j, i]                         # Consumption (4.5)
      B_h[j, i] = V[j, i] * (lambda0 + lambda1 * r[j, i]) - lambda2 * YD[j, i] # Bill demand (4.7)
      B_s[j, i] = B_s[j, i - 1] + (G[j, i] + r[j, i - 1] * B_s[j, i - 1]) -
        (TAX[j, i] + r[j, i - 1] * B_cb[j, i - 1])                             # Bill supply (4.8)
      B_cb[j, i]= B_s[j, i] - B_h[j, i]                                        # Central bank residual (4.10)
      H_s[j, i] = H_s[j, i - 1] + (B_cb[j, i] - B_cb[j, i - 1])                # Cash supply (4.9)
      H_h[j, i] = V[j, i] - B_h[j, i]                                          # Household cash (4.6)
    }
  }
}
# Display the results ####
Ystar  <- (Gexog + rbase * 64.86478 * (1 - theta)) / theta                     # Analytic steady-state GDP (baseline)
sfcGap <- max(abs(H_h[1, 2:nPeriods] - H_s[1, 2:nPeriods]))
cat(" ******************************")
cat("\n Max |H_h - H_s| =", sfcGap)
cat("\n ******************************")
cat("\n Baseline steady-state values: \n Y =", round(Y[1, nPeriods], 2),
    "\n V =", round(V[1, nPeriods], 2),
    "\n B_h =", round(B_h[1, nPeriods], 2),
    "\n H_h =", round(H_h[1, nPeriods], 2))
cat("\n ******************************")

# Plot the results ####
op = par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))

# a) Consistency check (baseline): H_h - H_s should hug zero
plot(H_h[1, 2:nPeriods] - H_s[1, 2:nPeriods], type = "l", col = "seagreen", lwd = 2,
     font.main = 1, main = "a) Consistency check: H_h - H_s", xlab = "period", ylab = "",
     ylim = range(-1, 1)); abline(h = 0, lty = 3)

# b) Income building up after government spending starts (baseline)
plot(Y[1, 2:45], type = "l", col = "dodgerblue", lwd = 2, font.main = 1,
     main = "b) Income after government spending", xlab = "period", ylab = "",
     ylim = range(30, 120)); abline(h = Ystar, lty = 2)
legend("bottomright", c("National income", "Steady state"),
       col = c("dodgerblue", "black"), lwd = c(2, 1), lty = c(1, 2), bty = "n")

# c) Portfolio over time (baseline): bills vs cash
yr = range(H_h[1, 2:nPeriods], B_h[1, 2:nPeriods])
plot(B_h[1, 2:nPeriods], type = "l", col = "firebrick", lwd = 2, font.main = 1,
     main = "c) Portfolio: bills and cash (baseline)", xlab = "period", ylab = "", ylim = yr)
lines(H_h[1, 2:nPeriods], col = "steelblue", lwd = 2)
legend("right", c("Bills B_h", "Cash H_h"), col = c("firebrick", "steelblue"),
       lwd = 2, bty = "n")

# d) Income after the interest-rate rise (exogenous vs endogenous MPC)
yr = range(Y[2, 100:145], Y[3, 100:145])
plot(Y[2, 100:145], type = "l", col = "green2", lwd = 2, font.main = 1,
     main = "d) Income after interest-rate rise", xlab = "period (from 100)", ylab = "",
     ylim = yr)
lines(Y[3, 100:145], col = "purple", lwd = 2)
abline(h = Y[1, 100], lty = 3)
legend("right", c("Exogenous MPC", "Endogenous MPC", "Baseline"),
       col = c("green2", "purple", "black"), lwd = c(2, 2, 1), lty = c(1, 1, 3), bty = "n")

par(op)
