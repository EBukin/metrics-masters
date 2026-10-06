# Write the core panel models chapter

- **Date:** 2026-10-06
- **Author:** Eduard Bukin
- **Status:** active

## Goal

`chapters/05-core/` reads the way chapters 03 and 04 read: a question in the
running example's words, one paragraph of intuition, the test in words,
every call in the open, a picture, a one-sentence reading of each result, a
"Next" box, and collapsed Recipe, Pitfalls and Book check boxes. Seven steps
and a summary cover sections 3.1 to 3.4, 4a.1, 4a.2 and 4a.4 of
`.docs/panel-spat-PLAN.md`; what has no implementation is a stated
limitation, not a silent omission. Two theory notes are written, not
placeholders. Every book check prints next to the number Baltagi (2021) or
Croissant & Millo (2019) print, with the page. The six inbound links from
chapters 00 and 03 point at step anchors. The checklist in `index.qmd` is
ticked, `references.bib` carries every entry the chapter cites, and the book
renders from a clean cache.

## Context

**What exists.** `chapters/05-core/index.qmd` is a placeholder listing six
planned sections in the spec's order (poolability, slope homogeneity,
heteroskedasticity, effects tests, fixed vs random effects, robust standard
errors). No step file and no theory note exists. Six inbound links point at
the chapter page, none at a step:

| From | Promise | Target anchor |
|---|---|---|
| `00-road-map/index.qmd:123` | "Fixed and random effects, pooling, and the tests between them close the process; still to come" | chapter page; drop "still to come" |
| `03-spatial/2-map.qmd:169` | "report standard errors robust to whatever dependence is left" | `#sec-core-robust-se` |
| `03-spatial/4-fe.qmd:303` | "Test for [heteroskedasticity] in the core chapter and, if it is there, keep the GM fit" | `#sec-core-hetero` |
| `03-spatial/8-limits.qmd:24` | "Driscoll–Kraay standard errors, met in the core chapter" | `#sec-core-robust-se` |
| `03-spatial/9-summary.qmd:64` | "owns the heteroskedasticity test that decides between the ML and GM fits here, and the robust standard errors" | `#sec-core-hetero`, `#sec-core-robust-se` |
| `03-spatial/index.qmd:85` | "the fixed-effects estimator of the core chapter stays consistent and loses precision" | `#sec-core-fe-re` |

Chapter 04 hands over a serial correlation of 0.82 in the house-price errors
(`03-spatial/9-summary.qmd:63`); this chapter's serial-correlation step picks
it up.

**What runs.** Checked on 2026-10-06 in the project renv, R 4.6.1, plm 2.6.7,
lmtest 0.9-40, nlme (base R), pder 1.0-2. No call took more than 0.1 s; the
slowest were `piest` on RiceFarms (0.10 s), `pvcm(model = "random")` on
house prices (0.07 s) and the Hausman–Taylor fit (0.09 s). Printed page
numbers are the books'; the PDF index is in brackets (Baltagi: printed + 18;
CM: printed + 19).

| Target | Source | Printed | Here |
|---|---|---|---|
| Chow F, all coefficients, Grunfeld | B §4.1.3 Ex. 1, p. 80 [98] | 27.75, F(27, 170) | 27.749 |
| Chow F, slopes only | same | 5.78, F(18, 170) | 5.7805 |
| Chow F across time | same | 1.12, F(57, 140) | 1.1204 (`effect = "time"`) |
| Roy–Zellner across firms | same | 4.35, F(27, 170) | 4.3466, hand-coded (see Tooling) |
| `pooltest` vs pooling, house prices | CM Ex. 8.4, p. 194 [213] | 26, df (96, 1300) | 25.778, df (96, 1323); CM print two digits |
| `pooltest` vs within, house prices | same | 16, df (48, 1300) | 16.074, df (48, 1323) |
| `summary(pvcm)` dispersion, house prices | CM pp. 193–194 [212–213] | mean 0.302, min −1.141, max 2.037 | 0.3018, −1.1409, 2.0369 |
| Swamy vs MG, house prices | CM Ex. 8.2, p. 190 [209] | 0.2867, 0.3018 | 0.2867014, 0.3018117 |
| Breusch–Pagan LM, ind / time / both | B Table 4.2, p. 88 [106] | 798.1615, 6.453882, 804.6154 | same to all digits |
| Honda | same | 28.25175, −2.540449, 18.18064 | same |
| King–Wu | same | 28.25175, −2.540449, 21.83221 | same |
| GHM | same | 798.1615 | same |
| Standardized Honda / KW (SLM) | same | 32.66605, 16.29814; 20.96591 | not implemented |
| F cross-section given period | B Table 4.3, p. 89 [107] | 52.362355 (9, 169) | 52.362 (`pFtest(w2, wt)`) |
| F period given cross-section | same | 1.403241 (19, 169) | 1.4032 (`pFtest(w2, w)`) |
| F both | same | 17.403146 (28, 169) | 17.403 (`effect = "twoways"`) |
| F individual, one-way | B p. 88 [106] | 49.18 (9, 188) | 49.177 |
| Hausman m1, FE vs RE | B Table 4.4, p. 96 [114] | 2.33, p 0.3119 | 2.3304, p 0.3119 |
| Hausman m3 / regression form | B p. 95 [113]; CM Ex. 5.9, p. 126 [145] | 2.131; 2.1 | 2.1314 (`method = "aux"`) |
| Robust regression-form Hausman | B p. 95 [113] | F(2, 195) 1.58, p 0.208 | χ²₂ 8.30, p 0.016 (`vcov = vcovHC`, Arellano); 3.10, p 0.213 (`white2`). Not reproduced |
| Two-way Hausman | B p. 99 [117], Table 4.6 p. 100 [118] | χ²₂ 8.842, p 0.012 | 13.46 (`swar`), 8.963 (`amemiya`), 14.15 (`walhus`), 5.42 (`nerlove`). Not reproduced |
| `xttest1`: LM(Var(u)=0) two-sided | B Table 5.3, p. 129 [147] | 798.16 | 798.16 (`plmtest`, `type = "bp"`) |
| ALM(Var(u)=0) two-sided | same | 664.95 | 664.95 (`pbsytest`, `"re"`, `re.normal = FALSE`) |
| LM one-sided / ALM one-sided | same | 28.25, 25.79 | 28.252 (`honda`), 25.787 (`pbsytest`, `"re"`) |
| LM(λ=0), unadjusted | same | 143.52 | 140.30, hand-coded NT²B²/(T − 1). Not reproduced; not in plm |
| ALM(λ=0) | same | 10.31, p 0.0013 | 10.31, p 0.001323 (`pbsytest`, `"ar"`) |
| Joint LM | same | 808.47 | 808.47 (`pbsytest`, `"j"`) |
| LR tests by `nlme` (REML) | CM Ex. 4.5, pp. 99–101 [118–120] | 307.3; 113; 196.4; 2.134, p 0.144; φ 0.8238 | 307.28; 113.05; 196.37; 2.134, p 0.1335; 0.8238 |
| `pwartest` EmplUK | CM Ex. 4.7, p. 102 [121] | F 310 (1, 890) | 312.3 (1, 889); CM print two digits |
| `pwfdtest(h0 = "fd")` EmplUK | CM Ex. 4.8, p. 103 [122] | 0.93, p 0.3 | 1.5251, p 0.217; 0.9316, p 0.335 with `- 1`. plm NEWS 1.7-0: FD intercept back (gone in 1.6-6); CM fit lacks it |
| `pwfdtest(h0 = "fe")` EmplUK | same | 130 | 131.55 |
| `piest`, `aneweytest` RiceFarms | CM pp. 94–95 [113–114] | 110, df 87, p 0.03; 140, p 2e-4 | 113.72, p 0.029; 141.89, p 0.00019 |
| `coeftest(pooled, vcovHC)` Produc | CM Ex. 5.1, p. 112 [131] | SE 0.06012, 0.04623, 0.06861, 0.00309 | 0.0601, 0.0462, 0.0686, 0.0031 |
| `coeftest(pooled, vcovSCC)` Produc | CM Ex. 5.3, pp. 117–118 [136–137] | 0.15035, 0.03697, 0.00764, 0.03870, 0.00254 | 0.1503, 0.0370, 0.0076, 0.0387, 0.0025 |
| nine-estimator SE table, pooled Produc | CM Ex. 5.4, p. 119 [138] | OLS 0.0576 … Vcxt.L 0.2722 | all 45 entries equal to 4 dp |
| nine-estimator SE table, within Produc | CM Ex. 5.5, p. 122 [141] | 0.0290 … 0.0717 | all 36 entries equal |
| `pggls(model = "fd")` EmplUK | CM Ex. 5.13, p. 133 [152] | −0.3343 (0.0385), 0.3786 (0.0203) | −0.3129, 0.3712 with plm's intercept; −0.3343, 0.3786 with `- 1` |
| Hausman–Taylor, `Wages` | B Table 7.6, p. 175 [193] | ed .137944 (.0212485), cons 2.912726 (.2836522), σ_u .9418, σ_e .1518 | 0.13794 (0.02125), 2.91273 (0.28365), 0.94180, 0.15180 |
| Amemiya–MaCurdy, `Wages` | B Table 7.5, p. 174 [192] | cons 2.927, ed 0.137 | 2.92734, 0.13720 (`inst.method = "am"`) |
| Hausman GLS vs within, `Wages` | B p. 174 [192] | χ²₉ = 5075 | 5075.3 |
| Hausman HT vs within, `Wages` | B p. 175 [193] | χ²₃ = 5.26 | 5.2577, but plm reports df = 9 |

**What is broken or missing.**

- `plm::pooltest` (formula method) fails with `could not find function
  "plm"` unless **plm** is attached: it calls `plm()` unqualified, like
  `pmg` and `pcce`. The setup chunk attaches it with the comment the rules
  require.
- `plm::phtest(method = "aux")` fails with `Error in str2lang(x):
  unexpected symbol` when the formula contains `log()`: it builds the
  auxiliary formula from variable names and `log(income).tilde` does not
  parse. The house-price panel therefore carries precomputed columns `lp`
  and `li`.
- Two-way Hausman: plm's two-way random effects has no Wansbeek–Kapteyn
  option, and Swamy–Arora and Wallace–Hussain return a negative time
  variance that plm truncates to zero, so Baltagi's 8.842 (EViews, WK) is
  not reproduced: 13.46 (`swar`), 8.963 (`amemiya`).
- `plm::piest` on Grunfeld: `system is computationally singular`;
  `plm::aneweytest` on Grunfeld returns χ² = −508.75 on 758 df. Both need N
  large against T·K (Chamberlain's Π has T·K columns per equation; N = 10,
  T = 20). They run on RiceFarms (N = 171, T = 6) and match CM. Stated as a
  limitation of the small panel, shown on RiceFarms in the Book check only.
- Pesaran–Yamagata Δ: no R implementation. `exists()` and `help.search()`
  for "Yamagata", "slope homogeneity" find nothing in the installed
  library; no package named `p*`/`xt*` beyond plm, pder. Limitation with
  "Benchmark: Stata `xthst`" (deferred).
- Roy–Zellner F: not in plm. Hand-coded in `R/` (GLS transform with the
  one-way θ, then Chow), 4.3466 against the book's 4.35.
- LM₃ (serial correlation ignoring effects): not in plm; hand computation
  140.30 against Stata's 143.52. Shown as not reproduced; Baltagi says not
  to use it anyway (p. 127).
- SLM (B eq. 4.26), conditional LM tests (B eqs. 4.34, 4.36), Verbon and
  Lejeune heteroskedasticity tests, Bester–Conley–Hansen, Kang's five
  hypotheses: no implementation. Stated gaps.
- `pbnftest` returns a statistic only (no p-value) for both `"bnf"` and
  `"lbi"`: the reading uses the Bhargava et al. (1982) tables by eye, or
  the comparison across panels.
- `pwfdtest(h0 = "fd")` on EmplUK gives 1.53 where CM print 0.93. The
  `"fe"` leg matches. Reported as not reproduced; the writer must not quote
  CM's 0.93 as reproduced.

**Notation.**

| Where | Trap |
|---|---|
| `plmtest(effect = "twoways")` | Tests H₀: σ²_μ = σ²_λ = 0 jointly (Honda's "handy" (A + B)/√2, KW's weighted sum, BP's A² + B², GHM's mixed χ²). It is **not** the conditional test of one effect allowing the other (B eqs. 4.34, 4.36), which has no implementation. |
| `plmtest(type = "ghm")` | Two-way only; one-way errors with "type must be one of honda, bp or kw". |
| Honda on time effects | −2.540 (p 0.99): a negative one-sided statistic means the time variance estimate is negative, i.e. no time effect. BP squares it to 6.45 (p 0.011) and looks like a rejection. Read the sign. |
| `pFtest` three ways | `pFtest(f, effect = "twoways")` tests both against pooled (17.40); `pFtest(w2, w)` tests time given individual (1.40); `pFtest(w2, wt)` individual given time (52.36). The three rows of B Table 4.3. |
| `phtest(vcov = )` | Honoured only under `method = "aux"`; under `"chisq"` it is silently ignored (same 2.3304). |
| `phtest(effect = "twoways")` | Compares two-way within with two-way RE: Kang's hypothesis (5) only; EViews' "cross-section random" 0.715 and "period random" 7.209 are other contrasts. plm's `effect = "time"` (0.323) compares one-way time FE with one-way time RE and is none of Baltagi's numbers. |
| `phtest(ht, within)` | df = number of common coefficients (9); Baltagi uses df = 3, the over-identifying conditions. Same statistic 5.26, different p. |
| `pbsytest` | `test = "ar"` is χ²₁ (ALM(λ=0)); `test = "re"` is one-sided N(0, 1) by default, `re.normal = FALSE` gives the χ²₁ (ALM(Var(u)=0)); `test = "j"` is χ²₂. Stata's `xttest1` "ALM" rows are plm's "locally robust" tests. |
| `pbltest` | `alternative = "twosided"` (default) is χ²₁; `"onesided"` is N(0, 1). CM Ex. 4.4 print the one-sided z = 6.1. Fits the RE model by ML through **nlme**. |
| `pwfdtest` | `h0 = "fd"`: null is no serial correlation in the *differenced* errors (original errors a random walk; FD is the right estimator). `h0 = "fe"`: null is correlation −0.5 in the differenced errors, i.e. white-noise original errors (FE is right). The leg that is **not** rejected names the estimator. Both rejected: use robust errors. |
| `pwartest` | Null is correlation −1/(T − 1) in the within residuals, not zero. |
| `pdwtest`, `pbgtest` | Treat the stacked residuals as one series; corroboration only (spec 3.4). |
| `vcovHC.plm` | Default `method = "arellano"`, clustered by group; `"white1"` is White's. `sandwich::vcovHC` on an `lm` defaults to White, so the same name gives different numbers (CM Ex. 5.1). |
| `vcovDC` | Equals `Vcx + Vct − Vw` exactly (CM Table 5.1); `vcovBK` default `cluster = "group"`, read `?vcovBK` before calling it Beck–Katz; `vcovSCC` default Bartlett weights, `maxlag = NULL` means floor(T^(1/4)). |
| `pggls(model = "fd")` | Carries an intercept in plm 2.6.7; CM's printed FD-GLS has none. Add `- 1` to match. |
| `pooltest(model = )` | `"pooling"` restricts intercepts and slopes (B: "all coefficients"), `"within"` restricts slopes only. `effect = "time"` pools across years. |
| `random.method` | B's Grunfeld one-way RE is Swamy–Arora with θ = 0.861 (`ercomp`: 0.8612). The two-way case is where methods diverge (see above). |

**Data.**

- `plm::Grunfeld`: 10 firms × 20 years (1935–54), 200 rows, `inv ~ value +
  capital`. One-way RE: σ²_μ 7095, σ²_ν 2675, θ 0.861. Two-way: time
  variance 0 under `swar` and `walhus`, 244 under `amemiya`. Poolability
  rejected across firms (F 27.7) and for slopes alone (5.78), not across
  years (1.12). Individual slopes on `value` run from 0.0046 to 0.175.
  One-way Hausman does not reject (2.33); two-way rejects (13.5).
- `plm::Produc`: 48 states × 17 years, 816 rows, `log(gsp) ~ log(pcap) +
  log(pc) + log(emp) + unemp`. Within slopes −0.026, 0.292, 0.768, −0.0053.
  Classical SEs 0.0290, 0.0251, 0.0301, 0.00099; Arellano 2.1–2.7×; SCC
  2.0–2.8×; double clustering 2.4–3.2×. `pwfdtest`: fd not rejected (2.79,
  p 0.095), fe rejected (95): first differences are the better estimator.
- `pder::HousePricesUS`: 49 states × 29 years, 1421 rows, `log(price) ~
  log(income)`. Poolability rejected (25.8, 16.1); individual income slopes
  from −1.14 to 2.04 (mean 0.30). Two-way variance components: idiosyncratic
  0.0120, state 0.0124, year 0.0029; θ 0.82 (id), 0.72 (time). Every effects
  test rejects (Honda 60.0 individual, 18.6 time). One-way Hausman 1.39 (p
  0.24) does not reject; two-way 58.6 rejects; robust aux 1.78. Every serial
  test rejects (`pwartest` F 22753, LBI 0.249, DW 0.131); `pwfdtest` rejects
  both legs (105, 385). Within SE on income: classical 0.0268, Arellano
  0.0887, SCC 0.109, double clustering 0.113, Vcxt.L 0.148: 3.3 to 5.5×.
  Precompute `lp`, `li` for `phtest(method = "aux")`.
- `plm::Wages`: 595 heads of household × 7 years (1976–82), 4165 rows,
  `index = 595`. The Cornwell–Rupert equation with `ed` time-invariant and
  endogenous; X1 = (bluecol, south, smsa, ind), X2 = (exp, exp², wks,
  married, union), Z1 = (sex, black), Z2 = (ed).
- `plm::EmplUK`: 140 firms, 7–9 years, 1031 rows, unbalanced. Book-check
  panel only (CM Ex. 4.7, 4.8, 5.13); the whole battery runs on it.
- `plm::RiceFarms`: 171 farms × 6 seasons. Book-check panel for `piest`,
  `aneweytest` only.

**Running examples (decided 2026-10-06).** Both panels run through every
step, as chapter 03 ran two.

- **Grunfeld** carries the Baltagi book checks: Tables 4.2, 4.3, 4.4, 4.6,
  5.3 and Example 1 of §4.1.3 are all printed on it, so the reader sees the
  book's numbers come out of the calls in the main text, not only in a box.
  It is also the small, balanced, firm-level panel that makes "one
  regression for ten firms?" a concrete question.
- **House prices** carry the story forward from chapters 02 to 04 and
  supply the contrasting reading in four steps: poolability rejects while
  the slopes scatter from −1.1 to 2.0, which is what the mean-group
  estimator of chapter 02 answered; the one-way Hausman does not reject
  while the two-way does; `pwfdtest` rejects both legs, the "truth in the
  middle" case that sends the reader to robust errors; and the robust SE
  table shows the 3–5× inflation that redeems the promise of chapter 03
  ("report standard errors robust to whatever dependence is left") and the
  0.82 serial correlation of chapter 04. Every call runs on it; the one
  failure (`aux` with `log()`) is a pitfall, not a reason to drop it.
- **Produc** is the spec's canonical panel for 3.3 and 4a.4 and the panel
  CM print the nine-estimator table on; it is the main run of the robust
  SE step beside house prices, and the Book check of the heteroskedasticity
  step. **Wages** appears in the Hausman–Taylor part of the FE-or-RE step
  only; **EmplUK** and **RiceFarms** in Book check boxes only.

**Order.** The placeholder lists the spec's order (3.1, 3.2, 3.3, 4a.1,
4a.2, 4a.4). The chapter follows plan 0008's brief instead: poolability,
slope heterogeneity, effects tests, fixed or random, serial correlation,
heteroskedasticity, robust errors, summary. Serial correlation comes after
the effects choice because its tests condition on it (BSY, Baltagi–Li) and
because `pwfdtest` is the FE-against-FD choice; heteroskedasticity and the
robust-error menu close the chapter because they are what the reader
carries into chapters 03 and 06. The brief's "heteroskedasticity and robust
standard errors" is split in two steps, because the inbound links promise
two different things (a test, and a menu) and the two have different book
checks.

## Chapter structure

### `index.qmd`

Title "Core panel models". Intro: a panel asks three questions of its own
before any spatial or time story: can the units share one regression, is
the unit effect a nuisance or a draw, and can the standard errors be
believed. Gloss "fixed effects" and "random effects" in one sentence each
and link both theory notes. Running examples: Grunfeld (ten firms'
investment, 1935–54) and house prices (continuity sentence, link to chapter
02's `#sec-cce`). Road map as numbered points, one per step. Setup chunk
`c05-0-setup`: `devtools::load_all(quiet = TRUE)`; `library(plm)` with the
comment "pooltest's formula method calls plm() unqualified"; `data()` for
Grunfeld, Produc, Wages, HousePricesUS; `pdata.frame` for each; `hp$lp`,
`hp$li` precomputed; the formulas `fg`, `fp`, `fh`. Then eight
`{{< include >}}` lines.

### Step 1, `1-poolability.qmd`: "Poolability" `{#sec-core-pool}`

- **Question.** Can one investment equation serve all ten firms, and one
  price–income elasticity all 49 states, or does each need its own?
- **Intuition.** Fit one regression to everyone and one to each unit;
  compare the residual sums of squares. If the single line fits almost as
  well, pooling costs nothing and buys precision. Chow's F does exactly
  this [@chow1960; @baltagi2021, p. 77]. Two versions: restrict all
  coefficients (restricted model pooled OLS) or slopes only (restricted
  model within, each unit its own intercept). Under random effects the
  plain Chow test over-rejects; Roy–Zellner runs the same F on the
  GLS-transformed data [@roy1957; @zellner1962; @baltagi2021, pp. 78–79].
  Equations: eq. 4.8 (the F) and eq. 4.14 (transformed).
- **The tests.** `plm::pooltest` [@croissant2019, sec. 8.2.3] with
  `model = "pooling"` and `model = "within"`; `effect = "time"` for
  poolability across years; `roy_zellner()` from `R/` for the GLS version.
  Null: identical coefficients. A rejection means the units do not share
  the line.
- **Run it.** Grunfeld: four calls (pooling, within, time, Roy–Zellner).
  House prices: pooling, within; `plm::pvcm(model = "within")` fitted here
  for the picture and reused in step 2.
- **Picture.** The ten firm-by-firm regression lines of `inv` on `value`
  over the pooled line (left); the 49 state lines of log price on log
  income (right). Dispersion of slopes drawn, not tabulated.
- **Read it.** Rejects: Grunfeld 27.7 on F(27, 170) and 5.78 on F(18,
  170); house prices 25.8 and 16.1. *So:* neither panel pools, even with
  its own intercepts. Does not reject: Grunfeld across years, 1.12 on
  F(57, 140). *So:* the firms' lines are stable over time; the
  heterogeneity is across firms. Misleads: the Chow F under random
  effects; Roy–Zellner gives 4.35, still a rejection here, but Baltagi's
  Monte Carlo (p. 79) shows the plain F rejecting a true null often when
  the variance components are large.
- **Next.** Rejected: how far apart are the slopes, and is the average
  still worth estimating ([slope heterogeneity](index.qmd#sec-core-slopes))?
  Not rejected: pooled OLS with the effects tests of step 3.
- **Pitfalls.** `pooltest` needs **plm** attached. `model = "pooling"`
  versus `"within"` changes the null (all coefficients versus slopes).
  Poolability rejected does not forbid a pooled slope: it is the average
  effect, with the dispersion reported beside it (chapter 02's mean group).
  Roy–Zellner is not in plm; the helper is one-way, balanced only.
- **Book check.** B §4.1.3 Ex. 1, p. 80: 27.75 (27, 170), 5.78 (18, 170),
  1.12 (57, 140), 4.35 (27, 170): all four reproduced (27.749, 5.7805,
  1.1204, 4.3466). CM Ex. 8.4, p. 194: 26 (96, 1300) and 16 (48, 1300)
  reproduced as 25.778 and 16.074 on df (96, 1323), (48, 1323); CM print
  two significant digits.
- **Theory.** [Fixed and random effects](theory-fixed-random.qmd), the
  section on what "one regression" assumes.

### Step 2, `2-slopes.qmd`: "Slope heterogeneity" `{#sec-core-slopes}`

- **Question.** When the slopes differ, how much do they differ, and is the
  spread more than sampling noise would give?
- **Intuition.** Estimate each unit's own regression and look at the
  spread of the slopes. Swamy's model treats each unit's coefficient as a
  draw around a common mean and estimates the variance of the draws
  [@swamy1970; @croissant2019, sec. 8.2.2]; a large estimated variance says
  the units genuinely differ. The modern test for N large, T moderate is
  Pesaran–Yamagata's Δ, a standardised Swamy statistic [@pesaran2008],
  with a HAC version [@blomquist2013]. Equations: Swamy's dispersion
  estimator (CM p. 188), Δ̃ in words with its rate conditions √N/T → 0
  and √N/T² → 0 (spec 3.2).
- **The tests.** `plm::pvcm(model = "within")` and its `summary()`
  dispersion table; `plm::pvcm(model = "random")` for Swamy's mean and
  `$Delta`; `plm::pmg(model = "mg")` as the chapter-02 comparison.
  Pesaran–Yamagata: **not implemented in R**; limitation box with
  "Benchmark: Stata `xthst` (Bersvendsen & Ditzen 2021)".
- **Run it.** Grunfeld: `summary(pvcm within)`, `pvcm random` with
  `cbind(coef, sqrt(diag($Delta)))`. House prices: the same, plus `pmg`.
- **Picture.** Histograms of the individual slopes, CM Fig. 8.1 redrawn for
  both panels, with the Swamy mean and the MG mean as vertical lines.
- **Read it.** House prices: Swamy 0.287, MG 0.302, slopes from −1.14 to
  2.04; Swamy's standard deviation of the slope draws is of the order of
  the mean. *So:* the elasticity is not one number; chapter 02's
  mean-group choice was right. Grunfeld: `value` slopes 0.005 to 0.175
  around 0.09. *So:* the firms differ in scale as much as in slope. No
  "does not reject" case on these panels; say so.
- **Next.** Whatever the spread, the effects tests come next
  ([effects tests](index.qmd#sec-core-effects)): a pooled slope with unit
  effects is the average effect, and the question is what kind of effect.
- **Pitfalls.** Swamy's covariance can come back non-positive-definite;
  the MG dispersion is always valid (CM p. 190). Δ is the only test built
  for N ≫ T; its absence is a gap of the tools, not of the method. The
  spec's warning: Swamy's own test needs N fixed, T → ∞.
- **Book check.** CM Ex. 8.2, p. 190: Swamy 0.2867, MG 0.3018 reproduced
  exactly. CM pp. 193–194 `summary(housep.np)`: mean 0.302, min −1.141,
  max 2.037 reproduced (0.3018, −1.1409, 2.0369). No target for
  Pesaran–Yamagata: none in R.
- **Theory.** [Fixed and random effects](theory-fixed-random.qmd), random
  coefficients section.

### Step 3, `3-effects.qmd`: "Effects tests" `{#sec-core-effects}`

- **Question.** Is there a firm effect in investment, a year effect, both,
  or neither, so that pooled OLS would do?
- **Intuition.** Pooled OLS residuals from one unit should not resemble
  each other if there is no unit effect. The Breusch–Pagan LM test squares
  the ratio of "sum of the unit's residuals" to "sum of their squares"
  [@breusch1980; @baltagi2021, eq. 4.23]; Honda takes the signed square
  root, because a variance cannot be negative and a one-sided test is
  stronger [@honda1985, eq. 4.25]. King–Wu weights the two one-sided pieces
  [@king1997, eq. 4.30]; GHM drops a negative piece instead of squaring it
  [@gourieroux1982, eq. 4.33]. The F test compares the within and pooled
  residual sums of squares [@baltagi2021, eq. 4.38]. Equations 4.22–4.25,
  4.30, 4.33 in the step; 4.26, 4.34, 4.36 named as gaps.
- **The tests.** `plm::plmtest` with `type = "honda"`, `"bp"`, `"kw"` for
  `effect = "individual"`, `"time"`, `"twoways"` and `type = "ghm"` for
  `"twoways"`, each its own call; `plm::pFtest` three ways (formula
  `effect = "twoways"`; `(w2, w)`; `(w2, wt)`). Null: no effect of that
  kind. A rejection means the unit (or year) shares a component.
- **Run it.** Grunfeld: ten `plmtest` calls and three `pFtest` calls, in
  the open, one chunk per family. House prices: the same.
- **Picture.** Pooled residuals of Grunfeld grouped by firm (boxplots) and
  by year: the firm boxes sit apart, the year boxes do not. Beside it the
  house-price residuals by state and by year, where both sit apart.
- **Read it.** Rejects: Grunfeld firm effect, Honda 28.3, F 49.2; house
  prices both effects, Honda 60.0 and 18.6. Does not reject: Grunfeld year
  effect, Honda −2.54, F 1.40 given firm effects. *So:* firm effects yes,
  year effects no; a one-way model for Grunfeld, two-way for house prices.
  Misleads: BP on Grunfeld's time effect, 6.45 (p 0.011): the square of a
  negative Honda; and the joint tests (804.6, 18.2, 21.8) which reject
  because of the firm effect alone.
- **Next.** Effects found: are they draws or parameters ([fixed or
  random](index.qmd#sec-core-fe-re))? None found: pooled OLS, then the
  error diagnostics of steps 5 to 7.
- **Pitfalls.** Honda's sign; BP's two-sidedness; "twoways" is joint, not
  conditional (B eqs. 4.34, 4.36 are the correct family for the two-way
  case with correlated regressors and have no implementation); SLM (eq.
  4.26, B Table 4.2 "Standardized") not implemented, needed when regressors
  are many or spatially smooth; GHM only for two-way.
- **Book check.** B Table 4.2, p. 88: twelve numbers (BP, Honda, KW for
  three hypotheses; GHM 798.1615) reproduced to every printed digit;
  Standardized Honda / KW (32.66605, −2.432565, 16.29814, 20.96591) not
  reproducible, no implementation. B Table 4.3, p. 89: 52.362355 (9, 169),
  1.403241 (19, 169), 17.403146 (28, 169) reproduced (52.362, 1.4032,
  17.403); B p. 88 F(9, 188) 49.18 reproduced (49.177). Chi-square
  versions (266.3955, 29.297556, 271.340224) not run: EViews' LR form.
- **Theory.** [Fixed and random effects](theory-fixed-random.qmd).

### Step 4, `4-fe-or-re.qmd`: "Fixed or random" `{#sec-core-fe-re}`

- **Question.** Does a firm's unobserved character move with its capital
  stock? If it does, random effects is wrong; if it does not, fixed effects
  throws away precision.
- **Intuition.** Fixed effects uses only within-unit variation and is
  consistent either way; random effects also uses between-unit variation
  and is efficient only if the unit effect is uncorrelated with the
  regressors. Hausman compares the two estimates: far apart means the
  between variation carries the correlation [@hausman1978; @baltagi2021,
  eq. 4.41]. The same test is an F on the extra regressors in an augmented
  regression (eq. 4.42), which is how it is made robust [@arellano1993,
  eq. 4.49; @wooldridge2010]. Mundlak's model says why: the unit effect is
  a linear function of the unit means [@mundlak1978; @croissant2019, sec.
  4.2.1]. Hausman–Taylor keeps time-invariant regressors by instrumenting
  with the exogenous subset [@hausman1981; @baltagi2021, sec. 7.4].
- **The tests.** `plm::phtest` with `method = "chisq"`, `method = "aux"`,
  `method = "aux", vcov = plm::vcovHC`; the two-way case through
  `effect = "twoways"` and a `random.method` comparison; Chamberlain and
  Angrist–Newey (`plm::piest`, `plm::aneweytest`) named, run in the Book
  check on RiceFarms; Hausman–Taylor by `plm::plm(model = "random",
  random.method = "ht", inst.method = "baltagi")` on `Wages`, with
  `inst.method = "am"` beside it and `plm::pht` noted as deprecated.
- **Run it.** Grunfeld: chisq, aux, aux + vcovHC; two-way chisq with
  `swar` and `amemiya`. House prices: the same on `lp ~ li`. Wages: the HT
  fit, the AM fit, `phtest(re, within)` and `phtest(ht, within)`.
- **Picture.** Within and between estimates of Grunfeld's two slopes with
  their confidence bands (the contrast q₃ drawn); beside it the house-price
  within, between and RE income slopes.
- **Read it.** Does not reject: Grunfeld one-way, 2.33 (p 0.31); house
  prices one-way, 1.39 (p 0.24); HT against within on Wages, 5.26. *So:*
  random effects is admissible on both one-way models, and the HT
  instruments are legitimate. Rejects: Grunfeld two-way, 13.5; house prices
  two-way, 58.6; Wages GLS against within, 5075. *So:* once the year effect
  is in, the state (or firm) effect is correlated with the regressors; on
  Wages, education is correlated with the person effect, and HT recovers
  its return (0.138) that within cannot estimate. Misleads: the aux test
  with a clustered vcov on Grunfeld, 8.30 (p 0.016), rejecting where the
  classical test does not: ten clusters is too few for the Arellano
  estimator, and Baltagi's own robust F is 1.58.
- **Next.** Not rejected: random effects, and the serial-correlation tests
  that condition on it ([serial correlation](index.qmd#sec-core-serial)).
  Rejected: fixed effects; then `pwfdtest` for FE against FD in the same
  step.
- **Pitfalls.** `vcov` is ignored under `"chisq"`; `"aux"` breaks on
  `log()` in the formula; two-way RE needs a variance method, and
  Baltagi's 8.842 (Wansbeek–Kapteyn) is unavailable; plm returns one
  two-way statistic where Kang (1985) names five hypotheses (B p. 99);
  `piest` and `aneweytest` need N ≫ T; `phtest(ht, within)` reports df = 9,
  Baltagi df = 3; the Hausman pretest distorts the size of the second-stage
  test (Guggenberger 2010, B p. 94); rejection does not validate FE, it
  only rejects RE (B p. 93).
- **Book check.** B Table 4.4, p. 96: 2.33, p 0.3119 reproduced (2.3304,
  0.3119); B p. 95 m₃ 2.131 reproduced as `aux` 2.1314; B p. 95 robust
  F(2, 195) 1.58 not reproduced (χ²₂ 8.30 with Arellano, 3.10 with
  `white2`). B p. 99 two-way 8.842 not reproduced: 13.46 (`swar`), 8.963
  (`amemiya`). CM Ex. 5.9, p. 126: 2.3 and 2.1 reproduced. B Table 7.6, p.
  175: HT coefficients and SEs reproduced to the printed digits (ed 0.13794
  (0.02125), constant 2.91273 (0.28365), σ_u 0.9418, σ_e 0.1518); B p. 174
  χ²₉ 5075 reproduced (5075.3); B p. 175 χ²₃ 5.26 reproduced as 5.2577
  with plm's df 9. CM pp. 94–95 `piest` 110 (df 87, p 0.03) and
  `aneweytest` 140 (p 2e-4) on RiceFarms reproduced (113.72, p 0.029;
  141.89, p 0.00019).
- **Theory.** [Fixed and random effects](theory-fixed-random.qmd).

### Step 5, `5-serial.qmd`: "Serial correlation" `{#sec-core-serial}`

- **Question.** After the firm effect is out, does this year's investment
  shock carry into next year's? And for house prices: is the 0.82 that
  chapter 04 left behind a unit root in the errors or an AR(1)?
- **Intuition.** A unit effect makes every pair of a unit's residuals
  correlated by the same amount; an AR(1) makes neighbouring years more
  alike than distant ones. Tests that ignore the one over-reject on the
  other [@baltagi2021, p. 127; @croissant2019, sec. 4.3]. So the battery
  has three kinds: joint (both at once), locally robust (one allowing a
  little of the other), conditional (one given the other). Then the
  regression-based tests of Wooldridge on within and first-differenced
  residuals, which need no normality and give the FE-against-FD choice.
  Equations: LM₁ (B eq. 5.36), the BSY adjusted LM (B p. 128), LM₅ (eq.
  5.43), the BFN Durbin–Watson (eq. 5.44), Wooldridge's two auxiliary
  regressions (CM pp. 102–103).
- **The tests.** `plm::pwtest` [@wooldridge2010, sec. 10.4.4];
  `plm::pbsytest` with `test = "ar"`, `"re"`, `"j"` [@bera2001;
  @baltagi1991; @baltagi1995]; `plm::pbltest` [@baltagi1995];
  `plm::pbnftest` with `test = "bnf"` [@bhargava1982] and `"lbi"`
  [@baltagi1999]; `plm::pwartest`, `plm::pwfdtest` with `h0 = "fd"` and
  `"fe"` [@wooldridge2010, secs. 10.5.4, 10.6.3; @drukker2003];
  `plm::pbgtest`, `plm::pdwtest` as corroboration. Thirteen calls per
  panel, each in the open.
- **Run it.** Grunfeld: the thirteen calls, grouped in four chunks (joint
  and robust; conditional and DW; Wooldridge; corroboration). House
  prices: the same four chunks.
- **Picture.** Autocorrelation of the within residuals by lag, pooled over
  units, for both panels, with the −1/(T − 1) line that FE induces under
  the null; beside it the same for the first-differenced residuals with the
  −0.5 line.
- **Read it.** Rejects: Grunfeld joint 808, AR given RE 10.3, BL 69.5,
  `pwartest` 76.9; house prices everything, `pwartest` 22753, LBI 0.249.
  *So:* both panels have serially correlated idiosyncratic errors. The
  FE-against-FD choice: Grunfeld `h0 = "fd"` 16.5 and `h0 = "fe"` 372, both
  rejected, the second far more: FE's errors are nearer white noise than a
  random walk, FE with robust errors. House prices 105 and 385, both
  rejected: "the truth lies in the middle" (CM p. 104). Produc in the Book
  check: `fd` not rejected (2.79, p 0.095), FD is the estimator. Misleads:
  `pwtest` on Grunfeld, z 1.49 (p 0.14), does not reject although the firm
  effect is 73 % of the variance: it has power against RE and against AR
  together and trades it for robustness; and `pdwtest` on the pooled fit
  (0.36), which reads the firm effect as serial correlation.
- **Next.** Both legs rejected: robust standard errors ([robust
  errors](index.qmd#sec-core-robust-se)); one leg not rejected: that
  estimator, with the heteroskedasticity check first
  ([heteroskedasticity](index.qmd#sec-core-hetero)). House prices: the
  within residuals are close to a random walk, which is the dynamic
  specification of chapter 06.
- **Pitfalls.** The nulls of `pwartest` (−1/(T − 1)) and `pwfdtest`
  (`"fe"`: −0.5); `pbnftest` prints no p-value; `pbgtest` and `pdwtest`
  stack the panel; LM₃ over-rejects with effects present (B p. 127);
  `pbltest` and the BSY family assume normal, homoskedastic errors;
  Inoue–Solon needs N ≫ T²/2 (not run); `pwfdtest(h0 = "fd")` on EmplUK
  does not reproduce CM's 0.93.
- **Book check.** B Table 5.3, p. 129 (Stata `xttest1` on Grunfeld):
  798.16, 664.95, 28.25, 25.79, 10.31 (p 0.0013), 808.47 reproduced from
  `plmtest(type = "bp")`, `pbsytest("re", re.normal = FALSE)`,
  `plmtest(type = "honda")`, `pbsytest("re")`, `pbsytest("ar")`,
  `pbsytest("j")`; LM(λ=0) 143.52 not reproduced (hand formula 140.30, not
  in plm). CM Ex. 4.5, pp. 99–101, by `nlme::lme` (REML): 307.3, 113,
  196.4, 2.134 (p 0.144), φ 0.8238 reproduced (307.28, 113.05, 196.37,
  2.134, 0.8238). CM Ex. 4.7, p. 102, `pwartest` on EmplUK 310 (1, 890)
  reproduced as 312.3; CM Ex. 4.8, p. 103, `h0 = "fe"` 130 reproduced
  (131.55), `h0 = "fd"` 0.93 not reproduced (1.53, p 0.22).
- **Theory.** [The error of a panel regression](theory-panel-error.qmd).

### Step 6, `6-hetero.qmd`: "Heteroskedasticity" `{#sec-core-hetero}`

- **Question.** Do big firms' investment shocks have a bigger variance than
  small firms', and large states' price shocks than small states'? If so,
  which estimates can still be trusted, and which spatial estimator of
  chapter 03 survives?
- **Intuition.** Unequal error variances leave the slopes consistent but
  the classical standard errors wrong, in either direction [@baltagi2021,
  p. 109]. Two routes: keep OLS and fix the variance (White's sandwich,
  Arellano's panel version that also allows serial correlation within a
  unit [@white1980; @arellano1987, eq. 2.16]); or model the variance and
  reweight (general FGLS, which estimates the full T × T error covariance
  from the cross-section [@kiefer1980; @parks1967; @wooldridge2010, sec.
  10.4.3; @croissant2019, sec. 5.2]). There is no panel test of
  homoskedasticity in R: Verbon's and Lejeune's LM tests [@verbon1980;
  @lejeune2006; @baltagi2021, sec. 5.1.1] are the gap. The step shows the
  evidence by picture and by a hand-made auxiliary regression of squared
  within residuals on unit size, labelled as a diagnostic, not a test with
  a published size.
- **The tests.** `plm::vcovHC` with `method = "arellano"` (default) and
  `"white1"` through `lmtest::coeftest`; `plm::pggls` with
  `model = "pooling"` and `model = "within"`; `plm::phtest` on the two
  `pggls` fits (CM Ex. 5.14). Limitation box: Verbon, Lejeune, and the
  Li–Stengos robust BP, not implemented.
- **Run it.** Produc within fit (the spec's canonical): classical,
  White, Arellano `coeftest`; `pggls` pooled and within. Grunfeld and house
  prices: the same six calls each.
- **Picture.** Within residual standard deviation per unit against unit
  size (mean `value`; mean income), for Grunfeld and house prices: the
  fan. Beside it the estimated `$sigma` of `pggls` on Produc as an image:
  the off-diagonals that do not die out (CM p. 130).
- **Read it.** Produc: Arellano SEs 2.1–2.7× the classical ones;
  `pggls` within moves `log(pc)` from 0.29 to 0.17 and `log(emp)` from
  0.77 to 0.84. *So:* the classical errors overstate precision by half,
  and reweighting changes the point estimates, which is what inefficiency
  under heteroskedasticity and serial correlation looks like. Grunfeld:
  the fan is steep (the two largest firms carry most of the residual
  variance). House prices: `pggls` within 0.316 against within's slope,
  pooled 0.378. Misleads: White's `"white1"` on Produc, 1.1–1.3×: it
  allows the variance to differ but not the serial correlation, and
  understates the problem.
- **Next.** The menu of robust errors and which one fits which dependence
  ([robust errors](index.qmd#sec-core-robust-se)). For the spatial fits:
  heteroskedasticity present, keep the GM fit
  ([fixed effects](../03-spatial/index.qmd#sec-sp-fe)).
- **Pitfalls.** `vcovHC.plm` defaults to Arellano, `sandwich::vcovHC` to
  White (CM Ex. 5.1); FGLS needs N ≫ T, and T(T + 1)/2 covariance
  parameters on Grunfeld (210 from 10 firms) is not a model, so `pggls` on
  Grunfeld is shown and read as unreliable; `pggls(model = "fd")` has an
  intercept in plm 2.6.7; heteroskedastic errors make spatial ML
  inconsistent [@lin2010; @pesaran2015, p. 807].
- **Book check.** CM Ex. 5.1, p. 112: `coeftest(plmmod, vcovHC)` on pooled
  Produc, SEs 0.06012, 0.04623, 0.06861, 0.00309 reproduced (0.0601,
  0.0462, 0.0686, 0.0031). CM Ex. 5.13, p. 133: `pggls(model = "fd")` on
  EmplUK −0.3343 (0.0385), 0.3786 (0.0203) reproduced with `- 1` in the
  formula (−0.3343, 0.3786); with plm's default intercept −0.3129, 0.3712.
  CM Ex. 5.11, p. 130 (pooled GGLS on EmplUK, 2.0235, −0.2323, 0.6105) to
  be run by the writer; not run in recon. B §5.1 gives no numbers.
- **Theory.** [The error of a panel regression](theory-panel-error.qmd).

### Step 7, `7-robust-se.qmd`: "Robust errors" `{#sec-core-robust-se}`

- **Question.** Which standard error is honest for a panel whose errors
  are heteroskedastic, serially correlated within a state, and correlated
  across states in the same year?
- **Intuition.** Every panel sandwich is White's meat summed over a
  cluster, with or without kernel-weighted lags [@millo2017;
  @croissant2019, sec. 5.1.1]. Cluster by unit: Arellano, robust to any
  serial correlation inside a unit, asymptotic in N. Cluster by year:
  robust to any cross-sectional correlation, asymptotic in T. Both: double
  clustering [@cameron2011; @thompson2011]. Year clusters plus
  kernel-weighted lags: Driscoll–Kraay, robust to spatial and temporal
  dependence as T → ∞ [@driscoll1998; @baltagi2021, p. 394]. Unit-level
  White plus lags: panel Newey–West [@newey1987]. Beck–Katz PCSE assumes
  the same cross-sectional covariance every year [@beck1995]. CM Table 5.1
  (p. 117) as the chapter's own table of building blocks.
- **The tests.** `plm::vcovHC`, `plm::vcovSCC`, `plm::vcovBK`,
  `plm::vcovNW`, `plm::vcovDC`, each through `lmtest::coeftest`, each its
  own call; `plm::vcovG` named as the family's parent (`?vcovG`). Then
  `se_table()` from `R/` to set the nine estimators of CM Ex. 5.4 side by
  side, after every call has been shown.
- **Run it.** Produc within: five `coeftest` calls, then the table. House
  prices within: the same. Grunfeld within: the table only, read as the
  N = 10 cautionary case.
- **Picture.** Dot-and-whisker of the income elasticity (house prices)
  and `log(emp)` (Produc) under the nine covariance estimators: the band
  grows 3–5× from classical to double clustering with lags.
- **Read it.** Produc: Arellano 0.082, SCC 0.083, double clustering 0.095
  on `log(emp)` against 0.030 classical. House prices: 0.0887, 0.109,
  0.113, 0.148 against 0.0268. *So:* serial correlation inside a state is
  the main cost; cross-sectional correlation adds a third on top; the
  classical t statistics were three to five times too large. Petersen's
  reading (CM p. 119): Vcx ≈ Vcxt means the time clustering adds little,
  Vct.L > Vct means cross-serial correlation is there. Grunfeld: with ten
  clusters the Arellano SEs are themselves noisy, and the kernel estimators
  on T = 20 sit at Driscoll–Kraay's practical minimum (CM p. 116). Misleads:
  Newey–West on house prices, 0.043, the smallest robust number, because
  the kernel downweights the persistent part (Petersen 2009, CM p. 121).
- **Next.** Summary ([summary](index.qmd#sec-core-summary)); for a panel
  whose residuals look like a random walk, chapter 06's dynamic models.
- **Pitfalls.** Driscoll–Kraay needs T > 20–25 (CM p. 116); at T = 17 or
  20 the "T → ∞" caveat binds (B p. 394, already cited in chapter 03's
  limits); Newey–West is biased under persistent effects; clustering by
  group with time fixed effects and the reverse is inappropriate (CM p.
  121); `vcovBK` defaults to `cluster = "group"`; Bester–Conley–Hansen not
  implemented; `cortab` supports its precondition only (spec 4a.4).
- **Book check.** CM Ex. 5.3, pp. 117–118: `coeftest(plmmod, vcovSCC)` SEs
  0.15035, 0.03697, 0.00764, 0.03870, 0.00254 reproduced (0.1503, 0.0370,
  0.0076, 0.0387, 0.0025). CM Ex. 5.4, p. 119: the nine-row table on pooled
  Produc reproduced to four decimals in all 45 cells (OLS 0.0576 … Vcxt.L
  0.2722). CM Ex. 5.5, p. 122: the within table reproduced in all 36 cells
  (0.0290 … 0.0717); CM call it the random-effects table but `plm(fm,
  Produc)` is the within fit and the coefficients printed (−0.0261,
  0.2920, 0.7682, −0.0053) are within's. `vcovDC` equals Vcx + Vct − Vw in
  every cell.
- **Theory.** [The error of a panel regression](theory-panel-error.qmd).

### Step 8, `8-summary.qmd`: "Summary" `{#sec-core-summary}`

- The chapter's findings per panel in one table: poolability, slopes,
  effects, FE or RE, serial correlation, FE or FD, heteroskedasticity, the
  SE to report. Grunfeld: one-way FE or RE both admissible, FE with
  Arellano errors; house prices: two-way FE, errors near a random walk,
  Driscoll–Kraay or double clustering, and the dynamic chapter next.
- The decision list as numbered points, each line a step anchor.
- **Next.** Chapter 06 (dynamic panels) for the random-walk errors; back to
  chapter 03's fixed-effects step for the GM-versus-ML choice; chapter 04's
  cointegration step once it exists.
- No Book check; a Recipe box with the chapter's calls in order.

### Theory notes

- **`theory-fixed-random.qmd`, "Fixed and random effects".** What the
  one-way error-component model assumes (B eqs. 2.1–2.3), the within and
  between transformations as projections, GLS as a matrix-weighted average
  of within and between (B eq. 2.31; CM sec. 2.4.1), the θ quasi-demeaning
  and the variance-component estimators (Swamy–Arora, Wallace–Hussain,
  Amemiya, Nerlove, Wansbeek–Kapteyn; why they differ in the two-way case
  with a negative component), Mundlak's result that GLS on the augmented
  model is within (CM sec. 4.2.1), the Hausman contrast and its three
  equivalent forms (B eqs. 4.40–4.48), Chamberlain's Π matrix and the
  Angrist–Newey sum of R² (B eqs. 4.50–4.53; CM sec. 4.2.3), the two-way
  Hausman and Kang's five hypotheses (B p. 99), Hausman–Taylor's
  instrument set and order condition (B sec. 7.4; CM sec. 6.3.2.3), random
  coefficients and Swamy's dispersion (CM sec. 8.2.2), the poolability F
  under spherical and under error-component disturbances (B eqs. 4.8,
  4.14). Literature: @baltagi2021 (chs. 2, 4, 7), @croissant2019 (chs. 2,
  4, 6, 8), @hausman1978, @mundlak1978, @chamberlain1982, @angrist1991,
  @arellano1993, @hausman1981, @amemiya1986, @breusch1989, @cornwell1988,
  @kang1985, @swamy1970, @swamy1972 if added, @wansbeek1989, @chow1960,
  @roy1957, @zellner1962, @baltagi1981, @breusch1980, @honda1985,
  @honda1991, @moulton1989, @king1997, @gourieroux1982, @baltagi1992,
  @pesaran2008, @blomquist2013.
- **`theory-panel-error.qmd`, "The error of a panel regression".** The
  composite error and its covariance (B eq. 5.32 and the AR(1) and MA(1)
  V matrices, secs. 5.2.1–5.2.5), why a unit effect is "serial correlation
  that does not die out" and why the within transformation induces
  −1/(T − 1) (CM p. 101), the Baltagi–Li LM family and the decomposition
  LM*_μ + LM_ρ = LM*_ρ + LM_μ = LM₁ (B p. 128), the BSY local
  robustness idea, LM₅ on within residuals (B eq. 5.43), the BFN
  Durbin–Watson and Baltagi–Wu LBI, Wooldridge's within and FD regressions
  and the FE-or-FD rule, heteroskedastic error components (B sec. 5.1,
  Mazodier–Trognon, the Verbon and Lejeune tests), the sandwich principle
  and the vcovG building blocks with CM Table 5.1 (Vwh, Vcx, Vct, lags,
  kernels), the asymptotics each needs (N for group clustering, T for time
  clustering and Driscoll–Kraay, both for double clustering), FGLS and
  FEGLS with the rank-(T − 1) caveat (CM p. 131), PCSE. Literature:
  @baltagi2021 (ch. 5, p. 394), @croissant2019 (chs. 4, 5), @millo2017,
  @white1980, @arellano1987, @newey1987, @driscoll1998, @beck1995,
  @cameron2011, @thompson2011, @petersen2009, @liang1986 if added,
  @kiefer1980, @parks1967, @wooldridge2010, @baltagi1991, @baltagi1995,
  @bera2001, @bhargava1982, @baltagi1999, @drukker2003, @inoue2006,
  @verbon1980, @lejeune2006, @moulton1986 if added.

### Spec coverage

| Spec | Step | Status |
|---|---|---|
| 3.1 Chow F, all / slopes / time | 1 | reproduced, B p. 80 |
| 3.1 Roy–Zellner | 1 | reproduced by hand, B p. 80; helper in `R/` |
| 3.1 Swamy random coefficients | 2 | reproduced, CM Ex. 8.2 |
| 3.1 `pooltest`, `summary.pvcm`, histogram on HPUS | 1, 2 | reproduced, CM Ex. 8.4, Fig. 8.1 |
| 3.2 Pesaran–Yamagata Δ, HAC Δ | 2 | limitation; Stata `xthst` deferred |
| 3.3 `vcovHC`, `pggls` on PROD | 6 | reproduced, CM Ex. 5.1, 5.13 |
| 3.3 Verbon, Lejeune tests | 6 | limitation |
| 3.3 Arellano (1987) eq. 2.16 | 6 | reproduced (the default `vcovHC`) |
| 3.4 BSY family, B Table 5.3 | 5 | reproduced except LM(λ=0) |
| 3.4 Baltagi–Li, BFN, Baltagi–Wu, Wooldridge, BG, DW | 5 | run on GRUN, PROD, HPUS, EMPL |
| 3.4 LM₅ (eq. 5.43) | 5 | not literally implemented; `pbnftest` nearest (spec) |
| 3.4 Inoue–Solon | 5 | not applicable, stated |
| 3.4 `pwfdtest` FE-vs-FD rule | 5 | reproduced in part, CM Ex. 4.8 |
| 4a.1 BP, Honda, KW, GHM, F; B Table 4.3 | 3 | reproduced, B Tables 4.2, 4.3 |
| 4a.1 SLM, conditional LM | 3 | limitation |
| 4a.2 Hausman chisq / aux / robust | 4 | reproduced; robust F not reproduced |
| 4a.2 two-way Hausman 8.842 | 4 | not reproduced (no WK method); stated |
| 4a.2 Kang's five hypotheses | 4 | limitation |
| 4a.2 Chamberlain, Angrist–Newey | 4 | reproduced on RiceFarms (CM); fail on GRUN |
| 4a.2 Hausman–Taylor on WAGE | 4 | reproduced, B Table 7.6 |
| 4a.4 vcovSCC, BK, NW, DC, HC; Millo 2017 | 7 | reproduced, CM Ex. 5.3–5.5 |
| 4a.4 side-by-side table | 7 | `se_table()` |
| 4a.4 Bester–Conley–Hansen | 7 | limitation |

### Bibliography entries to add

Keys not in `references.bib` (checked with `grep -o '^@[a-z]*{[^,]*'`).
Details copied from the reference lists; "B p." is Baltagi's printed page,
"CM p." Croissant & Millo's, PDF index in brackets. The tooling agent adds
DOIs from the publisher's page.

- `hausman1978`: Hausman, J.A. 1978. Specification tests in econometrics.
  *Econometrica* 46: 1251–1271. B p. 107 [125]; CM p. 291 [310].
- `honda1985`: Honda, Y. 1985. Testing the error components model with
  non-normal disturbances. *Review of Economic Studies* 52: 681–690. B p.
  107 [125]; CM p. 291 [310].
- `honda1991`: Honda, Y. 1991. A standardized test for the error components
  model with the two-way layout. *Economics Letters* 37: 125–128. B p. 107
  [125].
- `moulton1989`: Moulton, B.R., and W.C. Randolph. 1989. Alternative tests
  of the error components model. *Econometrica* 57: 685–693. B p. 108
  [126].
- `king1997`: King, M.L., and P.X. Wu. 1997. Locally optimal one-sided
  tests for multiparameter hypotheses. *Econometric Reviews* 16: 131–156.
  B p. 107 [125]. CM p. 293 print "33: 523–529", which is wrong; use B.
- `gourieroux1982`: Gourieroux, C., A. Holly, and A. Monfort. 1982.
  Likelihood ratio test, Wald test, and Kuhn–Tucker test in linear models
  with inequality constraints on the regression parameters. *Econometrica*
  50: 63–80. B p. 107 [125]; CM p. 290 [309].
- `baltagi1992`: Baltagi, B.H., Y.J. Chang, and Q. Li. 1992. Monte Carlo
  results on several new and existing tests for the error component model.
  *Journal of Econometrics* 54: 95–120. B p. 106 [124].
- `mundlak1978`: Mundlak, Y. 1978. On the pooling of time series and
  cross-section data. *Econometrica* 46: 69–85. B p. 46 [64]; CM p. 294
  [313].
- `arellano1993`: Arellano, M. 1993. On the testing of correlated effects
  with panel data. *Journal of Econometrics* 59: 87–97. B p. 106 [124].
- `chamberlain1982`: Chamberlain, G. 1982. Multivariate regression models
  for panel data. *Journal of Econometrics* 18: 5–46. B p. 107 [125]; CM
  p. 288 [307].
- `angrist1991`: Angrist, J.D., and W.K. Newey. 1991. Over-identification
  tests in earnings functions with fixed effects. *Journal of Business and
  Economic Statistics* 9(3): 317–323. B p. 106 [124]; CM p. 286 [305].
- `hausman1981`: Hausman, J.A., and W.E. Taylor. 1981. Panel data and
  unobservable individual effects. *Econometrica* 49: 1377–1398. B p. 107
  [125]; CM p. 291 [310].
- `cornwell1988`: Cornwell, C., and P. Rupert. 1988. Efficient estimation
  with panel data: An empirical comparison of instrumental variables
  estimators. *Journal of Applied Econometrics* 3: 149–155. B p. 107
  [125]; CM p. 288 [307].
- `amemiya1986`: Amemiya, T., and T.E. MaCurdy. 1986. Instrumental-variable
  estimation of an error components model. *Econometrica* 54: 869–881. B
  p. 183 [201].
- `breusch1989`: Breusch, T.S., G.E. Mizon, and P. Schmidt. 1989. Efficient
  estimation using panel data. *Econometrica* 57: 695–700. B p. 183 [201].
- `wooldridge2010`: Wooldridge, J.M. 2010. *Econometric Analysis of
  Cross-Section and Panel Data*, 2nd ed. Cambridge, MA: MIT Press. B p. 147
  [165]; CM p. 296 [315].
- `baltagi1991`: Baltagi, B.H., and Q. Li. 1991. A joint test for serial
  correlation and random individual effects. *Statistics and Probability
  Letters* 11: 277–280. CM p. 288 [307]; B p. 145 [163].
- `baltagi1995`: Baltagi, B.H., and Q. Li. 1995. Testing AR(1) against
  MA(1) disturbances in an error component model. *Journal of
  Econometrics* 68: 133–151. B p. 145 [163]; CM p. 288 [307].
- `bera2001`: Bera, A.K., W. Sosa-Escudero, and M. Yoon. 2001. Tests for
  the error component model in the presence of local misspecification.
  *Journal of Econometrics* 101: 1–23. B p. 145 [163].
- `bhargava1982`: Bhargava, A., L. Franzini, and W. Narendranathan. 1982.
  Serial correlation and the fixed effects model. *Review of Economic
  Studies* 49: 533–549. B p. 145 [163]; CM p. 287 [306] prints 533–554.
- `baltagi1999`: Baltagi, B.H., and P.X. Wu. 1999. Unequally spaced panel
  data regressions with AR(1) disturbances. *Econometric Theory* 15:
  814–823. B p. 145 [163].
- `driscoll1998`: Driscoll, J.C., and A.C. Kraay. 1998. Consistent
  covariance matrix estimation with spatially dependent panel data. *Review
  of Economics and Statistics* 80(4): 549–560. B p. 416 [434]; CM p. 289
  [308].
- `beck1995`: Beck, N., and J.N. Katz. 1995. What to do (and not to do)
  with time-series cross-section data. *American Political Science Review*
  89(3): 634–647. B p. 145 [163]; CM p. 289 [308].
- `swamy1970`: Swamy, P.A.V.B. 1970. Efficient inference in a random
  coefficient regression model. *Econometrica* 38: 311–323. B p. 108 [126];
  CM p. 296 [315].
- `pesaran2008`: Pesaran, M.H., and T. Yamagata. 2008. Testing slope
  homogeneity in large panels. *Journal of Econometrics* 142: 50–93. B p.
  108 [126].
- `blomquist2013`: Blomquist, J., and J. Westerlund. 2013. Testing slope
  homogeneity in large panels with serial correlation. *Economics Letters*
  121(3): 374–378. Not in either book; verify at the publisher.
- `bersvendsen2021`: Bersvendsen, T., and J. Ditzen. 2021. Testing for
  slope heterogeneity in Stata. *The Stata Journal* 21(1): 51–80. Not in
  either book; verify at the publisher.
- `kang1985`: Kang, S. 1985. A note on the equivalence of specification
  tests in the two-factor multivariate variance components model. *Journal
  of Econometrics* 28: 193–203. B p. 107 [125].
- `arellano1987`: Arellano, M. 1987. Computing robust standard errors for
  within-groups estimators. *Oxford Bulletin of Economics and Statistics*
  49(4): 431–434. B p. 44 [62]; CM p. 286 [305].
- `white1980`: White, H. 1980. A heteroskedasticity-consistent covariance
  matrix estimator and a direct test for heteroskedasticity. *Econometrica*
  48(4): 817–838. B p. 46 [64]; CM p. 296 [315].
- `roy1957`: Roy, S.N. 1957. *Some Aspects of Multivariate Analysis*. New
  York: Wiley. B p. 108 [126].
- `zellner1962`: Zellner, A. 1962. An efficient method of estimating
  seemingly unrelated regressions and tests for aggregation bias. *Journal
  of the American Statistical Association* 57: 348–368. B p. 46 [64]. CM p.
  297 [316] print 500–509, which is Parks' page range; use B.
- `chow1960`: Chow, G.C. 1960. Tests of equality between sets of
  coefficients in two linear regressions. *Econometrica* 28: 591–605. B p.
  107 [125].
- `wansbeek1989`: Wansbeek, T.J., and A. Kapteyn. 1989. Estimation of the
  error components model with incomplete panels. *Journal of Econometrics*
  41: 341–361. B p. 46 [64].
- `verbon1980`: Verbon, H.A.A. 1980. Testing for heteroscedasticity in a
  model of seemingly unrelated regression equations with variance
  components (SUREVC). *Economics Letters* 5: 149–153. B p. 147 [165].
- `lejeune2006`: Lejeune, B. 2006. A full heteroscedastic one-way error
  components model: Pseudo maximum likelihood estimation and specification
  testing. In *Panel Data Econometrics: Theoretical Contributions and
  Empirical Applications*, ed. B.H. Baltagi, 31–66. Amsterdam: Elsevier. B
  p. 146 [164].
- `inoue2006`: Inoue, A., and G. Solon. 2006. A portmanteau test for
  serially correlated errors in fixed effects models. *Econometric Theory*
  22: 835–851. B p. 146 [164].
- `newey1987`: Newey, W.K., and K.D. West. 1987. A simple, positive
  semi-definite, heteroskedasticity and autocorrelation consistent
  covariance matrix. *Econometrica* 55(3): 703–708. CM p. 294 [313].
- `cameron2011`: Cameron, A.C., J.B. Gelbach, and D.L. Miller. 2011. Robust
  inference with multiway clustering. *Journal of Business & Economic
  Statistics* 29(2): 238–249. CM p. 290 [309] gives no pages; verify.
- `thompson2011`: Thompson, S.B. 2011. Simple formulas for standard errors
  that cluster by both firm and time. *Journal of Financial Economics*
  99(1): 1–10. CM p. 296 [315].
- `petersen2009`: Petersen, M.A. 2009. Estimating standard errors in
  finance panel data sets: Comparing approaches. *Review of Financial
  Studies* 22(1): 435–480. CM p. 295 [314].
- `kiefer1980`: Kiefer, N.M. 1980. Estimation of fixed effect models for
  time series of cross-sections with arbitrary intertemporal covariance.
  *Journal of Econometrics* 14(2): 195–202. CM p. 293 [312].
- `parks1967`: Parks, R.W. 1967. Efficient estimation of a system of
  regression equations when disturbances are both serially and
  contemporaneously correlated. *Journal of the American Statistical
  Association* 62(318): 500–509. CM p. 295 [314].
- `drukker2003`: Drukker, D.M. 2003. Testing for serial correlation in
  linear panel-data models. *The Stata Journal* 3(2): 168–177. CM p. 290
  [309].
- `baltagi1981`: Baltagi, B.H. 1981. Pooling: An experimental study of
  alternative testing and estimation procedures in a two-way error
  components model. *Journal of Econometrics* 17: 21–49. B p. 44 [62].
- Optional, if the theory notes use them: `swamy1972` (Swamy and Arora
  1972, *Econometrica* 40: 261–275, B p. 46 [64]); `liang1986` (Liang and
  Zeger 1986, *Biometrika* 73(1): 13–22, CM p. 294 [313]); `moulton1986`
  (Moulton 1986, *Journal of Econometrics* 32(3): 385–397, CM p. 294
  [313]); `baltagi1990` (Baltagi and Khanti-Akom 1990, the Cornwell–Rupert
  replication, B p. 183 [201], details to copy).

Already present and reused: `baltagi2021`, `croissant2019`, `millo2017`,
`breusch1980`, `lin2010`, `munnell1990`, `pesaran2015`, `arellano1991`,
`holly2010`, `grunfeld1958`, `croissant2008`.

### Tooling

- `R/poolability.R`: `roy_zellner(formula, data, effect = "individual")`.
  Fits the one-way RE model, takes θ from `plm::ercomp`, transforms y and
  X by `Within + (1 − θ) Between` (intercept 1 − θ), then runs the Chow F
  across units on the transformed data; returns an `htest` with F, df
  (N − 1)K′, N(T − K′) and the p-value. Balanced panels only; errors
  otherwise with `cli::cli_abort()`. Verified: 4.3466 on Grunfeld against
  B p. 80's 4.35.
- `R/robust-se.R`: `vcov_menu()` returns the named list of nine covariance
  functions of CM Ex. 5.4 (OLS, Vw, Vcx, Vct, Vcxt, Vct.L, Vnw.L, Vscc.L,
  Vcxt.L) built from `plm::vcovHC`, `plm::vcovSCC`, `plm::vcovNW`, so
  both chapters 05 and 03 can call them; `se_table(fit, menu = vcov_menu(),
  ratio = FALSE)` returns the matrix of standard errors (rows: estimators;
  columns: coefficients), or the ratio to the first row. Verified cell by
  cell against CM pp. 119 and 122. This is plumbing: every `coeftest` call
  is still shown in the open first.
- No helper for the effects table: the ten `plmtest` calls are written out;
  the Book check assembles their stored results with `cbind` into B Table
  4.2's layout.
- Setup: `library(plm)` attached for `pooltest` (comment in the chunk);
  `nlme` (base R) for CM Ex. 4.5; `lmtest` already in renv. No package to
  install; `renv::snapshot()` after the chapter if the lockfile moves.

## Steps

Each step ends in its own commit.

- [ ] **Tooling.** `R/poolability.R`, `R/robust-se.R` with roxygen;
  `references.bib` entries above; `renv::snapshot()` if needed.
- [ ] **Chapter page.** `index.qmd` from `.docs/_templates/chapter.qmd`.
- [ ] **Step 1, poolability.**
- [ ] **Step 2, slope heterogeneity.**
- [ ] **Step 3, effects tests.**
- [ ] **Step 4, fixed or random.**
- [ ] **Step 5, serial correlation.**
- [ ] **Step 6, heteroskedasticity.**
- [ ] **Step 7, robust errors.**
- [ ] **Step 8, summary.**
- [ ] **Theory notes.** `theory-fixed-random.qmd`, `theory-panel-error.qmd`;
  both listed in `_quarto.yml` under `project: render:` and the Theory
  sidebar group.
- [ ] **Links.** Retarget the six inbound links to the anchors in the table
  above; drop "still to come" in the road map; tick the checklist in
  `index.qmd`.
- [ ] **Render and check.** `quarto render` from a clean `_freeze/` for the
  chapter; every Book check number read against its page; plan closed.

## Open questions

Decided on 2026-10-06, before the tooling step:

- Two-way Hausman: show plm's four `random.method` values beside Baltagi's
  8.842 and say why none matches (no Wansbeek–Kapteyn in plm). No helper;
  no other number depends on it.
- Heteroskedasticity: the picture (squared within residuals against unit
  size) plus `lmtest::bptest` on an `lm` of the within-transformed data,
  labelled as a substitute that is not a panel test, with Verbon (1980) and
  Lejeune (2006) named as the tests that are not implemented.
- CM Ex. 4.8's `pwfdtest(h0 = "fd")` 0.93 against plm 2.6.7's 1.53: the
  tooling agent reads `news(package = "plm")` for `pwfdtest` and records
  what it finds in the What runs table; the Book check reports both values
  either way.
- `piest` and `aneweytest` run on `Wages` (N = 595, T = 7) as the chapter's
  own large-N case; the RiceFarms numbers stay in the Book check only.

## Outcome

Filled in when the status becomes done or superseded.
