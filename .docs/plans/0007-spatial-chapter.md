# Write the spatial dependence chapter

- **Date:** 2026-10-05
- **Author:** Eduard Bukin
- **Status:** active

## Goal

`chapters/03-spatial/` reads the way chapter 04 reads: a question in the
running example's words, one paragraph of intuition, the test or estimator
in words, every call in the open, a picture, a one-sentence reading of each
result, a "Next" box, and collapsed Recipe, Pitfalls and Book check boxes.
Eight steps and a summary cover sections 5.1 to 5.11 of
`.docs/panel-spat-PLAN.md`; what has no implementation is a stated
limitation, not a silent omission. Five theory notes are written, not
placeholders. Every book check prints next to the number Croissant & Millo
(2019, chapter 10) or Millo & Piras (2012) print. The inbound links from
chapters 00, 02 and 05 point at step anchors. The checklist in `index.qmd`
is ticked, `renv.lock` records the spatial packages, and the book renders
from a clean cache.

## Context

**What exists.** `chapters/03-spatial/index.qmd` is a placeholder listing
eight planned sections in the spec's order. Four theory notes are
placeholders: spatial weights, spatial model choice, testing for spatial
dependence, direct and indirect effects. Chapter 02 ends on the hand-off
this chapter picks up: the exponent α falls from 0.83 on log house prices
to 0.51 on the CCEMG residuals, so "once the national force is out, what is
left is local". Twelve inbound links point at the chapter page or at the
theory notes; none at a step, because no step exists yet.

**What runs.** Checked on 2026-10-05 with the project renv, R 4.6.1,
splm 1.6-5, spdep 1.4-2, spatialreg 1.4-3, sf 1.1-3, spData 2.3.5,
pder 1.0-2, plm 2.6-7. `renv.lock` does not record splm, spdep, spatialreg,
sf or spData yet (plan 0006 left this to the chapter that first calls
them). These reproduce the source to the printed digits:

| Target | Source | Printed | Here |
|---|---|---|---|
| local CD on `price`, `usaw49` | CM §10.1.2, Ex. 10.2 | z = 37 | 37.288 |
| `rwtest` on `price`, 999 reps | same | p = 0.002 | 0.002 |
| local CD on CCEMG residuals | same | z = 28 | 28.217 |
| `rwtest` on MG residuals | same | p = 0.002 | 0.002 |
| pure SAR on CCEMG residuals | CM Ex. 10.4 | λ = 0.6498 | 0.6498 |
| SEM-FE on RiceFarms, ρ | CM Ex. 10.6 | 0.7913 (0.0249) | 0.7913 |
| SEM-FE slopes | same | 0.1342, 0.2505, 0.5419 | same |
| SEMSRRE on RiceFarms φ, ψ, ρ | CM Ex. 10.16 | 0.2500, 0.1250, 0.6136 | same |
| BSJK C.2 | CM Ex. 10.15 | 11.894431, p 0.000563 | same |

`rwtest` with 999 replications takes 0.08 s; `spml` on RiceFarms 0.06 s;
`spreml(errors = "semsrre")` 6 s; `bsjktest(test = "C.2")` 3.5 s.

**What is broken or missing.**

- `splm::impacts()` fails on every `splm_ML` fit with the installed
  spatialreg, for `type = "mult"`, `"moments"` and `"MC"` alike:
  `!is.null(have_factor_preds) is not TRUE`. The direct, indirect and total
  effects have to be computed by hand from $(I - \rho W)^{-1}$; the hand
  computation runs and is the lesson anyway. `impacts()` on an `splm_GM`
  fit is untested.
- `plm::pmg` cannot run on RiceFarms: six periods per farm and four
  parameters. Section 5.9 (heterogeneous spatial panels) needs a
  simulation.
- `rwtest` returns a p-value only, no statistic and no randomised
  distribution. The picture of the randomisation has to be rebuilt by
  permuting the unit order and calling `plm::pcdtest(w = )` each time.
- No R implementation exists for the dynamic spatial panel (5.6), the
  spatial BLUP forecast (5.10), SMA and SEC errors (5.2), Debarsy–Ertur
  (5.5), the Pesaran–Tosetti variance (5.9) and het-robust panel GM (5.3).

**Notation.** Four conventions meet in this chapter and two of them are
each other's reverse:

| Where | Spatial lag | Spatial error |
|---|---|---|
| Pesaran (2015), eqs. 30.1 and 30.4; this book | ρ | λ |
| `spml(model = "within")` output and `coef()` | `lambda` | `rho` |
| `spml(model = "random")` and `spreml` output | `lambda` in `$arcoef` | `rho` in `$errcomp` |
| Millo & Piras (2012), printed output | `rho` | `lambda` |

The book writes ρ for the lag and λ for the error everywhere, and reads a
fit by what the parameter does, never by its printed name. One table in the
estimation theory note, one pitfall in the fixed-effects step.

**Data.** `usaw49` is the queen contiguity of the 49 states in
`spData::us_states`, link for link: 130 links in both, none in one only.
So the map can be drawn from `spData` with no new package, after a name
map (`usaw49` writes `NEW_YORK`, `DISTRICT_OF_COLUMBIA` and `TENNESSE`).
`usaw49` is row-standardised, not symmetric, column sums 0.33 to 1.7,
eigenvalues in [−0.718, 1], 9.1 % non-zero cells against 99.7 % in
$(I - 0.5W)^{-1}$, and one state has a single neighbour, so its weight is
1: the non-granularity condition fails there. `riceww` is 171 farms in six
villages, symmetric, row-standardised, and `spdep::mat2listw` warns of six
sub-graphs. `mat2listw` must be called with `style = "W"`, or the object
carries style `M` and later methods refuse it.

**Running examples.** Both panels run through every step (decided
2026-10-06).

- `HousePricesUS` with `usaw49` carries the story: continuity with chapter
  02, the four-number pattern the spec calls the most useful verification
  target in Stage 5, and the maps. Through the fits it goes as a
  **two-stage** regression (Bailey, Holly & Pesaran 2016): stage one
  partials the cross-state averages of log price and log income out of
  each state's series, which is the CCE transformation; stage two fits the
  spatial model to what is left. Pooled OLS on the partialled data gives
  the CCEP slope exactly, 1.199407 against `pcce(model = "p")`'s
  1.199407, which is the internal check. A spatial regression on the raw
  panel picks up the national factor, the trap named in the
  cross-sectional dependence theory note, and appears as a "misleads"
  case: SAR-FE on raw log prices gives ρ = 0.68 with an income slope of
  0.15, two-way FE 0.60 and 0.70, the partialled panel 0.65 and 0.72.
- `RiceFarms` with `riceww` carries the book checks: 171 farms over six
  seasons, so N/T = 28, the one canonical panel shaped like the project's
  target (N ≫ T); a credible spatial *error* story (a village's weather and
  pests); and every estimator and test of CM chapter 10 printed on it.
  Munnell's `Produc` with `usaww` appears in book checks only, for the
  Millo & Piras numbers.

House prices through the fits, checked 2026-10-06 on the partialled panel
(`lp_t`, `li_t`), `model = "within"`:

| Call | Result |
|---|---|
| `slmtest` lml, lme, rlml, rlme | 942, 938, 32.2, 27.5: both robust tests reject |
| SEM-FE | λ = 0.685 (0.020), slope 0.861 (0.063) |
| SAR-FE | ρ = 0.645 (0.020), slope 0.715 (0.056) |
| SARAR-FE | lag −0.52, error 0.87: not identified with one W |
| GM SEM-FE | λ = 0.653, slope 0.869; `summary()` fails with one regressor |
| SEM residuals u, local CD / rwtest | z = 31.7, p = 0.002: still spatial, by construction |
| filtered (I − λW)u | z = 0.53, p = 0.54: the SEM captured it |
| `bsktest` LMH, CLMmu, CLMlambda | 938, 4.39, then `spreml` fails: singular Hessian |
| `sphtest` | singular: no state effect is left after partialling |
| `bsjktest` J, C.1, C.2, C.3 | 2038, 46.2, 216, 20.1 |
| `spreml(errors = "semsr")` | ψ = 0.825 (0.015), λ = 0.605 (0.022) |
| hand impacts on SAR-FE | β 0.715, direct 0.827, indirect 1.19, total 2.01 |

Two consequences for the chapter. The random-effects branch does not
apply to the partialled panel, because partialling removes the state
effect along with the factor; the step shows the refusal with `error:
true` and reads it. The serial correlation of 0.82 in the house-price
errors is the hand-off to the time chapter: the static two-stage model is
not Holly et al.'s spatio-temporal one.

Residuals of a `spml(model = "within")` fit come back stacked by period,
then unit, not in the `pdata.frame` order; and a SEM's residuals are
$u = y - X\beta$, spatially correlated by construction, so a residual
check needs the filtered innovations $(I - \lambda W) u$. On RiceFarms the
same filter takes the local CD from z = 46.9 on u to −0.49 on ε.

**Order.** The placeholder lists FE, RE, then testing. The chapter follows
the workflow instead: tests that need only the restricted model come
before the fits that they choose between. Weights, does the dependence
follow the map, lag or error, fixed effects, random effects (with the LM
battery and the spatial Hausman test), serial correlation too, direct and
indirect effects, limits, summary.

## Chapter structure

### `index.qmd`

Title "Spatial dependence". Opening in the world: when Nevada's house prices
jump, Arizona's follow and Maine's do not; chapter 02 removed the national
force and found what was left weak, and weak can mean local. Definition in
one sentence: spatial dependence is correlation that follows a map, so a
unit moves with its neighbours and the link fades with distance. Picture:
two choropleths of the 49 states, the 1980–2000 growth of the price index
(CM Fig. 10.1) and the CCEMG residual in one year, so the reader sees
clusters survive defactoring. The two equations that organise the chapter,

$$
y_{it} = \rho \sum_j w_{ij} y_{jt} + x_{it}'\beta + u_{it}, \qquad
u_{it} = \lambda \sum_j w_{ij} u_{jt} + \varepsilon_{it},
$$

named at once: the first is a **spatial lag** (a neighbour's outcome moves
yours), the second a **spatial error** (only the shocks are shared).
Glosses with links back: the CD test, α, CCEMG residuals (chapter 02); fixed
effects and the within transformation (chapter 05, placeholder). "In this
chapter" as nine numbered points. Setup chunk `c03-0-setup`:
`devtools::load_all()`, `HousePricesUS`, `usaw49`, `RiceFarms`, `riceww`,
`plm::pdata.frame` of each, `spdep::mat2listw(..., style = "W")` of each,
the name map for the US map. `library(plm)` is attached there with the
comment that `pmg()` builds a call to `plm()`; `splm::spml`, `slmtest`,
`bsktest` and `sphtest` run with the `::` prefix alone (checked). Includes
`1-weights.qmd` to `9-summary.qmd`.

### Step 1, `1-weights.qmd`: "Spatial weights" `{#sec-sp-weights}`

- **Question.** Who counts as Arizona's neighbour, and what does that
  choice commit the model to?
- **Intuition.** W is an assumption, not data: a row says whose outcome
  enters unit *i*'s equation and with what weight. Row standardisation
  turns $\sum_j w_{ij} y_{jt}$ into the neighbours' average, so ρ reads as
  "how much of the average". Three choices of W encode three beliefs:
  shared border, k nearest, inverse distance.
- **Run it.** `usaw49` inspected: `dim`, row sums, one row printed
  (Arizona's). The four pre-checks, one line each, in the open: ‖W‖∞ = 1,
  ‖W‖₁ = 1.7, τ\* = min of the two, so |ρ| < 1 (Kelejian & Prucha 2010;
  P p. 799); eigenvalue bounds 1/λ_min = −1.39 and 1/λ_max = 1;
  granularity, the largest weight, 1, and which state carries it;
  sparsity, 9.1 % non-zero in W against 99.7 % in $(I - 0.5W)^{-1}$.
  Then two alternatives built with `spdep::knearneigh` and
  `spdep::dnearneigh` from state centroids, and the same four checks on
  each.
- **Picture.** Three maps side by side, links drawn between state
  centroids: contiguity, 4 nearest, inverse distance within 800 km. A
  fourth panel: `image()` of W next to $(I - 0.5W)^{-1}$, sparse against
  dense.
- **Read it.** Contiguity: every state has at least one neighbour, one has
  exactly one. Nearest: symmetric by count, not by border. Distance: dense
  in the east, thin in the west. *So:* ρ̂ is only comparable across models
  that share W, and the chapter keeps `usaw49`.
- **Next.** Ask whether the dependence left after chapter 02 follows this
  map ([does it follow the map](index.qmd#sec-sp-map)).
- **Pitfalls.** `mat2listw` without `style = "W"` carries style `M` and
  methods refuse it. A disconnected W (`riceww`, six villages) is legal for
  SEM and SAR but changes what "a neighbour" means. Row standardisation
  makes W asymmetric, so `type = "moments"` impacts need the symmetric
  similarity form. Bivand & Wong (2018) on `spdep` conventions.
- **Book check.** None: self-verifying. ‖W‖∞ must equal 1 for a
  row-standardised W, and the eigenvalue bounds must bracket τ\*.
- **Theory.** [spatial weights](theory-spatial-weights.qmd).

### Step 2, `2-map.qmd`: "Does it follow the map?" `{#sec-sp-map}`

- **Question.** After the national force is out, do neighbouring states'
  prices still move together more than random pairs do?
- **Intuition.** The CD test of chapter 02 averages all 1 176 pairwise
  correlations. The **local CD** test averages only the 130 neighbour
  pairs that `usaw49` names. But a large local CD can come from a factor
  that moves every pair, neighbours included. The **randomised-W test**
  shuffles the map 999 times: if the true map's statistic is more extreme
  than all but a handful of shuffled ones, the dependence follows the map
  and not merely the panel (Millo 2017).
- **The tests.** Local CD [@pesaran2004; CM §10.1.2.1], null: no
  dependence between neighbours. `rwtest` [@millo2017], null: units are
  exchangeable, the map does not matter.
- **Run it.** The four calls, one per chunk, in CM's order:
  `plm::pcdtest(php$price, w = usaw49)`;
  `splm::rwtest(php$price, w = usaw49, replications = 999, seed = 1)`;
  `plm::pcdtest(resid(ccemg), w = usaw49)`;
  `splm::rwtest(resid(mg), w = usaw49, replications = 999, seed = 1)`.
  Then the size of what is left: the pure SAR on the CCEMG residuals,
  `splm::spreml(e ~ 1, data = edat, w = usaw49, lag = TRUE, errors = "ols")`,
  ρ = 0.65 with SE 0.02, next to the spatial OLS of `e` on
  `splm::slag(e)`, 0.88, which overstates it.
- **Pictures.** (a) Two histograms of pairwise correlations of the CCEMG
  residuals, neighbour pairs against non-neighbour pairs, with their
  means. (b) The randomisation made visible: 999 local CD statistics under
  shuffled maps, the true one marked, built by permuting the unit order
  and calling `plm::pcdtest(w = )`, because `rwtest` keeps no statistic.
- **Read it.** Rejects (prices, z = 37, p = 0.002): nearby states move
  together. Rejects (CCEMG residuals, z = 28, p = 0.002): the local
  co-movement survives defactoring, so it is spatial, not a shadow of the
  factor. Misleads (local CD on raw prices alone): z = 37 is consistent with
  a national factor and no geography at all; only the shuffled maps settle
  it. Misleads (global CD on two-way FE residuals, from chapter 02): blind
  by construction, while local CD and `rwtest` still see the map.
- **Next.** Dependence follows the map: choose lag or error
  ([lag or error](index.qmd#sec-sp-lag-or-error)). It does not: spatial
  modelling buys nothing; report the robust standard errors of chapter 05.
- **Pitfalls.** `pcdtest(w = )` and `rwtest(w = )` coerce W through
  `as.logical()`: weights are discarded, only the neighbour structure is
  tested. `replications = 99` is the default and too few. CDw, PEA and CD\*
  have no local version. `order = 2` tests second-order neighbours.
- **Book check.** CM §10.1.2 four numbers and CM Ex. 10.4's λ = 0.6498 (all
  reproduced on 2026-10-05).
- **Theory.** [testing for spatial
  dependence](theory-spatial-dependence-tests.qmd).

### Step 3, `3-lag-or-error.qmd`: "Lag or error?" `{#sec-sp-lag-or-error}`

Introduce `RiceFarms` here: 171 farms, six seasons, six villages, output on
seed, labour and land, all in logs; neighbours are the farms of the same
village; N/T = 28. Say why it is the modelling example.

- **Question.** Does a neighbour's harvest move mine, or do we only share
  the weather?
- **Intuition.** Fit the model with no spatial term and look at the
  residuals twice: once for whether they correlate with the neighbours'
  *outcomes* (a lag left out), once for whether they correlate with the
  neighbours' *residuals* (an error left out). Each plain LM test fires on
  the other's problem, so Anselin, Bera, Florax and Yoon (1996) made each
  robust to a local amount of the other.
- **The tests.** `slmtest`: `lml`, `lme`, `rlml`, `rlme` [@anselin1996;
  CM §10.3.4.2]. Nulls: ρ = 0 and λ = 0, each robust version allowing a
  small value of the other parameter.
- **Run it.** House prices first: the partialled panel, four calls with
  `model = "within"`. Then rice: four calls on the pooled model with
  village and season dummies, as CM Ex. 10.11, then the same four with
  `model = "within"`.
- **Picture.** A Moran scatterplot of the within residuals against their
  spatial lag, with the regression line, for each panel; the slope is
  Moran's I, the error signal.
- **Read it.** Rice: `lml` rejects (39.3) but `rlml` does not (0.17): the
  lag signal was the error's shadow. `lme` and `rlme` both reject (245,
  206): the shocks are shared. *So:* a spatial error model. House prices:
  all four reject, `rlml` 32 and `rlme` 28. *So:* neither robust test can
  rule the other out; fit both and the encompassing model, and let the
  fits decide. Misleads: the plain `lml` alone would have put a
  neighbour's harvest into the rice equation.
- **Next.** Error: [fixed effects](index.qmd#sec-sp-fe). Both robust tests
  reject strongly: fit SARAR and let the encompassing model decide.
- **Pitfalls.** `slmtest` assumes pooling; `model = "within"` must be
  passed. The robust tests are local: with both effects large they
  "can behave suboptimally". SMA and SEC error forms (P eqs. 30.5–30.6)
  are not implemented; `spatial.error` is SAR errors only.
- **Book check.** CM Ex. 10.11, eight numbers: 39.28, 244.8, 0.1654,
  205.7 pooled; 125.2, 604.3, 1.538, 480.6 within.
- **Theory.** [spatial model choice](theory-spatial-model-choice.qmd).

### Step 4, `4-fe.qmd`: "Fixed effects" `{#sec-sp-fe}`

- **Question.** With a farm effect for soil and skill, how far does a
  village shock spread, and what are the input elasticities?
- **Intuition.** Take out each farm's mean, then maximise a likelihood
  that carries the Jacobian $|I - \lambda W|$, the price of a model in
  which every unit's error depends on every other's. A spatial error buys
  efficiency: FE was consistent already. A spatial lag buys consistency:
  FE without it is biased. GM skips the determinant and the normality
  assumption, at the price of no standard error for λ.
- **Estimators.** `spml(model = "within")` with `spatial.error = "b"`,
  `lag = TRUE`, both; `spgm(model = "within", spatial.error = TRUE)`.
  The within correction of Lee & Yu (2010a, §3.2) in words.
- **Run it.** House prices: plain FE with `plm::plm` on the partialled
  panel (the CCEP slope 1.20, the check), SEM-FE, SAR-FE, SARAR-FE by ML,
  SEM-FE by GM, one chunk each. Then the residual check that closes the
  loop: local CD and `rwtest` on the SEM residuals, which still reject,
  and on the filtered innovations $(I - \lambda W)u$, which do not. Then
  rice: the same five fits.
- **Picture.** Dot-and-whisker of the income elasticity under plain FE on
  raw prices, two-way FE, SAR-FE on raw prices, and the four fits on the
  partialled panel: how the slope swings with the treatment of the
  national factor. Beside it the three rice slopes under the five fits.
- **Read it.** House prices: SEM-FE λ = 0.69, slope 0.86 (0.06); SAR-FE
  ρ = 0.65, slope 0.72; the CCEP slope 1.20 sits between. SARAR with one W
  returns a lag of −0.52 and an error of 0.87: not identified, the
  encompassing model does not settle it here. Rice: SEM-FE λ = 0.79,
  slopes 0.13, 0.25, 0.54 against FE's 0.21, 0.29, 0.50, moved by the GLS
  weighting under λ ≈ 0.8; SAR-FE ρ = 0.51; SARAR ρ = 0.24, λ = 0.71, the
  LR test on ρ given λ; GM λ = 0.78 with no SE, slopes to the third
  decimal. Misleads: SAR-FE on raw log prices, ρ = 0.68 and slope 0.15,
  the factor read as geography.
- **Next.** Are the farm effects random draws, and does the error battery
  agree ([random effects](index.qmd#sec-sp-re))?
- **Pitfalls.** Names: in `spml(model = "within")` the lag prints as
  `lambda` and the error as `rho`, the reverse of this book. The FE fit is
  the ex-post variance correction, not Lee & Yu's orthonormal
  transformation, so "either N or T → ∞" does not transfer. GM gives no
  SE for λ. Heteroskedastic errors make spatial ML inconsistent (Lin & Lee
  2010; P p. 807): test first in chapter 05, route to `spgm`. A spatial
  Durbin model is `spgm(Durbin = TRUE)` only; `spml` adds WX through
  `splm::slag()` in the formula.
- **Book check.** CM Ex. 10.6 (λ 0.7913, slopes), CM Ex. 10.9 (GM λ 0.7807,
  σ²ν 0.0801, slopes 0.1346, 0.2508, 0.5418), CM Ex. 10.13 LR values.
  Millo & Piras (2012) on `Produc`: SEM-FE 0.5574, SARAR-FE 0.4553 and
  0.0886 (their `rho` is the lag), GM SARAR-FE 0.3328 and 0.1313.
- **Theory.** [fitting spatial panels](theory-spatial-estimation.qmd), new
  note.

### Step 5, `5-re.qmd`: "Random effects" `{#sec-sp-re}`

- **Question.** If farms are draws from one population, can the farm
  effect stay in the error, and is it itself spatially correlated?
- **Intuition.** Two symptoms can sit in the error: a farm effect and a
  spatial shock. Baltagi, Song and Koh (2003) test each conditional on the
  other, because testing one while ignoring the other misleads. Two RE
  models follow: Anselin's, where only the shock is spatial, and KKP's,
  where the farm effect is too. The spatial Hausman test of Mutl and
  Pfaffermayr (2011) then compares RE with FE.
- **Tests and estimators.** `bsktest` `LMH`, `CLMmu`, `CLMlambda`;
  `spml(model = "random", spatial.error = "b")` and `"kkp"`;
  `spml(model = "random", lag = TRUE)` for comparison; `sphtest`.
- **Run it.** Rice: three `bsktest` calls, one chunk each; three fits; one
  `sphtest` on the formula and one on two fits. House prices: `bsktest`
  LMH and CLMmu run (938, 4.4); CLMlambda and `sphtest` fail on the
  partialled panel with a singular Hessian, shown with `error: true` and
  read: partialling removed the state effect with the factor, so there is
  no random effect left to test, and the FE fits of step 4 stand.
- **Picture.** The estimated spatial parameter with its interval under
  SEM-FE, SEM-RE (b), SEM-RE (kkp) and SAR-RE, with the FE value as a
  reference line; and the variance ratio φ beside it.
- **Read it.** LMH = 310 rejects and says nothing more. CLMmu = 11: a farm
  effect given spatial error. CLMlambda = 21: spatial error given a farm
  effect. SEM-RE: φ = 0.30, λ = 0.77; KKP: 0.30, 0.77: the RE component is
  too small for the distinction to matter. Hausman χ² = 2.6, p = 0.4: RE
  is not rejected. Misleads: SAR-RE gives ρ = 0.41 "significant", the
  error's shadow again.
- **Next.** Serial correlation is the third symptom
  ([serial correlation too](index.qmd#sec-sp-serial)).
- **Pitfalls.** LMH "is of little use". `spreml`'s likelihood is not well
  behaved: `initval = "estimate"` before changing the optimiser. In RE fits
  the lag is `$arcoef` and the error is in `$errcomp`. `sphtest(method =
  "GM")` needs no error structure; `"ML"` needs `errors = "KKP"` or
  `"BSK"`.
- **Book check.** CM Ex. 10.7 (φ 0.3690, ρ 0.4132), Ex. 10.8 (b: φ 0.2955,
  λ 0.7748, slopes 0.1520, 0.2562, 0.5757; kkp: 0.2959, 0.7686, 0.1518,
  0.2564, 0.5763), Ex. 10.10 (310, 11, 21), §10.3.1 Hausman (2.6, df 3,
  p 0.4). Millo & Piras on `Produc`: SLM1 0.083 (p 0.9338), SLM2 0.0151,
  CLMlambda 9.7157, Hausman 7.4824 (df 4, p 0.1125) and 41.7396 (df 5).
- **Theory.** [fitting spatial panels](theory-spatial-estimation.qmd).

### Step 6, `6-serial.qmd`: "Serial correlation too" `{#sec-sp-serial}`

- **Question.** Does a farm's shock also carry over to its next season,
  once the farm effect and the village shock are allowed for?
- **Intuition.** Three symptoms, one error: a farm effect, a spatial
  shock, a serially correlated remainder. Baltagi, Song, Jung and Koh
  (2007) give a joint test and three conditional ones, each for one
  symptom allowing the other two. The encompassing model then estimates
  all three. Gloss serial correlation with a link forward to chapter 04's
  unwritten part.
- **Tests and estimator.** `bsjktest` `J`, `C.1`, `C.2`, `C.3`;
  `spreml(errors = "semsrre")`.
- **Run it.** House prices: four `bsjktest` calls on the partialled panel,
  then `spreml(errors = "semsr")`, spatial plus serial without random
  effects. Rice: four `bsjktest` calls, one chunk each; one `spreml`
  fit with `errors = "semsrre"`, printing `$ErrCompTable`.
- **Picture.** The lag-1 autocorrelation of the filtered innovations, one
  point per unit, for both panels, with the estimated ψ marked: 0.82 for
  states, 0.13 for farms.
- **Read it.** House prices: C.2 = 216, ψ = 0.82 (0.015). *So:* the
  errors of the static two-stage model carry most of last year's shock;
  the model is incomplete in time, which is the time chapter's question.
  Rice: J = 320, C.1 = 372 (spatial), C.3 = 76 (farm effect) reject hard;
  C.2 = 11.9, p = 0.0006 (serial) rejects softly. The encompassing fit:
  φ = 0.25, ψ = 0.13, λ = 0.61. *So:* the spatial shock is the strongest
  effect; serial correlation is real and small.
- **Next.** Read the lag model's coefficients as effects
  ([direct and indirect effects](index.qmd#sec-sp-impacts)).
- **Pitfalls.** `bsjktest` takes `data = RiceFarms, index = "id"`, not
  the `pdata.frame`. `spreml` takes `w`, `spml` takes `listw`. The
  `semsrre` fit takes 6 s and the C.2 test 3.5 s: freeze them.
- **Book check.** CM Ex. 10.15 (319.5, 371.5, 11.894431 with p 0.000563,
  75.8) and Ex. 10.16 (0.2500, 0.1250, 0.6136), both reproduced on
  2026-10-05.
- **Theory.** [fitting spatial panels](theory-spatial-estimation.qmd).

### Step 7, `7-impacts.qmd`: "Direct and indirect effects" `{#sec-sp-impacts}`

- **Question.** Land rises 10 % on one farm. How much does its output
  rise, how much do the neighbours', and how much comes back?
- **Intuition.** With $\rho W y$ on the right-hand side, a change on farm
  *i* moves its neighbours, whose change moves *i* again. The effect of
  $x_k$ is the matrix $(I - \rho W)^{-1}\beta_k$: its diagonal averaged is
  the **direct** effect (feedback included), its row sums averaged the
  **total**, the difference the **indirect**. β alone is neither.
- **Run it.** On the SAR-FE fits of step 4, both panels, the three
  numbers computed in the open: $S = (I - \hat\rho W)^{-1}$,
  `mean(diag(S)) * b`, `mean(rowSums(S)) * b`. Then the Monte Carlo
  interval: draw (ρ, β) from the fit's asymptotic normal 200 times and
  repeat. `splm::impacts()` is tried in the Pitfalls box with
  `error: true`, so the reader sees the refusal.
- **Picture.** The row of $S$ for one state, drawn on the map: Ohio's own
  cell, its neighbours, their neighbours, fading; next to it, direct,
  indirect and total for income with intervals, and the same three for
  the rice inputs.
- **Read it.** House prices: β = 0.72, direct 0.83, indirect 1.19, total
  2.01: with ρ = 0.65 the multiplier $1/(1-\rho)$ is 2.8. Rice: direct
  0.512 against β = 0.503 for land, the feedback adds 2 %; indirect
  0.517, as much again spills to the village; total 1.03. Misleads:
  reporting β as "the elasticity" halves the rice number and misses two
  thirds of the house-price one. Both are SAR readings; step 3 preferred a
  SEM for rice, where β is the whole effect.
- **Next.** What the spatial parameters cannot do
  ([limits](index.qmd#sec-sp-limits)).
- **Pitfalls.** `impacts()` fails in splm 1.6-5 with spatialreg 1.4-3
  (`!is.null(have_factor_preds) is not TRUE`). With large N `type =
  "mult"` densifies an N × N inverse; `"MC"` or `"moments"` from
  `spatialreg::trW`. `"moments"` needs a symmetric W or its similarity
  form. In a SEM there are no indirect effects: β is the effect.
- **Book check.** None with a published number: `?spml` shows the call on
  `Produc` commented out, and CM predates `impacts()`. The hand
  computation is checked against `spatialreg::impacts` on a
  cross-sectional `lagsarlm` fit of one season, where the machinery is
  documented.
- **Theory.** [direct and indirect effects](theory-direct-indirect-effects.qmd).

### Step 8, `8-limits.qmd`: "Limits" `{#sec-sp-limits}`

Same shape as chapter 04's "When the tests lie": simulations with no
published target, and stated limitations.

- **Heterogeneous slopes** `{#sec-sp-heterogeneous}` (5.9). Question: if
  every farm has its own elasticity, is the pooled FE slope still right,
  and are its standard errors? Run: a DGP on `rook_w(7)` with
  $\beta_i \sim N(1, 0.3^2)$ and SAR errors at λ = 0, 0.4, 0.8; 200 draws;
  coverage of the 95 % interval for the mean slope from FE with the
  conventional vcov, FE with `plm::vcovSCC`, and MG (`plm::pmg`). Picture:
  coverage against λ by estimator. Read: FE and MG both centre on 1
  (Pesaran & Tosetti 2011; P p. 801); the conventional FE interval
  undercovers, MG's own interval holds. Pitfall: MG needs T large enough
  for a per-unit regression, which RiceFarms (T = 6) does not have.
- **Dynamic spatial panels** `{#sec-sp-dynamic}` (5.6). No R
  implementation. State the model (P eq. 30.27), the stability condition
  |γ| + |ρ| + |λ| < 1, and the three regimes of Yu, de Jong and Lee (2008):
  at N/T ≈ 8.5 the estimator is at best not centred. Pitfall shown with a
  chunk: adding `plm::lag(y)` to `spml` is not a dynamic spatial
  estimator; it inherits the Nickell bias. Benchmark: Stata `xsmle`.
- **Forecasting** `{#sec-sp-forecast}` (5.10). No `predict` method for
  `splm`. Baltagi–Li BLUP in one equation; the two sources disagree on
  whether spatial terms help out of sample; the honest answer is a
  rolling-origin RMSE on one's own data. Stated limitation.
- **Pitfalls** box: Debarsy–Ertur tests, het-robust panel GM (`sphet` is
  cross-sectional), SMA and SEC errors, spatial filtering as a robustness
  check (Tiefelsdorf & Griffith 2007): none implemented for panels.
- **Book check.** None, with the reason, as in chapter 04.

### Step 9, `9-summary.qmd`: "Summary" `{#sec-sp-summary}`

What the two panels say: US house prices keep a local co-movement after
the national factor is out, ρ = 0.65 on the defactored residuals; rice
output carries a village shock with λ ≈ 0.8, farm effects that can be
random, and a small serial correlation. A decision table (if / then, one
row per step). The whole recipe in one code block: `mat2listw(style =
"W")`, `pcdtest(w = )`, `rwtest`, `slmtest(model = "within")`, `spml`,
`bsktest`, `sphtest`, `bsjktest`, `spreml`, the hand impacts. Next: time
dependence, and chapter 05 for the heteroskedasticity test that routes ML
to GM.

### Theory notes

Each on `.docs/_templates/theory.qmd`: "Code:" links to the steps, why the
method exists, the minimum math, if / then, next, with an "Open" section
where the spec records gaps.

- **`theory-spatial-weights.qmd`**, "Spatial weights". Contiguity, nearest
  neighbours, distance; row standardisation and the meaning of ρ; the
  parameter space |ρ| < 1/τ\* (Kelejian & Prucha 2010; P pp. 799, 802) and
  why |ρ| < 1 needs row *and* column standardisation; granularity and
  SAR endogeneity (P p. 800); sparsity of W against density of
  $(I - \rho W)^{-1}$ (P p. 801); exogeneity of W (CM §10.2).
- **`theory-spatial-dependence-tests.qmd`**, "Testing for spatial
  dependence". Unordered against ordered tests (P p. 784); why plain CD's
  null is weak dependence and it does not fire on spatial alternatives
  (P pp. 786, 839); local CD and its false positive under a factor
  (CM §10.1.2.2); the randomised-W test with its three pseudo-p-values
  (CM eqs. 10.1–10.3); CD_Moran and the weighted local CD (P eqs. 30.40–41)
  as the unimplemented forms; the `as.logical()` coercion.
- **`theory-spatial-model-choice.qmd`**, "Spatial model choice". SAR, SEM,
  SARAR, Durbin (P eqs. 30.1–30.9; B pp. 401–406); what an omitted lag
  does to FE (inconsistent) against an omitted error (inefficient)
  (P p. 801); the ABFY robust LM family and its locality; Wald and LR from
  the encompassing model (CM §10.3.4.2); Anselin against KKP effects and the
  BEP three-matrix model (B pp. 394–395; P p. 803); SMA and SEC not
  implemented.
- **`theory-spatial-estimation.qmd`**, "Fitting spatial panels", **new**.
  The log-likelihood with its Jacobian; the within fit and Lee & Yu's
  correction against the orthonormal transformation (P pp. 802–803); RE
  error covariances for `"b"` and `"kkp"`; the `spreml` error menu;
  KKP's six moments and `spgm`'s three `moments` options (B p. 395;
  CM §10.3.3.3); the 2SLS family behind `method =` (B pp. 401–404);
  heteroskedasticity and ML (P p. 807); the BSK and BSJK test
  construction; the spatial Hausman test; the notation table of this
  plan. Open: het-robust GM, Debarsy–Ertur, SDPD.
- **`theory-direct-indirect-effects.qmd`**, "Direct and indirect
  effects". The reduced form and $(I - \rho W)^{-1}$; direct, indirect,
  total as averages over units (LeSage & Pace 2009); why the Durbin model
  changes effects without changing estimation (B p. 406); Monte Carlo and
  trace approximations; SEM has no indirect effects.

### Spec coverage

| Spec | Where |
|---|---|
| 5.1 pre-checks on W | step 1 |
| 5.2 model choice | step 3, step 4; theory model choice |
| 5.3 FE estimation, ML and GM | step 4 |
| 5.4 RE estimation | step 5; serial + spatial in step 6 |
| 5.5 which structure: BSK, ABFY, Hausman, BSJK | steps 3, 5, 6 |
| 5.6 dynamic + spatial | step 8, limitation |
| 5.7 residual spatial diagnostics | step 2 |
| 5.8 direct and indirect effects | step 7 |
| 5.9 heterogeneous spatial panels | step 8, simulation |
| 5.10 forecasting | step 8, limitation |
| 5.11 filtering | step 8 pitfalls; theory open |

### Bibliography entries to add

anselin1988, anselin1996 (Anselin, Bera, Florax, Yoon), baltagi2003 (Song,
Koh), baltagi2007serial (Song, Jung, Koh), baltagi2013 (Egger,
Pfaffermayr), bivand2018 (Wong), burridge1980, debarsy2010 (Ertur),
druska2004 (Horrace), elhorst2003, elhorst2014, kapoor2007 (Kelejian,
Prucha), kelejian1998, kelejian1999, kelejian2010, lee2010 (Yu), lesage2009
(Pace), lin2010 (Lee), millo2014, munnell1990, mutl2011 (Pfaffermayr),
pesaran2011 (Tosetti), piras2010, tiefelsdorf2007 (Griffith), yu2008 (de
Jong, Lee). Keys `baltagi2007` (unit roots) and `millo2017` exist already.

## Steps

Each step ends in its own commit.

- [ ] **Tooling.** `renv::snapshot()` so `renv.lock` records splm, spdep,
  spatialreg, sf and spData (after the chapter calls them). Add the
  bibliography entries above plus `bailey2016spatio` (Bailey, Holly &
  Pesaran 2016, *J. Applied Econometrics*). In `R/`: `cce.R`
  (`cce_partial()`, partial the cross-section averages out of a variable
  unit by unit), `spatial-residuals.R` (`splm_residuals()`, put a within
  fit's residuals back in `pdata.frame` order; `spatial_filter()`, the
  innovations $(I - \lambda W)u$), `spatial-impacts.R` (`sar_impacts()`
  and its Monte Carlo interval), `spatial-weights.R` (`us_states_sf()`,
  the 49 polygons in `usaw49` order; `w_checks()`, the four pre-checks),
  and in `simulate-panels.R` a `sim_spatial_slope_panel()` DGP for
  step 8. All roxygen-documented.
- [ ] **Chapter page.** Rewrite `index.qmd` on `.docs/_templates/chapter.qmd`:
  opener, definition, the two maps, the two equations, glosses, numbered
  points, setup chunk, includes.
- [ ] **Step 1, weights.** `1-weights.qmd` as above.
- [ ] **Step 2, map.** `2-map.qmd` as above; the four-number pattern and
  the pure SAR.
- [ ] **Step 3, lag or error.** `3-lag-or-error.qmd`; introduce RiceFarms.
- [ ] **Step 4, fixed effects.** `4-fe.qmd`.
- [ ] **Step 5, random effects.** `5-re.qmd`.
- [ ] **Step 6, serial correlation.** `6-serial.qmd`.
- [ ] **Step 7, impacts.** `7-impacts.qmd`.
- [ ] **Step 8, limits.** `8-limits.qmd`.
- [ ] **Step 9, summary.** `9-summary.qmd`.
- [ ] **Theory notes.** Write the five notes, one commit each; create
  `theory-spatial-estimation.qmd` and list it in `_quarto.yml` under
  `project: render:` and `book: appendices:` and in the checklist.
- [ ] **Links.** Retarget the "Next" boxes of `02-cross-dependence/1-tests.qmd`
  and `2-exponent.qmd`, the CCE note and the road map's point 3 to
  `index.qmd#sec-sp-map`; the road map's "still to come" wording goes.
  Add a "Next" line in chapter 04's summary pointing here for the spatial
  size trap. Tick the checklist in `index.qmd` and add the step lines.
- [ ] **Render and check.** Clear `_freeze/` and `_book/`, render in full,
  read the log, compare every number quoted in prose with the output,
  crawl `_book/` for dead links. Fill in the outcome.

## Open questions

- ~~RiceFarms as the modelling example, or house prices through the fits
  too?~~ Both, decided 2026-10-06; house prices as the two-stage
  regression above.
- Does `impacts()` work on an `splm_GM` fit? If it does, step 7 can show
  it on the GM SAR-FE next to the hand computation.
- Should step 8 show the Nickell bias of a naive `spml` with a lagged
  outcome by simulation, or only state it? A simulation costs one DGP and
  one picture; the regime claim of Yu, de Jong and Lee (2008) cannot be
  checked without an SDPD estimator either way.
- Spatial Durbin by `spgm(Durbin = TRUE)`: one call in step 4's Pitfalls,
  or left to the theory note? No published target exists for it on
  RiceFarms.

## Outcome

Filled in when the status becomes done or superseded.
