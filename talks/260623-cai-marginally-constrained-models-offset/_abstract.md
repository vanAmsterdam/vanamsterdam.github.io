# Improving Observational Conditional Average Treatment Effect Estimation with Average Treatment Effects from Randomized Controlled Trials

In healthcare we wish to tailor treatment decisions based on individual patient characteristics.
Estimates of the Conditional Average Treatment Effect (CATE) allow us to do so, but these are hard to come by.
CATE estimates from observational data may be biased by unobserved confounding.
Randomized controlled trials can estimate CATEs without confounding bias, but often only report a single Average (marginal) Treatment Effect for the trial population because of sample size limitations.

An important question is whether we can create better CATE estimators by combining these marginal effect estimates from RCTs with observational data and get best of both worlds.
In this talk I investigate a popular method to do so using the marginal effect estimates from trials as so-called 'offset'-terms in regression models that are then fit on observational data.
Though straightforward to use, we show that this approach does not lead to valid CATE estimators because of two issues: *unobserved confounding* is **not resolved** by plugging in an offset term from an RCT, and typical treatment effect measures like the *odds-ratio* are **non-collapsible**, meaning that the marginal effect estimate from the trial is not even the right offset term to begin with.
I then introduce a class of estimators called *Marginally Constrained Models* that use the marginal effect estimate as a constraint instead of as an offset term.
In simulations covering the space of a binary covariate and binary treatment setup, the marginally constrained models perform better for CATE estimation.

I round off with a discussion on strengths and limitations of these types of approaches, including avenues for future work.

[Link to paper](https://www.degruyterbrill.com/document/doi/10.1515/jci-2022-0027/html)
