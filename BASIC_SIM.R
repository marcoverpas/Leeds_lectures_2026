# *************************************************************************
#  Model SIM (aggregate)
#  Source: Godley & Lavoie, Monetary Economics, chapter 3
#  Last change: 01/07/2026
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods    <- 100         # Periods
nScenarios  <- 2           # 1 baseline, 2 higher government spending
alpha1      <- 0.6         # Propensity to consume out of income
alpha2      <- 0.4         # Propensity to consume out of wealth
theta       <- 0.2         # Tax rate on income
Gexog       <- 20          # Government spending (once switched on)
Gshock      <- 30          # Higher government spending (scenario 2)
shockStart  <- 50          # Period at which spending rises (scenario 2)

# Create the variables as matrices [scenario, period], all starting at zero ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income
C   <- matrix(0, nScenarios, nPeriods)  # Consumption
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
TAX <- matrix(0, nScenarios, nPeriods)  # Taxes
V   <- matrix(0, nScenarios, nPeriods)  # Household wealth (= money in SIM)
H_h <- matrix(0, nScenarios, nPeriods)  # Money held by households
H_s <- matrix(0, nScenarios, nPeriods)  # Money supplied by the government

# Exogenous variables ####
G <- matrix(0, nScenarios, nPeriods)    # Government spending

# Shocks ####
G[, 2:nPeriods] <- Gexog                          # Spending switched on in period 2
G[2, shockStart:nPeriods] <- Gshock               # Higher spending in scenario 2

# Loop over scenarios ####
for (j in 1:nScenarios) {
  
  # Time loop
  for (i in 2:nPeriods) {
    
    # Solve the SIMULTANEOUS equations by iteration
    for (iter in 1:100) {
      
      Y[j, i]   = C[j, i] + G[j, i]                        # Output = demand
      YD[j, i]  = Y[j, i] - TAX[j, i]                      # Disposable income
      TAX[j, i] = theta * Y[j, i]                          # Taxes on income
      V[j, i]   = V[j, i - 1] + (YD[j, i] - C[j, i])       # Wealth accumulation
      C[j, i]   = alpha1 * YD[j, i] + alpha2 * V[j, i]     # Consumption
      H_h[j, i] = V[j, i]                                  # Money held = wealth
      H_s[j, i] = H_s[j, i - 1] + (G[j, i] - TAX[j, i])    # Money supply = cumulative deficit
    }
  }
}

# Display the results ####
Ystar  <- Gexog / theta                                    # Analytic steady-state GDP (baseline)
sfcGap <- max(abs(H_h[1, 2:nPeriods] - H_s[1, 2:nPeriods]))
cat(" ******************************")
cat("\n Max |H_h - H_s| =", sfcGap)
cat("\n ******************************")
cat("\n Baseline steady-state values: \n Y =", round(Y[1, nPeriods], 2),
    "\n V =", round(V[1, nPeriods], 2),
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
     ylim = range(0, 120)); abline(h = Ystar, lty = 2)
legend("bottomright", c("National income", "Steady state"),
       col = c("dodgerblue", "black"), lwd = c(2, 1), lty = c(1, 2), bty = "n")

# c) Money stock building up (baseline)
plot(H_h[1, 2:nPeriods], type = "l", col = "darkorange", lwd = 2, font.main = 1,
     main = "c) Money stock (baseline)", xlab = "period", ylab = "")
abline(h = (1 - theta) * Gexog / theta * (1 - alpha1) / alpha2, lty = 2)  # steady-state H

# d) Income after the government-spending rise (scenario 2 vs baseline)
yr = range(Y[1, 40:nPeriods], Y[2, 40:nPeriods])
plot(Y[2, 40:nPeriods], type = "l", col = "firebrick", lwd = 2, font.main = 1,
     main = "d) Income after higher spending", xlab = "period (from 40)", ylab = "", ylim = yr)
lines(Y[1, 40:nPeriods], col = "black", lwd = 1, lty = 3)
legend("right", c("Higher spending", "Baseline"), col = c("firebrick", "black"),
       lwd = c(2, 1), lty = c(1, 3), bty = "n")

par(op)