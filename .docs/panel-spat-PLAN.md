# Panel Data Diagnostic Decision Tree — v5 (Implementation Specification)

**Purpose.** This document is a specification, not a tutorial. It contains **no R code**. For every test, estimator and decision in the tree it gives four things:

1. **THEORY** — what the procedure is and where it is derived.
2. **DATA** — the canonical dataset the literature demonstrates it on.
3. **CODE REF** — where to find a worked, authoritative code example.
4. **VERIFY** — a published numerical result the implementation must reproduce.

An agent implementing any element should be able to write the code from the CODE REF, run it on the DATA, and check the output against VERIFY before proceeding. Where VERIFY is empty, the element **cannot be self-validated** and must be flagged as unverified in any downstream use.

**Anchors**: **[B]** Baltagi (2021) 6th ed. · **[P]** Pesaran (2015) Part VI · **[CM]** Croissant & Millo (2019) · **[MP]** Millo & Piras (2012), *JSS* 47(1) · **[src]** package source.

---

## §1 — Global resources

### 1.1 Canonical datasets

| Tag | Dataset | Dimensions | Ships in | Canonical for |
|---|---|---|---|---|
| **GRUN** | Grunfeld investment (1958) | 10–11 firms × 20 yrs (1935–54) | `plm::Grunfeld` | Pooling, within/between, BP-LM, Hausman, SUR, poolability |
| **PROD** | Munnell (1990) US state productivity | 48 states × 17 yrs (1970–86) | `plm::Produc` + `splm::usaww` | **The** spatial panel benchmark; also FGLS, robust vcov, GMM |
| **EMPL** | Arellano & Bond (1991) UK employment | 140 firms × 1976–84, unbalanced | `plm::EmplUK` | Dynamic panel GMM, Sargan, AR(2), Windmeijer |
| **CIG** | Baltagi & Levin cigarette demand | 46 states × 1963–92 | `plm::Cigar` | Dynamic demand, spatial panels, BLUP forecasting |
| **GAS** | Baltagi & Griffin gasoline demand | 18 OECD × 1960–78 | `plm::Gasoline` | Poolability, heterogeneity, cointegration |
| **WAGE** | Cornwell & Rupert PSID wages | 595 individuals × 7 yrs (1976–82) | `plm::Wages` | Hausman–Taylor, time-invariant regressors |
| **CRIME** | Cornwell & Trumbull | 90 NC counties × 1981–87 | `plm::Crime` | Panel IV, EC2SLS |
| **MALES** | Vella & Verbeek NLSY | 545 young males × 1980–87 | `plm::Males` | Limited dependent variables |
| **RICE** | Indonesian rice farms | ~171 farms × 6 periods | `splm::RiceFarms` + `riceww` | **[CM] Ch. 10** running example for all splm functions |
| **INS** | Millo & Carmeci Italian insurance | 103 provinces × 1998–2002 | `splm::Insurance` + `itaww` | Spatial RE, serial + spatial correlation |
| **HPUS** | Holly, Pesaran & Yamagata US house prices | 49 states × ~1975–2003 | `pder::HousePricesUS` + `pder::usaw49` | **CCE, and the factor-vs-spatial discrimination** |
| **PWT** | Penn World Table / Summers–Heston | varies | `plm::SumHes` | Panel unit roots, growth convergence |

> **Selection rule for an agent.** Use **GRUN** for anything in Stages 3–4a on a small balanced panel. Use **PROD + usaww** for everything spatial — it is the only dataset for which almost every splm function has a published reference output. Use **EMPL** for Stage 4b. Use **HPUS** for Stage 0's α routing and for the CCE branch. Use **RICE** when following **[CM]** Chapter 10 step by step.

> **⚠ Dimensional warning.** None of these has the target N/T ratio (~8.5). PROD is 48/17 ≈ 2.8; HPUS is 49/29 ≈ 1.7; RICE has T = 6. Diagnostics will behave *better* on the canonical data than on a 170 × 20 panel. Successful replication validates the **code**, not the **method at the target dimensions**. Method validation at N/T ≈ 8.5 requires simulation.

### 1.2 Where authoritative code examples live

| Source | Coverage | Access |
|---|---|---|
| **Package help pages** — `?funcname` | Every exported function; examples are run on every CRAN check, so they are guaranteed to execute | `example(funcname)` |
| **plm vignettes** — `A_plmPackage`, `B_plmFunction`, `C_plmModelComponents` | Full workflow, estimator internals, model components | `vignette(package="plm")` |
| **[CM] Croissant & Millo (2019)** | Every plm/splm function with narrative; companion package `pder` | Book + `pder` datasets |
| **[MP] Millo & Piras (2012), JSS 47(1)** | All of splm on PROD, with printed output | Open access, with replication script |
| **Croissant & Millo (2008), JSS 27(2)** | Original plm paper | Open access |
| **plm GitHub `tests/`** | Regression tests with saved expected output (`.Rout.save`) | `github.com/ycroissant/plm` |
| **plm GitHub `R/`** | Source. Definitive when help pages are ambiguous | `github.com/ycroissant/plm` |

> **⚠ Argument-name reliability.** Help pages and source are authoritative. **[CM]** predates current package versions and is *not* reliable for argument names in `spgm` (which gained `Durbin`, `endog`, `instruments`, `method`) or for `impacts()`. Always reconcile against `args()` in the installed version.

### 1.3 Where verified numerical targets live

| Source | What it gives |
|---|---|
| **plm `?pgmm` / `?mtest` examples** | Explicitly annotated to reproduce Arellano–Bond (1991) Table 4 col. b and Windmeijer (2005) Table 2 |
| **[B] worked examples** | Numbered outputs at specific pages — see per-step VERIFY entries below |
| **[P] Table 30.2, p. 807** | Eight spatial estimators on liquor demand with SEs and forecast RMSEs |
| **[CM] Ch. 8 and 10** | Printed output for cipstest, pcdtest, rwtest, spml, spgm, bsktest, bsjktest, sphtest, spreml |
| **[MP] JSS 47(1)** | Printed output for all splm estimators on PROD |
| **plm `tests/*.Rout.save`** | Byte-level expected output; the strongest verification available |

---

## §2 — Stage specifications

---

### STAGE 0 — Panel shape and the dependence fork

#### 0.1 Panel dimensions, balance, variation
- **THEORY** — Micro vs macro framing **[B p. 1, §1.1]**, **[B p. 337, §12.1]**. Unbalanced panels **[B Ch. 9, pp. 229–255]**, **[P §26.12, p. 671]**. Regime map: with N > 100 and T < 50, analysis is tractable only under dynamic homogeneity and/or local (spatial) dependence **[P p. 817]** — the strongest single justification for the spatial specification.
- **DATA** — GRUN (balanced), EMPL (unbalanced).
- **CODE REF** — `?pdim`, `?punbalancedness`, `?pvar`, `?is.pconsecutive`; **[CM §1.6, §3.1]**; plm vignette `C_plmModelComponents`.
- **VERIFY** — `pdim(Grunfeld)` must report 10 firms × 20 years, 200 obs, balanced. Unbalancedness measures on EMPL appear in `?punbalancedness`.

#### 0.2 Exponent of cross-sectional dependence, α — **the routing decision**
- **THEORY** — Definition 29 and Proposition 46 **[P p. 753]**; exponent α, eq. (29.6) **[P p. 754]**, identified on 1/2 < α ≤ 1. **CWD ⟺ α < 1; CSD ⟺ α = 1.** Spatial processes generate *weak* dependence **[P §30.3.3, pp. 801–802]**; common factors generate *strong* dependence **[P p. 754]**. Bailey, Kapetanios & Pesaran (2016), *J. Applied Econometrics*.
- **DATA** — HPUS. **[CM §10.1]** runs the factor-vs-spatial question on exactly this data.
- **CODE REF** — ✖ **No R implementation exists.** Closest published reference: the BKP paper's own Gauss/MATLAB code. The eigenvalue criterion of Proposition 46 is directly codeable from the proposition.
- **VERIFY** — ✖ **No verification target.** BKP report α estimates for US macro series and stock returns in their paper; those are the only available benchmarks and they use data not shipped in R. **Flag any α estimate as unvalidated.**
- **AGENT NOTE** — Because this cannot be verified, do not let it be the sole basis for the weak/strong routing. Corroborate with the `rwtest` vs `pcdtest` contrast at §5.7, which *can* be verified.

#### 0.3 The strong-dependence branch: CCE
- **THEORY** — Pesaran (2006) CCE; **[P §29.4, pp. 763–772]**, CCEP at **[P p. 766]**. Holly, Pesaran & Yamagata (2010) for the panel application. CCEP variance: **[CM §8.3.2.2]**.
- **DATA** — HPUS.
- **CODE REF** — `?pcce`, `?pmg`; **[CM §8.3.2]**. Source note: CCEMG from `pcce` equals `pmg(model="cmg")`, but CCEP is only available through `pcce(model="p")` **[CM §8.3.2.1]**.
- **VERIFY** — **[CM §8.3.2]** prints CCEMG and CCEP coefficients for log(price) ~ log(income) on HPUS. Reproduce those two coefficient tables.

---

### STAGE 1 — Panel unit roots

#### 1.1 State the alternative first
- **THEORY** — Taxonomy H₁ₐ / H₁b / H₁c **[P §31.2, pp. 818–820, eqs. 31.4–31.6]**. Remark 8 **[P p. 820]**: at T ≈ 15 results are informative only "in an average sense". This is a write-up constraint, not a computational one.
- **VERIFY** — n/a (taxonomy, not a statistic).

#### 1.2 First-generation tests
- **THEORY** — LLC **[B §12.2.1, pp. 340–343]** · Harris–Tzavalis **[B p. 343, eq. 12.5]** · IPS **[B §12.2.2, pp. 344–345, eqs. 12.6–12.10]** · Breitung **[B §12.2.3, pp. 345–346]** · Fisher/Maddala–Wu/Choi **[B §12.2.4, pp. 346–348, eq. 12.11]** · Hadri **[B §12.2.5, pp. 348–349]**. Comparative evidence: LLC local power exceeds IPS **[P p. 819]**; LLC and Breitung have smallest size distortions **[P p. 838]**; Fisher ≈ or better than IPS **[P p. 838]**, matching **[B p. 348]**.
- **DATA** — GRUN (the help page uses it), PWT for a macro application.
- **CODE REF** — `?purtest`. **Two interfaces with incompatible conventions**: formula (`y ~ 0` / `y ~ 1` / `y ~ trend`, `exo` ignored) vs pseries/matrix (`exo` used). **[CM §8.4.2]**.
- **VERIFY** — `?purtest` examples run LLC/IPS/Maddala–Wu on Grunfeld investment via three interfaces and the results must agree across them; this is a strong internal consistency check. **[CM §8.4.2]** prints LLC, Maddala–Wu and IPS on HPUS log(price) with `lags=2, exo="trend"`.
- **✖ GAPS** — **Breitung and Harris–Tzavalis are not in `purtest`.** No verified R implementation. If Breitung is load-bearing, the reference is Breitung (2000) in *Advances in Econometrics* 15; Stata's `xtunitroot breitung` is the benchmark.
- **⚠ CONSTRAINTS from [src]** — LLC, Hadri, and IPS `tbar` require **balanced** panels; `tbar` is unavailable with `lags > 0` and returns interpolated critical values rather than a p-value. Install `urca` for MacKinnon (1996) p-values.

#### 1.3 Second-generation tests
- **THEORY** — CADF/CIPS, Pesaran (2007); **[B pp. 352–353]**. CIPS with multiple factors and the CSB statistic, Pesaran, Smith & Yamagata (2013), **[P p. 836]**. Moon–Perron **[B pp. 350–351]**; Bai–Ng **[B p. 352]**, **[P p. 837]**; Phillips–Sul **[B pp. 351–352]**.
- **DATA** — HPUS.
- **CODE REF** — `?cipstest`; **[CM §8.4.3]**. Takes a **pseries only**, not a formula.
- **VERIFY** — **[CM §8.4.3]** reports CIPS ≈ −2 with p ≈ 0.1 for log(price) with `type="drift"`, and ≈ −1.8 with p ≈ 0.01 for the differenced series with `type="none"`; also rejections for residuals of both CCEMG and CCEP models with `type="none"`. Four reproducible numbers.
- **✖ GAPS** — Moon–Perron, Bai–Ng, Phillips–Sul, CSB: none implemented, none verifiable.
- **⚠** No exact p-values; the distribution is non-standard and the nearest tabulated significance level is returned with a warning.

#### 1.4 Fraction of stationary series — closes Remark 8
- **THEORY** — Simes (1986); Hanck (2013) applied to panel unit roots; Hommel (1988) FWER control. Corresponds to **[P §31.3.6, p. 832]**, absent from Baltagi.
- **DATA** — any Fisher-type `purtest` object.
- **CODE REF** — `?phansitest`. Requires a test producing per-individual p-values (`madwu`, `Pm`, `invnormal`, `logit`, `ips`); explicitly refuses Hadri-based objects.
- **VERIFY** — `?phansitest` examples.

#### 1.5 Spatial size distortion in Stage 1
- **THEORY** — Baltagi, Bresson & Pirotte (2007), 1600 experiments; largest distortions under SAR, sensitive to W sparseness **[B pp. 353–354]**, **[B p. 411, §13.5]**. Pesaran's CD-based test is most robust to spatial alternatives **[P p. 839]**. Factor methods are **invalid** under weak dependence **[P p. 839]**.
- **VERIFY** — ✖ No canned target. The BBP paper's own size tables are the reference; reproducing them requires a Monte Carlo.
- **AGENT NOTE** — This is a simulation task, not a function call. The deliverable is an empirical size table for the project's own W, compared against nominal 5%.

#### 1.6 Cross-unit cointegration
- **THEORY** — **[P §31.5, pp. 836–838]**. Tests may be "severely biased" under cross-cointegration, distinct from mere cross-correlation **[P p. 836]**. Moon–Perron and Pesaran (2007) rule it out **[P p. 837]**; Bai–Ng (2004) allows it but Westerlund & Larsson (2009) show the pooled version is asymptotically invalid; Bai & Ng (2010) give an alternative. Choi & Chue (2007) subsampling handles it but needs N small relative to T **[P p. 838]** — unavailable at N ≈ 170.
- **✖ GAPS** — No R implementation, no verification target. Must be handled as a stated limitation.

---

### STAGE 2 — Cointegration

> **⚠ STATUS: this stage is essentially unimplemented in R.** `plm` contains no cointegration functionality. Budget accordingly.

#### 2.1 Structural precondition
- **THEORY** — **[P §31.7, pp. 839–840]**. Residual-based tests are valid **only when r_i = 1** with no cointegration among the regressors; system approaches allow r_i > 1. Baltagi's §12.5 does not state this precondition.
- **CODE REF** — Per-unit rank estimation via `urca::ca.jo`; `?ca.jo`, Pfaff (2008) *Analysis of Integrated and Cointegrated Time Series with R*.
- **VERIFY** — `urca` help pages replicate Johansen's Danish and Finnish money-demand examples.

#### 2.2 Residual-based tests
- **THEORY** — Kao (1999) **[B §12.5.1, pp. 357–358]** · McCoskey–Kao (1998) **[B §12.5.2, pp. 358–360]**, null = cointegration, and "not equipped to deal with cross-sectional dependence" **[B p. 359]** · Pedroni (2000, 2004) **[B §12.5.3, pp. 360–361]** · Larsson, Lyhagen & Löthgren (2001) **[B §12.5.4, pp. 361–362]**, severely size-distorted at small T · finite-sample evidence **[B §12.5.5, p. 362]**.
- **DATA** — Feldstein–Horioka savings–investment (OECD) is the classic application for Kao and Pedroni; PPP panels for Pedroni.
- **CODE REF** — `pco::pedroni99` (bivariate) and `pco::pedroni99m` (multivariate). **⚠** Requires array input `[time, individual, variable]`, complete and NA-free. `Westerlund` package for the ECM tests with bootstrap p-values robust to cross-sectional dependence — **verify its signature with `args()` before use; I have not read its source.**
- **VERIFY** — `?pedroni99m` gives the seven Pedroni statistics with standardized values for its own example. **Weak target**: it is a package example, not a published replication. Pedroni (1999) *OBES* 61 Table 2 contains the adjustment terms the implementation must use.
- **✖ GAPS** — Kao, McCoskey–Kao, Larsson: no implementation.

#### 2.3 Long-run estimation
- **THEORY** — FMOLS (Phillips–Moon 1999; Pedroni 2000) and DOLS (Kao–Chiang 2000) **[B §12.6, p. 364]** — **⚠ both maintain cross-sectional independence**. Breitung (2005) two-step **[P §31.10.2, p. 853]**, less biased in small samples; countered by Wagner & Hlouskova (2010), who favour DOLS.
- **THEORY (under CSD)** — DSUR eq. (31.57) **[P p. 854]**; Bai–Kao (2005) / Westerlund (2007) eq. (31.58); Bai, Kao & Ng (2009) eq. (31.59). **⚠ All three represent CSD as contemporaneous error correlation and exclude cross-unit cointegration [P p. 854].** Panel VECM eq. (31.60) allows it but is infeasible at large N.
- **✖ GAPS** — None implemented for panels. `cointReg` handles single-equation FMOLS/DOLS only.
- **PRAGMATIC SUBSTITUTE** — CCE-based cointegrating regression with a CIPS test on defactored residuals. **CODE REF / VERIFY**: **[CM §8.4.3]** does exactly this on HPUS and prints the results, concluding both CCEMG and CCEP represent cointegrating regressions. This is verifiable; label it as a substitute, not as Pedroni or FMOLS.

---

### STAGE 3 — Error structure

#### 3.1 Poolability, classical
- **THEORY** — Chow-type F under spherical errors **[B §4.1.1, p. 76]**; Roy–Zellner under u ~ N(0, Ω) **[B §4.1.2, p. 77]**. Swamy random coefficients.
- **DATA** — GRUN; HPUS in **[CM §8.2.3]**.
- **CODE REF** — `?pooltest`, `?pvcm`; **[CM §8.2.1–8.2.3]**.
- **VERIFY** — **[B p. 81]** gives a worked poolability example. **[CM §8.2.3]** prints `pooltest` results against both pooled and within restricted models on HPUS, plus the `summary.pvcm` coefficient-dispersion table and a histogram of individual slopes.

#### 3.2 Slope homogeneity, modern
- **THEORY** — Swamy's test eq. (28.78) **[P p. 738]**, valid for N fixed, T → ∞ — **not applicable at N = 170**. Pesaran–Yamagata Δ tests eq. (28.79) **[P pp. 738–739]**: Δ̂ requires √N/T → 0; Δ̃ requires only √N/T² → 0; Δ̂_adj / Δ̃_adj valid without restrictions on relative expansion rates. Original: Pesaran & Yamagata (2008), *J. Econometrics* 142, 50–93. HAC extension: Blomquist & Westerlund (2013), *Economics Letters*.
- **⚠ ASSUMPTIONS** — PY assume cross-sectionally and serially independent, homoskedastic errors and strictly exogenous regressors. Stage 3 will typically violate all three; this is why the HAC variant exists.
- **DATA** — PY (2008) use PSID earnings-dynamics data; Blomquist & Westerlund use their own.
- **CODE REF** — ✖ **Not in any R package.** Reference implementation: Stata `xthst` (Bersvendsen & Ditzen 2021, *Stata Journal* 21(1)) — the article documents the formulae and gives worked output. Pesaran & Yamagata's Gauss code accompanies the original paper.
- **VERIFY** — `xthst`'s *Stata Journal* article reports Δ and Δ_adj on a documented dataset; that is the benchmark. **An agent implementing this must run the same data through both and match to at least 3 significant figures, or declare it unverified.**

#### 3.3 Heteroskedasticity
- **THEORY** — **[B §5.1, pp. 109–115]**; consistent but inefficient, biased SEs **[B p. 109]**. Testing **[B §5.1.1, p. 113]** (Verbon 1980; Lejeune 2006). Robust: Arellano (1987) eq. (2.16) **[B p. 19]**. **[P §26.7, pp. 653–657]** for variances robust to heteroskedasticity *and* serial correlation.
- **DECISION WEIGHT** — This determines the Stage 5 estimator. Heteroskedastic → spatial ML is **inconsistent** **[P p. 807]** (Lin & Lee 2010) → route to IV/GMM.
- **DATA** — PROD, GRUN.
- **CODE REF** — `?vcovHC.plm`, `?pggls`; **[CM §5.1.1, §5.2]**; Millo (2017), *JSS* 82(3), "Robust standard error estimators for panel models: a unifying approach" — the definitive reference for which estimator is which.
- **VERIFY** — `?vcovHC` and `?pggls` examples on PROD. **[CM §5.2.2]** prints applied FGLS examples.
- **✖ GAPS** — Verbon and Lejeune tests not implemented; no verification target for formal heteroskedasticity testing in panels.

#### 3.4 Serial correlation
- **THEORY** — Processes AR(1)…MA(1) **[B §5.2.1–5.2.5, pp. 115–120]**. Baltagi–Li LM family **[B §5.2.7, pp. 124–136]**: LM₁ joint eq. (5.36) p. 126; LM₂ p. 126; **LM₃ p. 126 — do not use**, since testing serial correlation assuming no individual effects over-rejects **[B p. 127]**; LM₄ conditional/RE p. 127; **LM₅ eq. (5.43) p. 130**, conditional/FE on Within residuals, valid for both branches because "the Within transformation wipes out the individual effects whether fixed or random" **[B p. 130]**. Bera, Sosa-Escudero & Yoon (2001) robust LM **[B p. 128]**, with LM\*μ + LMρ = LM\*ρ + LMμ = LM₁. BFN panel Durbin–Watson eq. (5.44) **[B p. 130]**. Inoue–Solon (2006) **[B p. 131]** needs N ≫ T²/2 — **unavailable at N = 170, T = 20**. Wooldridge's within- and FD-based tests.
- **DATA** — GRUN, PROD, EMPL.
- **CODE REF** — `?pwtest` (Wooldridge unobserved effects), `?pbsytest` (BSY, `test = "ar"/"re"/"j"`), `?pbltest` (Baltagi–Li), `?pbnftest` (BFN Durbin–Watson and Baltagi–Wu LBI), `?pwartest`, `?pwfdtest`, `?pbgtest`, `?pdwtest`. **[CM §4.3]** covers all of them in order.
- **VERIFY** — **[B Table 5.3, p. 129]** gives Stata `xttest1` output for the BSY family — the target for `pbsytest`. Each plm help page carries an example. **[CM §4.3.1–4.3.5]** prints results for each test.
- **⚠** `pbnftest` is the closest available to LM₅ but is **not literally eq. (5.43)**. `pbgtest` / `pdwtest` treat panel residuals as one long series — corroboration only.
- **DECISION RULE** — `pwfdtest(h0="fd")` vs `h0="fe"` is the FE-vs-FD choice, **[CM §4.3.5]**.

---

### STAGE 4a — Static panel

#### 4a.1 Effects tests
- **THEORY** — Breusch–Pagan LM **[B §4.2.1, p. 81, eqs. 4.22–4.24]** · Honda (1985) UMP one-sided eq. (4.25) **[B p. 83]** · **SLM (Moulton–Randolph) eq. (4.26)**, needed when "the number of regressors is large or the intra-class correlation of some of the regressors is high" **[B p. 83]** — i.e. with spatially smooth regressors · King–Wu LMMP eq. (4.30) **[B p. 84]** · GHM mixed χ² eq. (4.33) **[B p. 84]**, immune to negative variance estimates · **conditional LM: LM_μ eq. (4.34), LM_λ eq. (4.36) [B p. 85]** — the correct family for a two-way specification · ANOVA F/LR eq. (4.38) **[B p. 85]**.
- **DATA** — GRUN.
- **CODE REF** — `?plmtest` (`type = "honda"/"bp"/"ghm"/"kw"`), `?pFtest`; **[CM §4.1]**.
- **VERIFY** — **[B Table 4.3, p. 89]** gives the full Grunfeld effects-test output. This is the single best verification target in Stage 4a: reproduce that table.
- **✖ GAPS** — **SLM (eq. 4.26) and the conditional LM tests (eqs. 4.34, 4.36) are not implemented.** No verification target. Since these are exactly what **[B]** recommends for the two-way case with correlated regressors, this gap should be stated explicitly in any write-up. Bootstrapping the Honda statistic is a defensible substitute but has no published benchmark.

#### 4a.2 Fixed vs random effects
- **THEORY** — Hausman (1978) **[B §4.3, pp. 89–94]**, augmented regression eq. (4.42) · **robust Hausman, Arellano (1993) eq. (4.49) [B p. 91]** · Chamberlain omnibus eq. (4.53) **[B p. 93]** · Angrist–Newey version · Mundlak (1978) · **two-way Hausman [B §4.3.7, p. 99]**, Kang (1985): one-way equivalences fail, two Between estimators, **five distinct testable hypotheses** · time-invariant regressors **[P §26.10, pp. 663–670]**, Case 1 p. 663 / Case 2 p. 665; Hausman–Taylor **[B §7.4, pp. 170–177]**.
- **DATA** — GRUN for Hausman; WAGE for Hausman–Taylor.
- **CODE REF** — `?phtest` (`method = "chisq"/"aux"`, with `vcov=` effective **only** under `"aux"`), `?piest`, `?aneweytest`, `?pht`; **[CM §4.2, §5.1.3.1]** for robust Hausman testing, **[CM §6.3.2.3]** for Hausman–Taylor.
- **VERIFY** — **[B p. 99]** reports the two-way Hausman on Grunfeld as χ²₂ = 8.842, p = 0.012. **[CM §5.1.3.1]** prints a robust Hausman application. `?pht` reproduces the Cornwell–Rupert wage equation.
- **⚠** plm returns **one** statistic for `effect="twoways"` where **[B §4.3.7]** identifies five hypotheses. Do not present it as settling Kang's taxonomy.

#### 4a.3 Cross-sectional dependence
- **THEORY** — The literature splits by whether units are **ordered** or not **[P p. 784]**; with spatial data the unordered tests detect *whether anything exists*, not spatial structure. BP LM **[B p. 412]**, **[P p. 784]** · CD_P eq. (29.76) **[P p. 786]**, **[B p. 350]** — **implicit null is weak dependence, α < 1/4 when N and T grow at the same rate [P p. 786]**, and it over-rejects with weakly exogenous regressors when N ≫ T **[P p. 789]** · CD_lm eq. (13.32)/(29.74) **[B p. 412]**, poorly centred at finite T · LM_Adj/PUY eq. (13.33)/(29.75) **[B p. 413]** — **14.25% rejection at N=200, T=20 against nominal 5% [P p. 789]** · LM_S (Schott 2005) eq. (29.78) **[P p. 787]** · J_BFK sphericity eq. (29.77) **[P p. 787]** — **~100% rejection regardless [P p. 789]**, avoid · **LM_P (Baltagi, Feng & Kao 2012) eq. (13.36) [B p. 414]** — the FE-appropriate one. Survey: Moscone & Tosetti (2009), spacing-based tests have low power against spatial correlation **[B p. 413]**.
- **DATA** — PROD, HPUS.
- **CODE REF** — `?pcdtest` — `test = "cd"/"lm"/"sclm"/"bcsclm"/"rho"/"absrho"`; **`"bcsclm"` IS eq. (13.36)** and requires a within model with individual or two-way effects. `?cortab` for the group-correlation diagnostic. **[CM §4.4]**.
- **VERIFY** — **[CM §10.1.2.1]** prints the local CD test on HPUS prices with z ≈ 37, and on CCEMG residuals with z ≈ 28. `?pcdtest` includes a 10×10 `w` example.
- **⚠ CRITICAL [src]** — `pcdtest(w=)` coerces `w` through `as.logical()` and reads only the lower triangle. **Numeric weights are discarded.** The implemented local statistic is the binary-neighbour version, **not** the weighted CD_{P,Local} of eq. (30.41).
- **⚠** Do not run the *global* CD test on two-way FE residuals and read non-rejection as evidence: the test has no power under zero-mean dependence, i.e. on cross-sectionally demeaned data **[CM §10.1.2.2]**.
- **✖ GAPS** — LM_Adj/PUY, LM_S, J_BFK not implemented. Given **[P p. 789]**, this is fortunate rather than limiting.

#### 4a.4 Robust standard errors
- **THEORY** — Driscoll–Kraay (1998) **[B p. 394]**, robust to general spatial and temporal dependence **as T → ∞**; "if T is small… the problem of consistent nonparametric covariance matrix estimation is much less tractable" **[B p. 394]**. Beck–Katz PCSE; panel Newey–West; double clustering. Bester, Conley & Hansen (2011) group-membership HAC **[P p. 814]** — validity "relies on the capacity of the researcher to construct groups whose averages are approximately uncorrelated."
- **DATA** — PROD.
- **CODE REF** — `?vcovSCC`, `?vcovBK`, `?vcovNW`, `?vcovDC`, `?vcovHC.plm`, `?vcovG`; Millo (2017) *JSS* 82(3) is the unifying treatment; **[CM §5.1.1]**.
- **VERIFY** — Every vcov help page carries worked examples on PROD with `coeftest`, `waldtest` and `linearHypothesis`. Millo (2017) tabulates which estimator corresponds to which published proposal.
- **⚠** At T = 20 the T → ∞ caveat binds. Present a side-by-side SE comparison rather than a single choice.
- **✖ GAPS** — Bester–Conley–Hansen not implemented as such; `cortab` supports checking its precondition only.

---

### STAGE 4b — Dynamic panel

#### 4b.1 The problem
- **THEORY** — OLS biased and inconsistent **[B p. 187]**, **[P §27.2, p. 676]**. Nickell (1981) bias O(1/T) **[B p. 188]**; full derivation eqs. (27.7)–(27.10) **[P §27.3, pp. 678–681]**, including the explicit plim. **Applies to both FE and RE [P p. 678]**. Judson & Owen (1999): even at T = 30 the bias may reach 20% of the true value **[B p. 188]**.
- **VERIFY** — Nickell (1981) *Econometrica* 49 Table 1 gives bias magnitudes by T; reproducible by simulation.

#### 4b.2 Estimators
- **THEORY** — Anderson–Hsiao (1982) **[B p. 188]**, **[P §27.4.1, p. 681]**, levels instruments preferred (Arellano 1989) · Arellano–Bond (1991) **[B §8.2, pp. 189–191]**, instrument matrix eq. (8.6), **[P §27.4.2, p. 682]** · Ahn–Schmidt (1995) nonlinear moments **[B pp. 198–201]**, **[P §27.4.3, p. 685]**, asymptotically efficient with the same asymptotic variance as MLE under normality **[B p. 201]** · Arellano–Bover (1995) **[B pp. 194–198]**, framed by **[P §27.4.4, p. 686]** as the time-invariant-regressor solution · Blundell–Bond (1998) system GMM **[B §8.5, pp. 201–203]**, **[P §27.4.5, p. 688]**, with weak-instrument behaviour eq. (8.35) and the **initial-condition stationarity restriction eq. (8.36) [B p. 201]** as the price of admission · Kiviet (1995) bias-corrected FE **[B p. 188]** · transformed likelihood **[P §27.6, pp. 692–696]**, Hsiao, Pesaran & Tahmiscioglu · factor error structure **[P §27.7, pp. 696–699]**.
- **QUANTIFIED TRADE-OFFS** — Efficiency gain of SYS over DIF, variance ratio: 1.75 at δ=0, 3.26 at δ=0.5, **55.4 at δ=0.9** **[B p. 202]**. Counter: Bun & Windmeijer (2010) **[B p. 202]** — SYS retains a weak-instrument problem increasing in σ²μ/σ²ν, and Wald size properties deteriorate further with the variance ratio.
- **DATA** — **EMPL. This is non-negotiable**; it is the dataset every GMM paper replicates.
- **CODE REF** — `?pgmm`; **[CM §7.2–7.3]**. Formula has up to three parts: `y ~ regressors | gmm.instruments | normal.instruments`. `transformation = "d"` is difference GMM, `"ld"` is system GMM. Default `effect` is `"twoways"`, unlike `plm`.
- **VERIFY** — **This is the strongest verification target in the whole document.** `?pgmm` examples are explicitly annotated to reproduce **Arellano & Bond (1991) Table 4, column (b)**, and `summary(model, robust = TRUE)` to reproduce **Windmeijer (2005) Table 2 standard errors**. `?mtest` is annotated to reproduce Windmeijer (2005) Table 2 one-step corrected standard errors. An implementation that does not match these is wrong.
- **✖ GAPS** — Ahn–Schmidt, Kiviet BC-FE, transformed likelihood, factor-error dynamic: none in plm. `pdynmc` implements nonlinear moment conditions — **signature unverified**. Kripfganz & Schwarz (2018) two-step for time-invariant regressors **[B pp. 197–198]**: Stata `xtseqreg` only.

#### 4b.3 Diagnostics
- **THEORY** — Sargan **[B p. 191]**, **[P §27.4.6, p. 691]** · **Bowsher (2002) [B p. 192]**: with too many moments Sargan is "undersized and [has] extremely low power"; at N=100, T=15 the χ²₉₀ statistic has Monte Carlo variance 13.7 against a theoretical 180, with zero rejection rate under null *and* alternative · AR(1) reject / AR(2) fail to reject **[B p. 192]**, consistency relies on E[Δν_it Δν_i,t−2] = 0 · Windmeijer (2005) correction **[B §8.2.2, p. 193]**, without which Wald tests are oversized · moment proliferation **[B §8.2.3, p. 194]**: Ziliak (1997) — elasticity moved from 0.519 to 0.093 as moments went from 9 to 212; Roodman (2009) `collapse`.
- **CODE REF** — `?sargan`, `?mtest`. **`summary(x, robust = TRUE)` is the Windmeijer correction and is the default for `summary.pgmm`.**
- **VERIFY** — Windmeijer (2005) Table 2, via the annotated `?mtest` and `?pgmm` examples. Ziliak's 0.519 → 0.093 is reproducible in structure (not in level) as an instrument-count sensitivity table.
- **AGENT NOTE** — A Sargan p-value near 1.00 with many instruments is the Bowsher pathology, not evidence of good specification. Any GMM implementation must report the instrument count and an instrument-count sensitivity table.

---

### STAGE 5 — Spatial

> **Notation**: ρ = spatial lag, δ or λ = spatial error, following **[P eqs. 30.1, 30.4]**. **⚠ splm's printed output does not follow this**; in a SEM fit the error parameter prints as `rho`. Always read `$arcoef` (lag) versus `$errcomp` (error) rather than trusting labels.

#### 5.1 Pre-checks on W
- **THEORY** — Parameter space: I_N − ρW invertible iff |ρ| < 1/τ\*, **τ\* = min(‖W‖₁, ‖W‖∞)** (Kelejian & Prucha 2010) **[P p. 799]**; reduces to |ρ| < 1 only when W is row **and column** standardised **[P p. 802]**. Granularity: SAR endogeneity requires **non-granular** weights; if w_ij = O(N⁻¹) then lim Cov(w′_i y_.t, u_it) = 0 **[P p. 800]**. Sparsity criterion: under SAR the covariance involves an inverse and is **not sparse**, linking all units; under SMA and SEC the non-zeros are those of W **[P p. 801]**.
- **CODE REF** — Pure matrix algebra; no package needed. `spdep` for W construction (`knearneigh`, `dnearneigh`, `nb2listw`, `nb2mat`, `nblag`); Bivand & Wong (2018), *TEST* 27, for `spdep` comparability.
- **VERIFY** — Self-verifying: ‖W‖∞ must equal 1 for a row-standardised W. Eigenvalue bounds must bracket the reported bound.
- **AGENT NOTE** — These four checks are cheap and are the most distinctive theoretical content in the tree. They should be computed and reported for the project's actual W, not asserted from citation.

#### 5.2 Model choice
- **THEORY** — SAR lag **[P eqs. 30.1–30.2, pp. 798–799]**, **[B eq. 13.16, p. 401]**; FE and pooled OLS **inconsistent** **[P p. 800]**, **[B p. 401]**. Error specifications, all **[P pp. 800–801]**: SAR errors eq. (30.4); **SMA errors eq. (30.5)**; **SEC eq. (30.6)**. SARAR/SAC **[B p. 405]**, **[P eqs. 30.8–30.9, p. 802]**, with possibly different W₁ and W₂. Spatial Durbin **[B p. 406]** — does not complicate estimation but changes direct and indirect effects. **Consistency note [P p. 801]**: under spatial *errors*, FE and RE are √(NT)-consistent, merely inefficient — spatial modelling buys efficiency, not consistency. Anselin vs KKP **[B pp. 394–395]**: Anselin's spillovers are time-varying, KKP's are time-invariant as well; encompassing three-matrix model, Baltagi, Egger & Pfaffermayr (2013) **[B p. 395]**, **[P eqs. 30.13–30.16, p. 803]**.
- **DATA** — PROD + usaww; RICE + riceww.
- **CODE REF** — `?spml` (`spatial.error = "b"/"kkp"/"none"`, `lag=`, `model=`, `effect=`), `?spreml` (`errors=` with 12 options including `"semsrre"`, `"sem2re"`, `"semgre"`), `?spgm` (`Durbin=`, `endog=`, `instruments=`). **[MP] JSS 47(1)** is the authoritative walkthrough; **[CM §10.2–10.3]**.
- **VERIFY** — **[MP] JSS 47(1)** prints all specifications on PROD. **[CM §10.3.3]** prints the SEM-FE fit on RICE with spatial error parameter ≈ 0.7913 (SE 0.0249) and coefficients ≈ 0.1342, 0.2505, 0.5419 for log(seed), log(totlabor), log(size). **[P Table 30.2, p. 807]** gives eight estimators on liquor demand with SEs.
- **✖ GAPS** — **SMA and SEC error specifications are not implemented in splm.** `spatial.error` gives SAR errors only. This is the sharpest modelling distinction in **[P §30.3]** and it is unavailable. No workaround, no verification target.
- **⚠** `spml` takes `listw`; `spreml` takes `w`. Different names, same package.

#### 5.3 Estimation — fixed effects
- **THEORY** — **Lee & Yu (2010a) orthonormal P-transformation [P pp. 802–803]**: removes individual effects and leaves uncorrelated transformed errors; eqs. (30.10)–(30.12); **consistent and asymptotically normal when either N and/or T → ∞** — a weaker condition than the joint ones in Yu–de Jong–Lee. Baltagi's 2SLS family: FE-S2SLS **[B p. 402]** with H = [QX, QWX, QW²X]; BE-S2SLS **[B p. 402]**; RE-S2SLS eq. (13.23); SEC-2SLS eq. (13.26) **[B p. 404]**; base instruments eq. (13.18) **[B p. 401]** (Kelejian–Prucha 1998; Baltagi–Liu 2011). Mutl & Pfaffermayr (2011): the IV approach adapts to fixed or random effects **[P p. 808]**; Lee (2003) for optimal instruments. KKP GM, six moment conditions eq. (13.13) **[B p. 395]**, T fixed, N → ∞. **Lee & Liu (2006) quadratic moments eq. (30.25) [P p. 808]**: A_ℓ with zero diagonal renders GMM robust to unknown cross-sectional heteroskedasticity; extended to FE panels by Moscone & Tosetti (2011).
- **CODE REF** — `?spgm` — `method = "w2sls"/"b2sls"/"g2sls"/"ec2sls"` maps to FE-S2SLS / BE-S2SLS / RE-S2SLS / EC2SLS. `moments = "initial"/"weights"/"fullweights"`; the **default is the least efficient**. **[MP] JSS §4**; **[CM §10.3.3.3]**.
- **VERIFY** — **[MP] JSS 47(1)** prints `spgm` results on PROD for lag, error and SARAR under FE and RE. **[CM §10.3.3.3]** prints the GM SEM-RE fit on RICE with ρ ≈ 0.7807, σ²ν ≈ 0.0801 and coefficients ≈ 0.1346, 0.2508, 0.5418 — directly comparable to the ML numbers in 5.2 above, which is itself a useful cross-check.
- **⚠ TWO COSTS** — (i) **`splm`'s FE implementation is the ex-post variance correction of Lee & Yu (2010a §3.2), not the P-transformation** **[CM §10.3]**. The "either N and/or T → ∞" property does **not** transfer. (ii) **GM gives no standard error for ρ**; no significance testing is possible **[CM §10.3.3.3]**.
- **✖ GAPS** — Lee–Liu / Moscone–Tosetti het-robust panel GM: not implemented. `sphet` (`spreg(het=TRUE)`, `gstslshet`, `stslshac`, `kpjtest`) implements the het-robust machinery but is **cross-sectional only** — single `listw`, no panel index. Reference: Piras (2010), *JSS* 35(1).

#### 5.4 Estimation — random effects
- **THEORY** — Anselin RE log-likelihood eq. (13.10) **[B p. 393]**; BEP generalized RE eqs. (30.13)–(30.16) **[P p. 803]**, **[B p. 395]**. Serial + spatial + RE jointly: Millo (2014), *CSDA* 71, 914–933.
- **DATA** — PROD, RICE, INS.
- **CODE REF** — `?spml(model="random")`, `?spreml`. Abbreviations: `"sem"` = Anselin/Baltagi–Song–Koh type (effects not spatially correlated), `"sem2"` = KKP type (effects spatially correlated), `"sr"` = serially correlated remainder, `"re"` = random effects, `"ols"` = spherical. **[CM §10.3.2, §10.4.1]**.
- **VERIFY** — **[CM §10.4.1.1]** prints the full SEMSRRE fit on RICE: φ (RE variance ratio) ≈ 0.2500, ψ (serial) ≈ 0.1250, ρ (spatial) ≈ 0.6136, with t-statistics. **[P Table 30.2, p. 807]** reports F(42,1029) = 165.79 for H₀: μ = 0, BP = 97.30 for σ²μ = 0, and Hausman χ²₃ = 3.36, p = 0.339.
- **⚠** `spreml`'s likelihood is not well behaved. Default optimiser `nlminb`; `"BFGS"` available; `"NM"` and `"SANN"` experimental. Try `initval = "estimate"` before changing optimiser.

#### 5.5 Testing which structure fits
- **THEORY** — **RE branch [B p. 393]**: Baltagi, Song & Koh (2003) joint LM (H₀: δ = 0 and σ²μ = 0) plus conditional LM in both directions; Baltagi et al. (2007) adds serial correlation as a third symptom — **"testing for any one of these symptoms ignoring the other two is shown to lead to misleading results"**; Baltagi, Song & Kwon (2009) adds heteroskedasticity. **FE branch [B pp. 404–406]**: Debarsy & Ertur (2010) joint, marginal and conditional **LM and LR** tests. **FE vs RE**: Mutl & Pfaffermayr (2011) spatial Hausman **[B p. 406]** — *not* a dynamic test; Debarsy (2012) Mundlak approach **[B p. 406]**, auxiliary regression of the effects on time-averaged regressors **plus their spatial weighted averages**.
- **DATA** — PROD, RICE.
- **CODE REF** — `?bsktest` (`test = "LMH"/"LM1"/"LM2"/"CLMlambda"/"CLMmu"`), `?bsjktest` (`test = "J"/"C.1"/"C.2"/"C.3"` — C.1 spatial, C.2 serial, C.3 random effects, each conditional on the others), `?slmtest` (`test = "lml"/"lme"/"rlml"/"rlme"`), `?sphtest` (`spatial.model = "lag"/"error"/"sarar"`, `method = "ML"/"GM"`, `errors = "KKP"/"BSK"`). **[CM §10.3.4, §10.4.2]**.
- **VERIFY** — **[CM §10.3.4.1]** on RICE: LMH ≈ 310, CLMmu ≈ 11, CLMlambda ≈ 21. **[CM §10.4.2.1]** on RICE: J ≈ 319.5, C.1 ≈ 371.5, C.2 ≈ 11.894431 (p ≈ 0.000563), C.3 ≈ 75.8. **[CM §10.3.1]** sphtest on RICE: χ² ≈ 2.6, df = 3, p ≈ 0.4. **[B p. 406]** Debarsy–Ertur worked LR example on residential electricity demand (48 states + DC, 1990–2010, Belotti, Hughes & Piano Mortari 2017): marginal LR for ρ=0 → 157.3; marginal LR for λ=0 → 82.34; joint → 157.3 (χ²₂); conditional λ=0|ρ → 0.04; conditional ρ=0|λ → 74.96; fitted SAC ρ̂ = 0.36 significant, λ̂ = 0.02 insignificant **[B p. 405]**.
- **⚠ TWO CRITICAL USAGE POINTS from [src]** — (i) `slmtest` is built on a **pooling assumption and does not allow individual effects**; the default `model = "pooling"` is wrong for panel data with effects — **always pass `model = "within"`**. (ii) The locally robust versions are designed for cases where the "other" effect is not of substantial magnitude and "can behave suboptimally otherwise"; if both robust tests reject strongly, estimate the encompassing SARAR instead of choosing between them.
- **⚠** The joint test LMH "is of little use, because it will reject in the presence of either effect, giving no further directions" **[CM §10.3.4.1]**. Go straight to the conditional tests.
- **✖ GAPS** — **Debarsy & Ertur (2010) is not implemented**; `slmtest` implements the Anselin, Bera, Florax & Yoon (1996) family, which is a different test. The Debarsy–Ertur LR *structure* is reconstructible from `spml`'s `$logLik` across nested specifications and can be checked against **[B p. 406]**'s five numbers — that is a legitimate verification path even though the statistic differs. Debarsy (2012) Mundlak: not implemented.

#### 5.6 Dynamic + spatial
- **THEORY** — Model **[P eq. 30.27, p. 810]**: y_.t = α + γ y_.,t−1 + ρ W y_.t + **λ W y_.,t−1** + X_.t β + u_.t. The λWy_{t−1} space-time diffusion term is absent from **[B pp. 406–407]**. **Stability: |γ| + |ρ| + |λ| < 1, assuming W row and column standardised [P p. 810]**. Yu, de Jong & Lee (2008): three regimes **[B pp. 406–407]** — T large relative to N → √(NT)-consistent and centred; N proportional to T → not centred; N large relative to T → consistent at rate T only, degenerate limiting distribution. **[P p. 810]**: if lim N/T > 0 the limit distribution is not centred and a bias-corrected estimator is needed. Alternative: Kukenova & Monteiro (2009) IV/GMM **[P p. 810]**.
- **⚠ REGIME** — At N ≈ 170, T ≈ 20, N/T ≈ 8.5 ≫ 0. Not-centred regime at best; near rate-T/degenerate at worst. Bias correction required; its adequacy at these dimensions is an open question.
- **DATA** — Elhorst's applications; Belotti, Hughes & Piano Mortari (2017) *Stata Journal* 17(1) uses the residential electricity panel.
- **CODE REF** — ✖ **No R implementation.** Stata `xsmle` with `model(sdpd)`; Elhorst's MATLAB routines (available from his website and in Elhorst 2014, *Spatial Econometrics: From Cross-Sectional Data to Spatial Panels*, Springer).
- **VERIFY** — Belotti, Hughes & Piano Mortari (2017) print `xsmle` output for the SDPD model. **An R implementation would have to be validated against Stata output on the same data.**
- **AGENT NOTE** — This is the largest gap in the tree. The stability condition **can** be checked once estimates exist, and should be, with the caveat that its row-and-column-standardisation precondition will not hold for a row-standardised W (use the general τ\* form instead).

#### 5.7 Residual spatial diagnostics — **the corrected version**
- **THEORY** — **Do not use plain CD_P**: its implicit null *is* weak dependence, which includes spatial **[P p. 786]**; confirmed from the other direction at **[P p. 839]**, where CD is found most robust to spatial alternatives, i.e. it does not fire on them. Ordered-alternative statistics: **CD_Moran eq. (30.40) [P p. 814]**, asymptotically normal (Kelejian & Prucha 2001), equivalent to the Burridge (1980) LM for large N; **CD_{P,Local} eq. (30.41) [P p. 814]**, the W-weighted CD on FE residuals. Robinson (2008) quadratic forms **[P p. 815]**. **Randomized-W test**: Millo (2017), robust to global (factor) dependence and to serial correlation, both of which local CD(p) does not tolerate **[CM §10.1.2.2]**; pseudo-p-value formulae eqs. (10.1)–(10.3) for one-sided, symmetric and asymmetric two-sided variants.
- **⚠ WHY rwtest DISPLACES local CD** — **[CM §10.1.2.2]**: with non-spatial dependence present, a local CD(p) test uses a subset of spatially related pairs drawn from a population of correlated ones, and is therefore likely to produce a **false positive favouring spatial dependence**. This is the correction that supersedes the v3/v4 recommendation of CD_Moran and CD_{P,Local} as primary.
- **DATA** — HPUS + usaw49.
- **CODE REF** — `?rwtest` (`test = "rho"/"cd"/"sclm"`, `alternative = "twosided"/"onesided"/"symmetric"`, `replications`, `order`, `seed`, `mc`); `?pcdtest` for the local versions. **[CM §10.1.2]**.
- **VERIFY** — **[CM §10.1.2.2]** on HPUS: `rwtest` on raw prices with 999 replications gives p ≈ 0.002; `pcdtest` local on prices gives z ≈ 37; `pcdtest` local on CCEMG residuals gives z ≈ 28; `rwtest` on MG residuals gives p ≈ 0.002. **This four-number pattern is the single most useful verification target in Stage 5**, because it validates the whole factor-versus-spatial discrimination at once.
- **⚠** `rwtest` coerces `w` through `as.logical()` exactly as `pcdtest` does. It tests neighbourhood **structure**, not the weighting scheme. Do not describe it as using an inverse-distance W. Default `replications = 99` is too few; use ≥ 999 and set `seed`.
- **✖ GAPS** — Weighted CD_{P,Local} eq. (30.41) and CD_Moran eq. (30.40) are not implemented as such; Robinson (2008) not implemented. These must be hand-coded from the equations, and **have no verification target** beyond internal consistency with the binary version.

#### 5.8 Direct and indirect effects
- **THEORY** — In any model containing Wy the coefficient is **not** the marginal effect. LeSage & Pace (2009), *Introduction to Spatial Econometrics*; **[B pp. 406, 408]**. Spatial Durbin changes the effects even though it does not complicate estimation **[B p. 406]**.
- **CODE REF** — `impacts()` methods exist for both `splm_ML` and `splm_GM` (`tr=`, `R=`, `type = "mult"/"MC"/"moments"`, `time=`, `evalues=`, `Q=`). `spdep::trW` for trace approximations. **⚠ Not covered in [CM]** — postdates the book.
- **VERIFY** — `?spml` impacts example on PROD (commented out in the help page but runnable). `spdep`'s `impacts` methods for cross-sectional models are extensively documented and share the underlying machinery.
- **AGENT NOTE** — With moderate-to-large N, `type = "mult"` densifies the matrix and may swap. Use `"MC"` or `"moments"`; `"moments"` requires symmetric W (or row-standardised weights via a similarity transformation).

#### 5.9 Heterogeneous spatial panels
- **THEORY** — Pesaran & Tosetti (2011) **[P §30.6, pp. 810–813]**: model eq. (30.28), FE estimator eq. (30.29), Mean Group eq. (30.30), with √N(β̂_FE − β) → N(0, Σ_FE) eq. (30.31) **[P p. 811]**. Temporal heterogeneity **[P §30.6.1, p. 812]**.
- **✖ GAPS** — Not implemented. `pmg` provides the MG estimator, which under **[P p. 801]** is consistent under spatial errors (merely inefficient), so it is a defensible partial route. No verification target for the Pesaran–Tosetti variance.

#### 5.10 Forecasting
- **THEORY** — Baltagi–Li BLUP eq. (13.27) **[B §13.4, pp. 408–410]**; with σ²μ = 0 the BLUP prediction terms drop out entirely **[B p. 408]**.
- **⚠ THE SOURCES DISAGREE** — **[B p. 408]**, cigarette demand, 46 states 1963–92: spatial FE and RE estimators gave the best out-of-sample RMSE. **[P p. 807]**, liquor demand, 43 states 1965–94, Table 30.2: adding spatial correlation did not improve prediction except in the first year; FE 5-year RMSE 0.1360 versus FE-spatial 0.1515. Both trace to Baltagi–Li work; the conclusion is dataset-specific.
- **✖ GAPS** — No `predict` method for `splm`; `effects.splm()` extracts fixed effects but the spatial BLUP must be derived by hand. No verification target beyond the two published RMSE tables, which are on data not shipped in R.
- **AGENT NOTE** — Given the disagreement, the correct response is a rolling-origin RMSE comparison on the project's own data, not a choice of citation.

#### 5.11 Non-parametric and filtering alternatives
- **THEORY** — Robinson (2007) kernel regression under general linear-process errors **[P §30.7, p. 813]**. Spatial filtering via eigenvectors of a matrix function of W: Tiefelsdorf & Griffith (2007); Griffith (2010).
- **CODE REF** — `spdep::ME` and `spatialreg::SpatialFiltering` for the cross-sectional case; the panel extension is a straightforward construction from the eigenvectors of the doubly-centred W.
- **VERIFY** — `?SpatialFiltering` examples (cross-sectional). No panel verification target.
- **AGENT NOTE** — Worth doing as a robustness check: if coefficients from an eigenvector-filtered model match those from `spgm`, the spatial conclusion does not depend on the SAR functional form.

---

## §3 — Elements with no implementation and no verification target

An agent must treat these as **blocked**, not as tasks. Each requires either an external tool, a from-scratch implementation validated by simulation, or an explicit limitation statement.

| Element | Blocking reason | Nearest external benchmark |
|---|---|---|
| Exponent of CSD, α | No implementation | BKP (2016) paper; own Gauss code |
| Breitung, Harris–Tzavalis unit roots | No implementation | Stata `xtunitroot` |
| Moon–Perron, Bai–Ng, CSB | No implementation | — |
| Cross-unit cointegration tests | No implementation | — |
| Kao, McCoskey–Kao, Larsson | No implementation | Stata `xtcointtest kao` |
| FMOLS, DOLS, Breitung two-step, DSUR, Bai–Kao–Ng | No implementation | Stata; Gauss code from original papers |
| Pesaran–Yamagata Δ̃ | No R implementation | **Stata `xthst`** (Bersvendsen & Ditzen 2021, *SJ* 21(1)) |
| Pooled Mean Group | No implementation | Stata `xtpmg` |
| Conditional LM eqs. (4.34)/(4.36), SLM eq. (4.26) | No implementation | — |
| Ahn–Schmidt, Kiviet BC-FE, transformed likelihood | No implementation | Stata `xtdpdqml`, `xtlsdvc` |
| SMA and SEC error specifications | No implementation | — |
| Lee–Liu / Moscone–Tosetti het-robust panel GM | `sphet` is cross-sectional only | — |
| Debarsy–Ertur LM/LR, Debarsy Mundlak | No implementation | **[B p. 406]** five LR values (reconstructible in structure) |
| **Dynamic spatial panel (SDPD)** | No implementation | **Stata `xsmle, model(sdpd)`**; Elhorst MATLAB |
| Weighted CD_{P,Local}, CD_Moran | No implementation | Internal consistency with binary version only |
| Spatial BLUP forecasting | No `predict` method | **[B p. 408]**, **[P Table 30.2]** RMSEs |
| Pesaran–Tosetti FE/MG variance | No implementation | — |

---

## §4 — Validation protocol for an implementing agent

For each element, in order:

1. **Read the THEORY reference** to establish what the statistic is, its null, its alternative, and its rate conditions. Rate conditions matter: several tests in this tree are formally inapplicable at N ≈ 170, T ≈ 20 regardless of whether the software runs.
2. **Read the CODE REF**, in this precedence: package source → help page → package vignette → **[MP]** / **[CM]** → textbook. **[CM]** is authoritative for interpretation and obsolete for argument names.
3. **Run on the specified DATA**, not on project data. Canonical datasets first, always.
4. **Match the VERIFY target.** Three significant figures for coefficients and test statistics. A mismatch is an implementation error until proven otherwise — not a version difference.
5. **Only then** run on project data, and re-check the rate conditions from step 1 against the actual N and T.
6. **If VERIFY is empty**, mark the element as unverified in the output and do not let it carry a conclusion alone. Corroborate with a verified element testing an overlapping hypothesis.
7. **For blocked elements (§3)**, produce an explicit limitation statement rather than a substitute presented as the real thing.

### Priority order for verification effort

Highest return, in order:

1. **`pgmm` against Arellano–Bond (1991) Table 4(b) and Windmeijer (2005) Table 2** — annotated in the help pages, exact, and validates the whole dynamic branch.
2. **The [CM §10.1.2.2] four-number pattern on HPUS** — validates the factor-versus-spatial discrimination, which is the tree's central routing decision.
3. **[B Table 4.3, p. 89] on Grunfeld** — validates the whole static effects branch.
4. **[MP] JSS 47(1) on PROD** — validates every splm estimator at once.
5. **[CM §10.3.4, §10.4.2] on RICE** — validates the spatial testing battery.
