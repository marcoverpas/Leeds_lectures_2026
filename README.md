# Modelling Monetary Economies of Production: Integrating SFC, IO and AB Approaches

<figure>
<img src="https://github.com/marcoverpas/figures/blob/main/cover_4.png" width="1000">
</figure>

## Overview

This repository presents **nine small macroeconomic models**, organised as a 3 × 3 grid. Three benchmark Stock-Flow Consistent (SFC) toy models from [Godley and Lavoie (2007)](#references) — **SIM**, **PC** and **BMW** — are each developed in three coding *styles*:

|                          | **Aggregate (original)** | **Input-Output (IO)** | **Agent-Based (ABM)** |
|:-------------------------|:------------------------:|:---------------------:|:---------------------:|
| **SIM** (money only)     | [1. Model SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_SIM.R) | [4. Model IO-SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_SIM.R) | [7. Model ABM-SIM](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_SIM.R) |
| **PC** (money + bonds)   | [2. Model PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_PC.R) | [5. Model IO-PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_PC.R) | [8. Model ABM-PC](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_PC.R) |
| **BMW** (banks + capital)| [3. Model BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_BMW.R) | [6. Model IO-BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_BMW.R) | [9. Model ABM-BMW](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_BMW.R) |

Reading across a row shows how the *same* economy can be represented at three levels of resolution: as economy-wide aggregates, as a set of interacting **industries** (IO), and as a population of interacting **households** (ABM). Reading down a column shows how the financial structure is progressively enriched: from a single state money (SIM), to money plus government bonds (PC), to bank loans and deposits financing fixed capital (BMW).

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
- [References](#references)

All code has been developed for an `R` environment and is available in [this repository](https://github.com/marcoverpas/Leeds_lectures_2026).

:unlock: :copyright: *Note*: All the material in this repository is licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/?ref=chooser-v1). You are encouraged to use it for non-commercial purposes, provided that proper credit is given.

---

## A note on SFC accounting

Every model below obeys the four accounting principles of SFC modelling: **flow consistency**, **stock consistency**, **stock-flow consistency**, and **quadruple book-keeping**. In practice this means each model is built around two accounting tables — a **balance-sheet matrix** (stocks) and a **transactions-flow matrix** (flows) — whose rows and columns must sum to zero. Because the tables are watertight, every model contains one *redundant* (or *hidden*) equation, logically implied by all the others (*Walras' Law*). We omit it from the code and use it instead to double-check that the model is watertight.

Throughout, scalars are written in *italics*; vectors and matrices in upright bold. The subscript $-1$ denotes a one-period lag.

---

## 1 - Aggregate models

### 1.1 - Model SIM

Model **SIM** ("**SIM**plest") is the most basic SFC model ([Godley and Lavoie, 2007, ch. 3](#references)). It has a single financial asset — **state money (cash)** — created when the government spends and destroyed when it taxes.

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

*[Figure 1 here — consistency check: $H_h - H_s$]*

*[Figure 2 here — evolution of disposable income and consumption towards the steady state]*

The `R` code for this model is [`BASIC_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_SIM.R).

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

|                       | Households          | Firms          | Central bank         | Government          | Row tot |
|:----------------------|:-------------------:|:--------------:|:--------------------:|:-------------------:|:-------:|
|                       |                     |                |                      |                     |         |
| Consumption           | $$-C$$              | $$+C$$         |                      |                     |   0     |
| Government expenditure |                    | $$+G$$         |                      | $$-G$$              |   0     |
| GDP (income)          | $$+Y$$              | $$-Y$$         |                      |                     |   0     |
| Interest payments     | $$r_{-1} B_{h,-1}$$ |                | $$r_{-1} B_{cb,-1}$$ | $$-r_{-1} B_{s,-1}$$|   0     |
| CB profit             |                     |                | $$-r_{-1} B_{cb,-1}$$| $$r_{-1} B_{cb,-1}$$|   0     |
| Taxes                 | $$-T$$              |                |                      | $$T$$               |   0     |
|                       |                     |                |                      |                     |         |
| Change in cash        | $$-\Delta H_h$$     |                | $$\Delta H_s$$       |                     |   0     |
| Change in bonds       | $$-\Delta B_h$$     |                | $$-\Delta B_{cb}$$   | $$\Delta B_s$$      |   0     |
|                       |                     |                |                      |                     |         |
| Column tot.           |   0                 |  0             |   0                  |   0                 |   0     |

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

*[Figure 3 here — consistency check]*

*[Figure 4 here — income after government spending, with steady-state value]*

*[Figure 5 here — income after an interest-rate rise (exogenous vs endogenous propensity to consume)]*

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

Since banks and firms make no net profit, household net wealth equals the stock of fixed capital.

#### Table 2. Transactions-flow matrix

|                      | Households                | Firms (current)          | Firms (capital) | Banks                     | Row tot |
|:---------------------|:-------------------------:|:------------------------:|:---------------:|:-------------------------:|:-------:|
|                      |                           |                          |                 |                           |         |
| Consumption          | $$-C$$                    | $$+C$$                   |                 |                           |   0     |
| Investment           |                           | $$+I$$                   | $$-I$$          |                           |   0     |
| [ Production ]       |                           | $$[Y]$$                  |                 |                           |         |
| Wages                | $$+WB$$                   | $$-WB$$                  |                 |                           |   0     |
| Depreciation         |                           | $$-AF$$                  | $$+AF$$         |                           |   0     |
| Interest on loans    |                           | $$-r_{l,-1} L_{-1}$$     |                 | $$+r_{l,-1} L_{-1}$$      |   0     |
| Interest on deposits | $$+r_{m,-1} M_{-1}$$      |                          |                 | $$-r_{m,-1} M_{-1}$$      |   0     |
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

$$N = \frac{Y}{pr}, \qquad w = \frac{WB}{N} \quad \text{(B.14, B.15)}$$

$$C = \alpha_0 + \alpha_1 \cdot YD + \alpha_2 \cdot M_{h,-1} \quad \text{(B.16)}$$

$$K = K_{-1} + I - DA, \qquad DA = \delta \cdot K_{-1} \quad \text{(B.17, B.18)}$$

$$K^t = \kappa \cdot Y_{-1}, \qquad I = \gamma \cdot (K^t - K_{-1}) + DA \quad \text{(B.19, B.20)}$$

$$r_l = \bar{r}_l \quad \text{(B.21)}$$

The redundant equation is $\Delta M_h = \Delta M_s$ (equivalently $M_h = M_s$). Note the accelerator (B.19)–(B.20): firms target a capital stock proportional to lagged output and close a fraction $\gamma$ of the gap each period, on top of replacing depreciation.

*[Figure 6 here — consistency check and evolution of national income toward the steady state]*

*[Figure 7 here — the six BMW experiments: autonomous-consumption shock, paradox of thrift, change in the capital-output ratio, interest-rate rise]*

The `R` code for this model is [`BASIC_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/BASIC_BMW.R).

---

## 2 - Input-Output models

### 2.1 - The logic of IO and IO-SFC models

The benchmark models above are **fully aggregated**: production is a single homogeneous good. **Input-Output (IO) analysis** ([Miller and Blair, 2009](#references)) instead splits production into several **industries** that buy and sell intermediate goods from one another. Each industry needs the products of the others as inputs, so total ("gross") output must cover both **final demand** (consumption, government, investment) and **intermediate demand**.

With $n$ industries, let $\mathbf{x}$ be the vector of real gross outputs, $\mathbf{d}$ the vector of real final demands, and $\mathbf{A}$ the matrix of **technical coefficients**, where $a_{ij}$ is the amount of good $i$ needed to produce one unit of good $j$. The accounting identity of production is:

$$\mathbf{x} = \mathbf{A}\,\mathbf{x} + \mathbf{d} \quad \Longrightarrow \quad \mathbf{x} = (\mathbf{I} - \mathbf{A})^{-1}\,\mathbf{d}$$

where $(\mathbf{I} - \mathbf{A})^{-1}$ is the **Leontief inverse**, which translates any final demand into the gross output every industry must produce to satisfy it (directly and indirectly).

Standard IO analysis is powerful but **static**: it compares two snapshots without describing the path between them, and it says little about money and finance. **SFC modelling** is the mirror image: dynamically and financially coherent, but usually blind to inter-industry detail. **IO-SFC models** combine the two — industrial granularity from IO, dynamic and financial coherence from SFC — so that a demand-driven, monetary economy is resolved industry by industry while every stock and flow still adds up ([Berg et al. 2015](#references); [Veronese Passarella, 2023](#references); [Fevereiro et al. 2025](#references)).

Adding an IO layer to an SFC model requires only a handful of extra equations. Prices are no longer fixed but set by **cost-plus (reproduction) conditions**, and final demand is split across industries by fixed **composition shares**. Because prices now exist, real and nominal magnitudes diverge: consumption is decided in real terms while GDP is measured in value.

### 2.2 - Model IO-SIM

Model **IO-SIM** is Model SIM with a three-industry input-output core (agriculture, manufacturing, services). The macro-accounting (Tables 1–2 of SIM) is unchanged; the following equations are added or modified.

Additional assumptions relative to SIM:

1. Three industries; each produces one good with one technique

1. Fixed technical coefficients (circulating capital)

1. Prices set by reproduction conditions (cost-plus mark-up)

1. The composition of consumption and government spending is exogenous

Composition of real consumption and government spending (behavioural):

$$\mathbf{B}_c = \bar{\mathbf{B}}_c, \qquad \mathbf{B}_g = \bar{\mathbf{B}}_g \quad \text{(13, 14)}$$

with $\sum_j B_{cj} = \sum_j B_{gj} = 1$.

Real final demand by industry (identity):

$$\mathbf{d} = \mathbf{B}_c \cdot c + \mathbf{B}_g \cdot g \quad \text{(15)}$$

Real gross output by industry (identity):

$$\mathbf{x} = (\mathbf{I}-\mathbf{A})^{-1}\,\mathbf{d} \quad \text{(16)}$$

Nominal GDP (identity):

$$Y = \mathbf{p}^T \cdot \mathbf{d} \quad \text{(1.A)}$$

Unit prices of reproduction (behavioural):

$$\mathbf{p}^T = \left( w \oslash \mathbf{pr}^T \right) + \left( \mathbf{p}^T \cdot \mathbf{A} \right)(1 + \mu) \quad \text{(17)}$$

where $w$ is the (uniform) wage rate, $\mathbf{pr}$ the vector of labour productivities, and $\mu$ the (uniform) mark-up.

Average consumer and government price indices (identities):

$$p_c = \mathbf{p}^T \cdot \mathbf{B}_c, \qquad p_g = \mathbf{p}^T \cdot \mathbf{B}_g \quad \text{(18, 19)}$$

Real consumption (behavioural), where consumers do not suffer from money illusion:

$$c = \alpha_1 \cdot \left( \frac{YD}{p_c} - \pi \cdot \frac{H_{h,-1}}{p_c} \right) + \alpha_2 \cdot \frac{H_{h,-1}}{p_c} \quad \text{(5.A)}$$

Nominal consumption and government spending become $p_c \cdot c$ and $p_g \cdot g$. The redundant equation $H_h = H_s$ still holds.

*[Figure 8 here — consistency check and income/consumption (matching aggregate SIM)]*

*[Figure 9 here — final demand and gross output by industry]*

*[Figure 10 here — unit prices by industry and the consumer/government price indices]*

The `R` code for this model is [`IO_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_SIM.R).

### 2.3 - Model IO-PC

Model **IO-PC** is the same IO layer bolted onto Model PC. The only difference from IO-SIM is the financial side inherited from PC: households now allocate wealth between cash and bonds (equations 6–11 above), income includes interest, and taxes fall on total income. The IO block (equations 13–19) is identical, and government spending is valued at $p_g \cdot g$. The redundant equation remains $H_h = H_s$, and the aggregate behaviour reproduces Model PC while adding the industrial and price detail.

*[Figure 11 here — IO-PC baseline: consistency, income/consumption, portfolio, industry detail]*

The `R` code for this model is [`IO_PC.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_PC.R).

### 2.4 - Model IO-BMW

Model **IO-BMW** adds the same IO/price layer to Model BMW. The novelty is **investment**: final demand now has three components — consumption, government (absent in BMW) and **investment** — so

$$\mathbf{d} = \mathbf{B}_c \cdot c + \mathbf{B}_i \cdot i$$

where $\mathbf{B}_i$ is the vector of investment composition shares. Capital is now determined **industry by industry**, following the solution used in larger empirical IO-SFC models: each industry targets a capital stock proportional to its own lagged **gross** output, and invests to close part of the gap plus replace depreciation:

$$k^t_z = \kappa_z \cdot x_{z,-1}, \qquad i_z = \gamma \cdot (k^t_z - k_{z,-1}) + da_z, \qquad da_z = \delta_z \cdot k_{z,-1}$$

Aggregate investment is then $\sum_z i_z$, and the BMW loan/deposit block (B.6–B.21) operates on the resulting nominal magnitudes. Because the target is defined on gross output (which exceeds value added), the capital-to-output ratio $\kappa_z$ is smaller than the value used against income in the aggregate BMW. The redundant equation is again $M_h = M_s$.

*[Figure 12 here — IO-BMW baseline: consistency, income/consumption, investment/depreciation, industry outputs, prices, deposits]*

The `R` code for this model is [`IO_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/IO_BMW.R).

---

## 3 - Agent-based models

### 3.1 - The agent-based approach

The aggregate and IO models are **top-down**: they specify economy-wide (or industry-wide) behavioural rules directly. **Agent-based models (ABMs)** are **bottom-up**: they specify the behaviour of many individual **agents** — here, households — and obtain the macro variables by *summing over agents*. Aggregate regularities then **emerge** from the interaction of the agents rather than being imposed.

Three features distinguish the ABM style used here:

1. **Heterogeneity.** Agents differ — for instance, each household has its own propensity to consume.

1. **Interaction and matching.** Agents meet through explicit mechanisms — here a random *job lottery* (who is hired) and a *first-come-first-served* goods market (who gets served when output is short).

1. **Sequential decisions.** Agents act one after another, out of *last* period's information, so there is no need to solve a simultaneous system by iteration.

Crucially, the models remain **stock-flow consistent**: because money is only ever transferred between agents (never created or destroyed by the matching), the redundant equation continues to hold to machine precision. The ABMs are run many times (**Monte Carlo** repetitions); charts show every run (thin grey lines) plus the mean (bold line).

### 3.2 - Model ABM-SIM

Model **ABM-SIM** is Model SIM populated by $N$ households. Each household holds its own money $h_i$, forms its own disposable income $yd_i$, and has its own propensity to consume $\alpha_{1,i}$. The number of households exceeds the workers ever needed, so **unemployment emerges** rather than being assumed. One period unfolds as a sequence of "ticks":

1. each household plans consumption out of its last income and its money, $c_i = \alpha_{1,i}\,yd_{i,-1} + \alpha_2\,h_i$;

1. the economy needs one worker per unit of demand; a **job lottery** (with spread $s$) fills the jobs — some go unfilled;

1. whoever works produces the good and is paid; goods are sold **first-come-first-served** until they run out;

1. taxes are paid, and each household updates its money holdings.

Summing over households reproduces the aggregate SIM: mean output converges to $G/\theta$. Two results are worth highlighting.

- **Emergent unemployment.** With the hiring spread $s>0$, employment is a genuinely fluctuating, model-generated variable.

- **Higher accumulated wealth.** The money stock settles *above* the frictionless SIM value. When hiring falls short, households are rationed and cannot spend all they planned; the unspent income becomes **involuntary saving**, so wealth builds up a buffer. In steady state $H \approx H_{SIM} + \text{(average rationing)}/\alpha_2$, so the more friction, the larger the money stock. Setting $s = 0$ (and no heterogeneity) recovers the textbook value exactly.

*[Figure 13 here — output, income/consumption, money stock (above the SIM value), and emergent unemployment, with Monte Carlo fan]*

The `R` code for this model is [`ABM_SIM.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_SIM.R).

### 3.3 - Model ABM-PC

Model **ABM-PC** adds PC's portfolio choice to the households. Each household still works (job lottery) and consumes (own propensity), but now also splits its wealth between cash and bonds and earns interest. Aggregating reproduces Model PC. Heterogeneity here has a sharper consequence: because aggregate demand depends on *which* households earn income (weighted by their individual propensities), the random order of hiring now **feeds through to the macro totals** — the composition of income becomes a macro variable in its own right, exactly the mechanism that motivates heterogeneous-agent macroeconomics.

*[Figure 14 here — ABM-PC: aggregate paths with Monte Carlo fan; portfolio split]*

The `R` code for this model is [`ABM_PC.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_PC.R).

### 3.4 - Model ABM-BMW

Model **ABM-BMW** keeps the households as the agents — heterogeneous as both **workers** (job lottery with spread $s$) and **consumers** (own $\alpha_{1,i}$) — while the **firm, capital and banking block is the standard aggregate BMW**. When hiring falls short, output is below demand, so **investment as well as consumption** is rationed. Because the investment accelerator feeds on output, the friction's recessionary bias is **amplified** (lower output → lower target capital → lower investment → lower output), so the mean output sits noticeably below the frictionless BMW level. Setting $s = 0$ (and no heterogeneity) recovers the exact deterministic BMW. The redundant equation $M_h = M_s$ holds throughout.

*[Figure 15 here — ABM-BMW: output, consumption, investment/depreciation, capital, deposits, unemployment, with Monte Carlo fan]*

The `R` code for this model is [`ABM_BMW.R`](https://github.com/marcoverpas/Leeds_lectures_2026/blob/main/ABM_BMW.R).

---

## References

- Berg, M., Hartley, B., and Richters, O. (2015). **A stock-flow consistent input-output model with applications to energy price shocks, interest rates, and heat emissions**. *New Journal of Physics*, 17, 015011.

- Fevereiro, J. B. R. T., Genovese, A., Purvis, B., Valles Codina, O., and Veronese Passarella, M. (2025). **Macroeconomic Models for Assessing the Transition towards a Circular Economy: A Systematic Review**. *Ecological Economics*, 236, 108669.

- Godley, W., and Lavoie, M. (2007). **Monetary Economics: An Integrated Approach to Credit, Money, Income, Production and Wealth**. Palgrave Macmillan (chapters 3, 4 and 7).

- Miller, R. E., and Blair, P. D. (2009). **Input-Output Analysis: Foundations and Extensions**. Cambridge University Press, 2nd edition (chapters 1–2).

- Nikiforos, M., and Zezza, G. (2017). **Stock-flow Consistent Macroeconomic Models: A Survey**. *Journal of Economic Surveys*, 31 (5): 1204-1239.

- Veronese Passarella, M. (2023). **Technical change and the monetary circuit: an input-output stock-flow consistent dynamic model**. *Quaderni del Dipartimento di Economia Politica e Statistica*, Università di Siena, n. 903.
