# *************************************************************************
#  Model BMW (aggregate)
#  Source: Godley & Lavoie, Monetary Economics, chapter 7
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods    <- 150         # Periods
nScenarios  <- 6           # 1 baseline + 5 experiments
alpha2      <- 0.1         # Propensity to consume out of wealth
delta       <- 0.1         # Depreciation rate
gamma       <- 0.15        # Speed of adjustment of capital to its target
alpha1r     <- 0.5         # Propensity to consume out of interest (scenario 5)
alpha1w     <- 0.75        # Propensity to consume out of wages   (scenario 5)
pr          <- 1           # Labour productivity

# Exogenous variables as matrices (so they can take scenario-specific shocks) ####
alpha0 <- matrix(0,    nScenarios, nPeriods)   # Autonomous consumption
alpha1 <- matrix(0.75, nScenarios, nPeriods)   # Propensity to consume out of income
kappa  <- matrix(1,    nScenarios, nPeriods)   # Target capital-output ratio
rl_bar <- matrix(0.04, nScenarios, nPeriods)   # Policy loan rate

# Create the variables as matrices [scenario, period] ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income
C   <- matrix(0, nScenarios, nPeriods)  # Consumption
I   <- matrix(0, nScenarios, nPeriods)  # Investment
K   <- matrix(0, nScenarios, nPeriods)  # Capital stock
KT  <- matrix(0, nScenarios, nPeriods)  # Target capital stock
DA  <- matrix(0, nScenarios, nPeriods)  # Depreciation allowances
L   <- matrix(0, nScenarios, nPeriods)  # Bank loans
M_h <- matrix(0, nScenarios, nPeriods)  # Deposits held by households (= wealth)
M_s <- matrix(0, nScenarios, nPeriods)  # Deposits supplied by banks
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
WB  <- matrix(0, nScenarios, nPeriods)  # Wage bill
N   <- matrix(0, nScenarios, nPeriods)  # Employment
w   <- matrix(0.86, nScenarios, nPeriods)  # Wage rate
rl  <- matrix(0.04, nScenarios, nPeriods)  # Loan rate
rm  <- matrix(0.04, nScenarios, nPeriods)  # Deposit rate
Ystar <- matrix(0, nScenarios, nPeriods)   # Analytic steady-state income

# Loop over scenarios ####
for (j in 1:nScenarios) {
  
  # Time loop
  for (i in 2:nPeriods) {
    
    # Shocks ####
    alpha0[j, i] <- 25                                   # autonomous consumption switched on
    if (i >= 52 && j == 2) kappa[j, i]  <- 1.1           # higher target capital-output
    if (i >= 52 && j == 3) kappa[j, i]  <- 0.9           # lower target capital-output
    if (i >= 52 && j == 4) alpha0[j, i] <- 28            # higher autonomous consumption
    if (i >= 52 && j == 5) rl_bar[j, i] <- 0.05          # higher interest rate (uses c(r))
    if (i >= 52 && j == 6) alpha1[j, i] <- 0.74          # higher propensity to save
    
    # Solve the SIMULTANEOUS equations by iteration
    for (iter in 1:100) {
      
      # A) FIRMS ####
      Y[j, i]  = C[j, i] + I[j, i]                                  # GDP (7.5)
      WB[j, i] = Y[j, i] - rl[j, i - 1] * L[j, i - 1] - DA[j, i]    # Wage bill = residual (7.6, 7.7)
      L[j, i]  = L[j, i - 1] + I[j, i] - DA[j, i]                   # Loans finance net investment (7.8)
      N[j, i]  = Y[j, i] / pr                                       # Employment (7.14)
      w[j, i]  = WB[j, i] / N[j, i]                                 # Wage rate (7.15)
      
      # B) HOUSEHOLDS ####
      YD[j, i]  = WB[j, i] + rm[j, i - 1] * M_h[j, i - 1]           # Disposable income (7.9)
      M_h[j, i] = M_h[j, i - 1] + YD[j, i] - C[j, i]                # Deposit accumulation (7.10)
      if (j == 5)                                                   # Consumption (7.16 / 7.16A)
        C[j, i] = alpha0[j, i] + alpha1w * WB[j, i] +
        alpha1r * rm[j, i - 1] * M_h[j, i - 1] + alpha2 * M_h[j, i - 1]
      else
        C[j, i] = alpha0[j, i] + alpha1[j, i] * YD[j, i] + alpha2 * M_h[j, i - 1]
      
      # C) INVESTMENT ####
      K[j, i]  = K[j, i - 1] + I[j, i] - DA[j, i]                   # Capital accumulation (7.17)
      DA[j, i] = delta * K[j, i - 1]                                # Depreciation (7.18)
      KT[j, i] = kappa[j, i] * Y[j, i - 1]                          # Target capital (7.19)
      I[j, i]  = gamma * (KT[j, i] - K[j, i - 1]) + DA[j, i]        # Investment (7.20)
      
      # D) BANKS ####
      M_s[j, i] = M_s[j, i - 1] + (L[j, i] - L[j, i - 1])           # Deposits from loans (7.11)
      rm[j, i]  = rl[j, i]                                          # Deposit rate (7.12)
      rl[j, i]  = rl_bar[j, i]                                      # Loan rate (7.21)
      
      # Analytic steady-state income (for reference)
      Ystar[j, i] = alpha0[j, i] /
        ((1 - alpha1[j, i]) * (1 - delta * kappa[j, i]) - alpha2 * kappa[j, i])
    }
  }
}

# Display the results ####
sfcGap <- max(abs(M_h[1, 2:nPeriods] - M_s[1, 2:nPeriods]))
cat(" ******************************")
cat("\n Max |M_h - M_s| =", sfcGap)
cat("\n ******************************")
cat("\n Baseline steady-state values: \n Y =", round(Y[1, nPeriods], 2),
    "\n K =", round(K[1, nPeriods], 2),
    "\n I =", round(I[1, nPeriods], 2),
    "\n M_h =", round(M_h[1, nPeriods], 2))
cat("\n ******************************")

# Plot the results ####
op = par(mfrow = c(3, 2), mar = c(4, 4, 3, 1))

# 1) Baseline income vs analytic steady state
plot(Y[1, 2:45], type = "l", col = "black", lwd = 2, font.main = 1,
     main = "a) Income after autonomous consumption", xlab = "period", ylab = "",
     ylim = range(100, 230))
lines(Ystar[1, 2:45], col = "dodgerblue", lwd = 2, lty = 2)
legend("bottomright", c("National income", "Steady state"),
       col = c("black", "dodgerblue"), lwd = 2, lty = c(1, 2), bty = "n")

# 2) Disposable income & consumption after autonomous-consumption shock (scenario 4)
plot(YD[4, 48:140], type = "l", col = "aquamarine3", lwd = 2, font.main = 1,
     main = "b) Income & consumption (cons. shock)", xlab = "period (from 48)", ylab = "")
lines(C[4, 48:140], col = "aquamarine4", lwd = 2, lty = 3)
legend("bottomright", c("Disposable income", "Consumption"),
       col = c("aquamarine3", "aquamarine4"), lwd = 2, lty = c(1, 3), bty = "n")

# 3) Investment & depreciation after the same shock (scenario 4)
plot(I[4, 48:140], type = "l", col = "orchid", lwd = 2, font.main = 1,
     main = "c) Investment & depreciation (cons. shock)", xlab = "period (from 48)", ylab = "")
lines(DA[4, 48:140], col = "gray50", lwd = 2, lty = 2)
legend("right", c("Gross investment", "Depreciation"),
       col = c("orchid", "gray50"), lwd = 2, lty = c(1, 2), bty = "n")

# 4) Paradox of thrift: higher propensity to save (scenario 6)
plot(YD[6, 48:140], type = "l", col = "aquamarine3", lwd = 2, font.main = 1,
     main = "d) Paradox of thrift (higher saving)", xlab = "period (from 48)", ylab = "")
lines(C[6, 48:140], col = "aquamarine4", lwd = 2, lty = 3)
legend("bottomright", c("Disposable income", "Consumption"),
       col = c("aquamarine3", "aquamarine4"), lwd = 2, lty = c(1, 3), bty = "n")

# 5) Income after change in target capital-output (scenario 2 vs 3)
yr = range(Y[3, 48:140], Y[2, 48:140])
plot(Y[2, 48:140], type = "l", col = "firebrick", lwd = 2, font.main = 1,
     main = "e) Income after capital-output change", xlab = "period (from 48)", ylab = "",
     ylim = yr)
lines(Y[3, 48:140], col = "green3", lwd = 2)
lines(Y[1, 48:140], col = "black", lwd = 1, lty = 2)
legend("right", c("Higher K/Y", "Lower K/Y", "Baseline"),
       col = c("firebrick", "green3", "black"), lwd = c(2, 2, 1), lty = c(1, 1, 2), bty = "n")

# 6) Income after an interest-rate rise (scenario 5)
plot(Y[5, 48:140], type = "l", col = "coral3", lwd = 2, font.main = 1,
     main = "f) Income after interest-rate rise", xlab = "period (from 48)", ylab = "")
abline(h = Y[5, 48], lty = 3)

par(op)
