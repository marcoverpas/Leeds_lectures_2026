# *************************************************************************
#  Model SIM + agent-based microfoundation (ABM-SIM)
#  Source: Godley & Lavoie ch.3 (SIM), extended with a "job-lottery"
#  Author: Marco Veronese Passarella
#  Last change: 04/07/2026
# *************************************************************************
#  Description: A tiny "agent-based" version of the textbook SIM model:
#  several households, each with its own state money (cash) and its own
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
alpha1d      <- 0.4        # Spread 
alpha2       <- 0.4        # Propensity to consume out of wealth (common to all)
theta        <- 0.2        # Average tax rate on income
pr           <- 1.1        # Product per worker (labour productivity)
w            <- pr         # Wage per worker = productivity (=> zero profit)
G            <- rep(20, nPeriods)   # Government spending

# Define randomness
MC           <- 100        # MC simulations
s            <- 0.2        # Size of the hiring randomness
set.seed(123)              # Set random seed

# Heterogeneous, time-invariant propensity to consume out of income ####
alpha1 <- runif(nHouseholds, alpha1m - alpha1d, alpha1m + alpha1d)

# Define macro variables (results) to be stored ####
store = list(Y   = matrix(0, nPeriods, MC),   # Output each period, each MC run
             C   = matrix(0, nPeriods, MC),   # Consumption
             YD  = matrix(0, nPeriods, MC),   # Disposable income
             H_d = matrix(0, nPeriods, MC),   # Total household money
             UR  = matrix(0, nPeriods, MC))   # Unemployment rate

# Store micro values
cHist = matrix(0, nPeriods, nHouseholds)   # Consumption of each household, each period
eHist = matrix(0, nPeriods, nHouseholds)   # Proxy: 1 if employed this period, else 0
hHist = matrix(0, nPeriods, nHouseholds)   # Money held

# Record the worst gap between H_d and H_s
sfcGap = 0

# Shock to government spending in period 60 (from 20$ to 30$) ####
G[60:nPeriods] <- 30

# Start the MC loop
for (mc in 1:MC) {
  
  # Set randomness seed
  set.seed(mc)
  
  # Define and initialize the stocks outside the time loop
  h_d = rep(0, nHouseholds) # Micro: money each household holds (now)
  H_s = 0                   # Macro: total money supply
  
  # Recall values from previous period
  yd  = rep(0, nHouseholds) # Micro: disposable income
  
  # Start time loop
  for (i in 1:nPeriods) {
    
    ## TICK 1: households decide how much to spend ####
    
    # Micro: consumption planned by each household (each uses its own alpha1)
    cd = pmin(alpha1 * yd + alpha2 * h_d, h_d)
    
    # Macro: total demand for goods
    AD = sum(cd) + G[i]
    
    # Macro: labour needed (note: one good requires 1/pr workers)
    N_d = AD / pr
    
    ## TICK 2: households/workers are hired based on a job lottery ####
    
    # Macro: job lottery (min of random number, labour needed and existing labour force)
    N = min(floor(N_d * runif(1, 1 - s, 1 + s)), floor(N_d), nHouseholds)
    
    ## TICK 3: households are re-shuffled ####
    
    # Define random order of households for both jobs and goods (queue)
    order = sample(nHouseholds)
    
    ## TICK 4: goods are served based on first-come-first-served mechanism ####
    
    # Actual government spending (note: it is served first; N workers make N*pr goods)
    YG = min(G[i], N * pr)
    
    # Goods left for households
    YC = N * pr - YG
    
    # Micro: planned consumption of individual households, put in queue order
    cdq = cd[order]
    
    # Micro: cumulative consumption goods that the households ahead have already claimed
    cda = cumsum(cdq) - cdq
    
    # Micro: actual consumption in queue order (served)
    cds = pmin(cdq, pmax(0, YC - cda))
    
    # Micro: actual consumption associated with the related household.
    c = rep(0, nHouseholds); c[order] = cds
    
    ## TICK 5: wages are earned and then taxes are paid ####
    
    # Micro: initial income of everyone
    y = rep(0, nHouseholds)
    
    # Micro: if hired then income = wage received (w = pr, so no profit)
    if (N >= 1) y[order[1:N]] = w
    
    # Micro: taxes are paid
    tax = theta * y
    
    # Micro: money stock increases thanks to wages and reduces because of
    # consumption and taxes
    h_d = h_d + y - c - tax
    
    # Micro: in next period, disposable income is net of taxes paid "today"
    yd  = y - tax
    
    # Store micro values of selected variables (for MC = 1)
    if (mc == 1) {
      cHist[i, ] = c
      eHist[i, ] = as.numeric(y > 0)
      hHist[i, ] = h_d
    }
    
    ## TICK 6: write down totals, store values and check consistency ####
    
    # Economy-wide totals
    Y   = sum(y)                                      # Macro: output / income
    C   = sum(c)                                      # Macro: consumption
    YD  = sum(yd)                                     # Macro: disposable income
    H_d   = sum(h_d)                                  # Macro: household money
    TAX = sum(tax)                                    # Macro: total taxes
    H_s = H_s + (YG - TAX)                            # Macro: money supply
    
    # Store results
    store$Y[i, mc]  = Y
    store$C[i, mc]  = C
    store$YD[i, mc] = YD
    store$H_d[i, mc]  = H_d
    store$UR[i, mc] = (nHouseholds - N) / nHouseholds # Unemployment rate
    
    # SFC check
    sfcGap = max(sfcGap, abs(H_d - H_s))
  }
}
# Display the results ####

# Calculate average values of variables
meanY  = rowMeans(store$Y);  meanC = rowMeans(store$C)
meanYD = rowMeans(store$YD); meanH_d = rowMeans(store$H_d)

# Take the last periods before the shock (to define steady-state values)
period= 29:59

# Show details
cat(" MC runs:", MC, "( s =", s, ", pr =", pr, ", alpha1 in [", alpha1m - alpha1d, ",", alpha1m + alpha1d, "] )")
cat("\n Max |H_d - H_s| =", sfcGap)
cat("\n Y  =", round(mean(meanY[period]), 2))
cat("\n C  =", round(mean(meanC[period]), 2))
cat("\n H  =", round(mean(meanH_d[period]), 2))

# Plot the results ####
op = par(mfrow = c(3, 2), mar = c(4, 4, 2, 1))   # Note: "op" saves the old settings

# Define colour
myred = adjustcolor("red", alpha.f = 0.2)

# Chart 1: Total output
matplot(store$Y, type = "l", lty = 1, col = "grey85",
        font.main=1, main = "a) Total output", xlab = "", ylab = "")
lines(meanY, lwd = 2, col = "dodgerblue"); abline(h = G[1] / theta, lty = 2)
abline(v = 60, lty = 1, lwd = 2, col = myred )

# Chart 2: Disposable income and consumption
matplot(store$YD, type = "l", lty = 1, col = "grey88", ylim = range(0, 140),
        font.main=1, main = "b) Income and consumption", xlab = "", ylab = "")
matlines(store$C, lty = 1, col = "grey92")            # add the consumption runs
lines(meanYD, lwd = 2, col = "purple"); lines(meanC, lwd = 2, col = "lightgreen")
abline(h = (1 - theta) * G[1] / theta, lty = 2)
abline(v = 60, lty = 1, lwd = 2, col = myred )
legend("bottomright", c("Disposable income", "Consumption"), col = c("purple", "lightgreen"),
       lwd = 2, bty = "n")                            # bty = "n": no box

# Chart 3: Total money stock  (dashed grey = homogeneous-SIM benchmark at mean alpha1)
matplot(store$H_d, type = "l", lty = 1, col = "grey88",
        font.main=1, main = "c) Money stock", xlab = "", ylab = "")
lines(meanH_d, lwd = 2, col = "darkorange")
abline(h = (1 - theta) * G[1] / theta * (1 - alpha1m) / alpha2, lty = 2, col="grey30")
abline(h = mean(meanH_d[period]), lty = 2)
abline(v = 60, lty = 1, lwd = 2, col = myred )
text(75,75,cex=0.8,"Original SIM (s~0)", col="grey30")

# Chart 4: Unemployment rate
matplot(store$UR, type = "l", lty = 1, col = "grey88",
        font.main=1, main = "d) Unemployment rate (emergent)", xlab = "", ylab = "")
lines(rowMeans(store$UR), lwd = 2, col = "salmon")
abline(v = 60, lty = 1, lwd = 2, col = myred )

# Chart 5: Consumption and employment condition of first household
yr = range(0, cHist[, 1], hHist[, 1])
plot(NA, xlim = c(1, nPeriods), ylim = yr,
     main = "e) First household (note: pink = unemployed periods)",
     xlab = "", ylab = "", font.main = 1, cex.main = 1.3)
un = which(eHist[, 1] == 0)
rect(un - 0.5, yr[1], un + 0.5, yr[2], col = "#ffd9d9", border = NA)
lines(cHist[, 1], col = "seagreen",   lwd = 1)              # consumption
lines(hHist[, 1], col = "darkorange3", lwd = 1)
legend("topleft", c("Consumption", "Cash"),
       col = c("seagreen", "darkorange3"), lwd = c(1, 1), lty = c(1, 1), bty = "n")
box()

# Chart 6: Consumption and employment condition of last household
yr = range(0, cHist[, nHouseholds], hHist[, nHouseholds])
plot(NA, xlim = c(1, nPeriods), ylim = yr,
     main = "f) Last household (note: pink = unemployed periods)",
     xlab = "", ylab = "", font.main = 1, cex.main = 1.3)
un = which(eHist[, nHouseholds] == 0)
rect(un - 0.5, yr[1], un + 0.5, yr[2], col = "#ffd9d9", border = NA)
lines(cHist[, nHouseholds], col = "seagreen",   lwd = 1)              # consumption
lines(hHist[, nHouseholds], col = "darkorange3", lwd = 1, lty = 1)  # cash
legend("topleft", c("Consumption", "Cash"),
       col = c("seagreen", "darkorange3"), lwd = c(1, 1), lty = c(1, 1), bty = "n")
box()

# Restore the original plotting settings
par(op)

# Save plot
dev.copy(png, "Fig1_ABM_SIM.png", width = 3000, height = 2400, res = 300); dev.off()