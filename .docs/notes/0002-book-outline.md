# Book outline: practical workflow, theory alongside

- **Date:** 2026-10-05
- **Author:** Eduard Bukin
- **Summary:** One folder per chapter in `chapters/`, holding its steps and its
  theory notes; chapters follow the workflow of a panel analysis, and spatial
  dependence is its own chapter.

## Instruction (verbatim)

> b the components that we use here should be defined more by um by an outline
> or by some background analysis that has been performed before for now i
> propose to um first uh, move theory chapters and all this uh, chapter lead
> analysis into the examples and recall examples rename examples the content
> or something and then every subfolder in example should contain the specific
> example step by step that uh, refer to the theory uh, elements as well so
> that uh, all the book materials are self-contained within the examples
> folder this is first second um I would like to have a more detailed
> discussion on the um, structure of the book based on this uh, material that
> I prepared before. So let's go into details there. um, so let's find
> something uh, more, so more sustainable in terms of structure. So yeah, the
> first is exploring the panel, how it looks like. What else is next? Well,
> probably yes, the cross-sectional dependency. This is the next one, right?
> Um, and then probably serial correlation. So um, these are two main kind of
> problems, right? And then uh, we probably need some kind of a, um, maybe
> decision diagram, maybe introduction that outlines the full um, kind of
> process and uh, the starting from the uh, panel data establishment and then
> going into the uh, different aspects of cross-sectional dependency and
> different aspects of the uh, time series correlation and spatial dependency
> is probably part of cross-sectional de dependence you know and then theory
> is kind of going in parallel explaining what is what Uh, we would like also
> to have probably chapters on the uh, course check elements on the um, panel
> itself. Panel itself, uh, without space or all the time series part. Uh,
> random fixed effects, for example, but this is later on. So now we, we
> update the outline

> Spatila is a eparate chapter. Claude code needs to be updated.

## Note

The outline is built from the decision tree in `.docs/panel-spat-PLAN.md`;
the numbers in brackets are its sections.

1. **Road map** (`00-road-map`). The whole process, from building the panel
   to the dependence fork, with one decision diagram.
2. **Explore the panel** (`01-explore`). Dimensions, balance, variation
   (0.1).
3. **Cross-sectional dependence** (`02-cross-dependence`). Is it there: CD
   and LM tests (0.4, 4a.3). How strong: the exponent α (0.2). Strong
   dependence means common factors: CCE (0.3).
4. **Spatial dependence** (`03-spatial`). Weak, local dependence. Weights W
   (5.1); tests and model choice (5.2, 5.5); FE and RE estimation (5.3,
   5.4); residual diagnostics (5.7); direct and indirect effects (5.8);
   heterogeneous spatial panels (5.9).
5. **Time dependence** (`04-time`). Unit roots (stage 1); cointegration
   (stage 2); serial correlation (3.4); dynamic panels (4b).
6. **Core panel models** (`05-core`), later. Poolability and slope
   homogeneity (3.1, 3.2); heteroskedasticity (3.3); effects tests, FE vs RE
   (4a.1, 4a.2); robust standard errors (4a.4).

Chapters 2–4 use FE residuals before chapter 5 explains FE. Each such use
gets a one-line gloss and a link forward.

Each chapter folder holds its theory notes. The current `theory/` notes move
as follows: 01 and 04 to `02-cross-dependence`; 02, 03, 05 and 06 to
`03-spatial`; 07 to `04-time`.

## Amendment, 2026-10-06 (verbatim)

Chapters 00 to 03 and the unit-root part of 04 were written. Asked how to
implement the rest of `.docs/panel-spat-PLAN.md`, the proposal was to keep
chapter 04 to the time dependence of the series (unit roots, cointegration),
to put serial correlation beside the effects tests in the core chapter, and
to give dynamic panels a chapter of their own; the alternative was the outline
above, with about seventeen steps on one page. The decision:

> Okay, with your split in three chapters. Um, state and benchmark are not
> necessary right now, so don't do state and benchmark, keep it planned for
> later. What I would like to do is to ensure that every chapter is written
> nicely and it's been properly backed by literature, so it uses literature
> rigorously and references it properly. And uh, yeah, I would like you to
> flag this in the, in the um, plan. Also, it's important that every single
> chapter is written by a different subagent. with a sufficient context in
> the right context to focus on. So that's another point. And please use
> subagents to, to write every single component or chapter um, you decide,
> but this subagent shouldn't be overloaded with the context.

"State and benchmark" is read as the Stata benchmarks proposed for the
elements the spec lists as blocked in R (Pesaran–Yamagata Δ, Kao, Breitung,
SDPD). They are deferred, not dropped.

The outline from point 5 on becomes:

5. **Time dependence** (`04-time`). Unit roots (stage 1); cointegration
   (stage 2).
6. **Core panel models** (`05-core`). Poolability and slope homogeneity
   (3.1, 3.2); heteroskedasticity (3.3); serial correlation (3.4); effects
   tests, FE vs RE (4a.1, 4a.2); robust standard errors (4a.4).
7. **Dynamic panels** (`06-dynamic`). The problem (4b.1); estimators (4b.2);
   diagnostics (4b.3).

Serial correlation moves from the time chapter to the core chapter because
its tests run on the residuals of a `plm` fit and the Bera–Sosa-Escudero–Yoon
family tests random effects and serial correlation jointly. Dynamic panels
get their own chapter because the spec treats them as a stage of their own
(4b, beside the static 4a) and they carry the strongest verification target
in the book. The three chapters are written in the order core, dynamic,
cointegration, by verification value, not reading order; the plan is
`.docs/plans/0008-remaining-chapters.md`.
