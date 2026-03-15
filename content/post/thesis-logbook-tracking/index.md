---
title: Tracking
summary: "Archived note defining tracking, state variables, and the difference between observations and raw sensor data."
authors:
  - admin
tags:
  - Archive
  - Tracking
  - Thesis logbook
categories:
  - Engineering
  - Archive
date: '2026-02-24T00:00:00+01:00'
lastmod: '2026-02-24T00:00:00+01:00'
draft: false
featured: false
math: true
aliases:
  - /thesis/logbook/tracking/
---


# The problem

Tracking is the *processing of measurements* or *observations* obtained from a *target* in order to maintain an *estimate of its current* ***state***

The state of a target usually consists of:

* Kinematics - position, velocity, acceleration , turn rate, etc. expressed  w.r.t a coordinate frame
* Feature components - target classificiation, spectral characteristics, radar cross-section etc.

***Measurements or observations*** are noise-corrupted quantities which are related to the state of a target, such as

* Direct estimate of position (GPS)
* Range and azimuth(bearing) from the sensor (radar, cameras)
* Range rate (radar)

The observations are not raw data sequences but usually the output of a complex signal processing subsystem.

<center>{{< figure src="/thesis/information.png" title="Tracking system components." width="100%">}}</center>
