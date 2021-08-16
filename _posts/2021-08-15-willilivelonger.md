---
title: Will this treatment make me live longer?
output: pdf_document
date: '2021-08-16'
tags:
- causal inference 
- statistics 
permalink: '/posts/2021-08-16-willilivelonger'
postname: '2021-08-16-willilivelonger'
pdf: true
rmd: false
header-includes:
  - \usepackage{mathrsfs}
---

(in comes a patient with disease D)

Patient: Doctor, will I live longer if I take this treatment?

--- Doctor: We cannot be sure, but most likely you will

Patient: OK, then what is the probability that I will live longer if I take this treatment?

--- Doctor: We cannot be sure, somewhere between 50% and 100%

Patient: Can you be more specific? I have a PhD in statistics

<!----- Doctor: OK, If you tell me what Bayes optimal error is for $\int_{-\infty}^{\infty}\mathbf{I}_{p(y|do(X=1),Z) > p(y|do(X=0),Z)} dy$ where $Z$ indicates everything about you including the things we cannot measure or know then I'll give you your answer.-->

Interestingly, it is impossible to answer this very basic and important question: **"What is the probability that I will live longer if I take this treatment?"**
To show you why I will first define the question and then show how the unknown sources of randomness make answering this question impossible.

## Defining the question

Let's define the question as follows (using a frequentistic interpretation of probability):

Given an infinite number of **exact** replicas of this patient, if we give the treatment to half of them, in what proportion of times that the copies with treatments live longer than the copies with the treatment?

The emphasis here is on **exact**. With exact we mean not only the *known* characteristics of this patient but also the *unknown* characteristics up to every cell, brain connection, etcetera.

## Setting up the answer

It turns out that the answer to this question depends on unknowable things about the world.
Let's assume that we have information from a huge randomized controlled trial.
This trial tells us that patients with disease D live on average 13 months when they get treated, versus 12 months when not treated.
However, there is residual variance in overall survival and some patients who were treated will liver shorter than 12 months and some untreated patients will live longer than 13 months.
Specifically, the distribution of survival is a Gaussian distribution with mean 13 and standard deviation 2 for treated patients
and a Gaussian distribution with mean 12 and standard deviation 2 for untreated patients.
We will assume that the trial was large enough to measure the means and standard deviations for these groups with negligible error.

The gist of the problem is this: *how much of the residual error comes from unmodeled patients characteristics, and how much comes from intrinsic randomness?*.
Obviously we know that no two patients are alike.
For example, we may expect that patients who are younger and in good overall health will liver longer than older and weaker patients.
This will be true regardless of whether they are treated or not.
However, there will also be 

## Conclusion

