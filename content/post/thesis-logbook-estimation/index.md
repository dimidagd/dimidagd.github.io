---
title: Tracking as an estimation problem
summary: "Notes on state estimation, the limits of raw measurements, and the role of the estimator."
authors:
  - admin
tags:
  - Archive
  - Estimation
  - Thesis logbook
categories:
  - Engineering
  - Archive
date: '2026-02-10T00:00:00+01:00'
lastmod: '2026-02-10T00:00:00+01:00'
draft: false
featured: false
aliases:
  - /thesis/logbook/estimation/
---


# The problem

<center>{{< figure src="/thesis/SE.png" title="Mathematical view of state estimation." width="100%">}}</center>

[Multitarget-multisensor Tracking: Principles and Techniques : Yakkov Bar-Shalom Xiao-Rong Li]

***The generation of information that has the following properties***

* Quality (accuracy/reliability) higher than the raw measurements
* Contains information not directly available in the measurements


Note that in the figure above,

* No access to variables inside the first two blocks
* The only accessible variable are the measurements which are affected by noise.

# The estimator
Uses knowledge and processes the measurements to yield an estimate of a variable of interest(state or state uncertainty), while trying to make best use of the available data. In this process it is taking into account the:

* System dynamics
* Sensor Models
* Prior information & probabilistic nature of the uncertainties
