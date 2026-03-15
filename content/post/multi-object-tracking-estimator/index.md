---
title: What estimator plots say about multi object tracking
subtitle: Reading NIS, NEES, covariance, and course traces from a vessel tracker.
summary: A tracking plot is only useful if it tells you where the estimator is holding together and where it is not. This article reads a default multi-object run through the diagnostics exported by the estimator.
authors:
  - admin
tags:
  - Tracking
  - Estimation
  - Sensor Fusion
  - Maritime
  - Kalman Filter
categories:
  - Engineering
  - Maritime Technology
date: '2026-03-15T00:00:00Z'
lastmod: '2026-03-15T00:00:00Z'
draft: false
featured: false
projects: []
---

A tracker can draw a clean line on a chart and still be wrong. The harder question is whether the estimator behind that line is still believable.

In this run, the diagnostic plots are more informative than the map view. They show which tracks settle, which states stay weakly observed, and where the filter starts to lose statistical consistency.

## The estimator behind the plots

The current implementation carries a five-state vessel model:

| State index | Variable | Meaning |
| --- | --- | --- |
| 0 | `lat` | Latitude |
| 1 | `lon` | Longitude |
| 2 | `sog` | Speed over ground |
| 3 | `cog` | Course over ground |
| 4 | `turn_rate` | Turn rate |

For active tracks, the estimator predicts forward with a constant-turn-rate motion model and then updates against the measurement that arrives. The important detail is that not every measurement observes the full state. AIS updates carry position, speed, and course. Truncated AIS and positional measurements carry position only.

That split matters because it means the tracker is solving two problems at once:

- keep position stable under uneven updates
- infer hidden motion states when speed and course are not directly observed

Tentative tracks make that even clearer. Before a track is fully alive, the implementation estimates velocity and heading from the positional history alone. The filter is already reasoning about missing information before it ever looks confident on screen.

## NIS and NEES are the first check

Two plots carry most of the argument.

- NIS checks whether each update is plausible under the current measurement model.
- NEES checks whether the full state error is plausible under the covariance the filter claims to have.

If both stay in a sensible range, the estimator is broadly honest about what it knows. If NIS rises, the incoming measurements are no longer fitting the predicted track well. If NEES rises, the full state estimate is no longer matching reality as well as the covariance says it should.

<figure>
  <iframe
    src="/plots/sensor-fusion-default/NIS.html"
    title="Normalized innovation squared over time"
    loading="lazy"
    style="width:100%;height:560px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>NIS from the default estimator log. Each trace is the mean innovation statistic stored after an update.</figcaption>
</figure>

<figure>
  <iframe
    src="/plots/sensor-fusion-default/NEES.html"
    title="Normalized estimation error squared over time"
    loading="lazy"
    style="width:100%;height:560px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>NEES from the same run. This is the stronger check because it compares the full estimated state against ground truth.</figcaption>
</figure>

The pattern is clear. `MV Iron Falcon2` starts rough, with very large early NIS and NEES values, then settles after the filter gets enough support. `SS Iron Aurora1` behaves better after initialization and stays in a narrower band. `SS Northern Star0` is the one to watch. Its NIS rises late, and its NEES blows up near the end of the run. That is the signature of a track that has stopped being internally consistent.

## This run converges for two tracks and breaks for one

The three named tracks in the log do not fail in the same way.

| Track | What improves | What stays weak |
| --- | --- | --- |
| `MV Iron Falcon2` | Update fit and state consistency both settle after a poor start | Initialization is noisy |
| `SS Iron Aurora1` | Broadly stable after the first updates | Course remains less certain than position |
| `SS Northern Star0` | Holds together for part of the run | Late NIS rise and a large NEES spike show a state-level mismatch |

The late `SS Northern Star0` jump matters more than the early startup noise on the other two tracks. Large early errors are common while a filter is still finding the track. A late divergence means the estimator had already formed a story about the target and then could not keep that story coherent as new data arrived.

The covariance export shows where that weakness sits.

<figure>
  <iframe
    src="/plots/sensor-fusion-default/covariances.html"
    title="State covariance standard deviations over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Square-root covariance terms for the five-state estimator. Because the state order is fixed, `std[3]` is course over ground and `std[4]` is turn rate.</figcaption>
</figure>

The strongest growth is in `state[3]`, the course state. `SS Northern Star0` shows the largest spike there, which matches the late consistency failure in the NEES plot. Position stays comparatively tame. Heading uncertainty is what expands first.

## Partial measurements make course fragile

The course plot explains why.

<figure>
  <iframe
    src="/plots/sensor-fusion-default/cog.html"
    title="Course over ground over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Course over ground with mixed measurement support. The continuous line is the predicted track state. Marker shapes show which measurement type arrived at each update.</figcaption>
</figure>

In this implementation, only full AIS updates directly observe course. Position-only measurements and truncated AIS updates do not. That leaves the estimator to carry `cog` forward through the motion model until a richer update arrives. When that gap lasts too long, the tracker can keep looking smooth while becoming less trustworthy.

The same effect shows up in speed.

<figure>
  <iframe
    src="/plots/sensor-fusion-default/sog.html"
    title="Speed over ground over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Speed over ground from the same run. Hidden motion states are inferred between direct observations, not continuously measured.</figcaption>
</figure>

That is the practical lesson from these plots. Track IDs and smooth trajectories are not enough. The estimator also has to stay honest about partially observed motion. Position can look fine while course, speed, and turn behavior drift into a weaker estimate. NIS, NEES, and covariance growth show that drift before a map display makes it obvious.
