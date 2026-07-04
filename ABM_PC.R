# *************************************************************************
#  Model PC + agent-based microfoundation (ABM-PC)
#  Source: Godley & Lavoie ch.4 (PC), extended with a "job-lottery"
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************
#  Description: A tiny "agent-based" version of the textbook PC model: 
#  several households, each with its own wealth (cash & bonds) and its own
#  spending choice, added up to get the economy-wide totals
# *************************************************************************
#  Conventions: upper-case = MACRO total; lower-case = MICRO (one household)
# *************************************************************************
#  Story:
#    - each household decides how much it wants to spend (its OWN alpha1);
#    - the economy needs 1/pr workers for each unit people want to buy;
#    - a random job lottery fills those jobs (some stay unfilled = friction);
#    - whoever works makes pr goods and is paid a wage w = pr;
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

# Clear environment
rm(list = ls(all = TRUE))

# Set model parameters ####
nPeriods     <- 100        # Periods
nHouseholds  <- 200        # Number of households (if > output -> unemployment)
alpha1m      <- 0.6        # Mean propensity to consume out of income
alpha1d      <- 0.0        # Spread of alpha1 across households (0 = homogeneous PC)
alpha2       <- 0.4        # Propensity to consume out of wealth (common to all)
theta        <- 0.2        # Tax rate (on labour AND interest income)
pr           <- 1.1        # Product per worker (labour productivity)
w            <- pr         # Wage per worker = productivity (=> zero profit)
G            <- rep(20, nPeriods)   # Government spending (goods)
lambda0      <- 0.635      # Portfolio: baseline share of bills
lambda1      <- 5          # Portfolio: sensitivity of bill share to interest rate
lambda2      <- 0.01       # Portfolio: sensitivity of bill share to income/wealth

# Define randomness
MC           <- 100        # MC simulations
s            <- 0.2        # Size of the hiring randomness
set.seed(123)              # Set random seed

# Heterogeneous, time-invariant propensity to consume out of income ####
alpha1 <- runif(nHouseholds, alpha1m - alpha1d, alpha1m + alpha1d)

# Interest rate
r <- rep(0.025, nPeriods)   # Baseline policy rate

# Define macro variables (results) to be stored ####
store = list(Y   = matrix(0, nPeriods, MC),   # Output / income
             C   = matrix(0, nPeriods, MC),   # Consumption
             YD  = matrix(0, nPeriods, MC),   # Disposable income
             V   = matrix(0, nPeriods, MC),   # Household wealth
             B_h = matrix(0, nPeriods, MC),   # Bills held by households
             H_h = matrix(0, nPeriods, MC),   # Cash held by households
             UR  = matrix(0, nPeriods, MC))   # Unemployment rate

# Store micro values (for MC = 1)
cHist = matrix(0, nPeriods, nHouseholds)   # Consumption of each household
eHist = matrix(0, nPeriods, nHouseholds)   # 1 if employed this period, else 0
vHist = matrix(0, nPeriods, nHouseholds)   # Wealth of each household

# Record the worst gap between H_h and H_s
sfcGap = 0

# Shock: rate rises from 2.5% to 3.5% at period 60 ####
r[60:nPeriods] <- 0.035                

# Shock to government spending in period 60 (from 20$ to 30$) ####
#G[60:nPeriods] <- 30

# Start the MC loop
for (mc in 1:MC) {
  
  # Set randomness seed
  set.seed(mc)
  
  # Define and initialize the stocks outside the time loop (MICRO)
  v   = rep(0, nHouseholds)  # Micro: household wealth (cash + bills)
  b   = rep(0, nHouseholds)  # Micro: bills held by each household
  yd  = rep(0, nHouseholds)  # Micro: disposable income (LAST period)
  
  # Government / central bank stocks (MACRO, carried across periods)
  B_s = 0                    # Bills supplied by government
  B_cb = 0                   # Bills held by central bank
  H_s = 0                    # Cash supplied by central bank
  
  # Start time loop
  for (i in 1:nPeriods) {
    
    r_now = r[i]                          # This period's interest rate
    r_lag = if (i > 1) r[i - 1] else r[1] # Last period's interest rate (for interest paid now)
    
    ## TICK 1: households decide how much to spend ####
    cd = pmin(pmax(alpha1 * yd + alpha2 * v, 0), v)  # Micro: consumption (4.5)
    AD = sum(cd) + G[i]                    # Macro: total demand for goods (4.1)
    N_d = AD / pr                          # Macro: labour needed (1/pr per unit)
    
    ## TICK 2: households/workers are hired based on a job lottery ####
    N = min(floor(N_d * runif(1, 1 - s, 1 + s)), floor(N_d), nHouseholds)
    
    ## TICK 3: households are re-shuffled ####
    order = sample(nHouseholds)            # Queue for both jobs and goods
    
    ## TICK 4: goods are served first-come-first-served ####
    YG = min(G[i], N * pr)                 # Macro: government served first (N workers make N*pr goods)
    YC = N * pr - YG                       # Macro: goods left for households
    cdq = cd[order]                        # Micro: planned demand in queue order
    cda = cumsum(cdq) - cdq                # Micro: goods claimed by those ahead
    cds = pmin(cdq, pmax(0, YC - cda))     # Micro: actually served
    c = rep(0, nHouseholds); c[order] = cds #Micro: actual consumption associated with the related household
    
    ## TICK 5: incomes, taxes, wealth ####
    y = rep(0, nHouseholds)                # Micro: initial income
    if (N >= 1) y[order[1:N]] = w          # Micro: labour income
    intinc = r_lag * b                     # Micro: interest on bills held since last period
    income = y + intinc                    # Micro: total income
    tax    = theta * income                # Micro: tax on labour AND interest (4.3)
    yd     = income - tax                  # Micro: disposable income (also used NEXT period) (4.2)
    v      = v - c + yd                    # Micro: wealth = old wealth - spending + saving (4.4)
    
    ## TICK 6: portfolio choice ####
    b = v * (lambda0 + lambda1 * r_now) - lambda2 * yd   # Micro: bills held (4.7)
    b = pmin(pmax(b, 0), v)                              # Guard line
    h = v - b                                            # Macro: cash held (4.6)
    
    # Store micro values of selected variables (for MC = 1)
    if (mc == 1) {
      cHist[i, ] = c
      eHist[i, ] = as.numeric(y > 0)
      vHist[i, ] = v
    }
    
    ## TICK 7: government + central bank settle the accounts ####
    B_h = sum(b)                           # Macro: bills demanded by households
    TAX = sum(tax)                         # Macro: total taxes
    B_cb_old = B_cb
    
    # Government issues bills to cover its deficit (spending + interest - taxes - CB profit) (4.8)
    B_s  = B_s + (YG + r_lag * B_s) - (TAX + r_lag * B_cb)
    
    # Central bank absorbs the bills households did not want (4.10)
    B_cb = B_s - B_h
    
    # Central bank issues cash equal to the change in its bill holdings
    H_s  = H_s + (B_cb - B_cb_old)         # Macro: cash supply (4.9) 
    H_h  = sum(h)                          # Macro: cash held by households
    
    ## TICK 8: record economy-wide totals and check consistency ####
    store$Y[i, mc]   = sum(y)              # Output / income
    store$C[i, mc]   = sum(c)              # Consumption
    store$YD[i, mc]  = sum(yd)             # Disposable income
    store$V[i, mc]   = sum(v)              # Wealth
    store$B_h[i, mc] = B_h                 # Bills held by households
    store$H_h[i, mc] = H_h                 # Cash held by households
    store$UR[i, mc]  = (nHouseholds - N) / nHouseholds #Unemployment rate
    sfcGap = max(sfcGap, abs(H_h - H_s))   # SFC check: H_h must equal H_s
  }
}
# Display the results ####
meanY  = rowMeans(store$Y);   meanC  = rowMeans(store$C)
meanYD = rowMeans(store$YD);  meanV  = rowMeans(store$V)
meanBh = rowMeans(store$B_h); meanHh = rowMeans(store$H_h)
preWin = 40:58                 # window just before the rate shock
cat(" MC runs:", MC, "( s =", s, ", pr =", pr, ", r:", r[1], "->", r[nPeriods], ")")
cat("\n Max |H_h - H_s| =", sfcGap, " (should be ~0)")
cat("\n Pre-shock  Y =", round(mean(meanY[preWin]), 2),
    " V =", round(mean(meanV[preWin]), 2),
    " B_h =", round(mean(meanBh[preWin]), 2),
    " H_h =", round(mean(meanHh[preWin]), 2),
    " bill share =", round(mean(meanBh[preWin]) / mean(meanV[preWin]), 3))

# Plot the results ####
op = par(mfrow = c(3, 2), mar = c(4, 4, 2, 1))

# Define colour
myred = adjustcolor("red", alpha.f = 0.2)

# a) Total output
matplot(store$Y, type = "l", lty = 1, col = "grey85",
        font.main = 1, main = "a) Total output", xlab = "", ylab = "")
lines(meanY, lwd = 2, col = "dodgerblue"); abline(v = 60, lty = 1, lwd = 2, col = myred )

# b) Disposable income and consumption
matplot(store$YD, type = "l", lty = 1, col = "grey88",
        font.main = 1, main = "b) Income and consumption", xlab = "", ylab = "")
matlines(store$C, lty = 1, col = "grey92")
lines(meanYD, lwd = 2, col = "purple"); lines(meanC, lwd = 2, col = "lightgreen")
abline(v = 60, lty = 1, lwd = 2, col = myred )
legend("bottomright", c("Disposable income", "Consumption"),
       col = c("purple", "lightgreen"), lwd = 2, bty = "n")

# c) Household wealth
matplot(store$V, type = "l", lty = 1, col = "grey88",
        font.main = 1, main = "c) Household wealth", xlab = "", ylab = "")
lines(meanV, lwd = 2, col = "darkorange"); abline(v = 60, lty = 1, lwd = 2, col = myred )

# d) Portfolio: bills vs cash (the rate shock shifts wealth toward bills)
matplot(store$B_h, type = "l", lty = 1, col = "grey90", ylim = range(store$H_h, store$B_h),
        font.main = 1, main = "d) Portfolio: bills and cash", xlab = "", ylab = "")
matlines(store$H_h, lty = 1, col = "grey92")
lines(meanBh, lwd = 2, col = "firebrick"); lines(meanHh, lwd = 2, col = "steelblue")
abline(v = 60, lty = 1, lwd = 2, col = myred )
legend("right", c("Bills B_h", "Cash H_h"), col = c("firebrick", "steelblue"),
       lwd = 2, bty = "n")

# e) Unemployment rate
matplot(store$UR, type = "l", lty = 1, col = "grey88",
        font.main = 1, main = "e) Unemployment rate (emergent)", xlab = "", ylab = "")
lines(rowMeans(store$UR), lwd = 2, col = "salmon"); abline(v = 60, lty = 1, lwd = 2, col = myred )

# f) One household: consumption and wealth (pink = unemployed periods)
yr = range(0, cHist[, 1], vHist[, 1])
plot(NA, xlim = c(1, nPeriods), ylim = yr,
     main = "f) First household (pink = unemployed periods)",
     xlab = "", ylab = "", font.main = 1, cex.main = 1.3)
un = which(eHist[, 1] == 0)
rect(un - 0.5, yr[1], un + 0.5, yr[2], col = "#ffd9d9", border = NA)
lines(cHist[, 1], col = "seagreen",    lwd = 1)    # consumption
lines(vHist[, 1], col = "darkorange3", lwd = 1)    # wealth
legend("topleft", c("Consumption", "Wealth"),
       col = c("seagreen", "darkorange3"), lwd = 1, bty = "n")
box()
par(op)

dev.copy(png, "Fig1_ABM_PC.png", width = 3000, height = 2400, res = 300); dev.off()