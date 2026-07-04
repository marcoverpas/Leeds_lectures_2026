# Leeds, July 9-10, 2026  🛠️ work in progress 🛠️

<div align="center">
<figure>
<img src="https://github.com/marcoverpas/figures/blob/main/cover_leeds_2026.png" width="1000">
</figure>
</div>

<div align="center">
<figure>
<img src="https://github.com/marcoverpas/figures/blob/main/QR_code_Leeds_2026.png" width="200">
</figure>
</div>

## Overview

This repository presents **nine small macroeconomic models**, organised as a 3 × 3 grid. Three benchmark Stock-Flow Consistent (SFC) toy models from [Godley and Lavoie (2007)](#references) - **SIM**, **PC** and **BMW** - are each developed in three coding *styles*: *aggregate*, *input-output*, and *agent-based*.

|                          | **Aggregate (original)** | **Input-Output (IO)** | **Agent-Based (ABM)** |
|:-------------------------|:------------------------:|:---------------------:|:---------------------:|
| **SIM** (money only)     | [1. Model SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_SIM.R) | [4. Model IO-SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_SIM.R) | [7. Model ABM-SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_SIM.R) |
| **PC** (money + bonds)   | [2. Model PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_PC.R) | [5. Model IO-PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_PC.R) | [8. Model ABM-PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_PC.R) |
| **BMW** (banks + capital)| [3. Model BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_BMW.R) | [6. Model IO-BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_BMW.R) | [9. Model ABM-BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_BMW.R) |

Reading across a row shows how the *same* economy can be represented at three levels of resolution: as economy-wide aggregates, as a set of interconnected **industries** (IO), and as a population of heterogeneous interacting **households** (ABM). Reading down a column shows how the financial structure is progressively enriched: from a single state money (SIM), to money plus government bonds (PC), to bank loans and deposits financing fixed capital (BMW).

- [1 - Aggregate models](#1---aggregate-models)
  - [1.1 - Model SIM](#11---model-sim)
  - [1.2 - Model PC](#12---model-pc)
  - [1.3 - Model BMW](#13---model-bmw)
- [2 - Input-Output models](#2---input-output-models)
  - [2.1 - The logic of IO and IO-SFC models](#21---the-logic-of-io-and-io-sfc-models)
  - [2.2 - Model IO-SIM](#22---model-io-sim)
  - [2.3 - Model IO-PC](#23---model-io-pc)
  - [2.4 - Model IO-BMW](#24---model-io-bmw)
- [3 - Agent-based models](#3---agent-based-models)
  - [3.1 - The agent-based approach](#31---the-agent-based-approach)
  - [3.2 - Model ABM-SIM](#32---model-abm-sim)
  - [3.3 - Model ABM-PC](#33---model-abm-pc)
  - [3.4 - Model ABM-BMW](#34---model-abm-bmw)
- [Concluding remarks](#concluding-remarks)
- [References](#references)

All code has been developed for an `R` environment and is available in [this repository](https://github.com/marcoverpas/Leeds_lectures_2026). Similar lectures and further material of interest are available in these companion repositories:
- [Six lectures on SFC models, 2023](https://github.com/marcoverpas/Six_lectures_on_sfc_models) - a broad introduction to the whole SFC family, from the basic PC and BMW toy models to multi-country, input-output, ecological, and empirically-calibrated versions (six online lectures for the Central University of Finance and Economics, CUFE, Beijing).
- [EAEPE Summer School, 2024](https://github.com/marcoverpas/EAEPE_summer_school_2024) - a hands-on introduction to ecological SFC models (17th EAEPE Summer School, Roma Tre University).
- [PhD Lectures, Macerata 2025](https://github.com/marcoverpas/PhD_Lectures_Macerata_2025) - doctoral lectures linking Graziani's monetary circuit theory to SFC modelling (University of Macerata).
- [Keynote speech, Florence, 2025](https://github.com/marcoverpas/keynote_speech_Florence) - how to extend SFC models with ecological variables (matter, energy, emissions, temperature) to analyse the low-carbon transition (Summer School on "Multiscale Modeling and Ecological Macroeconomics", University of Florence).

:unlock: :copyright: *Note*: Except where otherwise credited, all the material in this repository is licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/?ref=chooser-v1). You are encouraged to use it for non-commercial purposes, provided that proper credit is given. Third-party items - notably the generative-art snippet adapted from [@yuruyurau](https://x.com/yuruyurau) - are used with attribution and are not covered by this licence.

---

> ### 📦 Box A - What is a stock-flow consistent (SFC) model?
>
> Stock-flow consistent (SFC) models describe the economy as a set of **sectors** (households, firms, banks, government, and so on) whose balance sheets and mutual transactions are recorded, without gaps, in a system of accounting matrices. Rooted in the national accounts and the flow of funds ([Godley and Lavoie, 2007](#references)), they integrate the *real* and the *financial* sides of the economy in one consistent whole: every expenditure is someone's income, and every financial asset is someone else's liability.
>
> The framework rests on four accounting principles - **flow consistency**, **stock consistency**, **stock-flow consistency**, and **quadruple book-keeping** - which together guarantee that nothing appears from, or vanishes into, nowhere. In practice each model is built around two tables: a **balance-sheet matrix** (the stocks each sector owns and owes) and a **transactions-flow matrix** (the payments between sectors and the changes in stocks they imply). Both are *watertight*: every column sums to zero, and every financial-asset row sums to zero; a real-asset row (e.g. fixed capital) instead sums to the economy's net worth. The transactions-flow matrix has the schematic form below, where a minus sign is a use of funds (an outflow) and a plus sign a source (an inflow):
>
> |                    | Households | Firms  | Government | Row sum |
> |:-------------------|:----------:|:------:|:----------:|:-------:|
> | Consumption        | $-C$       | $+C$   |            | 0       |
> | Income (wages)     | $+Y$       | $-Y$   |            | 0       |
> | Government spending |           | $+G$   | $-G$       | 0       |
> | Taxes              | $-T$       |        | $+T$       | 0       |
> | Change in money    | $-\Delta H$|        | $+\Delta H$| 0       |
> | **Column sum**     | 0          | 0      | 0          | 0       |
>
> Because the tables are watertight, every model contains one **redundant** (or *hidden*) equation, logically implied by all the others (*Walras' Law*). We omit it from the code and use it instead to double-check that the model is watertight. The accounting skeleton is then closed with **behavioural equations** - usually simple rules of thumb and stock-flow norms - that describe how each sector spends, saves and allocates its wealth. The result is a dynamic system, normally written in discrete time as difference equations: the simplest models (such as those below) can be solved analytically for their steady state, while richer ones are simulated on a computer.
>
> The models in this repository are the smallest members of this family. From the same accounting core grow the many extensions now used in research - multi-area (MA-SFC), ecological (ECO-SFC), input-output (IO-SFC), agent-based (AB-SFC) and empirical (E-SFC) SFC models - several of which are illustrated in the companion repositories listed above. For a full theoretical treatment, see [Godley and Lavoie (2007)](#references); for a survey, [Nikiforos and Zezza (2017)](#references).
>
> Note: models SIM, PC and BMW are reproduced and extended from Godley and Lavoie (2007), while the input-output and agent-based versions are our own.

---

## 1 - Aggregate models

### 1.1 - Model SIM

Model **SIM** ("**SIM**plest") is the most basic SFC model ([Godley and Lavoie, 2007, ch. 3](#references)). It has a single financial asset - **state money (cash)** - created when the government spends and destroyed when it taxes.

Key assumptions:

1. Closed economy, no ecosystem
1. Three agents: households, "firms", government
1. One financial asset: outside money (cash)
1. No investment, no inventories, no banks, no bonds
1. Fixed prices and zero net profits (all income is wages)

#### Table 1. Balance-sheet matrix

|              | Households | Firms | Government | Row tot |
|:------------:|:----------:|:-----:|:----------:|:-------:|
|              |            |       |            |         |
| Money (cash) | $$+H_h$$   |       | $$-H_s$$   |   0     |
| Balance      | $$-H_h$$   |  0    | $$+H_s$$   |   0     |
|              |            |       |            |         |
| Column tot.  |    0       |  0    |    0       |   0     |

#### Table 2. Transactions-flow matrix

|                       | Households      | Firms   | Government      | Row tot |
|:----------------------|:---------------:|:-------:|:---------------:|:-------:|
|                       |                 |         |                 |         |
| Consumption           | $$-C$$          | $$+C$$  |                 |   0     |
| Government expenditure |                | $$+G$$  | $$-G$$          |   0     |
| GDP (income)          | $$+Y$$          | $$-Y$$  |                 |   0     |
| Taxes                 | $$-T$$          |         | $$+T$$          |   0     |
|                       |                 |         |                 |         |
| Change in money       | $$-\Delta H_h$$ |         | $$+\Delta H_s$$ |   0     |
|                       |                 |         |                 |         |
| Column tot.           |    0            |  0      |    0            |   0     |

Completing the identities with behavioural equations for taxes and consumption, we obtain:

National income (identity):

$$Y = C + G \quad \text{(1)}$$

Disposable income (identity):

$$YD = Y - T \quad \text{(2)}$$

Tax revenue (behavioural):

$$T = \theta \cdot Y \quad \text{(3)}$$

Money held by households, equal to wealth (identity):

$$H_h = H_{h,-1} + (YD - C) \quad \text{(4)}$$

Consumption (behavioural):

$$C = \alpha_1 \cdot YD + \alpha_2 \cdot H_{h,-1} \quad \text{(5)}$$

where $\alpha_1$ is the propensity to consume out of income and $\alpha_2$ the propensity to consume out of wealth.

Money supplied by the government (identity):

$$H_s = H_{s,-1} + (G - T) \quad \text{(6)}$$

The redundant (hidden) equation matches money demand with money supply:

$$H_h = H_s$$

In the steady state there is no saving ($C = YD$) and money holdings are stable, so national income converges to:

$$Y^{\*} = \frac{G}{\theta}$$

Before turning to the accounting, it helps to *see* the model move. The animation below renders Model SIM as a **system-dynamics diagram**: the three sectors are boxes, every flow is a pipe along which tokens travel (its thickness scaling with the flow), and the two financial stocks are tanks. Government spending $G$ reaches firms, who pay wages $Y$ to households. Households return part of their income as consumption ($\alpha_1 \cdot YD$) and taxes ($T$), and save the rest ($(1-\alpha_1) \cdot YD$) into their **money tank** $H_h$ - which in turn finances further consumption out of wealth ($\alpha_2 \cdot H_h$). The government's tank is the exact mirror image: it fills with the accumulated deficit $G - T$ but in the *opposite* direction, because the money households hold is nothing other than the government's debt. At every instant $H_h = H_s$, so the household asset (blue, rising) and the government liability (red, falling) are equal and opposite, summing to zero. As income grows, taxes catch up to spending, the deficit closes, and both tanks stop moving: the economy has reached its steady state $Y^{\*} = G/\theta$.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/sim_sd.gif" width="820">
</figure>

The animation runs the economy forward through many periods. To inspect the plumbing of a *single* period more closely, we can freeze one snapshot and lay its payments out side by side.

This is precisely what the transactions-flow matrix records, which can be read as a Sankey diagram. Traversed left to right - payer, transaction, payee - it traces every monetary flow of a single period: firms pay wages to households, who return them as consumption (to firms), taxes (to the government) and the money they save. Since each transaction has exactly one source and one destination, the two sides of every account balance.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SANKEY_SIM.png" width="800">
</figure>

Simulated over time, these one-period flows become dynamic paths. The figure below tracks the main variables and the consistency check as the economy converges to its steady state.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SIM_anim.gif" width="900">
</figure>

As a first experiment, we let government spending $G$ rise permanently. 

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SIM_experiment.gif" width="900">
</figure>

In the animation above the grey line is the baseline, and the red one - branching off at the dashed marker - is the shock scenario. National income converges to its new, higher steady state $Y^{\*} = G/\theta$, pulling disposable income and consumption up with it, while households end up holding a permanently larger stock of money. Panels a)–d) reveal these adjustments period by period.

#### 🛠️ Hands-on: building Model SIM in `R`

Model SIM needs no external package: base `R` is enough. We start by clearing the workspace.

```r
# Clear environment
rm(list = ls(all = TRUE))
```

We then fix the parameters: the propensities to consume ($\alpha_1$, $\alpha_2$), the tax rate $\theta$, and the fiscal experiment (spending switches on at 20 and, in scenario 2, rises to 30 from period 50).

```r
# Set model parameters ####
nPeriods    <- 100         # Periods
nScenarios  <- 2           # 1 baseline, 2 higher government spending
alpha1      <- 0.6         # Propensity to consume out of income
alpha2      <- 0.4         # Propensity to consume out of wealth
theta       <- 0.2         # Tax rate on income
Gexog       <- 20          # Government spending (once switched on)
Gshock      <- 30          # Higher government spending (scenario 2)
shockStart  <- 50          # Period at which spending rises (scenario 2)
```

Each variable is a matrix with one row per scenario and one column per period, initialised at zero (row 1 = baseline, row 2 = shock). Since SIM has a single asset, wealth `V` equals money `H_h`.

```r
# Create the variables as matrices [scenario, period], all starting at zero ####
Y   <- matrix(0, nScenarios, nPeriods)  # Output / income
C   <- matrix(0, nScenarios, nPeriods)  # Consumption
YD  <- matrix(0, nScenarios, nPeriods)  # Disposable income
TAX <- matrix(0, nScenarios, nPeriods)  # Taxes
V   <- matrix(0, nScenarios, nPeriods)  # Household wealth (= money in SIM)
H_h <- matrix(0, nScenarios, nPeriods)  # Money held by households
H_s <- matrix(0, nScenarios, nPeriods)  # Money supplied by the government
```

Government spending is the only exogenous variable: switched on from period 2 in both scenarios, and raised from `shockStart` in scenario 2 only.

```r
# Exogenous variables ####
G <- matrix(0, nScenarios, nPeriods)    # Government spending

# Shocks ####
G[, 2:nPeriods] <- Gexog                          # Spending switched on in period 2
G[2, shockStart:nPeriods] <- Gshock               # Higher spending in scenario 2
```

The core is a triple loop: over scenarios, over time (from period 2), and an inner loop that solves the seven equations. Being simultaneous, they are iterated 100 times per period until they converge (a Gauss–Seidel scheme). The lines are equations (1)–(6) plus the money-demand identity.

```r
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
```

We now report the analytic steady state $Y^{\*}=G/\theta$ and the consistency gap $|H_h - H_s|$ (which must be zero to machine precision).

```r
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

```

Lastly, we visualize the evolution of the main macroeconomic variables over time.

```r

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
```

The complete `R` code for this model is [`BASIC_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_SIM.R).

---

### 1.2 - Model PC

Model **PC** ("**p**ortfolio **c**hoice") adds a second financial asset ([Godley and Lavoie, 2007, ch. 4](#references)): households can now hold their wealth as **cash and/or government bonds**, and the central bank appears explicitly.

Key assumptions:

1. Closed economy, no ecosystem
1. Four agents: households, "firms", government, central bank
1. Two financial assets: government bonds and cash
1. No investment and no inventories
1. Fixed prices and zero net profits
1. No banks, no inside money (bank deposits)

#### Table 1. Balance-sheet matrix

|              | Households  | Firms  | Central bank | Government | Row tot |
|:------------:|:-----------:|:------:|:------------:|:----------:|:-------:|
|              |             |        |              |            |         |
| Cash (money) | $$H_h$$     |        | $$-H_s$$     |            |   0     |
| Bonds        | $$B_h$$     |        | $$B_{cb}$$   | $$-B_s$$   |   0     |
| Wealth       | $$-V_h$$    |        |              | $$V_g$$    |   0     |
|              |             |        |              |            |         |
| Column tot.  |   0         |  0     |   0          |   0        |   0     |

#### Table 2. Transactions-flow matrix

|                       | Households               | Firms          | Central bank              | Government               | Row tot |
|:----------------------|:------------------------:|:--------------:|:-------------------------:|:------------------------:|:-------:|
|                       |                          |                |                           |                          |         |
| Consumption           | $$-C$$                   | $$+C$$         |                           |                          |   0     |
| Government expenditure |                         | $$+G$$         |                           | $$-G$$                   |   0     |
| GDP (income)          | $$+Y$$                   | $$-Y$$         |                           |                          |   0     |
| Interest payments     | $$r_{-1} \cdot B_{h,-1}$$ |               | $$r_{-1} \cdot B_{cb,-1}$$ | $$-r_{-1} \cdot B_{s,-1}$$|   0     |
| CB profit             |                          |                | $$-r_{-1} \cdot B_{cb,-1}$$| $$r_{-1} \cdot B_{cb,-1}$$|   0     |
| Taxes                 | $$-T$$                   |                |                           | $$T$$                    |   0     |
|                       |                          |                |                           |                          |         |
| Change in cash        | $$-\Delta H_h$$          |                | $$\Delta H_s$$            |                          |   0     |
| Change in bonds       | $$-\Delta B_h$$          |                | $$-\Delta B_{cb}$$        | $$\Delta B_s$$           |   0     |
|                       |                          |                |                           |                          |         |
| Column tot.           |   0                      |  0             |   0                       |   0                      |   0     |

The system of difference equations is:

$$Y = C + G \quad \text{(1)}$$

$$YD = Y - T + r_{-1} \cdot B_{h,-1} \quad \text{(2)}$$

$$T = \theta \cdot (Y + r_{-1} \cdot B_{h,-1}) \quad \text{(3)}$$

$$V_h = V_{h,-1} + YD - C \quad \text{(4)}$$

$$C = \alpha_1 \cdot YD + \alpha_2 \cdot V_{h,-1} \quad \text{(5)}$$

$$H_h = V_h - B_h \quad \text{(6)}$$

$$\frac{B_h}{V_h} = \lambda_0 + \lambda_1 \cdot r - \lambda_2 \cdot \frac{YD}{V_h} \quad \text{(7)}$$

$$B_s = B_{s,-1} + G - T + r_{-1} \cdot (B_{s,-1} - B_{cb,-1}) \quad \text{(8)}$$

$$H_s = H_{s,-1} + \Delta B_{cb} \quad \text{(9)}$$

$$B_{cb} = B_s - B_h \quad \text{(10)}$$

$$r = \bar{r} \quad \text{(11)}$$

Optionally, the propensity to consume can be made a decreasing function of the interest rate:

$$\alpha_1 = \alpha_{10} - \alpha_{11} \cdot r_{-1} \quad \text{(12)}$$

The redundant equation is $H_h = H_s$. The steady-state income is:

$$Y^{\*} = \frac{G + r \cdot B_h^{*} \cdot (1 - \theta)}{\theta}$$

The same payer → transaction → payee reading applies, now enriched with interest income and the portfolio choice between cash and government bills. The Sankey diagram shows the government financing its deficit through new bills absorbed by households and the central bank, and the central bank issuing cash against the bills it holds - the extra financial plumbing that distinguishes PC from SIM.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SANKEY_PC.png" width="800">
</figure>

Iterated forward, these flows generate the dynamics of income, wealth and its portfolio composition reported below.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/PC_anim.gif" width="900">
</figure>

As an experiment, we now raise the interest rate $r$ permanently. In the animation below the grey line is the baseline and the red one - branching off at the dashed marker - is the shock scenario. A higher rate lifts the interest income households earn on their bonds, so disposable income, and with it national income, settle at a higher steady state $Y^{\*} = [G + r \cdot B_h^{*} \cdot (1 - \theta)] / \theta$, while households rebalance their portfolio towards bonds. Panels a)–d) reveal these adjustments period by period.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/PC_experiment.gif" width="900">
</figure>

The `R` code for this model is [`BASIC_PC.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_PC.R).

---

### 1.3 - Model BMW

Model **BMW** ("**b**ank-**m**oney **w**orld") is the simplest model with private **banks**, **investment** and **fixed capital** ([Godley and Lavoie, 2007, ch. 7](#references)). The only financial asset is **bank deposits**; firms borrow from banks to finance net investment, and banks turn loans into deposits. It is the dynamic counterpart of the monetary circuit.

Key assumptions:

1. Closed economy, no ecosystem
1. Three agents: households, firms, banks
1. Assets/liabilities: loans, deposits, fixed capital
1. Investment funded by loans and internal (amortisation) funds
1. Target capital-to-output ratio
1. Fixed prices and zero net profits
1. No state, no outside money (cash)

#### Table 1. Balance-sheet matrix

|                    | Households | Firms   | Banks   | Row tot |
|:------------------:|:----------:|:-------:|:-------:|:-------:|
|                    |            |         |         |         |
| Deposits           | $$+M$$     |         | $$-M$$  |   0     |
| Loans              |            | $$-L$$  | $$+L$$  |   0     |
| Fixed capital      |            | $$+K$$  |         | $$+K$$  |
|                    |            |         |         |         |
| Balance (net worth)| $$-V_h$$   |   0     |   0     | $$-V_h$$|
|                    |            |         |         |         |
| Column tot.        |   0        |   0     |   0     |   0     |

Since banks and firms make no net profit, household net wealth equals the stock of fixed capital. This holds because loans and capital grow in step: equations (B.8) and (B.17) both give $\Delta L = \Delta K = I - DA$, so with equal initial stocks $L = K$ throughout, leaving firms with zero net worth ($K - L = 0$), while the banks' balance sheet keeps $M = L$. Hence $V_h = M = L = K$.

#### Table 2. Transactions-flow matrix

|                      | Households                | Firms (current)          | Firms (capital) | Banks                     | Row tot |
|:---------------------|:-------------------------:|:------------------------:|:---------------:|:-------------------------:|:-------:|
|                      |                           |                          |                 |                           |         |
| Consumption          | $$-C$$                    | $$+C$$                   |                 |                           |   0     |
| Investment           |                           | $$+I$$                   | $$-I$$          |                           |   0     |
| [ Production ]       |                           | $$[Y]$$                  |                 |                           |         |
| Wages                | $$+WB$$                   | $$-WB$$                  |                 |                           |   0     |
| Depreciation         |                           | $$-AF$$                  | $$+AF$$         |                           |   0     |
| Interest on loans    |                           | $$-r_{l,-1} \cdot L_{-1}$$|                | $$+r_{l,-1} \cdot L_{-1}$$ |   0     |
| Interest on deposits | $$+r_{m,-1} \cdot M_{-1}$$ |                          |                 | $$-r_{m,-1} \cdot M_{-1}$$ |   0     |
|                      |                           |                          |                 |                           |         |
| Change in loans      |                           |                          | $$+\Delta L$$   | $$-\Delta L$$             |   0     |
| Change in deposits   | $$-\Delta M$$             |                          |                 | $$+\Delta M$$             |   0     |
|                      |                           |                          |                 |                           |         |
| Column tot.          |   0                       |   0                      |   0             |   0                       |   0     |

The model is a system of 21 equations. Collapsing the trivial supply = demand identities ($C_s = C_d$, $I_s = I_d$, $N_s = N_d$, $L_s = L_d$, $AF = DA$), the core is:

$$Y = C + I \quad \text{(B.5)}$$

$$WB = Y - r_{l,-1} \cdot L_{-1} - DA \quad \text{(B.6)}$$

$$L = L_{-1} + I - DA \quad \text{(B.8)}$$

$$YD = WB + r_{m,-1} \cdot M_{h,-1} \quad \text{(B.9)}$$

$$M_h = M_{h,-1} + YD - C \quad \text{(B.10)}$$

$$M_s = M_{s,-1} + \Delta L \quad \text{(B.11)}$$

$$r_m = r_l \quad \text{(B.12)}$$

$$N = \frac{Y}{pr} \quad \text{(B.14)}$$

$$w = \frac{WB}{N} \quad \text{(B.15)}$$

$$C = \alpha_0 + \alpha_1 \cdot YD + \alpha_2 \cdot M_{h,-1} \quad \text{(B.16)}$$

$$K = K_{-1} + I - DA \quad \text{(B.17)}$$

$$DA = \delta \cdot K_{-1} \quad \text{(B.18)}$$

$$K^t = \kappa \cdot Y_{-1} \quad \text{(B.19)}$$

$$I = \gamma \cdot (K^t - K_{-1}) + DA \quad \text{(B.20)}$$

$$r_l = \bar{r}_l \quad \text{(B.21)}$$

The redundant equation is $\Delta M_h = \Delta M_s$ (equivalently $M_h = M_s$). Note the accelerator (B.19)–(B.20): firms target a capital stock proportional to lagged output and close a fraction $\gamma$ of the gap each period, on top of replacing depreciation.

Here the four accounts - households, firms (current), firms (capital) and banks - appear as payers and payees, with investment and depreciation shown as flows internal to the firm sector. Because loans create deposits of equal size and the two interest legs cancel at the bank, the Sankey diagram makes the loans-and-deposits circuit, and its self-balancing character, legible at a glance.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SANKEY_BMW.png" width="800">
</figure>

Run over time, the same circuit produces the paths of output, investment, capital and deposits reported below.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/BMW_anim.gif" width="900">
</figure>

As an experiment, we raise the target capital-output ratio $\kappa$ permanently. In the animation below the grey line is the baseline and the red one - branching off at the dashed marker - is the shock scenario. Aiming at a larger capital stock, firms step up investment: investment jumps on impact and the capital stock climbs to a permanently higher level, pulling output and consumption up with it through the accelerator, before the economy settles at its new steady state. Panels a)–d) reveal these adjustments period by period.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/BMW_experiment.gif" width="900">
</figure>

The `R` code for this model is [`BASIC_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_BMW.R).

---

## 2 - Input-Output models

### 2.1 - The logic of IO and IO-SFC models

The benchmark models above are **fully aggregated**: production is a single homogeneous good. **Input-Output (IO) analysis** ([Miller and Blair, 2009](#references)) instead splits production into several **industries** that buy and sell intermediate goods from one another. Each industry needs the products of the others as inputs, so total ("gross") output must cover both **final demand** (consumption, government, investment) and **intermediate demand**.

With $n$ industries, let $\mathbf{x}$ be the vector of real gross outputs, $\mathbf{d}$ the vector of real final demands, and $\mathbf{A}$ the matrix of **technical coefficients**, where $a_{ij}$ is the amount of good $i$ needed to produce one unit of good $j$. Each industry's output must cover both intermediate and final demand, giving the accounting identity $\mathbf{x} = \mathbf{A} \cdot \mathbf{x} + \mathbf{d}$, whose solution is $\mathbf{x} = (\mathbf{I} - \mathbf{A})^{-1} \cdot \mathbf{d}$, where $(\mathbf{I} - \mathbf{A})^{-1}$ is the **Leontief inverse** that translates any final demand into the gross output every industry must produce to satisfy it (directly and indirectly).

Standard IO analysis is powerful but **static**: it compares two snapshots without describing the path between them, and it says little about money and finance. **SFC modelling** is the mirror image: dynamically and financially coherent, but usually blind to inter-industry detail. **IO-SFC models** combine the two - industrial granularity from IO, dynamic and financial coherence from SFC - so that a demand-driven, monetary economy is resolved industry by industry while every stock and flow still adds up ([Berg et al. 2015](#references); [Veronese Passarella, 2025](#references); [Fevereiro et al. 2025](#references)).

Adding an IO layer to an SFC model requires only a handful of extra equations. Prices are no longer fixed but set by **cost-plus (reproduction) conditions**, and final demand is split across industries by fixed **composition shares**. Because prices now exist, real and nominal magnitudes diverge: consumption is decided in real terms while GDP is measured in value.

> ### 📦 Box B - What is an input-output model?
>
> An input-output (IO) model pictures the economy as a set of **industries** that trade with one another. Each industry produces a single good, and to do so it must buy the goods of the other industries as **intermediate inputs**. Part of every industry's output is therefore absorbed inside the productive system (as inputs to others), and only what is left over is delivered to **final demand** - consumption, government, investment. The whole picture is summarised in a single accounting table ([Miller and Blair, 2009, chapters 1-2](#references)):
>
> |                     | Industry 1 | Industry 2 | $\cdots$ | Industry $n$ | Final demand | Total output |
> |:--------------------|:----------:|:----------:|:--------:|:------------:|:------------:|:------------:|
> | **Industry 1**      | $z_{11}$   | $z_{12}$   | $\cdots$ | $z_{1n}$     | $d_1$        | $x_1$        |
> | **Industry 2**      | $z_{21}$   | $z_{22}$   | $\cdots$ | $z_{2n}$     | $d_2$        | $x_2$        |
> | $\vdots$            | $\vdots$   | $\vdots$   | $\ddots$ | $\vdots$     | $\vdots$     | $\vdots$     |
> | **Industry $n$**    | $z_{n1}$   | $z_{n2}$   | $\cdots$ | $z_{nn}$     | $d_n$        | $x_n$        |
> | **Value added**     | $v_1$      | $v_2$      | $\cdots$ | $v_n$        |              |              |
> | **Total input**     | $x_1$      | $x_2$      | $\cdots$ | $x_n$        |              |              |
>
> Read **along a row**, the table shows how industry $i$'s output is distributed: the flows $z_{ij}$ sold as inputs to each industry $j$, plus the final demand $d_i$. Read **down a column**, it shows what industry $j$ must buy to produce: the same flows $z_{ij}$, plus the value added $v_j$ (wages and profits). Since every industry's total output equals its total input, we have, for each industry:
>
> $$x_i = \sum_{j} z_{ij} + d_i$$
>
> The key behavioural assumption is that production uses inputs in **fixed proportions**. The amount of good $i$ needed to make one unit of good $j$ is the *technical coefficient* $a_{ij} = z_{ij} / x_j$, so that intermediate flows can be written $z_{ij} = a_{ij} \cdot x_j$. Collecting the coefficients in the matrix $\mathbf{A}$, gross outputs in $\mathbf{x}$ and final demands in $\mathbf{d}$, the identity above becomes the compact **Leontief system**:
>
> $$\mathbf{x} = \mathbf{A} \cdot \mathbf{x} + \mathbf{d} \quad \Longrightarrow \quad \mathbf{x} = (\mathbf{I} - \mathbf{A})^{-1} \cdot \mathbf{d}$$
>
> This is a **demand-driven** picture: given any final demand $\mathbf{d}$, the Leontief inverse $(\mathbf{I} - \mathbf{A})^{-1}$ returns the gross output every industry must produce to satisfy it, directly and indirectly. What it does *not* contain is money, finance, or time - it is a static snapshot. The IO-SFC models that follow keep this inter-industry core exactly as it stands and embed it inside a dynamic, stock-flow consistent structure, so that the same demand-led economy is resolved industry by industry while every monetary stock and flow still adds up.

---

### 2.2 - Model IO-SIM

Model **IO-SIM** is Model SIM with a three-industry input-output core (agriculture, manufacturing, services). The macro-accounting (Tables 1–2 of SIM) is unchanged; the following equations are added or modified.

Additional assumptions relative to SIM:

1. Three industries; each produces one good with one technique
1. Fixed technical coefficients (circulating capital)
1. Prices set by reproduction conditions (cost-plus mark-up)
1. The composition of consumption and government spending is exogenous

The input-output matrix of Model IO-SIM is shown in **Table 3** below.

#### Table 3. Input-output matrix

|                               | Agriculture (demand)         | Manufacturing (demand)       | Services (demand)            | Final demand    | Output                          |
|:------------------------------|:----------------------------:|:----------------------------:|:----------------------------:|:---------------:|:-------------------------------:|
|                               |                              |                              |                              |                 |                                 |
| **Agriculture (production)**  | $p_1 \cdot a_{11} \cdot x_1$ | $p_1 \cdot a_{12} \cdot x_2$ | $p_1 \cdot a_{13} \cdot x_3$ | $p_1 \cdot d_1$ | $p_1 \cdot x_1$                 |
| **Manufacturing (production)**| $p_2 \cdot a_{21} \cdot x_1$ | $p_2 \cdot a_{22} \cdot x_2$ | $p_2 \cdot a_{23} \cdot x_3$ | $p_2 \cdot d_2$ | $p_2 \cdot x_2$                 |
| **Services (production)**     | $p_3 \cdot a_{31} \cdot x_1$ | $p_3 \cdot a_{32} \cdot x_2$ | $p_3 \cdot a_{33} \cdot x_3$ | $p_3 \cdot d_3$ | $p_3 \cdot x_3$                 |
| **Value added**               | $yn_1$                       | $yn_2$                       | $yn_3$                       | $yn$            |                                 |
| **Output**                    | $p_1 \cdot x_1$              | $p_2 \cdot x_2$              | $p_3 \cdot x_3$              |                 | $\mathbf{p}^T \cdot \mathbf{x}$ |

**Table 3** illustrates the cross-industry interdependencies in a simplified economy where three products - agricultural goods, manufactures and services - are produced using the same three products together with labour. Each entry $p_i \cdot a_{ij} \cdot x_j$ is the value of product $i$ absorbed as an intermediate input by industry $j$. Reading along a row gives how each industry's output is used (as inputs elsewhere plus final demand), while reading down a column gives what each industry buys to produce, plus its value added.

We can now turn to the additional equations necessary to complete Model IO-SIM.

Composition of real consumption and government spending (behavioural):

$$\mathbf{B}_c = \bar{\mathbf{B}}_c \quad \text{(7)}$$

$$\mathbf{B}_g = \bar{\mathbf{B}}_g \quad \text{(8)}$$

with $\sum_j B_{cj} = \sum_j B_{gj} = 1$.

Real final demand by industry (identity):

$$\mathbf{d} = \mathbf{B}_c \cdot c + \mathbf{B}_g \cdot g \quad \text{(9)}$$

Real gross output by industry (identity):

$$\mathbf{x} = (\mathbf{I}-\mathbf{A})^{-1} \cdot \mathbf{d} \quad \text{(10)}$$

Unit prices of reproduction (behavioural):

$$\mathbf{p}^T = \left( w \oslash \mathbf{pr}^T \right) + \left( \mathbf{p}^T \cdot \mathbf{A} \right) \cdot (1 + \mu) \quad \text{(11)}$$

where $w$ is the (uniform) wage rate, $\mathbf{pr}$ the vector of labour productivities, and $\mu$ the (uniform) mark-up.

Nominal GDP (identity):

$$Y = \mathbf{p}^T \cdot \mathbf{d} \quad \text{(1.A)}$$

Average consumer and government price indices (identities):

$$p_c = \mathbf{p}^T \cdot \mathbf{B}_c \quad \text{(12)}$$

$$p_g = \mathbf{p}^T \cdot \mathbf{B}_g \quad \text{(13)}$$

Real consumption (behavioural), where consumers do not suffer from money illusion:

$$c = \alpha_1 \cdot \left( \frac{YD}{p_c} - \pi \cdot \frac{H_{h,-1}}{p_c} \right) + \alpha_2 \cdot \frac{H_{h,-1}}{p_c} \quad \text{(5.A)}$$

where $\pi$ is the rate of growth of the consumer price index (the inflation rate). Nominal consumption and government spending become $p_c \cdot c$ and $p_g \cdot g$. The redundant equation $H_h = H_s$ still holds.

For the input-output core the flows are best read product by product. This Sankey diagram unpacks the (nominal) use table: each product on the left fans out to the three industries that consume it as an intermediate input, plus final demand on the right - a direct picture of how much of each sector's output is absorbed in production elsewhere versus delivered to final buyers.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/SANKEY_IO.png" width="800">
</figure>

The same interdependence can be summarised more compactly as a network.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/IO_network.png" width="600">
</figure>

This directed graph renders the technical-coefficients matrix itself: each node is an industry (sized by its gross output) and each weighted arrow $a_{ij}$ gives the amount of industry $i$'s product needed to make one unit of industry $j$'s, with self-loops capturing intra-industry input use. It conveys at a glance the density and asymmetry of the linkages that the Leontief inverse resolves.

With the industrial structure in place, the model can be run forward. The figures below report the aggregate dynamics (matching Model SIM) and the resulting industry-level detail.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_IO_SIM.png" width="900">
</figure>

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig2_IO_SIM.png" width="900">
</figure>

The `R` code for this model is [`IO_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_SIM.R).

---

### 2.3 - Model IO-PC

Model **IO-PC** is the same IO layer bolted onto Model PC. The only difference from IO-SIM is the financial side inherited from PC: households now allocate wealth between cash and bonds (equations 6–11 above), income includes interest, and taxes fall on total income. The IO block (equations 13–19) is identical, and government spending is valued at $p_g \cdot g$. The redundant equation remains $H_h = H_s$, and the aggregate behaviour reproduces Model PC while adding the industrial and price detail.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_IO_PC.png" width="900">
</figure>

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig2_IO_PC.png" width="900">
</figure>

The `R` code for this model is [`IO_PC.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_PC.R).

> ### 📦 Box C - Playing with the model
>
> One of the advantages of creating formal models using `R` is that they can be conveniently converted into online interactive models using the `Shiny` package. Here you can play with an ecosystem-extended version of Model IO-PC.
>  
> [![Open Shiny App](https://img.shields.io/badge/Launch-Shiny_App-blue?style=for-the-badge&logo=r)](https://x52gnt-marco-passarella.shinyapps.io/eco_3io_sfc_model/)
> 
> <figure>
> <a href="https://x52gnt-marco-passarella.shinyapps.io/eco_3io_sfc_model/" target="_blank">
> <img src="https://raw.githubusercontent.com/marcoverpas/figures/main/laboratory.png" width="1000">
> </a>
> </figure>
> <br><br>
>
> Click the link above (or the figure) to open the simulation laboratory for *Model ECO-3IO-PC*. Please wait a few moments while the simulation loads. :hourglass_flowing_sand:

---

### 2.4 - Model IO-BMW

Model **IO-BMW** adds the same IO/price layer to Model BMW. The novelty is **investment**: final demand now has two components - consumption and investment (BMW has no government) - so

$$\mathbf{d} = \mathbf{B}_c \cdot c + \mathbf{B}_i \cdot i$$

where $\mathbf{B}_i$ is the vector of investment composition shares. Capital is now determined **industry by industry**, following the solution used in larger empirical IO-SFC models: each industry targets a capital stock proportional to its own lagged **gross** output, and invests to close part of the gap plus replace depreciation:

$$k^t_z = \kappa_z \cdot x_{z,-1}, \qquad i_z = \gamma \cdot (k^t_z - k_{z,-1}) + da_z, \qquad da_z = \delta_z \cdot k_{z,-1}$$

Aggregate investment is then $\sum_z i_z$, and the BMW loan/deposit block (B.6–B.21) operates on the resulting nominal magnitudes. Because the target is defined on gross output (which exceeds value added), the capital-to-output ratio $\kappa_z$ is smaller than the value used against income in the aggregate BMW. The redundant equation is again $M_h = M_s$.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_IO_BMW.png" width="900">
</figure>

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig2_IO_BMW.png" width="900">
</figure>

The `R` code for this model is [`IO_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_BMW.R).

---

## 3 - Agent-based models

### 3.1 - The agent-based approach

The aggregate and IO models are **top-down**: they specify economy-wide (or industry-wide) behavioural rules directly. **Agent-based models (ABMs)** are **bottom-up**: they specify the behaviour of many individual **agents** - here, households - and obtain the macro variables by *summing over agents*. Aggregate regularities then **emerge** from the interaction of the agents rather than being imposed (for a practical, code-based introduction to this bottom-up approach, in the same "learning by doing" spirit as this repository, see [Caiani et al. (2016)](#references)).

Three features distinguish the ABM style used here:

1. **Heterogeneity.** Agents differ - for instance, each household has its own propensity to consume.
1. **Interaction and matching.** Agents meet through explicit mechanisms - here a random *job lottery* (who is hired) and a *first-come-first-served* goods market (who gets served when output is short).
1. **Sequential decisions.** Agents act one after another, out of *last* period's information, so there is no need to solve a simultaneous system by iteration.

Crucially, the models remain **stock-flow consistent**: because money is only ever transferred between agents (never created or destroyed by the matching), the redundant equation continues to hold to machine precision. The ABMs are run many times (**Monte Carlo** repetitions); charts show every run (thin grey lines) plus the mean (bold line).

> ### 📦 Box D - Emergence: a flock without a leader
>
> Watch a flock of starlings wheel across the sky and it is tempting to look for a
> leader, or a master plan. There is neither. Each bird follows only a few simple
> rules, looking at its nearest neighbours: **separation** (don't crowd them),
> **alignment** (head roughly the same way as them), and **cohesion** (don't drift
> too far from them). No bird can see the whole flock, and nowhere in these rules is
> the word "flock" written down. Yet the flock appears - a coherent, shifting shape
> that belongs to the group and to no individual. This is **emergence**: order at the
> level of the whole that arises purely from local interaction, and that you could
> never have read off a single bird.
>
> <div align="center">
> <img src="https://github.com/marcoverpas/figures/blob/main/deterministic_vs_emergent.gif" width="720"><br>
> <sub><i>Left: a swarm on the Lorenz attractor (deterministic dynamics, no interaction).
> Right: a Boids flock (order emerging from local interaction).</i></sub>
> </div>
>
> <br>
> 
> The two panels make the distinction concrete. On the **left**, a cloud of particles
> each obeys the very same set of differential equations (the Lorenz system): the motion
> is intricate, even chaotic, yet every dot is slaved to a global law and none of them
> ever look at one another - this is complexity, but *not* emergence, the shape was
> written into the equations from the start. On the **right**, the birds are told nothing
> about any global shape; they follow only local rules, and the flock self-organises. The
> test is simple: switch the interaction *off* - let each bird ignore its neighbours -
> and the flock dissolves into a cloud of independent wanderers. The pattern lived in the
> *interaction*, not in the birds.
>
> **Agent-based models (ABMs)** put this idea to work in economics. Instead of writing
> down how the *economy* behaves, we specify how many individual **agents** - here,
> households and/or firms - behave, and let them interact through markets. The aggregate
> quantities (output, employment, wealth) are then simply the sums over agents, and
> macroeconomic regularities *emerge* from the crowd rather than being assumed. As we will
> see, features that no household was ever told to produce - involuntary unemployment, or
> an aggregate demand that depends on precisely *who* was paid this period - appear all by
> themselves, the economic counterpart of the flock.
>
> <sub>Left panel: the Lorenz system (E. N. Lorenz, "Deterministic Nonperiodic Flow",
> *Journal of the Atmospheric Sciences*, 1963). Right panel: the "Boids" flocking model
> (C. W. Reynolds, "Flocks, Herds and Schools: A Distributed Behavioral Model",
> *Computer Graphics*, 1987).</sub>

---

### 3.2 - Model ABM-SIM

Model **ABM-SIM** is Model SIM populated by $N$ households. Each household holds its own money $h_i$, forms its own disposable income $yd_i$, and has its own propensity to consume $\alpha_{1,i}$. The number of households exceeds the workers ever needed, so **unemployment emerges** rather than being assumed. One period unfolds as a sequence of "ticks":

1. each household plans consumption out of its last income and its money, $c_i = \alpha_{1,i} \cdot yd_{i,-1} + \alpha_2 \cdot h_i$;
1. the economy needs one worker per unit of demand; a **job lottery** (with spread $s$) fills the jobs - some go unfilled;
1. whoever works produces the good and is paid; goods are sold **first-come-first-served** until they run out;
1. taxes are paid, and each household updates its money holdings.

Summing over households reproduces the aggregate SIM: mean output converges to $G/\theta$. Two results are worth highlighting.

- **Emergent unemployment.** With the hiring spread $s>0$, employment is a genuinely fluctuating, model-generated variable.
- **Higher accumulated wealth.** The money stock settles *above* the frictionless SIM value. When hiring falls short, households are rationed and cannot spend all they planned; the unspent income becomes **involuntary saving**, so wealth builds up a buffer. In steady state $H \approx H_{SIM} + \text{(average rationing)}/\alpha_2$, so the more friction, the larger the money stock. Setting $s = 0$ (and no heterogeneity) recovers the textbook value exactly.

In the figure below (as in all agent-based charts that follow), each **thin grey line is a single Monte Carlo run**, while the **bold coloured line is the average across the 50 runs**. In other words, the grey band shows how much the outcome varies from one realisation to the next, the coloured line its expected path.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_ABM_SIM.png" width="900">
</figure>

The `R` code for this model is [`ABM_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_SIM.R).

---

### 3.3 - Model ABM-PC

Model **ABM-PC** adds PC's portfolio choice to the households. Each household still works (job lottery) and consumes (own propensity), but now also splits its wealth between cash and bonds and earns interest. Aggregating reproduces Model PC. Heterogeneity here has a sharper consequence: because aggregate demand depends on *which* households earn income (weighted by their individual propensities), the random order of hiring now **feeds through to the macro totals** - the composition of income becomes a macro variable in its own right, exactly the mechanism that motivates heterogeneous-agent macroeconomics.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_ABM_PC.png" width="900">
</figure>

The `R` code for this model is [`ABM_PC.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_PC.R).

---

### 3.4 - Model ABM-BMW

Model **ABM-BMW** keeps the households as the agents - heterogeneous as both **workers** (job lottery with spread $s$) and **consumers** (own $\alpha_{1,i}$) - while the **firm, capital and banking block is the standard aggregate BMW**. When hiring falls short, output is below demand, so **investment as well as consumption** is rationed. Because the investment accelerator feeds on output, the friction's recessionary bias is **amplified** (lower output → lower target capital → lower investment → lower output), so the mean output sits noticeably below the frictionless BMW level. Setting $s = 0$ (and no heterogeneity) recovers the exact deterministic BMW. The redundant equation $M_h = M_s$ holds throughout.

<figure>
<img
src="https://github.com/marcoverpas/figures/blob/main/Fig1_ABM_BMW.png" width="900">
</figure>

The `R` code for this model is [`ABM_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_BMW.R).

---

## Concluding remarks

The nine models in this repository are deliberately small, and that **smallness is the point**. Each was built **one layer at a time**: an accounting skeleton first, then a behavioural closure, then - only where the research question demanded it - an input-output core or agent-based microfoundations. Proceeding step by step is not a pedagogical nicety but a methodological discipline. At every stage the balance-sheet and transactions-flow matrices must sum to zero, and the redundant equation must hold to machine precision. A model that fails this test is not "roughly right". It is leaking money somewhere, and any result it produces cannot be fully trusted. **Accounting consistency** is the non-negotiable floor beneath everything else.

Complexity, by contrast, should always have to justify itself. **Input-output** detail earns its place when the question is about industrial interdependence, structural change, relative prices, or the propagation of a sectoral shock. **Heterogeneous agent-based microfoundations** earn their place when heterogeneity and interaction genuinely produce emergent macroeconomic behaviour (in our simple examples, the composition of income becomes a macro variable in its own right, and involuntary saving and rationing drive wealth away from its frictionless value). When the question does not require these extensions, the aggregate model is not a poorer answer but the right one. The art is matching the resolution of the model to the resolution of the question, and no finer.

Lastly, allow me a few words on **Artificial Intelligence** (AI). AI is transforming how we develop these models. It writes and debugs code, checks consistency, ports a model from one language to another, and lets a single researcher explore in an afternoon what once took a term. This is a genuine gain. I could not have prepared these lectures so quickly without it. However, it carries a real danger: the ease of generating ever larger and more intricate models tempts us to mistake complication for insight. A model no one can fully read, whose mechanisms are buried under thousands of auto-generated lines, is a **black box** - and a black box does not deepen our understanding of economic, financial, social, and environmental phenomena. It merely relocates our ignorance. AI should be **used to simplify**: to strip a model to its essential mechanisms, to make its logic transparent, to let us see clearly why a result holds.

<div align="center">
<img src="https://github.com/marcoverpas/figures/blob/main/monster_rainbow.gif" width="500"><br>
<sub><i>A "mathematical monster": a few lines of code yield an elaborate, lifelike form that has no economic meaning. The point is that building complex models is easy. Giving them economic meaning to address real-world issues is much harder. <br>Source: adapted from an original generative-art snippet by <a href="https://x.com/yuruyurau">@yuruyurau</a>.</i></sub>
</div>

<br>

This is the challenge of the coming years. If SFC, IO, ABM and other monetary-production approaches are to outcompete neoclassical and other mainstream methods, it will not be by purely matching them in mathematical elaboration. It will be by offering models that are at once fully consistent, economically transparent, and no more complex than the question requires - models a student can open, read, and understand, and that AI has helped us make simpler rather than more opaque. Kept to that standard, these tools sharpen our capacity to analyse the real economy. Abandoned to it, they only automate our confusion.

## References

- Berg, M., Hartley, B., and Richters, O. (2015). **A stock-flow consistent input-output model with applications to energy price shocks, interest rates, and heat emissions**. *New Journal of Physics*, 17, 015011.
- Caiani, A., Russo, A., Palestrini, A., and Gallegati, M. (eds.) (2016). **Economics with Heterogeneous Interacting Agents: A Practical Guide to Agent-Based Modeling**. Springer, New Economic Windows series.
- Fevereiro, J. B. R. T., Genovese, A., Purvis, B., Valles Codina, O., and Veronese Passarella, M. (2025). **Macroeconomic Models for Assessing the Transition towards a Circular Economy: A Systematic Review**. *Ecological Economics*, 236, 108669.
- Godley, W., and Lavoie, M. (2007). **Monetary Economics: An Integrated Approach to Credit, Money, Income, Production and Wealth**. Palgrave Macmillan (chapters 3, 4 and 7).
- Lorenz, E. N. (1963). **Deterministic Nonperiodic Flow**. *Journal of the Atmospheric Sciences*, 20 (2): 130-141.
- Miller, R. E., and Blair, P. D. (2009). **Input-Output Analysis: Foundations and Extensions**. Cambridge University Press, 2nd edition (chapters 1–2).
- Nikiforos, M., and Zezza, G. (2017). **Stock-flow Consistent Macroeconomic Models: A Survey**. *Journal of Economic Surveys*, 31 (5): 1204-1239.
- Reynolds, C. W. (1987). **Flocks, Herds and Schools: A Distributed Behavioral Model**. *Computer Graphics*, 21 (4): 25-34.
- Veronese Passarella, M. (2025). **Destabilizing a Stable Economy: Minsky Meets Graziani's Monetary Circuit**. *International Journal of Political Economy*, 54 (3): 338-355.
