# Write the dynamic panels chapter

- **Date:** 2026-10-06
- **Author:** Eduard Bukin
- **Status:** active

## Goal

`chapters/06-dynamic/` reads the way chapters 03 and 04 read: a question in
the running example's words, one paragraph of intuition, the estimator or
test in words, every call in the open, a picture, a one-sentence reading of
each result, a "Next" box, and collapsed Recipe, Pitfalls and Book check
boxes. Four steps and a summary cover 4b.1 to 4b.3 of
`.docs/panel-spat-PLAN.md`: the Nickell bias by simulation, Anderson–Hsiao,
difference and system GMM through `pgmm`, and the diagnostics (Sargan, the
AR tests, the Windmeijer correction, the instrument count). What has no
implementation is a stated limitation. One theory note, "Dynamic panel GMM",
is written, not a placeholder. Every book check prints next to the number the
help pages, Croissant & Millo (2019, chapter 7) or Baltagi (2021, chapter 8)
give. The road map, the chapter list and the checklist in `index.qmd` gain
the chapter, `_quarto.yml` lists it, `renv.lock` records `pdynmc`, and the
book renders from a clean cache.

## Context

**What exists.** Nothing of this chapter: no folder, no placeholder, no
theory note. What the book promises about it:

- The road map's decision diagram (`chapters/00-road-map/index.qmd`, the
  `SC` box) routes series that do not wander to "Serial correlation, dynamic
  panels", and the chapter list ends "Cointegration, serial correlation and
  dynamic panels are still to come" under chapter 4. Chapter 4's intro says
  the same: "Cointegration, serial correlation and dynamic panels are later
  parts of this chapter, not yet written." Both sentences retarget here at
  wire-in.
- The checklist in `index.qmd` carries `- [ ] Dynamic panels` under the time
  chapter. It moves to its own "Dynamic panels" group with one line per
  node.
- `chapters/05-core/index.qmd` is a placeholder for the static models; it
  promises nothing about dynamics. This chapter links back to its
  fixed-effects step at `../05-core/index.qmd#sec-core-fe-re`, which plan
  0009 creates.
- The outline note `.docs/notes/0002-book-outline.md` fixes the chapter as
  number 7 in reading order: the problem (4b.1), estimators (4b.2),
  diagnostics (4b.3), and records why it is a chapter of its own: "they
  carry the strongest verification target in the book".
- Chapter 03's limits step (`#sec-sp-dynamic`) states the dynamic spatial
  panel as a limitation and can link here for the time-lag half.

**What runs.** Checked on 2026-10-06 in the project renv, R 4.6.1, plm 2.6.7,
pder 1.0.2, pdynmc 0.9.13 (installed by this plan's recon, not yet in
`renv.lock`). `plm::pgmm` fails unless plm is attached: it builds a `plm()`
call and evaluates it, so `library(plm)` is the documented exception in
`CLAUDE.md`. Every call below ran with plm attached and the `plm::` prefix
kept.

| Target | Source | Printed | Here |
|---|---|---|---|
| AB Table 4(b): two-step DIF GMM, conventional SEs | `?pgmm`, `ab.b`, `summary(robust = FALSE)`; B p. 223 names "Table 4 of Arellano and Bond (1991) (p. 290)" | paper not in `lit/` | γ₁ 0.474151 (0.085303), γ₂ −0.052967 (0.027284), w −0.513205 (0.049345), w₋₁ 0.224640 (0.080063), k 0.292723 (0.039463), y 0.609775 (0.108524), y₋₁ −0.446373 (0.124815) |
| same, Sargan, m1, m2 | same | paper not in `lit/` | χ²(25) = 30.11247, p 0.220; m1 −2.4278 (p 0.015); m2 −0.3325 (p 0.739) |
| Windmeijer Table 2: two-step corrected SEs | `?pgmm`, `summary(ab.b, robust = TRUE)` | paper not in `lit/` | 0.185398, 0.051749, 0.145565, 0.141950, 0.062627, 0.156263, 0.217302 |
| Windmeijer Table 2: one-step robust SEs and m-tests | `?mtest`, `ab.b.onestep`, `vcov = vcovHC` | paper not in `lit/` | γ₁ 0.534614 (0.166449); m1 −2.4934 (p 0.013); m2 −0.3594 (p 0.719) |
| AB Table 4(a1): one-step robust | `?pgmm`, `ab.a1` | paper not in `lit/` | γ₁ 0.686226 (0.144594), γ₂ −0.085358 (0.056016); Sargan 48.75 (25) p 0.003 |
| AB Table 4(a2): two-step | `?pgmm`, `ab.a2`; `?mtest` says AB print m2 = −0.434 | −0.434 | γ₁ 0.628709 (0.090454); Sargan 31.38 (25) p 0.177; m2 −0.4158 (p 0.678); with `vcovHC` −0.3517 |
| BB Table 4 (DPD for Ox p. 12 col. 4): one-step SYS | `?pgmm`, `bb.4` | paper not in `lit/` | γ 0.935605 (0.026295), w −0.630976 (0.118054), w₋₁ 0.482620 (0.136887), k 0.483930 (0.053867), k₋₁ −0.424393 (0.058479); Sargan 118.76 (100) p 0.097; m1 −4.81, m2 −0.28 |
| CM Ex. 7.2, OLS with time effects | CM p. 164 | 0.70637, 0.07232 | same |
| CM Ex. 7.3, two-way within | CM p. 165 | 0.37863, 0.01041 | same |
| CM Ex. 7.4, Anderson–Hsiao by formula | CM p. 168 | 0.4687 (0.1182), −0.1036 (0.3049) | same |
| CM Ex. 7.5, one-step and two-step DIF | CM pp. 171–172 | 0.50499 (0.09049); 0.554007 (0.10783) | same |
| CM Ex. 7.7, two-step SYS | CM p. 177 | 0.6176 (0.05714), 0.1200 (0.01792) | same |
| CM Ex. 7.8, `vcov` against `vcovHC` | CM p. 179 | 0.04795, 0.04646; 0.10783, 0.06054 | same |
| CM Ex. 7.9, Sargan | CM p. 180 | 50 (44) p 0.3; 56 (54) p 0.4 | 49.881 (44) p 0.251; 55.678 (54) p 0.411 |
| CM Ex. 7.10, m2 | CM p. 182 | 0.88, p 0.4 | 0.88094, p 0.378 |
| Nickell bias, T = 10, γ = 0.5 | CM p. 165 ("the bias is −0.167"); P eq. 27.11 exact −0.162 | −0.167 | simulated within 0.337, bias −0.163 |
| Nickell (1981) Table 1 | not in `lit/`; B p. 188, P p. 679 | — | structure: within 0.164, 0.337, 0.423, 0.450, 0.469 at T = 5, 10, 20, 30, 50 against the exact 0.169, 0.338, 0.422, 0.448, 0.469 |
| Variance ratio DIF/SYS 1.75, 3.26, 55.4 | B p. 202 | quoted | theory values at T = 4, σ²μ/σ²u = 1; not reproducible on EmplUK, quoted |
| Ziliak 0.519 → 0.093 as moments 9 → 212 | B p. 194 | quoted | structure: γ₁ 0.017 (23 inst.), 0.033 (28), 0.355 (35), 0.474 (38), 0.854 (18 collapsed) |
| Bowsher: Sargan undersized with many moments | B p. 192 | quoted | structure: Sargan p 0.20, 0.42, 0.20, 0.22, 0.04 down the same table |
| `pdynmc` two-step against `pgmm` on Table 4(a2) | `?pdynmc` example `m2` | — | coefficients and Windmeijer SEs identical to four decimals; J 31.38 (25) p 0.1767 |

The Arellano & Bond (1991) and Windmeijer (2005) papers are not in `lit/`.
The help pages annotate which call reproduces which table, and the `pgmm`
output above is what those annotations claim; the review agent must open the
papers (RES 58 p. 290; JoE 126 Table 2) or plm's `tests/*.Rout.save` before
the chapter prints "the paper gives 0.474". Until then the Book check boxes
say "annotated by `?pgmm`" and print the output.

`pgmm` fits take 0.06 s (difference) to 0.19 s (system). The five fits of the
instrument-count table take 0.23 s together. The Nickell grid (200 draws × 5
values of T, within and OLS) takes 21.6 s; 200 difference-GMM fits at T = 10
take 8.6 s. `pdynmc` two-step takes 2.4 s; with the Ahn–Schmidt nonlinear
moments and BFGS it takes 2.6 minutes.

**What is broken or missing.**

- `plm::plm(model = "fd")` with a two-part formula differences the
  instruments along with the regressors, so `lag(log(emp), 2)` in the
  instrument part becomes Δy₋₂, not the level y₋₂. Anderson–Hsiao with
  level instruments cannot be written that way. The working form is CM
  Ex. 7.4: difference inside the formula and keep `model = "pooling"`,
  `diff(y) ~ lag(diff(y)) + ... | lag(y, 2) + ...`. Reproduced to the
  printed digits on `DemocracyIncome`.
- Anderson–Hsiao on the two-lag Table 4(b) equation is just identified with
  two instruments and useless: γ₁ = 6.61 (22.5) with levels y₋₂, y₋₃;
  2.33 (5.13) with differences. On the one-lag equation it is 1.23 (0.86)
  with y₋₂ and −0.105 (0.30) with Δy₋₂: consistent, imprecise, the lesson.
- `mtest` on a two-step model uses the one-step residuals (help page) and
  so gives −0.416 where AB print −0.434 for Table 4(a2). Stated, not fixed.
- No R implementation: Ahn–Schmidt in plm (but `pdynmc` runs it, see
  below), Kiviet bias-corrected FE, the transformed likelihood of Hsiao,
  Pesaran & Tahmiscioglu, Kripfganz–Schwarz for time-invariant regressors,
  Arellano–Bover as a separate estimator (`transformation = "ld"` is its
  levels-plus-differences system in the Blundell–Bond form). Stata
  benchmarks: `xtdpdqml`, `xtlsdvc`, `xtseqreg`.
- The `Read` tool cannot render PDFs on this machine (no `pdftoppm`). The
  PDFs were read through `pdftotext` by PDF page. Printed page = PDF page
  minus 16 for Baltagi, minus 31 for Pesaran, minus 21 for CM.

**Notation.** Five conventions meet here, and the argument defaults are
traps:

| Where | Lag coefficient | Note |
|---|---|---|
| Baltagi (2021) eq. 8.1 | δ | one-way error components μᵢ + νᵢₜ |
| Pesaran (2015) eq. 27.5 | λ | αᵢ + λyᵢ,ₜ₋₁ + uᵢₜ |
| Croissant & Millo (2019) §7.1 | ρ | ηₙ + εₙₜ |
| this book | γ | yᵢₜ = γ yᵢ,ₜ₋₁ + x′ᵢₜβ + αᵢ + εᵢₜ |

- `pgmm(effect = )` defaults to `"twoways"`, unlike `plm` (`"individual"`).
  Two-way means time dummies enter as normal instruments and the Sargan
  degrees of freedom drop by their number. With `effect = "individual"` the
  Table 4(b) equation gives γ₁ = 0.449 (0.183), not 0.474.
- `pgmm(model = )` defaults to `"onestep"`. Arellano & Bond's Table 4(b) is
  `model = "twosteps"`, written out.
- The formula has up to three parts: `y ~ regressors | GMM instruments |
  normal instruments`. The third part defaults to every regressor not used
  as a GMM instrument, with the same lags. `lag(log(emp), 2:99)` means all
  lags from 2; `lag()` inside `pgmm` is plm's panel lag, never `stats::lag`.
- `transformation = "d"` is difference GMM (Arellano & Bond), `"ld"` is
  system GMM (Blundell & Bond): differences instrumented by lagged levels,
  levels instrumented by lagged differences, an intercept added. `fsm`
  follows: `"G"` for `"d"`, `"full"` for `"ld"`.
- `summary.pgmm(robust = TRUE)` is the default. For a two-step fit it is the
  Windmeijer (2005) corrected covariance from `vcovHC.pgmm`; for a one-step
  fit the robust sandwich. `robust = FALSE` is the conventional two-step
  covariance, which is what Arellano & Bond printed. The choice also changes
  the AR tests the summary prints (m1 = −2.43 against −1.54 on `ab.b`); the
  Sargan line does not change.
- `sargan(weights = "twosteps")` is the default and the only one to report;
  `weights = "onestep"` on the same two-step fit gives 79.5 instead of 30.1.
- `mtest(order, vcov = NULL)`: `vcov = plm::vcovHC` is the robust form the
  `?mtest` page pairs with Windmeijer's Table 2.
- A fit stores its instruments in `x$W`, one matrix per firm;
  `ncol(x$W[[1]])` is the instrument count, exogenous regressors and time
  dummies included. Sargan df = that count minus the coefficients minus the
  time dummies: 38 − 7 − 6 = 25 for `ab.b`.
- `diff()` on a `pseries` is base `diff` dispatching to plm's method;
  `plm::diff` is not exported.

**Data.** `plm::EmplUK`: 140 firms, 1976–1984, 1031 rows, unbalanced:
103 firms with 7 years, 23 with 8, 14 with 9. Rows per year: 80 in 1976,
138 in 1977, 140 in 1978 to 1982, 78 in 1983, 35 in 1984. Variables `emp`,
`wage`, `capital`, `output`, plus `sector`. The two-lag equation with one
lost period for differencing uses 611 firm-years (1979–1984, at most six
per firm); its system version 1362; the one-lag system fit 1642; the
one-lag Anderson–Hsiao fit 751. Baltagi (p. 193) calls it "the benchmark
data set used in Stata and EViews" and CM (p. 183) list the papers that
reuse it: Blundell & Bond (1998), Windmeijer (2005), Roodman (2009).
`pdynmc::ABdata` is the same 1031 rows with the same column names, so the
`pdynmc` check needs no reshaping beyond `log()`.

**Running example.** Decided on 2026-10-06: `EmplUK` carries every step,
and three equations on it do three jobs.

- The **Arellano–Bond equation**, Table 4(b): log employment on its first
  two lags, log wage and its lag, log capital, log industry output and its
  lag, time dummies. It carries the book checks and the diagnostics.
  Brackets on it, γ₁ then γ₁ + γ₂: pooled OLS 1.143 and 0.949; two-way
  within 0.700 and 0.531; two-step DIF 0.474 and 0.421; two-step SYS 1.160
  and 0.951. DIF falls *below* within here, the Blundell–Bond symptom of
  weak lagged-level instruments on a persistent series, so this equation
  cannot carry the "OLS above, within below, GMM between" picture.
- The **one-lag equation** of the `?pgmm` Blundell–Bond example: log
  employment on one lag, log wage and log capital each with one lag, time
  dummies. It carries the bracket picture: OLS 0.962 (0.007), SYS 0.936
  (0.026), DIF 0.708 (0.084), within 0.626 (0.031), with Anderson–Hsiao at
  1.23 (0.86) on y₋₂ and −0.11 (0.30) on Δy₋₂ beside them. Two-step DIF is
  0.679 (0.089), Sargan 88.8 (79) p 0.21 on 91 instruments; two-step SYS
  0.932 (0.027), Sargan 110.7 (100) p 0.22 on 113.
- The **pure AR(1)** of log employment with time dummies is the "misleads"
  case: OLS 0.997, within 0.744, two-step DIF 0.310 (0.162) with Sargan
  p = 0.030, two-step SYS 1.091 (0.039) with Sargan p = 0.0002,
  Anderson–Hsiao 1.18 (1.23). A series this persistent breaks the
  difference instruments and the system restriction alike.

The simulation of step 1 is its own small world: N = 100, γ = 0.5,
αᵢ ~ N(0, 1), εᵢₜ ~ N(0, 1), a 50-period burn-in, T + 1 periods kept so the
regression on one lag uses T. 200 draws per T.

| T | within, mean | sd | OLS, mean | Nickell exact | −(1+γ)/(T−1) |
|---|---|---|---|---|---|
| 5 | 0.164 | 0.048 | 0.872 | 0.169 | 0.125 |
| 10 | 0.337 | 0.031 | 0.872 | 0.338 | 0.333 |
| 20 | 0.423 | 0.021 | 0.873 | 0.422 | 0.421 |
| 30 | 0.450 | 0.015 | 0.872 | 0.448 | 0.448 |
| 50 | 0.469 | 0.012 | 0.872 | 0.469 | 0.469 |

"Nickell exact" is P eq. 27.11 (CM p. 165 print the same formula) at γ = 0.5;
the last column is the leading term. Two-step difference GMM on the same
draws: 0.472 (sd 0.064) at T = 10, 0.441 (sd 0.133) at T = 5. A first run
that kept T periods and so regressed on T − 1 gave 0.092 at "T = 5": the T
in the table must be the T in the regression, and the helper enforces it.

**Instrument-count table**, two-step on the Arellano–Bond equation, the
Bowsher and Ziliak structure in one object:

| GMM instruments | count | γ₁ | SE Windmeijer | SE two-step | Sargan | df | p | m2 |
|---|---|---|---|---|---|---|---|---|
| `lag(log(emp), 2:3)` | 23 | 0.017 | 0.275 | 0.159 | 13.44 | 10 | 0.200 | −0.51 |
| `2:4` | 28 | 0.033 | 0.243 | 0.152 | 15.47 | 15 | 0.418 | −0.49 |
| `2:6` | 35 | 0.355 | 0.215 | 0.097 | 27.24 | 22 | 0.202 | −0.18 |
| `2:99` | 38 | 0.474 | 0.185 | 0.085 | 30.11 | 25 | 0.220 | −0.28 |
| `2:99`, `collapse = TRUE` | 18 | 0.854 | 0.562 | 0.264 | 11.63 | 5 | 0.040 | 0.45 |

The count includes 5 exogenous regressors and 6 time dummies. The two-step
SE halves as instruments are added while the corrected SE barely moves: the
Windmeijer point. γ₁ walks from 0.02 to 0.47 to 0.85 across instrument sets
that Sargan accepts alike: the Ziliak and Bowsher point.

**`pdynmc`.** `renv::install("pdynmc")` pulled nloptr, numDeriv, optimx and
pracma in 10 s; no snapshot taken. The `?pdynmc` two-step example on
`ABdata` (Table 4(a2)) returns coefficients and Windmeijer SEs identical to
`pgmm`'s to four decimals in 2.4 s, J = 31.38 (25) p 0.1767, and its
`mtest.fct(order = 2)` equals `plm::mtest(ab.a2, 2L, vcov = vcovHC)`
(−0.35166). The one-step example equals `summary(ab.a1, robust = TRUE)` to
four decimals. With `use.mc.nonlin = TRUE` (the Ahn & Schmidt 1995
conditions, `opt.meth = "BFGS"`) it runs in 2.6 minutes and gives γ₁ 0.665
(0.200), γ₂ −0.084 (0.052), w −0.496 (0.153), k 0.264 (0.069), J = 40.35
(29) p 0.078: the Ahn–Schmidt gap closes in a Pitfalls box, not as a step.

**Order.** The spec order is the chapter order: the problem, the estimators,
the diagnostics. The estimators split into two steps, Anderson–Hsiao then
GMM, because they are two code paths (`plm` with a two-part formula, then
`pgmm`) and two ideas (one instrument per equation, then every available
lag), and because the Anderson–Hsiao step is where the reader meets
differencing-and-instrumenting with one instrument before the instrument
matrix. Weak instruments live inside the GMM step, between difference and
system, since system GMM is their answer.

## Chapter structure

`chapters/06-dynamic/index.qmd` from `.docs/_templates/chapter.qmd`, title
"Dynamic panels":

- **Opener, in the world.** A firm's payroll this year is mostly last
  year's payroll: hiring and firing are slow, so employment adjusts to
  wages and demand over several years. The question an economist asks is
  "how fast", and the answer is the coefficient on last year's employment.
  One number, and every static estimator gets it wrong.
- **Definition.** A **dynamic panel** has the lagged outcome among the
  regressors. The lag carries the firm effect inside it, so it is
  correlated with the error; the within transformation removes the firm
  effect but puts the whole error history into every demeaned lag. The
  bias shrinks with T and does not shrink with N.
- **Picture.** The within estimate of γ against T from the step-1
  simulation, the true 0.5 as a line, OLS flat above it.
- **The equation.** yᵢₜ = γ yᵢ,ₜ₋₁ + x′ᵢₜβ + αᵢ + εᵢₜ (B eq. 8.1,
  P eq. 27.1), then the first difference Δyᵢₜ = γ Δyᵢ,ₜ₋₁ + Δx′ᵢₜβ + Δεᵢₜ,
  with the one line that says why Δyᵢ,ₜ₋₁ and Δεᵢₜ share εᵢ,ₜ₋₁.
- **Glosses with links.** Fixed effects and the within transformation
  ([fixed effects](../05-core/index.qmd#sec-core-fe-re)); a unit root, for
  the persistent-series warning
  ([why it matters](../04-time/index.qmd#sec-ur-why)); serial correlation
  of the error, which the AR tests check
  (chapter 05's serial-correlation step, anchor fixed by plan 0009).
- **Running example** paragraph: `EmplUK`, the three equations above.
- **In this chapter**, numbered: 1 the bias and its size; 2 difference and
  instrument, one instrument; 3 all the instruments: difference GMM, the
  weak-instrument trap, system GMM; 4 the diagnostics that decide which fit
  to believe; 5 summary.
- Setup chunk `c06-0-setup`: `devtools::load_all(quiet = TRUE)`;
  `library(plm)` with the comment that `pgmm()` evaluates a `plm()` call
  and needs the package attached; `data("EmplUK", package = "plm")`;
  `pe <- plm::pdata.frame(EmplUK, index = c("firm", "year"))`.
- Includes: `1-problem.qmd`, `2-anderson-hsiao.qmd`, `3-gmm.qmd`,
  `4-diagnostics.qmd`, `5-summary.qmd`.

### Step 1, `1-problem.qmd`: "The bias" `{#sec-dyn-bias}`

- **Question.** If last year's employment explains this year's, how wrong
  is the within estimate of that persistence, and does more data fix it?
- **Intuition.** Demeaning subtracts the firm's average over the sample,
  and that average contains every shock the firm had, including the ones
  that built last year's employment. The lag and the demeaned error are
  correlated through those shocks, negatively, by about (1 + γ)/(T − 1).
  More firms do not help; more years do. OLS without firm effects errs the
  other way: the firm effect sits in the error and in the lag, so γ is
  pushed up. The two biases bracket the truth [@croissant2019, p. 168].
- **The tests.** No test; two estimators on a known truth. Nickell's bias
  [@nickell1981], as P eq. 27.11 and its leading term −(1 + γ)/T
  [@pesaran2015, p. 679], the same bias for RE [@pesaran2015, p. 678];
  Judson & Owen: "even for T = 30, this bias could be as much as 20% of the
  true value" [@baltagi2021, p. 188]; CM's −0.167 at T = 10, γ = 0.5
  [@croissant2019, p. 165].
- **Run it.** `c06-1-one-draw`: one draw at T = 10 from
  `sim_dynamic_panel(100, 10)`, then `plm::plm(y ~ plm::lag(y, 1), model =
  "pooling")` and `model = "within"`, both in the open. `c06-1-grid`: the
  200-draw loop over T = 5, 10, 20, 30, 50, mean within and OLS, the exact
  Nickell value from `nickell_bias(0.5, T)` beside them. `c06-1-emp`: the
  same two fits on the Arellano–Bond equation, γ₁ = 1.143 and 0.700, and
  the one-lag equation, 0.962 and 0.626: the bracket on real data, with the
  caveat that the width is unknown until step 3.
- **Picture.** Lines of mean γ̂ against T for within and OLS, the exact
  Nickell curve dashed through the within points, 0.5 as a horizontal
  line. Beside it the sampling spread at T = 10 as two overlaid
  histograms, within and OLS, so the reader sees that averaging over draws
  does not help.
- **Read it.** Within: 0.164 at T = 5, 0.337 at T = 10, 0.469 at T = 50, on
  the Nickell curve to two decimals. OLS: 0.872 at every T, so T is not its
  cure. The real-data bracket: 0.70 to 1.14 for the two-lag equation, 0.63
  to 0.96 for the one-lag one; the truth is somewhere inside and nothing in
  this step says where.
- **Next.** Remove the firm effect by differencing instead of demeaning,
  and instrument the lag ([Anderson–Hsiao](index.qmd#sec-dyn-ah)).
- **Pitfalls.** The T that matters is the number of periods in the
  regression, one fewer than the series after the lag is taken; the helper
  keeps T + 1 periods for that reason. The bias grows with γ, so a 10% error
  at γ = 0.5, T = 30 is 20% at higher γ (B p. 188). Kiviet's bias-corrected
  within estimator [@kiviet1995] has no R implementation (benchmark: Stata
  `xtlsdvc`); CM (p. 166) note it needs a balanced panel and treats the other
  regressors as exogenous.
- **Book check.** CM p. 165, Nickell bias −0.167 at T = 10, γ = 0.5:
  simulated −0.163, exact formula −0.162. Nickell (1981) Table 1 is not in
  `lit/`, so the check is the exact formula, not the table. CM Ex. 7.2 and
  7.3 on `DemocracyIncome` (0.70637 and 0.37863) reproduce to the printed
  digits and verify the `plm` calls; a one-chunk check, `c06-1-cm`.
- **Theory.** [Dynamic panel GMM](theory-dynamic-gmm.qmd), the bias
  section: P eqs. 27.7 to 27.11.

### Step 2, `2-anderson-hsiao.qmd`: "Difference and instrument" `{#sec-dyn-ah}`

- **Question.** With the firm effect differenced away, what can stand in
  for last year's change in employment that does not carry this year's
  shock?
- **Intuition.** Differencing kills αᵢ but makes the lag Δyᵢ,ₜ₋₁ share
  εᵢ,ₜ₋₁ with the error Δεᵢₜ. The level two periods back, yᵢ,ₜ₋₂, is
  correlated with Δyᵢ,ₜ₋₁ and not with Δεᵢₜ, as long as the εᵢₜ are not
  serially correlated [@anderson1982; @baltagi2021, p. 188]. One
  instrument, one equation, consistent and imprecise. Arellano (1989)
  shows the level beats the difference Δyᵢ,ₜ₋₂ as instrument: the
  differenced version "has a singularity point and very large variances"
  [@baltagi2021, p. 188]; CM (p. 167) say the same in one line.
- **The tests.** The Anderson–Hsiao IV estimator in its level form and its
  difference form, by 2SLS on the differenced equation.
- **Run it.** `c06-2-ah-level`: CM Ex. 7.4's form on the one-lag equation,
  `plm::plm(diff(log(emp)) ~ lag(diff(log(emp))) + diff(log(wage)) +
  lag(diff(log(wage))) + diff(log(capital)) + lag(diff(log(capital))) + year
  - 1 | lag(log(emp), 2) + ... + year - 1, data = pe, model = "pooling")`.
  `c06-2-ah-diff`: the same with `lag(diff(log(emp)), 2)` as the
  instrument. `c06-2-ah-two`: the two-lag Arellano–Bond equation with
  `lag(log(emp), 2) + lag(log(emp), 3)`, to show just-identification going
  wrong.
- **Picture.** Dot-and-whisker of γ̂ with 95% bands from OLS, within, AH
  level, AH difference on the one-lag equation: the AH bands span the whole
  bracket and more.
- **Read it.** AH level: 1.23 (0.86); AH difference: −0.11 (0.30). Both
  consistent, neither informative; the level form at least has a band that
  contains OLS and within. The two-lag equation: 6.6 (22.5) and 2.3 (5.1),
  the singularity Arellano warned of. Misleads: the pure AR(1) gives 1.18
  (1.23), and a reader who prints the point estimate reads explosive
  employment.
- **Next.** There are more instruments than one: every earlier level is
  valid for every later difference ([difference and system
  GMM](index.qmd#sec-dyn-gmm)).
- **Pitfalls.** `plm(model = "fd")` with a two-part formula differences
  the instruments too; the only working form is `diff()` in the formula
  with `model = "pooling"`, as CM Ex. 7.4. The differenced equation loses
  two rows per missing year, not one (CM p. 166). Alvarez & Arellano (2003)
  on inconsistency when T/N does not vanish [@pesaran2015, p. 682] is
  quoted, not reproduced.
- **Book check.** CM Ex. 7.4, p. 168, `DemocracyIncome`: 0.4687 (0.1182)
  and −0.1036 (0.3049), reproduced exactly in `c06-2-cm`. No published
  Anderson–Hsiao number exists for `EmplUK` in the sources on disk; the
  step says so.
- **Theory.** [Dynamic panel GMM](theory-dynamic-gmm.qmd), the
  instruments section.

### Step 3, `3-gmm.qmd`: "Difference and system GMM" `{#sec-dyn-gmm}`

- **Question.** Using every lagged level a firm offers, how persistent is
  employment, and when do those instruments stop carrying information?
- **Intuition.** In the third year one level is valid, in the fourth two,
  and so on: the instrument matrix is block-diagonal with a growing block
  per period (B eq. 8.6, P eq. 27.27, CM eq. 7.4). GMM weights the moments:
  one-step by the known MA(1) structure of a differenced error, two-step by
  the residual-based estimate of their covariance (B eqs. 8.8 to 8.9; CM
  §7.2.2 to 7.2.3). When the series is persistent, yᵢ,ₜ₋₂ barely predicts
  Δyᵢ,ₜ₋₁: the first-stage coefficient has plim (γ − 1)·c/(c + σ²α/σ²ε)
  with c = (1 − γ)/(1 + γ), which goes to zero as γ → 1 (B eq. 8.34, CM
  eq. 7.19). Blundell & Bond add the levels equation instrumented by
  Δyᵢ,ₜ₋₁, valid if deviations of the initial condition from the firm's
  steady state are uncorrelated with the firm effect (B eq. 8.36,
  P eq. 27.38, CM p. 176); the gain in asymptotic variance is 1.75 at
  γ = 0, 3.26 at 0.5, 55.4 at 0.9 for T = 4 [@baltagi2021, p. 202].
- **The tests.** Difference GMM one-step and two-step
  [@arellano1991]; system GMM [@blundell1998; @arellano1995]. The
  three-part formula, `effect = "twoways"`, `model`, `transformation`.
- **Run it.** `c06-3-ab-onestep`: `?pgmm`'s `ab.b` with `model =
  "onestep"`, `summary(robust = TRUE)`. `c06-3-ab-twostep`: the same with
  `model = "twosteps"`, `summary(robust = FALSE)` first, since that is the
  paper's table, then `summary(robust = TRUE)`, since that is the one to
  report; the difference is step 4's subject. `c06-3-count`:
  `ncol(ab.b$W[[1]])`, 38. `c06-3-weak`: the pure AR(1) through two-step
  difference GMM, 0.310 (0.162), beside within 0.744. `c06-3-sys`: the
  `?pgmm` Blundell–Bond example `bb.4` (`transformation = "ld"`, one-step,
  robust) and its two-step form; then system GMM on the Arellano–Bond
  equation, two-step robust: 1.160 (0.066), −0.208 (0.052). `c06-3-bracket`:
  the one-lag equation through OLS, within, DIF, SYS in four calls.
- **Picture.** The bracket as a horizontal ladder for the one-lag equation:
  within 0.63, DIF 0.68 to 0.71, SYS 0.93, OLS 0.96, each with its band,
  AH's wide band greyed behind. Second panel: the instrument matrix of one
  firm drawn as a filled block pattern (6 rows, 27 GMM columns, the
  staircase), which is the picture of "a new instrument each period".
- **Read it.** Two-step DIF on the Arellano–Bond equation: γ₁ = 0.474, the
  help-page target; wages −0.51 now and +0.22 lagged; capital 0.29; output
  0.61 and −0.45. One-step 0.535. On the one-lag equation DIF 0.68 to 0.71
  and SYS 0.93 to 0.94, inside the 0.63 to 0.96 bracket, as the theory
  says. On the two-lag equation DIF (0.47) sits below within (0.70): weak
  instruments, read as a warning rather than a result. Misleads: the pure
  AR(1), DIF 0.31 and SYS 1.09 with Sargan rejecting both; a near-unit-root
  series is not a dynamic panel problem, it is a unit-root problem, back to
  chapter 04.
- **Next.** Which of these fits can be believed: the moment conditions, the
  serial correlation, the standard errors and the instrument count
  ([diagnostics](index.qmd#sec-dyn-diagnostics)).
- **Pitfalls.** `effect` defaults to `"twoways"` in `pgmm` and
  `"individual"` in `plm`; `model` defaults to `"onestep"`. `pgmm` needs
  `library(plm)`. The system fit adds an intercept and one more period, so
  its instrument count and Sargan df are not comparable with the difference
  fit's. Bun & Windmeijer (2010): system GMM keeps a weak-instrument problem
  that grows with σ²α/σ²ε, and its Wald tests over-reject further
  [@baltagi2021, p. 202]. Hayakawa (2009): under mean non-stationarity the
  difference estimator can do well and the system restriction fail
  [@baltagi2021, pp. 202–203]. Ahn & Schmidt's T − 2 nonlinear moments are
  not in plm; `pdynmc` (`use.mc.nonlin = TRUE`) runs them in 2.6 minutes
  and gives γ₁ = 0.665 (0.200), shown in a chunk with its timing stated.
  Arellano–Bover as a Hausman–Taylor-type system for time-invariant
  regressors, and Kripfganz & Schwarz's two-step, are limitations
  (benchmark: Stata `xtseqreg`).
- **Book check.** `?pgmm` annotations: `ab.b` two-step, `robust = FALSE`,
  reproduces Arellano & Bond (1991) Table 4(b), 0.474151 (0.085303) and
  the rest of the column; `bb.4` reproduces Blundell & Bond (1998) Table 4
  as DPD for Ox p. 12 col. 4, 0.935605 (0.026295). Neither paper is in
  `lit/`: the box prints the output and the annotation, and the review
  agent decides whether "the paper prints" can be said. CM Ex. 7.5 and 7.7
  on `DemocracyIncome`, 0.50499, 0.554007, 0.6176, reproduced exactly in
  `c06-3-cm`. `pdynmc`'s two-step on Table 4(a2) equals `pgmm`'s to four
  decimals, in a Pitfalls chunk.
- **Theory.** [Dynamic panel GMM](theory-dynamic-gmm.qmd), the estimator
  and weak-instrument sections.

### Step 4, `4-diagnostics.qmd`: "Diagnostics" `{#sec-dyn-diagnostics}`

- **Question.** The fit prints a Sargan test, two autocorrelation tests and
  two sets of standard errors: which numbers decide whether 0.47 is an
  estimate or an artefact?
- **Intuition.** Sargan asks whether the moments the estimator did not need
  are also zero at the estimate; with too many of them it stops being able
  to tell [@baltagi2021, p. 192]. The AR tests ask whether the original
  errors are serially uncorrelated, which is what makes yᵢ,ₜ₋₂ a valid
  instrument: a differenced MA(0) error is MA(1), so m1 must reject and m2
  must not (B p. 192; CM p. 182). The two-step covariance is estimated from
  one-step residuals and understates the variance, so Wald tests are
  oversized; Windmeijer's correction adds the missing terms (B p. 193; CM
  eqs. 7.27 to 7.29). And the number of instruments is a choice: Ziliak's
  elasticity fell from 0.519 to 0.093 as moments rose from 9 to 212
  [@baltagi2021, p. 194]; Bowsher found the Sargan test with N = 100,
  T = 15 has Monte Carlo variance 13.7 against a theoretical 180 and never
  rejects [@baltagi2021, p. 192]; Roodman's `collapse` is the fix in
  software [@roodman2009; @croissant2019, p. 173].
- **The tests.** Sargan–Hansen [@sargan1958; @hansen1982], null: the
  overidentifying moments hold; a rejection means at least one instrument
  is invalid. Arellano–Bond m1 and m2 [@arellano1991], null: no serial
  correlation of that order in the differenced residuals; m2 rejecting
  means the levels error is AR(1) and the instruments fail. Windmeijer's
  corrected covariance [@windmeijer2005] as `summary(robust = TRUE)` and
  `vcovHC`.
- **Run it.** `c06-4-sargan`: `plm::sargan(ab.b)`. `c06-4-m1` and
  `c06-4-m2`: `plm::mtest(ab.b, order = 1L)` and `order = 2L`, each twice,
  `vcov = NULL` then `vcov = plm::vcovHC`. `c06-4-mtest-onestep`: the
  `?mtest` Windmeijer pair on `ab.b.onestep` with `vcovHC`.
  `c06-4-windmeijer`: `sqrt(diag(vcov(ab.b)))` against
  `sqrt(diag(plm::vcovHC(ab.b)))`, the CM Ex. 7.8 form. `c06-4-count`: the
  five fits of the instrument-count table, each `pgmm` call written out,
  then one table built from them by plain `sapply` over the five objects,
  which is plumbing, not a wrapper around the test.
- **Picture.** Two panels. Left: γ₁ with Windmeijer bands against the
  instrument count, 23 to 38 and the collapsed 18, within and OLS as
  horizontal lines; the estimate walks across the whole bracket. Right:
  the two SEs of γ₁ against the instrument count, two-step falling,
  corrected flat.
- **Read it.** Sargan 30.1 on 25 df, p = 0.22: does not reject. m1 = −2.43
  (p 0.015) rejects, m2 = −0.33 (p 0.74) does not: the pattern a valid
  difference model shows. Robust: m1 −1.54 (p 0.12), m2 −0.28 (p 0.78);
  the one-step robust pair −2.49 and −0.36. Windmeijer: the SE of γ₁ more
  than doubles, 0.085 to 0.185, and two coefficients lose their stars
  (γ₂, lagged wage). The count table: Sargan accepts five instrument sets
  whose γ₁ runs from 0.02 to 0.85; the collapsed set is the one it
  questions (p 0.04) and the one with the widest band. Misleads: a Sargan
  p-value near 1 with many instruments is the Bowsher pathology, not a
  clean bill; CM show it on `DemocracyIncome25`, p = 0.919 with all lags
  against 0.071 with three (CM p. 181).
- **Next.** Report the two-step estimate with Windmeijer SEs, the Sargan
  statistic with its df, m1 and m2, and the instrument count, and show how
  γ moves across instrument sets ([summary](index.qmd#sec-dyn-summary)).
- **Pitfalls.** `mtest` on a two-step fit uses one-step residuals, as DPD
  and `xtabond` do, so Table 4(a2)'s m2 is −0.416 here against the paper's
  −0.434 (help page). `sargan(weights = "onestep")` on a two-step fit is a
  different statistic (79.5) and not the one to report. The summary's AR
  lines follow its `robust` argument. Bond, Bowsher & Windmeijer (2001)
  suggest criterion-based tests in place of Wald tests [@baltagi2021,
  p. 193]; not implemented. Sargan's power at N = 46, T = 28 is "bad"
  enough that Baltagi collapses the instruments in his own example
  (B p. 209).
- **Book check.** `?mtest` annotations: `ab.b.onestep` with `vcov =
  vcovHC` reproduces Windmeijer (2005) Table 2's one-step corrected
  results, m1 −2.4934, m2 −0.3594; `ab.b` with `robust = TRUE` the two-step
  corrected SEs 0.185398 and so on; paper not in `lit/`, same caveat as
  step 3. B p. 194 Ziliak 0.519 → 0.093 and B p. 192 Bowsher, quoted, the
  table reproduces the structure (0.017 to 0.854; p = 0.20 to 0.42) and not
  the level. CM Ex. 7.8, 7.9, 7.10 on `DemocracyIncome`: 0.04795 against
  0.10783; Sargan 49.88 (44) p 0.25 and 55.68 (54) p 0.41 where CM print
  50, 0.3 and 56, 0.4; m2 0.881, p 0.38 where CM print 0.88, 0.4; all in
  `c06-4-cm`.
- **Theory.** [Dynamic panel GMM](theory-dynamic-gmm.qmd), the diagnostics
  section.

### Step 5, `5-summary.qmd`: "Summary" `{#sec-dyn-summary}`

- The five lines of the recipe: difference, instrument with levels, use
  every lag but count them, two-step with Windmeijer, Sargan plus m1 and
  m2, and an instrument-count table. One table of every γ estimate on the
  one-lag equation and on the Arellano–Bond equation (OLS, within, AH
  level, DIF one-step, DIF two-step, SYS one-step, SYS two-step), with the
  SE in use, the Sargan p-value, and the instrument count.
- Limitations stated once, with the Stata benchmark named: Kiviet
  (`xtlsdvc`), transformed likelihood (`xtdpdqml`), Kripfganz–Schwarz
  (`xtseqreg`), Ahn–Schmidt (available in `pdynmc` only), factor-error
  dynamic panels (P §27.7), the dynamic spatial panel (`xsmle`, chapter 03).
- **Next.** Back to the road map; forward to the serial-correlation tests
  of chapter 05, whose rejection is what invalidates everything here.

## Theory notes

One note, `theory-dynamic-gmm.qmd`, "Dynamic panel GMM", its own page in
the pane, from `.docs/_templates/` with the exemplar
`chapters/04-time/theory-panel-unit-roots.qmd`. Sections and what each
cites, every page checked against the PDFs on 2026-10-06:

1. **Why the within estimator is biased.** B p. 188 (the two leading terms,
   both O(T − 1)); P §27.3 pp. 678–679, eqs. 27.7 to 27.11 and the compact
   −(1 + λ)/T; CM §7.1.1 to 7.1.2 pp. 163–165 (OLS up, within down, the
   −0.167). Nickell (1981); Kiviet (1995) and Judson & Owen (1999) from
   B p. 188.
2. **Difference and instrument.** B p. 188 (Anderson & Hsiao, Arellano
   1989); P §27.4.1 pp. 681–682 (E[Δyᵢ,ₜ₋₂Δyᵢ,ₜ₋₁] and its vanishing as
   λ → 1); CM §7.1.3 pp. 165–167 (why not the within model, first
   differences against orthogonal deviations).
3. **The instrument matrix and the two steps.** B §8.2 pp. 189–191,
   eqs. 8.3 to 8.10; P §27.4.2 pp. 682–685, eqs. 27.20 to 27.35; CM §7.2
   pp. 168–171, eqs. 7.4 to 7.17. Holtz-Eakin, Newey & Rosen (1988) and
   Hansen (1982) as the GMM frame.
4. **Weak instruments and the system.** B §8.5 pp. 201–203, eqs. 8.32 to
   8.36 and the variance ratios; P §27.4.5 pp. 688–689, eqs. 27.37 to
   27.38; CM §7.3 pp. 174–177, eq. 7.19 and the redundancy argument of
   eqs. 7.20 to 7.25. Blundell & Bond (1998), Arellano & Bover (1995), Bun
   & Windmeijer (2010), Hayakawa (2009), Blundell, Bond & Windmeijer (2000)
   from P p. 689.
5. **Diagnostics.** Sargan: B p. 191, P p. 691 (§27.4.6), CM §7.4.2
   pp. 179–180. AR tests: B p. 192, CM §7.4.3 pp. 181–182 (the derivation
   of aₗ and bₗ). Windmeijer: B §8.2.2 p. 193, CM §7.4.1 pp. 178–179,
   eqs. 7.26 to 7.29. Instrument proliferation: B §8.2.3 p. 194 (Ziliak,
   Roodman), B p. 192 (Bowsher), CM §7.2.4 pp. 172–173 and eq. 7.18
   (collapse).
6. **What plm does not do.** Ahn & Schmidt: B §8.4 pp. 198–201, P §27.4.3
   pp. 685–686. Arellano–Bover for time-invariant regressors: B §8.3
   pp. 194–198, P §27.4.4 pp. 686–687; Kripfganz & Schwarz B pp. 197–198.
   Transformed likelihood: P §27.6 pp. 692–695. Factor errors: P §27.7
   pp. 696–699. Keane–Runkle: B §8.6 p. 203, P §27.5 pp. 691–692, named
   only.

The note carries the notation table from the Context section.

## Spec coverage

| Spec | Element | Where | Status |
|---|---|---|---|
| 4b.1 | OLS and within biased; Nickell O(1/T); RE too; Judson & Owen | step 1 | simulated, bracket on EmplUK |
| 4b.1 | Nickell Table 1 | step 1 book check | structure via exact formula; table not on disk |
| 4b.2 | Anderson–Hsiao, levels preferred (Arellano 1989) | step 2 | run, both forms |
| 4b.2 | Arellano–Bond, eq. 8.6 | step 3 | run, help-page target |
| 4b.2 | Blundell–Bond system, eqs. 8.35–8.36 | step 3 | run, help-page target |
| 4b.2 | variance ratios 1.75 / 3.26 / 55.4; Bun & Windmeijer | step 3 intuition and pitfalls | quoted |
| 4b.2 | Ahn–Schmidt | step 3 pitfalls | `pdynmc`, 2.6 min, shown |
| 4b.2 | Arellano–Bover, Kiviet, transformed likelihood, factor errors, Kripfganz–Schwarz | step 5 limitations, theory note | stated |
| 4b.3 | Sargan; Bowsher | step 4 | run; quoted |
| 4b.3 | m1 / m2 | step 4 | run |
| 4b.3 | Windmeijer | step 4 | run |
| 4b.3 | Ziliak; Roodman collapse | step 4 count table | structure reproduced |
| 4b.3 agent note | instrument count and sensitivity table always reported | steps 3–5 | done |
| §3 | Ahn–Schmidt, Kiviet, transformed likelihood blocked | step 5 | limitation lines with Stata names |

## Bibliography entries to add

`references.bib` has `arellano1991`, `baltagi2021`, `pesaran2015`,
`croissant2019`. Each entry below was read in a reference list in `lit/`;
the PDF page is where it was read (Baltagi's chapter-8 list is PDF
pp. 241–244, printed 225–228; Pesaran's list PDF pp. 1031–1063; CM's list
PDF pp. 306–315). DOIs are not printed in these lists; the tooling agent
adds them from the publisher page.

| Key | Entry | Read at |
|---|---|---|
| `nickell1981` | Nickell, S. (1981). Biases in dynamic models with fixed effects. *Econometrica* 49(6), 1417–1426. | B PDF 243; P PDF 1053; CM PDF 313 |
| `anderson1982` | Anderson, T.W., and C. Hsiao (1982). Formulation and estimation of dynamic models using panel data. *Journal of Econometrics* 18(1), 47–82. | B PDF 241; CM PDF 306 |
| `arellano1989` | Arellano, M. (1989). A note on the Anderson–Hsiao estimator for panel data. *Economics Letters* 31(4), 337–341. | B PDF 241 |
| `arellano1995` | Arellano, M., and O. Bover (1995). Another look at the instrumental variables estimation of error-components models. *Journal of Econometrics* 68(1), 29–51. | B PDF 241; CM PDF 306 |
| `blundell1998` | Blundell, R., and S. Bond (1998). Initial conditions and moment restrictions in dynamic panel data models. *Journal of Econometrics* 87(1), 115–143. | B PDF 242; P PDF 1031; CM PDF 308 |
| `blundell2000` | Blundell, R., and S. Bond (2000). GMM estimation with persistent panel data: An application to production functions. *Econometric Reviews* 19(3), 321–340. | B PDF 242; P PDF 1031; CM PDF 308 |
| `blundell2000ifs` | Blundell, R., S. Bond and F. Windmeijer (2000). Estimation in dynamic panel data models: Improving on the performance of the standard GMM estimator. IFS Working Paper W00/12, Institute for Fiscal Studies, London. | P PDF 1031 |
| `windmeijer2005` | Windmeijer, F. (2005). A finite sample correction for the variance of linear efficient two-step GMM estimators. *Journal of Econometrics* 126(1), 25–51. | B PDF 244; P PDF 1063; CM PDF 315 |
| `ahn1995` | Ahn, S.C., and P. Schmidt (1995). Efficient estimation of models for dynamic panel data. *Journal of Econometrics* 68(1), 5–27. | B PDF 241 |
| `kiviet1995` | Kiviet, J.F. (1995). On bias, inconsistency, and efficiency of various estimators in dynamic panel data models. *Journal of Econometrics* 68(1), 53–78. | B PDF 243; P PDF 1049; CM PDF 312 |
| `holtzeakin1988` | Holtz-Eakin, D., W. Newey and H.S. Rosen (1988). Estimating vector autoregressions with panel data. *Econometrica* 56(6), 1371–1395. | B PDF 243; P PDF 1045; CM PDF 311 |
| `hansen1982` | Hansen, L.P. (1982). Large sample properties of generalized method of moments estimators. *Econometrica* 50(4), 1029–1054. | B PDF 243; P PDF 1044; CM PDF 311 |
| `sargan1958` | Sargan, J.D. (1958). The estimation of economic relationships using instrumental variables. *Econometrica* 26(3), 393–415. | P PDF 1059; CM PDF 315 |
| `bowsher2002` | Bowsher, C.G. (2002). On testing overidentifying restrictions in dynamic panel data models. *Economics Letters* 77(2), 211–220. | B PDF 242; P PDF 1031 |
| `ziliak1997` | Ziliak, J.P. (1997). Efficient estimation with panel data when instruments are predetermined: An empirical comparison of moment-condition estimators. *Journal of Business and Economic Statistics* 15(4), 419–431. | B PDF 244 |
| `roodman2009` | Roodman, D. (2009). How to do xtabond2: An introduction to difference and system GMM in Stata. *The Stata Journal* 9(1), 86–136. | CM PDF 314 (as 2009a); `?pgmm` |
| `roodman2009note` | Roodman, D. (2009). A note on the theme of too many instruments. *Oxford Bulletin of Economics and Statistics* 71(1), 135–158. | B PDF 243; CM PDF 314 (as 2009b) |
| `bun2010` | Bun, M.J.G., and F. Windmeijer (2010). The weak instrument problem of the system GMM estimator in dynamic panel data models. *Econometrics Journal* 13(1), 95–126. | B PDF 242 |
| `judson1999` | Judson, R.A., and A.L. Owen (1999). Estimating dynamic panel data models: A guide for macroeconomists. *Economics Letters* 65(1), 9–15. | B PDF 243 |
| `hsiao2002` | Hsiao, C., M.H. Pesaran and A.K. Tahmiscioglu (2002). Maximum likelihood estimation of fixed effects dynamic panel data models covering short time periods. *Journal of Econometrics* 109(1), 107–150. | B PDF 243; P PDF 1046 |
| `kripfganz2019` | Kripfganz, S., and C. Schwarz (2019). Estimation of linear dynamic panel data models with time-invariant regressors. *Journal of Applied Econometrics* 34(4), 526–546. | B PDF 243 prints "2018" with volume 34; volume 34 is 2019, so the tooling agent checks the publisher page and the text cites whichever year the entry carries |
| `bond2001` | Bond, S., C. Bowsher and F. Windmeijer (2001). Criterion-based inference for GMM in autoregressive panel data models. *Economics Letters* 73(3), 379–388. | B PDF 242 |
| `hayakawa2009` | Hayakawa, K. (2009). On the effect of mean-nonstationarity in dynamic panel data models. *Journal of Econometrics* 153(2), 133–135. | B PDF 243 |
| `bond2002` | Bond, S.R. (2002). Dynamic panel data models: A guide to micro data methods and practice. *Portuguese Economic Journal* 1(2), 141–162. | CM PDF 308 |
| `kripfganz2016` | Kripfganz, S. (2016). Quasi-maximum likelihood estimation of linear dynamic short-T panel-data models. *The Stata Journal* 16(4), 1013–1038. | B PDF 243; for the benchmark line only |
| `fritsch2021` | Fritsch, M., A.A.Y. Pua and J. Schnurbus (2021). pdynmc: A package for estimating linear dynamic panel data models based on nonlinear moment conditions. *The R Journal* 13(1), 218–231. doi:10.32614/RJ-2021-035 | `citation("pdynmc")` |

Issue numbers in parentheses are not printed in the lists and come from the
journals' volumes; the tooling agent confirms each against the publisher
page before the entry is committed, per rule 4 of plan 0008.

## Tooling

- **`sim_dynamic_panel(n, t, gamma = 0.5, burn = 50)`** in
  `R/simulate-panels.R`, roxygen-documented in the style of `sim_ar1()`:
  draws αᵢ ~ N(0, 1), builds yᵢₜ = γ yᵢ,ₜ₋₁ + αᵢ + εᵢₜ with `Reduce(...,
  accumulate = TRUE)` after `burn` discarded periods, keeps `t + 1` periods
  so that a regression on one lag uses `t`, and returns a `pdata.frame`
  with columns `id`, `period`, `y`. Documented: "`t` is the number of
  periods in the regression after one lag is taken." The recon code is in
  the R transcript and in this plan's Context.
- **`nickell_bias(gamma, t)`**, same file, the exact large-N bias of the
  within estimator for the AR(1) with fixed effects, P eq. 27.11 (Nickell
  1981): returns −(1 + γ)/(t − 1) · A / (1 − 2γA/((1 − γ)(t − 1))) with
  A = 1 − (1 − γᵗ)/(t(1 − γ)). Used for the reference line in step 1's
  picture and its book check. Roxygen cites the equation.
- **No instrument-count helper.** The five `pgmm` calls are written out;
  the table is one `sapply` over the five fitted objects pulling
  `ncol(m$W[[1]])`, `coef(m)[1]`, the two SEs, and `plm::sargan(m)`. If the
  writer finds the extractor repeated across steps, it becomes
  `pgmm_row(m)` in a new `R/dynamic-panels.R`, documented, returning a
  named numeric vector.
- **`pdynmc` 0.9.13** and its dependencies nloptr 2.2.1, numDeriv
  2016.8-1.1, optimx 2025-4.9, pracma 2.4.6 are installed in the renv
  library and not in `renv.lock`; the tooling agent runs
  `renv::snapshot()`.
- `pder` is already installed (chapter 04) and provides `DemocracyIncome`
  for the CM book checks.

## Steps

Each step ends in its own commit.

- [ ] **Tooling.** Bibliography entries above checked and added; the two
  helpers in `R/simulate-panels.R` with roxygen and `devtools::document()`;
  `renv::snapshot()` for `pdynmc`.
- [ ] **Chapter page.** `chapters/06-dynamic/index.qmd` with the opener,
  definition, picture, equation, glosses, numbered points, setup chunk,
  includes; the theory note as a placeholder so links resolve.
- [ ] **Step 1, the bias.** `1-problem.qmd`, chunks `c06-1-*`.
- [ ] **Step 2, Anderson–Hsiao.** `2-anderson-hsiao.qmd`, chunks `c06-2-*`.
- [ ] **Step 3, GMM.** `3-gmm.qmd`, chunks `c06-3-*`.
- [ ] **Step 4, diagnostics.** `4-diagnostics.qmd`, chunks `c06-4-*`.
- [ ] **Step 5, summary.** `5-summary.qmd`, chunk `c06-5-table`.
- [ ] **Theory note.** `theory-dynamic-gmm.qmd` written in full.
- [ ] **Review and fix.** Citations against PDF pages; every number in
  prose against chunk output; links; the "paper prints" wording settled
  once the AB and Windmeijer papers are on disk or `tests/*.Rout.save` is
  read.
- [ ] **Wire in.** `_quarto.yml` (`project: render:`, `book: chapters:`,
  the theory note under "Theory"); the checklist in `index.qmd` with a
  "Dynamic panels" group; the road map's chapter list gains item 6 and its
  "still to come" sentence and chapter 04's intro sentence retarget to
  `../06-dynamic/index.qmd#sec-dyn-bias`; chapter 03's `#sec-sp-dynamic`
  links here; render the chapter; close this plan.

## Open questions

Decided on 2026-10-06, before the tooling step:

- Arellano & Bond (1991) and Windmeijer (2005) are not in `lit/`. The book
  checks of steps 3 and 4 cite the `?pgmm` and `?mtest` annotations as the
  authority, name the tables those annotations name, and print the output.
  They do not claim a page was read. No GitHub file is fetched; adding the
  two PDFs to `lit/` is the user's call and is recorded in the Outcome.
- Nickell (1981) Table 1 is not on disk. The exact bias formula, Pesaran
  eq. 27.11, is the reference; its page is in `lit/` and is cited.
- The split into an Anderson–Hsiao step and a GMM step stays: five steps.
- The `pdynmc` nonlinear-moments chunk runs under the freeze. 2.6 minutes
  once is acceptable; `eval: false` would print a number nobody ran.
- Kripfganz & Schwarz: the tooling agent takes the publisher's year and
  volume; the text cites whatever the entry says.

## Outcome

Filled in when the status becomes done or superseded.
