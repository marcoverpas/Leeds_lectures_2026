# *************************************************************************
#  Model BMW + agent-based microfoundation (ABM-BMW)
#  Source: Godley & Lavoie ch.7 (BMW), extended with a "job-lottery"
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************
#  Description: A tiny "agent-based" version of the textbook BMW model:
#  several households, each with its own bank money (deposits) and its own
#  spending choice, added up to get the economy-wide totals
# *************************************************************************
#  Conventions: upper-case = MACRO total; lower-case = MICRO (one household)
# *************************************************************************
#  Story:
#    - each household decides how much it wants to spend (its OWN alpha1);
#    - the economy needs 1/pr workers for each unit people want to buy;
#    - a random job lottery fills those jobs (some stay unfilled = friction);
#    - whoever works makes pr goods; the wage bill left after interest and
#      depreciation, WB = Y - r_l*L(-1) - DA, is split equally among the
#      employed (so the per-worker wage is WB/Nemp);
#    - goods are sold first-come-first-served until they run out;
#    - taxes are paid.
#  One single random shuffle of households per period decides BOTH who gets a
#  job AND who reaches the shop first.
# *************************************************************************
#  Note on heterogeneity: each household now has its own fixed propensity to
#  consume out of income (alpha1 is a vector, drawn once). Because households
#  differ, aggregate demand depends on which of them earn income, so the random
#  order matters for the macro totals too. The effect is smaller than that of
#  the job-lottery noise.
# *************************************************************************
#  BMW-specific wrinkle: when hiring falls short, output < demand, so INVESTMENT
#  (served first) as well as consumption gets constrained -- and because the
#  investment accelerator feeds on output, the friction's recessionary bias is
#  AMPLIFIED (lower output -> lower target capital -> lower investment -> ...).
# *************************************************************************

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods   <- 150          # Periods
N          <- 500          # Households (workforce; > employment ever needed)
MC         <- 50           # Monte Carlo repetitions
alpha0     <- 25           # Autonomous consumption
alpha1m    <- 0.75         # Mean propensity to consume out of income
alpha1d    <- 0.1          # Spread of alpha1 across households (0 = homogeneous)
alpha2     <- 0.1          # Propensity to consume out of wealth (deposits)
delta      <- 0.1          # Depreciation rate
gamma      <- 0.15         # Speed of adjustment of capital to its target
kappa      <- 1            # Capital-output ratio
pr         <- 1            # Labour productivity
rl_bar     <- 0.04         # Loan rate (= deposit rate)
s          <- 0.1          # Hiring-lottery spread (0 = no friction)

# Heterogeneous, time-invariant propensity to consume (fixed population) ####
set.seed(0)
alpha1 <- runif(N, alpha1m - alpha1d, alpha1m + alpha1d)

# Store macro variables (one column per MC run) ####
store = list(Y  = matrix(0, nPeriods, MC),   # Output / income
             C  = matrix(0, nPeriods, MC),   # Consumption
             I  = matrix(0, nPeriods, MC),   # Investment
             K  = matrix(0, nPeriods, MC),   # Capital
             DA = matrix(0, nPeriods, MC),   # Depreciation
             Mh = matrix(0, nPeriods, MC),   # Deposits held by households
             L  = matrix(0, nPeriods, MC),   # Bank loans
             UR = matrix(0, nPeriods, MC))   # Unemployment rate
sfcGap <- 0
rl <- rl_bar; rm <- rl_bar

# Monte Carlo loop ####
for (mc in 1:MC) {
  
  set.seed(mc)
  m  <- rep(0, N)    # Micro: household deposits
  yd <- rep(0, N)    # Micro: household disposable income (LAST period)
  K <- 0; L <- 0; Ms <- 0; Ylag <- 0   # aggregate stocks (standard BMW)
  
  # Time loop (no inner iteration: agents act in sequence)
  for (i in 1:nPeriods) {
    
    ## FIRMS (aggregate, standard BMW): investment from the accelerator ##
    DA  <- delta * K                               # Depreciation
    Ipl <- max(0, gamma * (kappa * Ylag - K) + DA) # Planned gross investment (>= 0)
    
    ## HOUSEHOLDS plan consumption (own alpha1; last income + deposits) ##
    cd <- pmax(alpha0 / N + alpha1 * yd + alpha2 * m, 0)
    D  <- sum(cd) + Ipl                            # Total demand
    Ln <- D / pr                                   # Labour needed
    
    ## JOB LOTTERY (spread s): employment, hence output ##
    Nemp <- min(floor(Ln * runif(1, 1 - s, 1 + s)), floor(Ln), N)
    Y    <- Nemp * pr
    
    ## RATIONING: investment served first, households first-come-first-served ##
    Is    <- min(Ipl, Y); hPool <- Y - Is
    order <- sample(N)
    cdq   <- cd[order]; ahead <- cumsum(cdq) - cdq
    served<- pmin(cdq, pmax(0, hPool - ahead))
    c     <- rep(0, N); c[order] <- served         # Micro: actual consumption
    
    ## WAGES (residual) + interest, then deposits ##
    WB   <- Y - rl * L - DA                         # Wage bill = residual
    wage <- rep(0, N)
    if (Nemp >= 1) wage[order[1:Nemp]] <- WB / Nemp # Employed = first Nemp in the queue
    yd <- wage + rm * m                             # Disposable income = wage + interest
    m  <- m + yd - c                                # Deposit accumulation
    
    ## FIRMS borrow, BANK creates deposits ##
    Llag <- L
    K  <- K + Is - DA                               # Capital accumulation (realised)
    L  <- L + (Is - DA)                             # New loans cover net investment
    Ms <- Ms + (L - Llag)                           # Deposits from loans
    Mh <- sum(m)
    Ylag <- Y
    
    ## Record ##
    store$Y[i, mc] <- Y;  store$C[i, mc] <- sum(c);  store$I[i, mc] <- Is
    store$K[i, mc] <- K;  store$DA[i, mc] <- DA;     store$Mh[i, mc] <- Mh
    store$L[i, mc] <- L;  store$UR[i, mc] <- (N - Nemp) / N
    sfcGap <- max(sfcGap, abs(Mh - Ms))
  }
}

# Display the results ####
meanY <- rowMeans(store$Y); tail <- (nPeriods - 40):nPeriods
cat(" ******************************")
cat("\n Households =", N, "| MC runs =", MC, "| s =", s)
cat("\n Max |M_h - M_s| =", sfcGap)
cat("\n ******************************")
cat("\n Mean late-sample values: \n Y =", round(mean(meanY[tail]), 2),
    "\n I =", round(mean(rowMeans(store$I)[tail]), 2),
    "\n K =", round(mean(rowMeans(store$K)[tail]), 2),
    "\n M_h =", round(mean(rowMeans(store$Mh)[tail]), 2),
    "\n (frictionless BMW: Y=200, I=20, K=200, M_h=200)")
cat("\n ******************************")

# Plot the results (grey = runs, bold = MC mean) ####
op = par(mfrow = c(3, 2), mar = c(4, 4, 2, 1))
Ystar <- alpha0 / ((1 - alpha1m) * (1 - delta * kappa) - alpha2 * kappa)   # frictionless 200

# a) Output
matplot(store$Y, type = "l", lty = 1, col = "grey85", font.main = 1,
        main = "a) Output Y", xlab = "period", ylab = "")
lines(rowMeans(store$Y), lwd = 2, col = "dodgerblue"); abline(h = Ystar, lty = 2)

# b) Consumption
matplot(store$C, type = "l", lty = 1, col = "grey85", font.main = 1,
        main = "b) Consumption", xlab = "period", ylab = "")
lines(rowMeans(store$C), lwd = 2, col = "purple")

# c) Investment and depreciation
matplot(store$I, type = "l", lty = 1, col = "grey88", font.main = 1,
        main = "c) Investment & depreciation", xlab = "period", ylab = "")
lines(rowMeans(store$I), lwd = 2, col = "orchid")
lines(rowMeans(store$DA), lwd = 2, col = "gray40", lty = 2)
legend("right", c("Investment", "Depreciation"), col = c("orchid", "gray40"),
       lwd = 2, lty = c(1, 2), bty = "n")

# d) Capital stock
matplot(store$K, type = "l", lty = 1, col = "grey88", font.main = 1,
        main = "d) Capital stock", xlab = "period", ylab = "")
lines(rowMeans(store$K), lwd = 2, col = "darkorange")

# e) Deposits and loans (they coincide: M_h = M_s = L)
matplot(store$Mh, type = "l", lty = 1, col = "grey88", font.main = 1,
        main = "e) Deposits (= loans)", xlab = "period", ylab = "")
lines(rowMeans(store$Mh), lwd = 2, col = "steelblue")

# f) Unemployment rate (emergent)
matplot(store$UR, type = "l", lty = 1, col = "grey88", font.main = 1,
        main = "f) Unemployment rate (emergent)", xlab = "period", ylab = "")
lines(rowMeans(store$UR), lwd = 2, col = "salmon")

par(op)

dev.copy(png, "Fig1_ABM_BMW.png", width = 3000, height = 2400, res = 300); dev.off()