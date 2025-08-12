# Much of AI is predict - predict - predict

- using ECG, predict presence of structural heart disease, typically diagnosed with cardiac echo
- predict 10-year heart attack risk using basic medical information

# The goal is impact on healthcare

## ECG to SHD [@yaoArtificialIntelligenceEnabled2021]

- prediction: structural heart disease
- intervention: refer patient for cardiac echo
- outcome: diagnosis of structural heart disease
- outcome (impact): reduce preventable early cardiac death

## 10 year heart attack risk [@hippisley-coxDevelopmentValidationNew2024]

- prediction: heart attack in 10 years
- intervention: prescribe cholesterol lowering medication
- outcome: heart attack
- outcome (impact): reduce heart attacks

## Process

- data scientists optimize for predictive accuracy, which entails modeling statistical associations in the 'healthcare system'
- the hope is: better prediction $\imply$ better impact
- unfortunately, this is not automatically the case

# When accurate prediction models yield harmful self-fulfilling prophecies [@vanamsterdamWhenAccuratePrediction2025]

---

:::{.r-stack}

![](figs/rt_example1.png){.fragment height=24cm}

![](figs/rt_example2.png){.fragment height=24cm}

![](figs/rt_example3.png){.fragment height=24cm}

![](figs/rt_example4.png){.fragment height=24cm}

![](figs/rt_example5.png){.fragment height=24cm}

![](figs/rt_example6.png){.fragment height=24cm}

![](figs/rt_example.png){.fragment height=24cm}

:::
