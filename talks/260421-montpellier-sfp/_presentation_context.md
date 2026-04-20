# Presentation Context: "When accurate prediction models yield harmful self-fulfilling prophecies"

## Paper metadata

- **Title:** When accurate prediction models yield harmful self-fulfilling prophecies
- **Authors:** Wouter A.C. van Amsterdam, Nan van Geloven, Jesse H. Krijthe, Rajesh Ranganath, Giovanni Cinà
- **Affiliation (lead):** Department of Data Science and Biostatistics, Julius Center, UMC Utrecht
- **Journal:** Patterns (Cell Press), 2024
- **Source files:** `/Users/wamster3/Documents/writing/selfulfilling/subm4_patterns/final3/sf-final.tex`
- **Published PDF:** `/Users/wamster3/Documents/writing/selfulfilling/subm4_patterns/final3/sf-final.pdf`
- **Numerical experiments:** `/Users/wamster3/Documents/writing/selfulfilling/subm4_patterns/final3/num_exps.qmd` (Quarto)

---

## One-sentence summary

Outcome prediction models (OPMs) used for treatment decisions can harm patients while simultaneously maintaining or improving their discrimination (AUC) — a harmful self-fulfilling prophecy — making standard post-deployment monitoring insufficient to detect harm.

---

## The core problem

Medical prediction models are routinely validated on discrimination (AUC) and calibration, then deployed to guide treatment decisions. The implicit assumption is: good predictive accuracy → good treatment decisions. This paper shows the assumption is **false**.

**Key insight:** Deploying a prediction model *is an intervention* that changes treatment policy and therefore patient outcomes. The predictive accuracy of the model under the new policy says nothing about whether the new policy is beneficial.

---

## Motivating example (slide-ready)

**Setting:** End-stage cancer patients; selecting who gets palliative radiotherapy (burdensome, so given only to patients expected to benefit).

**The model:** Predicts 6-month overall survival from pre-treatment tumor growth rate. Fast-growing tumors → shorter survival → lower predicted probability → model says: don't treat.

**The problem:** Fast-growing tumors respond *better* to radiotherapy. The model treats exactly the wrong patients.

**The paradox:** Post-deployment, treated patients (slow-growing) still survive longer than untreated patients (fast-growing). The contrast has *increased* because fast-growing patients are now also deprived of treatment. AUC goes up. The model looks like a success.

This is the harmful self-fulfilling prophecy.

---

## Setup and definitions

- **Binary treatment** $T$, **binary outcome** $Y$, **binary feature** $X \in \{0,1\}$
- **Potential outcomes:** $Y_t$ = outcome if treatment set to $t$
- **Historical policy** $\pi_0$: constant and deterministic (treat everyone or treat no one)
- **OPM-informed policy** $\pi_f$: threshold-based, assigns treatment iff $f(X) > \lambda$
- **Self-fulfilling:** AUC post-deployment $\geq$ AUC pre-deployment
- **Harmful (for group $X=x$):** expected outcome *worse* under $\pi_f$ than under $\pi_0$

---

## Main results

### Theorem (informal)
Under simple assumptions (constant historical policy, non-constant new policy, stable $X$ distribution), a **non-trivial subset** of OPMs is both self-fulfilling and harmful.

### Proposition: When is an OPM self-fulfilling?
- If the treatment effect is **always positive** (for all $x$), then $(f, \lambda)$ is self-fulfilling.
- If the treatment effect is **always negative**, it is not self-fulfilling.
- Note: self-fulfillingness does **not** depend on the OPM's pre-deployment discrimination — good and bad models are equally susceptible.

### Proposition: When is an OPM harmful?
Deploying $f$ is harmful for group $X=x$ if and only if the treatment change is in the wrong direction:
- $\pi_0(x)=1$, $\pi_f(x)=0$, and treatment was beneficial for that group, OR
- $\pi_0(x)=0$, $\pi_f(x)=1$, and treatment was harmful for that group.

### Theorem: Calibration pre- and post-deployment
An OPM that is calibrated both before and after deployment is **useless for decision making**: for each group $X=x$, either the policy didn't change, or the treatment effect is zero. Both cases mean the deployment had no consequential effect.

---

## The dual problem

There is a mirror image: **beneficial self-defeating** policies.

If a new policy *improves* patient outcomes for a subgroup, the outcome distribution becomes more uniform within groups → harder discrimination → AUC *decreases*. Naively withdrawing a model because its AUC dropped post-deployment could remove a beneficial policy.

---

## Summary table (Table 1 in paper)

| $Y=1$ preferable? | Historical policy | AUC change post-deployment | Interpretation |
|---|---|---|---|
| Yes (e.g. survival) | Treat all | Increased | Harmful: stopped treating a group that benefited |
| Yes | Treat none | Increased | Harmful: started treating a group where treatment hurts |
| Yes | Treat all | Decreased | Beneficial |
| Yes | Treat none | Decreased | Beneficial |
| No (e.g. heart attack) | (symmetric cases) | ... | ... |

Use this table when an OPM has already been deployed without proper evaluation — to assess *post-hoc* whether harm may have occurred.

---

## Numerical experiments

**Setup:** Logistic model with parameters $\beta_0, \beta_x, \beta_t, \beta_{xt}$ (feature effect, treatment effect, interaction). Sweep parameter space; for each setting compute pre- and post-deployment AUC and whether the policy is harmful.

**Key findings:**
- Harmful self-fulfilling policies occur at **moderate, realistic treatment effect sizes** — no extreme assumptions needed.
- They occur **even without treatment effect heterogeneity** ($\beta_{xt} \approx 0$).
- AUC increases of $>0.1$ are possible under harmful policies.

Source: `/Users/wamster3/Documents/writing/selfulfilling/subm4_patterns/final3/num_exps.qmd`

---

## Implications for practice

1. **Development:** Building OPMs on observational data without accounting for the historical treatment policy is dangerous — the policy change at deployment determines benefit or harm.
2. **Deployment:** A highly accurate OPM is not guaranteed to improve patient outcomes when used for decisions.
3. **Monitoring:** Post-deployment AUC increase ≠ success; AUC decrease ≠ failure.
4. **Regulators (FDA/EMA):** Current guidance on post-deployment monitoring focuses on predictive performance, which is insufficient.

---

## What to do instead

- Use **causal methods**: prediction-under-intervention models or CATE (conditional average treatment effect) estimation.
- Requires: good RCT data with pre-treatment covariates, or observational data with no unobserved confounding.
- Gold standard evaluation: **cluster randomized controlled trial** (some clinicians have model access, others don't).
- Key references in paper: Feuerriegel et al. 2024, Wager & Athey 2018, van Amsterdam et al. 2024 (Algorithms in Action).

---

## Related work (brief)

- **Performative prediction** (Perdomo et al. 2020): successive deployments + updates; we study single deployment, add exact conditions for harm.
- **Model degradation literature** (Lenert 2019, Sperrin 2019): they study AUC *dropping*; we study the case where it *doesn't* drop despite harm.
- **Boeken et al. 2024** (concurrent): domain adaptation framing, complementary assumptions.

---

## Figures in source

- `/Users/wamster3/Documents/writing/selfulfilling/subm4_patterns/final3/figs/auc.pdf` — AUC illustration
- Simulation figures generated by `num_exps.qmd` (rendered output: `num_exps.html`, `num_exps.pdf`)

---

## Potential slide structure

1. **Hook** — "Is a good prediction model a good treatment policy?" (answer: not necessarily)
2. **Motivating example** — radiotherapy and tumor growth rate
3. **Formal setup** — OPM, policy, harmful, self-fulfilling (definitions)
4. **Main result** — non-trivial subset is both; propositions
5. **Calibration result** — calibrated before + after = useless
6. **Numerical experiments** — realistic parameters, AUC changes
7. **The dual problem** — beneficial self-defeating
8. **Table** — how to interpret post-deployment AUC changes
9. **Regulatory implications** — FDA/EMA guidance gaps
10. **What to do instead** — causal methods, RCTs
11. **Conclusion** — shift focus from predictive performance to outcomes and policy change
