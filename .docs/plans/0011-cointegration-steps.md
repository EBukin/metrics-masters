# Write the cointegration steps of the time chapter

- **Date:** 2026-10-06
- **Author:** Eduard Bukin
- **Status:** active

## Goal

`chapters/04-time/` ends the way it starts: a question in the house-price
example's words, one paragraph of intuition, every call in the open, a
picture, a one-sentence reading of each result, a "Next" box, and collapsed
Recipe, Pitfalls and Book check boxes. Two steps cover sections 2.1 to 2.3
of `.docs/panel-spat-PLAN.md`: `7-cointegration.qmd` asks whether log house
prices and log incomes share one trend, state by state with Johansen's rank
test and as a panel with Pedroni's residual tests; `8-long-run.qmd` asks
what that long-run link is, and shows that only the CCE regression with a
CIPS test on its residuals, the substitute of Croissant & Millo §8.4.3,
answers it on this panel. Kao, McCoskey–Kao, Larsson, Westerlund, FMOLS,
DOLS, DSUR and the factor estimators are stated limitations with their
Stata benchmark named and deferred. One theory note, "Cointegration in
panels", carries the math and the literature with page-checked citations.
`7-summary.qmd` becomes `9-summary.qmd`, the chapter intro no longer says
"not yet written", the map has a cointegration box, the checklist in
`index.qmd` is ticked, `renv.lock` records `pco`, and the chapter renders
from a clean cache.

## Context

**What exists.** Chapter 04 is written through the summary, and three
places already touch cointegration:

- `chapters/04-time/index.qmd`, lines 12–13: "Cointegration, serial
  correlation and dynamic panels are later parts of this chapter, not yet
  written." Line 32 of the mermaid map ends in the box "Treat as I(1):
  difference, or test cointegration", which leads nowhere.
- `chapters/04-time/4-second-generation.qmd`, lines 70–92, chunk
  `c04-4-residuals`: attaches **plm**, fits `ccemg` and `ccep` with
  `plm::pcce` on `HousePricesUS`, and runs `plm::cipstest(type = "none")`
  on both residual series: −2.6588 and −2.2049, both below the 0.01 level.
  Its Book check (lines 129–136) matches Croissant & Millo §8.4.3. Lines
  90–92 read the result as "log price and log income move together in the
  long run, and the CCE estimates ... 1.14 and 1.20, describe that long-run
  link." This is spec 2.3's substitute, already run. The two objects stay
  in the chapter's session, so step 8 reuses them and does not refit.
- `chapters/04-time/6-traps.qmd`, lines 120–185, `{#sec-ur-cross-coint}`:
  spec 1.6, cross-unit cointegration, written as a trap. It introduces
  `urca::ca.jo` (`type = "trace"`, `ecdet = "none"`, `K = 2`) on simulated
  pairs, reads `@teststat[2]` against `@cval[2, "5pct"]`, and its Book check
  (lines 177–185) already credits `ca.jo` with reproducing Johansen's
  money-demand examples. Step 7 links to it and does not repeat it.
- `chapters/04-time/7-summary.qmd`: line 6–7 state the CCE residual result;
  line 17 of the decision table says "Treat as I(1); difference, or test
  cointegration" with no link; lines 34–36 say the long-run question "is
  Stage 2 of `.docs/panel-spat-PLAN.md`, still to be written." The file has
  no executed chunk, so no `c04-7-*` label exists to rename.
- `chapters/04-time/theory-panel-unit-roots.qmd`: §6 (lines 251–269) covers
  cross-unit cointegration; §8 "Open" (lines 290–292) and "Next" (lines
  300–305) hand off to "Stage 2 of `.docs/panel-spat-PLAN.md`" in code
  style, not to a node.
- `chapters/02-cross-dependence/3-cce.qmd`, chunk `c02-3-pcce`, fits the
  same `ccemg` and `ccep` and sets the gloss style for terms from another
  chapter: a one-line gloss plus a link by chapter and anchor.

**What runs.** Checked on 2026-10-06 in the project renv, R 4.6.1,
plm 2.6.7, urca 1.3.4, pder 1.0.2, pco 1.0.1.

| Target | Source | Printed | Here |
|---|---|---|---|
| `ca.jo` on `urca::denmark`, eigenvalues | `?ca.jo` example; Johansen & Juselius (1990) | 0.4332, 0.1776, 0.1128, 0.0434 (page not checkable here) | 0.4332, 0.1776, 0.1128, 0.0434 |
| same, λ-max | same | 30.09, 10.36, 6.34, 2.35 | 30.09, 10.36, 6.34, 2.35 |
| same, trace | same | 49.14, 19.06, 8.69, 2.35 | 49.14, 19.06, 8.69, 2.35 |
| `ca.jo` on `urca::finland`, λ-max | `?ca.jo` example | help page prints nothing | 38.49, 26.64, 7.89, 3.11 |
| CIPS on `ccemg` residuals | CM §8.4.3, p. 209 (PDF 230) | −2.7, p = 0.01 | −2.6588, p < 0.01 |
| CIPS on `ccep` residuals | same | −2.2, p = 0.01 | −2.2049, p < 0.01 |
| CCEMG, CCEP slope (SE) | CM pp. 197–199 | 1.135 (0.195), 1.199 (0.207) | 1.1354 (0.1955), 1.1994 (0.2073) |
| `pedroni99(gdi, gds)` | `?pedroni99` example | help page prints nothing | seven statistics, below |
| `pedroni99m` example | `?pedroni99m` | `rnorm` without a seed | not reproducible by design |
| Kao ADF on Coe–Helpman | B Table 12.3, p. 371 | −2.3058, p = 0.0106 | not run: data not in R |
| Pedroni on Coe–Helpman | B Table 12.4, p. 372 | 11 statistics | not run: data not in R |

The Danish numbers are the ones `?ca.jo` is written to reproduce; the help
page itself prints none, and neither Pfaff (2008) nor Johansen & Juselius
(1990) is in `lit/`, so the match is recorded against values known from
those sources without a page. The `pedroni99` example on the OECD
saving–investment panel (`gdi`, `gds`, 41 × 25, no NA) returns, for
`type.stat = 1`: panel v 34.69 (standardised −0.02), panel rho −28.70
(0.40), panel PP −8.97 (−0.53), panel ADF −7.64 (0.54), group rho −43.11
(0.98), group PP −10.58 (−0.76), group ADF −9.96 (0.00). Nothing to match
it against: the help page prints no output. This is the "weak target" of
the spec, and it is weaker than the spec says.

Timings. The per-state Johansen loop, 49 states × 3 deterministic cases,
0.32 s in all. `pcce` 0.05 s; `cipstest` 0.07 s; `pedroni99` 0.10 s;
`pedroni99m` on a 3-sheet array 0.11 s. Only two things take longer than a
second: `renv::install("pco@1.0.1")`, 6.7 s (4.7 s building from source),
and the Pedroni size simulation below, 200 draws under each hypothesis at
N = 49, T = 29, 38.9 s.

**Per-state rank, house prices.** `urca::ca.jo` on `cbind(log(price),
log(income))` for each of the 49 states, `type = "trace"`, `ecdet = "none"`,
`K = 2`, `spec = "longrun"`, read at 5 % (critical values 17.95 for r = 0
and 8.18 for r ≤ 1):

| Rank at 5 % | States | Which |
|---|---|---|
| 0 | 41 | the rest |
| 1 | 7 | California, Maryland, Massachusetts, New Jersey, Pennsylvania, Rhode Island, Virginia |
| 2 | 1 | New Hampshire (trace 29.35, then 11.16 > 8.18) |

The mean trace statistic for r = 0 is 11.24, the median 9.18; 11 states
pass the 10 % line (15.66) and 4 the 1 % line (23.52). With 49 tests at
5 %, 2.45 false alarms are expected, so the one rank-2 state is within
chance. The outcome moves with the deterministic term: `ecdet = "const"`
gives 29 / 16 / 4, `ecdet = "trend"` 36 / 13 / 0, and `K = 3` under
`"none"` gives 46 / 3 / 0. The long-run slope implied by the first
eigenvector of the eight rank ≥ 1 states runs from −0.13 (New Hampshire)
to 2.17 (California), median 0.70; over all 49 states the median is 0.60
and the range −3.03 to 10.12: a per-state cointegrating vector at T = 29
is noise.

**Per-state Engle–Granger.** `urca::ur.df(type = "none", lags = 2)` on the
residual of each state's OLS of log price on log income: mean t = −2.23,
median −2.09, range −4.42 to −0.60, five states below −3.37. On the CCEMG
residuals the mean is −2.79 (range −4.28 to −1.82, ten below −3.37); on the
CCEP residuals −2.86 (nine below). The per-state trace statistic and the
per-state Engle–Granger t correlate at −0.60. The per-state OLS slopes
average 0.302, the MG number of chapter 02, with range −1.14 to 2.04.

**Pedroni on house prices.** `pco::pedroni99(Y, X)` with `Y` and `X` the
29 × 49 matrices of log price and log income, `type.stat = 2` (intercept),
`kk` at its default `round(4 * (29/100)^(2/9))` = 3, `ka = 2`:

| `pco` name | Pedroni name | Empirical | Standardised |
|---|---|---|---|
| `nipanel` | panel v | 0.185 | −8.03 |
| `rhopanel` | panel rho | −35.52 | 4.08 |
| `tpanelnonpar` | panel PP | −10.64 | 4.68 |
| `tpanelpar` | panel ADF | −5334.18 | −5417.35 |
| `rhogroup` | group rho | −43.14 | 6.61 |
| `tgroupnonpar` | group PP | −11.62 | 7.06 |
| `tgrouppar` | group ADF | −7.82 | 11.90 |

`type.stat = 1` (no deterministic term) gives standardised −5.42, 3.73,
1.35, −5862.58, 7.26, 3.88, 3.86; `type.stat = 3` (intercept and trend)
−11.68, 7.39, 9.33, −5808.85, 8.46, 10.10, 14.60; `kk = 2` moves the
intercept case by less than one unit except for group ADF, which does not
depend on `kk`. Read against Pedroni's one-sided rule (panel v rejects in
the right tail, the other six in the left), none of the five usable
statistics rejects no cointegration, and all sit 4 to 12 standard
deviations into the non-rejection side.

**Pooled, within and CCE long-run slopes.** Income elasticity of house
prices, with the CIPS test (`type = "none"`) and the CD test on each
fit's residuals:

| Fit | Slope (SE) | CIPS on residuals | CD on residuals |
|---|---|---|---|
| pooled OLS | 0.4229 (0.0253) | −1.075, p > 0.10 | z = 49.3 |
| within, state effects | 0.3453 (0.0268) | −2.2011, p < 0.01 | z = 47.9 |
| within, two-way | 1.0769 (0.0683) | −2.0862, p < 0.01 | not run |
| CCEMG | 1.1354 (0.1955) | −2.6588, p < 0.01 | z = 4.45, p = 8.5e−06 |
| CCEP | 1.1994 (0.2073) | −2.2049, p < 0.01 | z = 0.62, p = 0.53 |

**What is broken or missing.**

- `pco` is archived on CRAN. `renv::install("pco")` fails with
  `package 'pco' is not available`; `renv::install("pco@1.0.1")` builds the
  archived source (2015-07-26) in 4.7 s under R 4.6.1 and loads. The
  package has no `NAMESPACE` imports beyond `stats`.
- `pco::pedroni99m` fails on the two-variable array the spec names:
  `Error in X2[, l, ] : incorrect number of dimensions`. The function takes
  `X[, , 2:M]`, which R drops to a matrix when M = 2. It runs on a 3-sheet
  array (log price, log income, log population: 0.11 s). The bivariate case
  has to go through `pco::pedroni99(Y, X)`.
- Two of the seven `pedroni99` statistics are not scale-invariant.
  Multiplying `Y` and `X` by 100 moves panel v from 0.185 to 1848.9 and
  panel ADF from −5334.18 to −0.533; the other five do not move. Pedroni's
  statistics are all scale-free, so these two are implementation errors
  and cannot be reported.
- The standardised values of the other five are not calibrated. Simulation
  at N = 49, T = 29, `type.stat = 2`, 200 draws each, one-sided 5 % rule:
  under independent random walks (no cointegration) panel v, panel rho,
  group rho, group PP and group ADF reject in 0 of 200 draws, panel PP in
  4 %, panel ADF in 100 %; under y = 1 + x + 0.5·e the six left-tail
  statistics reject in 200 of 200 and panel v in none. At N = 20, T = 200
  (100 draws) the five still reject in 0 draws; one null draw has
  standardised values +2.2 to +2.8. So the statistics separate the two
  hypotheses in direction and fail the N(0, 1) calibration. The moments
  `pco` applies for `type.stat = 2` (panel PP mean −2.177, variance 0.964)
  do not match the one pair the anchor text prints for the intercept model
  with one regressor, Z_t + 1.73√N → N(0, 0.93) [B p. 361]; the column
  `pco` uses for `type.stat = 1` (6.982, −6.388, −1.662, −1.662, −9.889,
  −1.992, −1.992; variances 81.145, 64.288, 1.559, 1.559, 41.943, 0.649,
  0.649) looks like a Table 2 column of Pedroni (1999), which is not in
  `lit/`. The step reports the five empirical values as unverified.
- `pedroni99` resets `ka = 1` to 2 with a warning (`Parameter 'ka' was
  changed to 2.`); `ka = 3` and `4` are accepted.
- No panel FMOLS, DOLS or cointegration test in **plm**: none of its 68
  exports matches `fmols|dols|coint|ecm|vecm`. `cointReg` (not installed,
  not to be installed) estimates a single cointegrating regression, no
  panel. `Westerlund` is not installed and not on CRAN as checked by the
  governing plan. Kao, McCoskey–Kao, Larsson–Lyhagen–Löthgren, Westerlund's
  ECM tests, FMOLS, DOLS, Breitung's two-step, DSUR, Bai–Kao, Bai–Kao–Ng:
  no implementation, stated limitations.
- Baltagi's printed targets for Kao and Pedroni (Tables 12.3 and 12.4,
  pp. 371–372) and for FMOLS and DOLS (Tables 12.6 and 12.7, pp. 372–373)
  are EViews output on the Coe–Helpman R&D panel of Kao, Chiang & Chen
  (1999), which ships in no R package. Not reproducible here.
- `summary()` on a `ca.jo` object prints `Length Class Mode` unless **urca**
  is attached or `urca::summary()` is called: the method lives on urca's
  own S4 generic. Read the slots `@teststat`, `@cval`, `@lambda`, `@V`
  instead, as `6-traps.qmd` does.
- `ca.jo` refuses an unnamed matrix: `cbind(log(price), log(income))`
  gives `length of 'dimnames' [2] not equal to array extent`. Name the
  columns.

**Notation.**

| Where | Term | Meaning |
|---|---|---|
| `ca.jo(ecdet = )` | `"none"` | no deterministic term in the long-run relation, unrestricted constant in the VAR: drift in the levels; prints "with linear trend" |
| | `"const"` | constant restricted to the long-run relation, no drift; prints "without linear trend and constant in cointegration" |
| | `"trend"` | trend in the long-run relation, constant unrestricted |
| `ca.jo` output | `@teststat` | ordered r ≤ 1 first, r = 0 last; `@cval` rows the same way; `@V[, 1]` the first cointegrating vector |
| `pedroni99(Y, X)` | `Y`, `X` | T × N matrices, time in rows, units in columns, no NA |
| `pedroni99m(X)` | `X` | T × N × M array, sheet 1 the dependent variable; fails at M = 2 |
| `type.stat` | 1, 2, 3 | none, intercept, intercept and trend in the per-unit regression |
| `kk`, `ka` | | Newey–West lags for the long-run variance; ADF lags for the two parametric statistics |
| `$STATISTIC` rows | `nipanel`, `rhopanel`, `tpanelnonpar`, `tpanelpar`, `rhogroup`, `tgroupnonpar`, `tgrouppar` | panel v, panel rho, panel PP, panel ADF, group rho, group PP, group ADF |
| Pesaran (2015), §31.7 | r_i | the cointegrating rank of unit i |
| Baltagi (2021), §12.5 | Z_ρ̃, Z_t̂ | Pedroni's panel rho (12.25) and panel t (12.26) |
| this book | "shares a trend" | cointegrated; "rank" is Johansen's r |

The book writes "rank" for r_i and names the seven Pedroni statistics by
Pedroni's names, with the `pco` row name in the Recipe only.

**Data.** `HousePricesUS` [@holly2010] in **pder**: 49 states, 1975–2003,
balanced, 1421 rows, no NA in `price` or `income`. The `[time, individual,
variable]` array is 29 × 49 × 2, built from `split(HousePricesUS, names)`
with rows ordered by `year`; the spot check against the long data passes.
`urca::denmark` (55 quarters, 1974Q1–1987Q3) and `urca::finland` carry the
Johansen checks; `pco::gdi` and `pco::gds` (41 × 25, OECD, 1973–2013) carry
the Pedroni example. All ship with their packages.

**Running example.** House prices continue, and nothing else is added. The
chapter has established that log price and log income wander (CIPS −2.03,
p > 0.10), that their growth rates do not, that the states share one strong
common shock (CD z = 53), and that the CCE residuals are stationary. Step 7
asks the question the chapter has so far answered only through CCE: do
price and income share a trend state by state, and does a panel test that
ignores the common shock see it? Step 8 turns the shared trend into a
slope and shows how the treatment of the common shock changes it from 0.42
to 1.20. Both steps use the `ccemg` and `ccep` objects of step 4.

## Chapter structure

### `index.qmd`

- Lines 12–13. Replace "Cointegration, serial correlation and dynamic
  panels are later parts of this chapter, not yet written." with two
  sentences: the second half asks whether two wandering series share one
  trend, **cointegration**, and how to estimate that long-run link; serial
  correlation is in [core panel models](../05-core/index.qmd), dynamic
  panels in their own chapter. Link chapter 06 only if
  `chapters/06-dynamic/index.qmd` exists when this is written; otherwise
  name no chapter (see Open questions).
- The map. Replace the dead-end box `I1` with a path, keeping every
  existing node id, so the traps stay last:

  ```
  I1["Treat as I(1)"] --> C{"Do they share a trend?<br/>rank by unit, panel test"}
  C -->|"yes"| LR["Estimate the long run<br/>with the factor removed"]
  C -->|"no"| D["Difference, or model<br/>the short run"]
  LR --> L
  D --> L
  ```
- Line 43–45. "The math and the full literature are in [the theory
  note](theory-panel-unit-roots.qmd)" becomes "the theory notes on [panel
  unit roots](theory-panel-unit-roots.qmd) and
  [cointegration](theory-cointegration.qmd)".
- Includes. Add `{{< include 7-cointegration.qmd >}}` and
  `{{< include 8-long-run.qmd >}}` after `6-traps.qmd`; change
  `7-summary.qmd` to `9-summary.qmd`.
- The setup chunk `c04-0-setup` is unchanged. Step 4 already attaches
  **plm** and leaves `ccemg`, `ccep` and `php` in the session.

### Step 7, `7-cointegration.qmd` `{#sec-ur-coint}`

Title: "Do they move together in the long run?"

- **Question.** Prices wander and incomes wander. Does a state's price
  level stay tied to its income level, so that the gap between them does
  not wander, and does the panel as a whole say so?
- **Intuition.** Open with the world: a state where incomes rise 10 %
  and prices rise 10 % and then both drift together; the ratio holds. Then
  the plain definition: two I(1) series are **cointegrated** when some
  combination of them is I(0) [@engle1987]; the combination is the
  long-run relation, and its residual is the gap that closes. Three ways
  to look for it, from one state to the panel. (1) Regress one on the
  other and test the residual for a unit root, the Engle–Granger route
  [@engle1987; @croissant2019, p. 204]. (2) Ask how many stationary
  combinations a system has, its **rank**, with Johansen's trace test
  [@johansen1988; @johansen1991]; rank 0 is no shared trend, rank 1 is one
  long-run relation, rank 2 means both series are stationary. (3) Pool the
  per-state evidence: Pedroni's tests average per-state residual
  statistics, the way IPS averaged per-state Dickey–Fuller statistics
  [@pedroni1999; @pedroni2004; @baltagi2021, pp. 360–361]. Gloss "IPS" and
  "CIPS" with a link to [second generation](index.qmd#sec-ur-second-gen).
  The precondition, in one sentence: residual-based panel tests are built
  for rank 1 in every unit with no cointegration among the regressors
  [@pesaran2015, p. 839], so the rank question comes first.
- **The tests.** Johansen trace, per state: null r = 0 against r ≥ 1,
  then r ≤ 1 against r = 2 [@johansen1991; @pfaff2008]. Pedroni's seven
  statistics: null no cointegration in any state, alternative a common
  (panel) or state-specific (group) adjustment; panel v rejects in the
  right tail, the six others in the left [@pedroni1999]. State what the
  chapter cannot run and why, in one line each, before the calls: Kao's
  pooled DF and ADF [@kao1999; @baltagi2021, pp. 357–358]; McCoskey–Kao,
  whose null is cointegration and which "is not equipped to deal with
  cross-sectional dependence" [@mccoskey1998; @baltagi2021, p. 359];
  Larsson–Lyhagen–Löthgren's LR-bar, which averages the trace statistics
  above but "requires a large time-series dimension", with size "severely
  distorted" otherwise [@larsson2001; @baltagi2021, p. 361]; Westerlund's
  error-correction tests [@westerlund2007]. None has an R implementation.
- **Run it.** Four chunks.
  - `c04-7-one-state`: `urca::ca.jo` on California (rank 1, trace 24.43
    against 17.95) and on Texas (rank 0, 3.38), in the open, reading
    `@teststat` and `@cval`, `ecdet = "none"` because the levels drift and
    step 4 gave them a drift; link the simulated version in
    [shared trends](index.qmd#sec-ur-cross-coint).
  - `c04-7-by-state`: `johansen_by_unit(php, c("price", "income"), log =
    TRUE, ecdet = "none", K = 2)` (new helper, Tooling) returning one row
    per state; print `table(rank)`: 41 / 7 / 1, and the eight names.
  - `c04-7-pedroni`: `Y <- panel_wide(php, log(price))`, `X <-
    panel_wide(php, log(income))` (helper), then
    `pco::pedroni99(Y, X, type.stat = 2)` in the open; print `$STATISTIC`
    with the two broken rows struck in the text.
  - `c04-7-eg`: `adf_by_unit()` (helper) on the per-state OLS residuals
    and on `residuals(ccemg)`: the means −2.23 and −2.79, the counts 5 and
    10 below −3.37. This is what Pedroni's group statistics average, and
    what CIPS on residuals averages after augmentation.
- **Picture.** `c04-7-picture`, two panels. Left: the 49 trace statistics
  for r = 0, sorted, as a dot plot with the 5 % line at 17.95 and the 10 %
  line at 15.66; the eight states above the line labelled. Right: each
  state's Engle–Granger t on the plain OLS residual (horizontal) against
  its t on the CCEMG residual (vertical), the 45-degree line, a cross at
  the means (−2.23, −2.79), the same design as the CADF picture of step 4
  so the reader sees the averages at work on residuals too.
- **Read it.**
  - **Rejects (seven states, rank 1).** California, Maryland,
    Massachusetts, New Jersey, Pennsylvania, Rhode Island, Virginia. *So:*
    in these states the price–income gap closes; their long-run slopes
    from the eigenvector (0.14 to 2.17) are too noisy at T = 29 to report.
  - **Does not reject (41 states).** Trace below 17.95; mean 11.24. *So:*
    one state over 29 years cannot show a shared trend; 2.45 of the eight
    rejections are expected by chance. The precondition r_i = 1 of
    @pesaran2015 [p. 839] cannot be confirmed state by state.
  - **Misleads (New Hampshire, rank 2).** 29.35 then 11.16 > 8.18, which
    says both series are stationary, against the chapter's unit-root
    results. *So:* one rank-2 result in 49 is a false alarm, not a finding.
  - **Does not reject (Pedroni, five usable statistics).** Standardised
    4.1 to 11.9, all in the non-rejection tail. *So:* a panel test that
    treats the 49 states as independent, with the national factor left in
    every residual, finds no shared trend; read with the Pitfalls, it is
    evidence about this code, not about the panel.
  - **With the averages (Engle–Granger on CCEMG residuals).** Mean t falls
    from −2.23 to −2.79, ten states pass −3.37 against five. *So:* the
    shared trend appears once the common shock is partialled out, which is
    the CIPS result of step 4 seen state by state.
- **Next.** Rank 1 in enough states, and residuals that do not wander once
  the factor is removed: estimate the long-run slope
  ([estimating the long run](index.qmd#sec-ur-long-run)). Rank 0
  everywhere: difference, and model the short run. Rank 2: go back to the
  unit-root tests.
- **Pitfalls.**
  - **`pedroni99m` fails with one regressor**: chunk `c04-7-pco-trap`,
    `error: true`, showing `incorrect number of dimensions`; use
    `pedroni99` for the bivariate case.
  - **Two `pco` statistics change with the units of the data**: chunk
    `c04-7-scale-trap`, `pedroni99(100 * Y, 100 * X)` beside the original:
    panel v 0.185 → 1848.9, panel ADF −5334 → −0.53. Never report them.
  - **The standardised values are not N(0, 1) at this shape**: chunk
    `c04-7-pco-size`, the 200-draw simulation (39 s, frozen): size 0 for
    five statistics under both T = 29 and T = 200, 1.00 for panel ADF;
    power 1.00. `pco`'s moments (−2.177, 0.964 for panel PP with an
    intercept) differ from the published pair Z_t + 1.73√N → N(0, 0.93)
    [@baltagi2021, p. 361]. Pedroni (1999) Table 2 is not in `lit/`, so
    the moments are unchecked.
  - **Pedroni assumes independent states.** Under a common factor the Kao
    and Pedroni statistics "are no longer asymptotically normal, and
    converge at the rate T rather than √N T" [@gengenbach2006;
    @baltagi2021, p. 362]; the cure Gengenbach, Palm & Urbain propose,
    defactor first and test the residuals, is step 8.
  - **Cross-unit cointegration oversizes every panel cointegration test**
    [@banerjee2004; @baltagi2021, p. 362], already shown as a trap in
    [shared trends](index.qmd#sec-ur-cross-coint).
  - **The deterministic term decides the count**: `ecdet = "const"` gives
    29 / 16 / 4, `"trend"` 36 / 13 / 0, `K = 3` 46 / 3 / 0
    [@johansen1994 on the role of the constant].
  - **`summary()` needs urca attached**; read the slots. **`ca.jo` needs
    named columns.** **`ka` below 2 is reset.**
  - **T = 29 is below the range where these tests have power**: Wagner &
    Hlouskova find power "dismal for T ≤ 25" and all but Pedroni's ADF
    tests "severely undersized" [@wagner2010; @baltagi2021, p. 363].
  - Benchmark: Stata `xtcointtest kao`, deferred. Benchmark: Stata
    `xtcointtest pedroni`, deferred. Benchmark: Stata
    `xtcointtest westerlund`, deferred.
- **Book check.** Johansen: `?ca.jo`'s Danish money-demand example gives
  eigenvalues 0.4332, 0.1776, 0.1128, 0.0434 and λ-max 30.09, 10.36, 6.34,
  2.35, the values of Johansen & Juselius (1990) that the help page is
  written to reproduce; all reproduced, page not checkable (PDF not in
  `lit/`). Pedroni: `?pedroni99`'s saving–investment example runs and
  returns seven statistics (panel v 34.69, panel rho −28.70, panel PP
  −8.97, panel ADF −7.64, group rho −43.11, group PP −10.58, group ADF
  −9.96); the help page prints no numbers, so there is nothing to match:
  the target is "runs", as the spec warns. Baltagi Table 12.4 (p. 372)
  prints Pedroni on the Coe–Helpman panel, which no R package ships: not
  reproduced. No published number for house prices: None, by
  `.docs/panel-spat-PLAN.md`.
- **Theory.** [cointegration in panels](theory-cointegration.qmd), new
  note.

### Step 8, `8-long-run.qmd` `{#sec-ur-long-run}`

Title: "Estimating the long run"

- **Question.** Incomes rise 10 % and stay there. How much do house
  prices rise in the long run, and which regression gives that number?
- **Intuition.** A cointegrating regression in levels is not spurious: its
  slope converges, and faster than in a stationary regression
  [@stock1987; @croissant2019, p. 201]. But three things sit in the
  residual of a levels regression on this panel, and each one changes the
  slope: the state's level (fixed effect), the year's level (time effect),
  and the national factor each state feels to its own degree. The
  estimators the literature built for cointegrated panels, FMOLS
  [@phillips1999; @pedroni2000] and DOLS [@kao2000], correct the residual
  for serial correlation and endogeneity but keep the states independent:
  "The assumption of cross-sectional independence is maintained"
  [@baltagi2021, p. 364]. The estimators that drop independence, DSUR
  [@mark2005], the factor FMOLS of Bai & Kao and Westerlund, and Bai, Kao &
  Ng's global stochastic trends [@bai2009kao], represent dependence "by a
  contemporaneous correlation of the errors" and exclude cross-unit
  cointegration [@pesaran2015, p. 854]. None is in R. What is in R is the
  CCE regression of chapter 02, which stays consistent when the factor is
  I(1) [@kapetanios2011], and the CIPS test on its residuals; Croissant &
  Millo use exactly this pair and conclude "both models represent
  cointegrating regressions" [@croissant2019, p. 209]. Say in the text
  that this is a substitute, labelled as such by the spec, not Pedroni's
  FMOLS or Kao's DOLS. Gloss CCE with a link to
  [CCE](../02-cross-dependence/index.qmd#sec-cce).
- **The tests.** No new test: `plm::cipstest(type = "none")` on
  residuals, as in step 4, paired with `plm::pcdtest(test = "cd")` on the
  same residuals, glossed with a link to [CD
  tests](../02-cross-dependence/index.qmd#sec-csd-tests). The pair is the
  point: CIPS says whether the gap wanders once the averages are inside
  the test; CD says whether the regression left the factor in the gap.
- **Run it.** Three chunks, one per treatment of the factor.
  - `c04-8-pooled`: `plm::plm(log(price) ~ log(income), data = php, model =
    "pooling")` and `"within"`, slopes 0.42 and 0.35; `cipstest` on each
    residual, −1.08 (p > 0.10) and −2.20 (p < 0.01); `pcdtest`, z = 49.3
    and 47.9.
  - `c04-8-twoway`: `model = "within", effect = "twoways"`, slope 1.08;
    CIPS −2.09 (p < 0.01).
  - `c04-8-cce`: `coef(ccemg)`, `coef(ccep)` from step 4 (no refit), the
    CD on their residuals, z = 4.45 and 0.62; refer to step 4's CIPS
    values, −2.66 and −2.20, in the text rather than rerunning them.
- **Picture.** `c04-8-picture`: dot-and-whisker of the income elasticity
  under the five fits (pooled 0.42, within 0.35, two-way 1.08, CCEMG 1.14,
  CCEP 1.20) with 95 % bands, each dot annotated with its residual CIPS
  verdict and its residual CD z, so the reader sees the slope triple as
  the factor leaves the residual.
- **Read it.**
  - **Rejects (CCEP, CCEMG).** CIPS −2.20 and −2.66, CD z 0.62 and 4.45.
    *So:* with the national factor partialled out, the price–income gap
    does not wander and the states' residuals no longer move together: a
    10 % rise in income goes with an 11 to 12 % rise in prices in the long
    run.
  - **Does not reject (pooled OLS).** CIPS −1.08, CD z = 49.3, slope 0.42.
    *So:* the levels regression with nothing removed is spurious on this
    panel; its slope is the leak of chapter 02.
  - **Misleads (within).** CIPS −2.20 rejects, yet CD z = 47.9 and the
    slope is 0.35. *So:* CIPS removed, inside the test, the factor the
    regression left in the residual; a stationary CIPS verdict on
    residuals does not make the regression's slope the long-run one. The
    two-way fit, slope 1.08, shows the time effect catching most of the
    factor and the CCE slope catching the rest.
- **Next.** The long-run slope is in hand and the residuals are stationary
  but serially correlated (0.82 in [the spatial
  chapter](../03-spatial/index.qmd#sec-sp-serial)): on to [core panel
  models](../05-core/index.qmd) for the error structure, and to the
  [summary](index.qmd#sec-ur-summary).
- **Pitfalls.**
  - **CIPS on residuals is not a cointegration test with tabulated size.**
    The residuals' critical values are Pesaran's for an observed series;
    the step says so, as CM do [@croissant2019, p. 209].
  - **A standard error on a cointegrating slope needs the long-run
    variance**: the `pcce` SE is the Pesaran (2006) one, not FMOLS's; the
    text reports it as such.
  - **FMOLS and DOLS "may be severely biased in small samples"**, where
    Breitung's two-step does better [@breitung2005; @pesaran2015, p. 853],
    and Wagner & Hlouskova find DOLS "outperforms all other estimators"
    [@wagner2010; @pesaran2015, p. 853]: with none implemented the book
    cannot adjudicate.
  - **Rate of convergence.** A spurious panel slope still converges, at
    √N, against √N·T for a cointegrating one [@phillips1999;
    @croissant2019, p. 201]; the standard error, not the slope, is what
    lies, as step 1 showed.
  - Benchmark: official Stata has no panel FMOLS or DOLS; `xtcointtest`
    is tests only; community `xtpedroni`, `xtdolshm`, deferred.
- **Book check.** CM §8.4.3, p. 209: CIPS on `ccemg` residuals −2.7,
  p = 0.01; on `ccep` residuals −2.2, p = 0.01. Here −2.6588 and −2.2049,
  both below 0.01: reproduced (step 4 carries the chunk; this step cites
  it). CM pp. 197–199: CCEMG 1.135 (0.195), CCEP 1.199 (0.207); here
  1.1354 (0.1955), 1.1994 (0.2073): reproduced in chapter 02. Baltagi
  Tables 12.6 and 12.7 (pp. 372–373) print FMOLS and DOLS on Coe–Helpman:
  not reproduced, data not in R. The pooled, within and two-way numbers
  have no target: None.
- **Theory.** [cointegration in panels](theory-cointegration.qmd), §
  on estimation.

### `9-summary.qmd`, renamed from `7-summary.qmd`

- `git mv chapters/04-time/7-summary.qmd chapters/04-time/9-summary.qmd`;
  the include line in `index.qmd` follows. No chunk label exists in the
  file, so no `c04-7-*` to `c04-9-*` rename happens; any chunk added later
  is `c04-9-*`.
- "What this panel says" (lines 3–7): after the CCE sentence add: state by
  state, Johansen finds a shared trend in seven states and none in 41, so
  the per-state evidence is thin at T = 29; Pedroni's panel test, which
  ignores the common shock, finds nothing and its R implementation is
  unverified; the long-run income elasticity is 1.1 to 1.2 once the factor
  is out, 0.4 if it is not.
- Decision table (lines 11–19): row "The panel does not reject" links
  "test cointegration" to [cointegration](index.qmd#sec-ur-coint). Add:
  "Both series wander and the gap does not | Estimate the slope with the
  factor removed ([long run](index.qmd#sec-ur-long-run))"; "Rank 0 in
  every unit | Difference; no long-run slope to estimate"; "Rank 2 in a
  unit | Reread the unit-root tests for that unit".
- The recipe block (lines 23–32): add
  `johansen_by_unit(d, c("y", "x"))`, `pco::pedroni99(Y, X, type.stat = 2)`
  with a comment "five of seven usable, unverified", and
  `plm::pcdtest(residuals(fit), test = "cd")` beside the existing residual
  CIPS line.
- "Next" (lines 34–36): replace the `.docs` reference with: the long-run
  slope is [estimated with CCE](index.qmd#sec-ur-long-run); the error
  around it, serial correlation included, is the subject of [core panel
  models](../05-core/index.qmd).

## Theory notes

**New: `theory-cointegration.qmd`, "Cointegration in panels"**, subtitle
"One trend shared by two series, and what a panel adds". Code links:
[cointegration](index.qmd#sec-ur-coint) and
[estimating the long run](index.qmd#sec-ur-long-run). Sections:

1. Why pool: one state over 29 years has no power against a shared trend;
   the panel adds units, and the proviso of the unit-root note returns:
   the units must bring independent evidence.
2. The minimum math: the cointegrating regression and its residual
   [@engle1987]; the VECM Δz = αβ'z_{t−1} + … and the rank of Π
   [@johansen1988; @johansen1991]; the role of the constant and trend
   [@johansen1994]; Kao's DF_ρ and ADF (B eqs. 12.16–12.19,
   pp. 357–358) [@kao1999]; Pedroni's panel rho and panel t (B eqs.
   12.25–12.26, pp. 360–361) and the standardisation Z_t + 1.73√N →
   N(0, 0.93) [@pedroni1999; @pedroni2004; @baltagi2021, p. 361]; the
   LR-bar as IPS on trace statistics [@larsson2001; @baltagi2021,
   p. 361]; McCoskey–Kao's reversed null [@mccoskey1998].
3. The precondition: residual tests need r_i = 1 and no cointegration
   among the regressors; system tests allow r_i > 1 [@pesaran2015, p. 839];
   the full pooled system is infeasible past about ten series, and common
   factors are how dependence is accommodated in practice [@pesaran2015,
   pp. 839–840, eq. 31.38].
4. Dependence: cross-unit cointegration oversizes every test
   [@banerjee2004; @baltagi2021, p. 362; @pesaran2015, p. 836]; under a
   common factor Kao's and Pedroni's statistics lose normality and the
   remedy is to defactor and test the residuals [@gengenbach2006;
   @baltagi2021, p. 362]; Westerlund & Larsson's bias in pooled PANIC and
   Bai & Ng's alternative [@westerlund2009; @bai2010; @pesaran2015,
   p. 837].
5. Estimation: FMOLS and DOLS keep independence [@phillips1999;
   @pedroni2000; @kao2000; @baltagi2021, p. 364]; Breitung's two-step and
   the Monte Carlo verdicts [@breitung2005; @wagner2010; @pesaran2015,
   p. 853]; DSUR eq. 31.57 [@mark2005; @moon2005], Bai–Kao and Westerlund
   eq. 31.58, Bai–Kao–Ng eq. 31.59, all excluding cross-unit
   cointegration [@bai2006kao; @westerlund2007factors; @bai2009kao;
   @pesaran2015, p. 854]; the panel VECM eq. 31.60 [@groen2003]; the CCE
   substitute [@kapetanios2011; @croissant2019, p. 209].
6. Finite samples: Gutierrez's mixed panels and Wagner & Hlouskova's
   "dismal" power at T ≤ 25 [@gutierrez2003; @wagner2010; @baltagi2021,
   pp. 362–363]; the project's own `pco` simulation.
7. If / then table; 8. Open (no R implementation for any test or
   estimator beyond `ca.jo` and `pco`; `pco`'s calibration; Stata
   benchmarks deferred); Next: [core panel models](../05-core/index.qmd).

**`theory-panel-unit-roots.qmd` gains one line.** In §8 "Open", the bullet
"Cross-unit cointegration ... carried as a stated limitation into Stage 2
of `.docs/panel-spat-PLAN.md`" ends instead with "into [cointegration in
panels](theory-cointegration.qmd)"; and "Next" (lines 300–305) points at
that note and at [cointegration](index.qmd#sec-ur-coint) instead of the
spec. Add the two new steps to its "Code:" list.

## Spec coverage

| Spec | Where | What runs | Stated limitation |
|---|---|---|---|
| 1.6 cross-unit cointegration | `6-traps.qmd` `#sec-ur-cross-coint`, written | `ca.jo` on simulated pairs | no panel test in R |
| 2.1 precondition | step 7, `c04-7-one-state`, `c04-7-by-state`; theory §3 | `urca::ca.jo` per state, Danish check | r_i = 1 not confirmable at T = 29 |
| 2.2 residual-based tests | step 7, `c04-7-pedroni`, `c04-7-eg`, Pitfalls; theory §2, §4, §6 | `pco::pedroni99`, per-state ADF, `?pedroni99` example | Kao, McCoskey–Kao, Larsson, Westerlund; `pco` unverified; Stata deferred |
| 2.3 long-run estimation | step 8; theory §5 | CCE + CIPS + CD, pooled and within contrast | FMOLS, DOLS, Breitung, DSUR, Bai–Kao, BKN, PMG |

## Bibliography entries to add

Every entry below was read in the reference list of Baltagi (B) or
Pesaran (P), PDF page given (Baltagi printed page = PDF − 13; Pesaran
printed = PDF − 31). Discrepancies between the two lists are flagged for
the tooling agent to settle against the publisher's page. DOIs are not in
either list and are to be added from the publisher.

| Key | Entry | Found |
|---|---|---|
| `kao1999` | Kao, C. (1999). Spurious regression and residual-based tests for cointegration in panel data. *Journal of Econometrics* 90(1): 1–44. | B PDF 400; P PDF 1047 |
| `mccoskey1998` | McCoskey, S. and Kao, C. (1998). A residual-based test of the null of cointegration in panel data. *Econometric Reviews* 17(1): 57–84. | B PDF 401; P PDF 1052 |
| `pedroni1999` | Pedroni, P. (1999). Critical values for cointegration tests in heterogeneous panels with multiple regressors. *Oxford Bulletin of Economics and Statistics* 61(S1): 653–670. | P PDF 1054 (653–670); B PDF 401 prints 653–678; `?pco` prints 653–70: flag |
| `pedroni2000` | Pedroni, P. (2000). Fully modified OLS for heterogeneous cointegrated panels. *Advances in Econometrics* 15: 93–130. | B PDF 401; P PDF 1054 (no pages) |
| `pedroni2004` | Pedroni, P. (2004). Panel cointegration: asymptotic and finite sample properties of pooled time series tests with an application to the PPP hypothesis. *Econometric Theory* 20(3): 597–625. | B PDF 401; P PDF 1054 |
| `larsson2001` | Larsson, R., Lyhagen, J. and Löthgren, M. (2001). Likelihood-based cointegration tests in heterogeneous panels. *Econometrics Journal* 4(1): 109–142. | B PDF 401; P PDF 1049 |
| `johansen1988` | Johansen, S. (1988). Statistical analysis of cointegration vectors. *Journal of Economic Dynamics and Control* 12(2–3): 231–254. | P PDF 1047 |
| `johansen1991` | Johansen, S. (1991). Estimation and hypothesis testing of cointegration vectors in Gaussian vector autoregressive models. *Econometrica* 59(6): 1551–1580. | P PDF 1047 |
| `johansen1994` | Johansen, S. (1994). The role of the constant and linear terms in cointegration analysis of nonstationary variables. *Econometric Reviews* 13(2): 205–229. | P PDF 1047 |
| `johansen1995` | Johansen, S. (1995). *Likelihood-Based Inference in Cointegrated Vector Autoregressive Models*. Oxford: Oxford University Press. | B PDF 400; P PDF 1047 |
| `johansen1990` | Johansen, S. and Juselius, K. (1990). Maximum likelihood estimation and inference on cointegration, with applications to the demand for money. *Oxford Bulletin of Economics and Statistics* 52(2): 169–210. | neither list; `?urca::denmark` Source field: flag |
| `engle1987` | Engle, R. F. and Granger, C. W. J. (1987). Co-integration and error correction: representation, estimation and testing. *Econometrica* 55(2): 251–276. | P PDF 1039 |
| `kao2000` | Kao, C. and Chiang, M.-H. (2000). On the estimation and inference of a cointegrated regression in panel data. *Advances in Econometrics* 15: 179–222. | B PDF 400 (2000); P PDF 1047 prints 2001: flag, volume 15 is 2000 |
| `breitung2005` | Breitung, J. (2005). A parametric approach to the estimation of cointegration vectors in panel data. *Econometric Reviews* 24(2): 151–173. | P PDF 1031 |
| `wagner2010` | Wagner, M. and Hlouskova, J. (2010). The performance of panel cointegration methods: results from a large scale simulation study. *Econometric Reviews* 29(2): 182–223. | B PDF 402; P PDF 1062 |
| `mark2005` | Mark, N. C., Ogaki, M. and Sul, D. (2005). Dynamic seemingly unrelated cointegrating regression. *Review of Economic Studies* 72(3): 797–820. | B PDF 401; P PDF 1051 |
| `moon2005` | Moon, H. R. and Perron, B. (2005). Efficient estimation of the seemingly unrelated regression cointegration model and testing for purchasing power parity. *Econometric Reviews* 23(4): 293–323. | P PDF 1052; volume 23 is dated 2004 by the journal: flag |
| `bai2006kao` | Bai, J. and Kao, C. (2006). On the estimation and inference of a panel cointegration model with cross-sectional dependence. In Baltagi, B. H. (ed.), *Panel Data Econometrics: Theoretical Contributions and Empirical Applications*, Contributions to Economic Analysis 274, 3–30. Amsterdam: Elsevier. | P PDF 1028 lists it as 2005, no pages: flag, check publisher |
| `bai2009kao` | Bai, J., Kao, C. and Ng, S. (2009). Panel cointegration with global stochastic trends. *Journal of Econometrics* 149(1): 82–99. | P PDF 1028 |
| `westerlund2007` | Westerlund, J. (2007). Testing for error correction in panel data. *Oxford Bulletin of Economics and Statistics* 69(6): 709–748. | B PDF 402 |
| `westerlund2007factors` | Westerlund, J. (2007). Estimating cointegrated panels with common factors and the forward rate unbiasedness hypothesis. *Journal of Financial Econometrics* 3(4): 491–522. | P PDF 1062; volume 3 is dated 2005 by the journal: flag |
| `westerlund2009` | Westerlund, J. and Larsson, R. (2009). A note on the pooling of individual PANIC unit root tests. *Econometric Theory* 25(6): 1851–1868. | P PDF 1062 |
| `bai2010` | Bai, J. and Ng, S. (2010). Panel unit root tests with cross-section dependence: a further investigation. *Econometric Theory* 26(4): 1088–1114. | P PDF 1028 |
| `banerjee1999` | Banerjee, A. (1999). Panel data unit roots and cointegration: an overview. *Oxford Bulletin of Economics and Statistics* 61(S1): 607–629. | B PDF 399; P PDF 1029 |
| `banerjee2004` | Banerjee, A., Marcellino, M. and Osbat, C. (2004). Some cautions on the use of panel methods for integrated series of macroeconomic data. *Econometrics Journal* 7(2): 322–340. | B PDF 399; P PDF 1029 |
| `banerjee2005` | Banerjee, A., Marcellino, M. and Osbat, C. (2005). Testing for PPP: should we use panel methods? *Empirical Economics* 30(1): 77–91. | B PDF 399; P PDF 1029 |
| `gengenbach2006` | Gengenbach, C., Palm, F. C. and Urbain, J.-P. (2006). Cointegration testing in panels with common factors. *Oxford Bulletin of Economics and Statistics* 68(S1): 683–719. | B PDF 400 |
| `gutierrez2003` | Gutierrez, L. (2003). On the power of panel cointegration tests: a Monte Carlo comparison. *Economics Letters* 80(1): 105–111. | B PDF 400 |
| `groen2003` | Groen, J. J. J. and Kleibergen, F. (2003). Likelihood-based cointegration analysis in panels of vector error correction models. *Journal of Business and Economic Statistics* 21(2): 295–318. | B PDF 400; P PDF 1043 |
| `phillips1990` | Phillips, P. C. B. and Ouliaris, S. (1990). Asymptotic properties of residual based tests for cointegration. *Econometrica* 58(1): 165–193. | P PDF 1058 |
| `stock1987` | Stock, J. H. (1987). Asymptotic properties of least squares estimators of cointegrating vectors. *Econometrica* 55(5): 1035–1056. | CM PDF 315 |
| `newey1994` | Newey, W. K. and West, K. D. (1994). Automatic lag selection in covariance matrix estimation. *Review of Economic Studies* 61(4): 631–653. | P PDF 1053; `?pco` prints 631–654: flag |
| `kao1999rd` | Kao, C., Chiang, M.-H. and Chen, B. (1999). International R&D spillovers: an application of estimation and inference in panel cointegration. *Oxford Bulletin of Economics and Statistics* 61(S1): 691–709. | B PDF 400; only if Baltagi's Tables 12.3–12.7 are named |
| `feldstein1980` | Feldstein, M. and Horioka, C. (1980). Domestic saving and international capital flows. *Economic Journal* 90(358): 314–329. | in neither list nor `?pco`; unchecked: cite only if the tooling agent confirms it from the publisher, else the `gdi`/`gds` example is described without the name |

Already present and reused: `phillips1999` (checked: *Econometrica* 67(5),
1057–1111), `granger1974`, `pfaff2008`, `bai2004`, `bai2009`,
`kapetanios2011`, `pesaran2006`, `pesaran2007`, `pesaran2013`, `choi2007`,
`moon2004`, `im2003`, `levin2002`, `baltagi2007`, `holly2010`,
`croissant2019`, `baltagi2021`, `pesaran2015`. Issue numbers in the table
are from memory where the lists print none and must be confirmed with the
DOI.

## Tooling

- `R/cointegration.R`, roxygen-documented, loaded by `devtools::load_all()`:
  - `johansen_by_unit(data, vars, log = TRUE, ecdet = "none", K = 2)`:
    takes a `pdata.frame`, splits by the unit index, orders by time, names
    the columns (`ca.jo` requires names), calls `urca::ca.jo(type =
    "trace", spec = "longrun")` once per unit, and returns a data frame
    with `unit`, `trace_r0`, `cv_r0`, `trace_r1`, `cv_r1`, `rank` (the
    sequential 5 % decision) and `slope` (−V[2, 1] / V[1, 1]). Plumbing
    only: the call is spelled out once in the open in `c04-7-one-state`.
  - `panel_wide(data, expr)`: a `pseries` or expression to a T × N matrix,
    time in rows, units in columns, dimnames set, stops on NA. Feeds
    `pco::pedroni99`.
  - `panel_array(data, ...)`: several expressions to the T × N × M array
    `pco::pedroni99m` wants; documented as needing M ≥ 3.
  - `adf_by_unit(resid, lags = 2, type = "none")`: a `pseries` of
    residuals (or a T × N matrix) to the vector of per-unit
    `urca::ur.df` t statistics.
  - A small simulator for the `pco` size check, `sim_coint_pair_panel(n,
    t, coint)`, beside the existing simulators in `R/simulate-panels.R`.
- `pco` 1.0.1 installed from the CRAN archive with
  `renv::install("pco@1.0.1")`; `renv::snapshot()` records it with Source
  Repository so `renv::restore()` pulls the archived tarball. Note the
  archive status in the chapter's Pitfalls.
- No other package. `cointReg` and `Westerlund` are not installed.

## Steps

Each step ends in its own commit.

- [ ] **Tooling.** `R/cointegration.R` with the four helpers and the
  simulator; `references.bib` gains the entries above with flags settled;
  `pco` snapshotted.
- [ ] **Step 7.** `7-cointegration.qmd` with chunks `c04-7-one-state`,
  `c04-7-by-state`, `c04-7-pedroni`, `c04-7-eg`, `c04-7-picture`,
  `c04-7-pco-trap`, `c04-7-scale-trap`, `c04-7-pco-size`; every number in
  prose from output.
- [ ] **Step 8.** `8-long-run.qmd` with `c04-8-pooled`, `c04-8-twoway`,
  `c04-8-cce`, `c04-8-picture`.
- [ ] **Summary.** `git mv 7-summary.qmd 9-summary.qmd`; the edits listed.
- [ ] **Intro and map.** `index.qmd` lines 12–13, the mermaid path, the
  theory sentence, the includes.
- [ ] **Theory.** `theory-cointegration.qmd` written, not a placeholder;
  the one-line change and the "Code:" additions in
  `theory-panel-unit-roots.qmd`.
- [ ] **Review and fix.** Every cited page opened; every number against
  output; links crawled.
- [ ] **Wire in.** `_quarto.yml`: `chapters/04-time/theory-cointegration.qmd`
  under `project: render:` and under `appendices:`; `index.qmd` checklist:
  the line "Cointegration" becomes the two steps and the note, ticked;
  the road map's "Cointegration, serial correlation ..." sentence
  (`chapters/00-road-map/index.qmd` line 119) retargeted to
  `#sec-ur-coint` and `#sec-ur-long-run`; chapter rendered from a clean
  `_freeze/chapters/04-time/`; this plan closed.

## Open questions

Decided on 2026-10-06, before the tooling step:

- Chapter 06 is written before these steps (plan 0008's order), so the
  intro links `../06-dynamic/index.qmd`; the wire-in step checks the link
  resolves.
- Pedroni (1999) Table 2 and Pfaff (2008) are not in `lit/`: both are cited
  without a page, as rule 2 of plan 0008 requires. `pco`'s moments stay
  unchecked and the Danish check cites the help page, not a page of Pfaff.
- The `pco` numbers on house prices go in the Pitfalls box, shown with
  `error: true` where the call fails. The size simulation stays in the
  step as the evidence for the limitation: a reader who skips the boxes
  must not meet a statistic whose size is 0 or 1 as if it were a result.
- Kao's DF_ρ and Pedroni's group ADF are not hand-coded now. They wait for
  the Stata plan, where `xtcointtest` gives the target to match.
- `westerlund2007factors` and `moon2005`: the tooling agent takes the
  publisher's date and keeps the key.

## Outcome

Filled in when the status becomes done or superseded.
