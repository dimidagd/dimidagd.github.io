---
title: State space
summary: "Planar vessel state vectors in Cartesian and polar form."
authors:
  - admin
tags:
  - Archive
  - Tracking
  - State space
  - Thesis logbook
categories:
  - Engineering
  - Archive
date: '2026-01-20T00:00:00+01:00'
lastmod: '2026-01-20T00:00:00+01:00'
draft: false
featured: false
math: true
aliases:
  - /thesis/logbook/state_space/
---


## State vector
Assuming the target's motion on the ***two-dimensional*** own-ship's tracking plane, then two different state-space descriptions can be used depending on the expression of the velocity vector:

- Cartesian velocity model
$$\mathbf{x} = \left[x,y,\dot{x}, \dot{y},\omega\right]^{T} $$

-  Polar velocity model
$$\mathbf{x} = \left[x,y,\upsilon, \psi,\omega\right]^{T} $$

where

$$
\begin{align*}
\upsilon &= \sqrt{\dot{x}^2 + \dot{y}^2}  \\\\
\psi &= \arctan\left(\frac{\dot{y}}{\dot{x}}\right) \\\\
\omega &= \dot{\psi}
\end{align*}
$$



* $(x,y)$ is the displacement relative to the local self-body fixed coordinate system

* $\upsilon$ is the target's linear velocity

* $\psi$ is the heading angle w.r.t the tracking system's x-axis.

* $\omega$ is the turn-rate of the target

all expressed w.r.t the own-ship's tracking coordinate system.


{{< figure src="/thesis/2d_track.png" title="Tracked target state vector top view, in the tracking coordinate system" width="50%">}}
