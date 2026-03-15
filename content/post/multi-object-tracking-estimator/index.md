---
title: Multi Object Tracking framework diagnostics
subtitle: A structured read of NIS, NEES, covariance, and motion-state plots from a vessel estimator.
summary: The useful question in multi-object tracking is not whether the tracker draws a smooth path. It is whether the estimator stays consistent as measurements become partial, noisy, or uneven. This article reads one default run through the diagnostics exported by the filter.
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
math: true
projects: []
---

A tracker can keep a clean trajectory on screen and still drift into a bad estimate. The plots exported by the estimator are useful because they show when that drift starts, which state is weakening, and whether the filter is still honest about its own uncertainty.

This post reads one default multi-object run from the `sensor-fusion` estimator. The goal is simple: move from “the plots look fine” to “the estimator is holding together for reasons we can explain.”

**At a glance**

- The estimator tracks five states: latitude, longitude, speed over ground, course over ground, and turn rate.
- Only full AIS updates observe speed and course directly.
- Two tracks settle after a noisy start.
- One track develops a late consistency problem, first visible in motion-state uncertainty and then in NEES.

## What the filter is estimating

The current estimator uses a five-state vessel model:

| State index | Variable | Meaning |
| --- | --- | --- |
| 0 | `lat` | Latitude |
| 1 | `lon` | Longitude |
| 2 | `sog` | Speed over ground |
| 3 | `cog` | Course over ground |
| 4 | `turn_rate` | Turn rate |

That state is not supported equally by every measurement. The measurement models in the implementation observe different slices of the state vector:

| Measurement type | `lat` | `lon` | `sog` | `cog` | `turn_rate` |
| --- | --- | --- | --- | --- | --- |
| AIS | yes | yes | yes | yes | no |
| Truncated AIS | yes | yes | no | no | no |
| Position measurement | yes | yes | no | no | no |

This shapes the whole problem. Position is updated often. Motion is not. `turn_rate` is never directly observed in this setup, and `cog` and `sog` depend on the mix of measurements arriving over time.

The implementation makes that split explicit:

```python
def AISMeasurementModel() -> LinearMeasurementModel:
    return LinearMeasurementModel(
        state_indices=[0, 1, 2, 3],
    )


def TruncatedAISMeasurementModel() -> LinearMeasurementModel:
    return LinearMeasurementModel(
        state_indices=[0, 1],
    )


def PositionMeasurementModel() -> LinearMeasurementModel:
    return LinearMeasurementModel(
        state_indices=[0, 1],
    )
```

The tentative-track logic already reflects that. Before a track is fully alive, the estimator derives velocity and heading from positional history. Once the track becomes active, the constant-turn-rate model carries the motion states forward until a richer update arrives.

## How to read NIS and NEES

The first two plots answer the same question from different angles.

- NIS asks whether the latest measurement fits the predicted track state.
- NEES asks whether the full estimated state fits the ground truth, given the covariance the filter carries.

Rising NIS means the update step is under strain. Rising NEES means the estimator has become too optimistic, too wrong, or both.

For one update, the estimator computes the normalized innovation squared as

$$
\mathrm{NIS}_k = \mathbf{y}_k^\top \mathbf{S}_k^{-1} \mathbf{y}_k
$$

where $\mathbf{y}_k = \mathbf{z}_k - \hat{\mathbf{z}}_k$ is the innovation and $\mathbf{S}_k$ is the innovation covariance.

NIS has a practical advantage over NEES: it does not require ground truth. That makes it a standalone consistency metric for live filtering. If NIS starts drifting, the problem can sit in the measurement model, the motion model, the assumed process noise, or assumptions about the types of their noise distributions.

The update step in the filter computes NIS directly from the innovation:

```python
z = measurement.to_vector()
z_pred = model.h(pred_track_state)
H = model.H(pred_track_state)
R = measurement.R()

y = z - z_pred
for idx in angular_measurement_indeces:
    y[idx] = angle_residual_deg(z[idx], z_pred[idx])

S = H @ pred_track_state.P @ H.T + R
S_inv = np.linalg.inv(S)
nis = y.T @ S_inv @ y
```

In repo terms, the symbols in the equation map cleanly onto the update code:

- $\mathbf{z}_k$ is `measurement.to_vector()`
- $\hat{\mathbf{z}}_k$ is `model.h(pred_track_state)`
- $\mathbf{S}_k$ is `H @ pred_track_state.P @ H.T + R`
- $\mathbf{y}_k$ is the residual `y`

For one state estimate, the normalized estimation error squared is

$$
\mathrm{NEES}_k = \mathbf{e}_k^\top \mathbf{P}_k^{-1} \mathbf{e}_k
$$

where $\mathbf{e}_k = \hat{\mathbf{x}}_k - \mathbf{x}_k$ is the state error and $\mathbf{P}_k$ is the predicted state covariance.

Unlike NIS, NEES needs ground truth for the full state. That makes it useful in simulation and offline evaluation, but not as a standalone live diagnostic.

The state side of that equation is also explicit in the repo:

```python
class LatLonSogCogTRState(TrackState):
    STATE_ORDER = {0: "lat", 1: "lon", 2: "sog", 3: "cog", 4: "turn_rate"}

    def to_vector(self) -> np.ndarray:
        vec = np.array(
            [getattr(self, self.state_order()[i]) for i in sorted(self.STATE_ORDER)],
            dtype=float,
        )
        return vec.reshape(-1, 1)

    @property
    def P(self) -> np.ndarray:
        return np.array(self.covariance, dtype=float)
```

That means $\hat{\mathbf{x}}_k$ is the state vector returned by `pred_track_state.to_vector()`, and $\mathbf{P}_k$ is the covariance matrix exposed as `pred_track_state.P`. The ground-truth term $\mathbf{x}_k$ only exists in the simulated runs used to generate the evaluation plots.

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
  <figcaption>NEES from the same run. This compares the full state estimate against ground truth.</figcaption>
</figure>

In this run, `MV Iron Falcon2` starts with large NIS and NEES values, then settles once the filter gets enough support. `SS Iron Aurora1` stays in a tighter band after initialization. `SS Northern Star0` behaves differently. Its NIS rises late, and its NEES jumps sharply near the end of the run. That is the clearest sign in the article: the track is no longer consistent at the state level.

## What this run shows track by track

The three tracks do not fail in the same way:

| Track | Main pattern | Reading |
| --- | --- | --- |
| `MV Iron Falcon2` | Large early NIS and NEES, then settles | Noisy startup, then convergence |
| `SS Iron Aurora1` | Moderate errors and narrower spread | Broadly stable after initialization |
| `SS Northern Star0` | Late NIS rise and a large NEES spike | State estimate breaks down late in the run |

The timing matters. Startup noise is common while a filter is still locking onto a target. Late divergence is harder to excuse, because it means the estimator had already built a coherent track and then lost that coherence as new data came in.

That is why NEES is so useful here. A smooth plotted trajectory can still hide a state estimate that no longer matches the covariance the filter claims to have.

## Why course breaks before position

The covariance and motion-state plots make the weak point visible.

<figure>
  <iframe
    src="/plots/sensor-fusion-default/covariances.html"
    title="State covariance standard deviations over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Square-root covariance terms for the five-state estimator. `std[3]` is course over ground and `std[4]` is turn rate.</figcaption>
</figure>

The largest growth appears in `state[3]`, the course state. `SS Northern Star0` shows the most severe spike there, which lines up with the late consistency failure in the NEES plot. Position remains much better behaved because every measurement updates `lat` and `lon`.

The course plot shows the same weakness from the state trajectory itself:

<figure>
  <iframe
    src="/plots/sensor-fusion-default/cog.html"
    title="Course over ground over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Course over ground with mixed measurement support. The continuous line is the predicted state. Marker shapes indicate the measurement type used at each update.</figcaption>
</figure>

Only full AIS updates observe course directly. Position-only and truncated AIS updates do not. When the estimator goes several updates without direct support for `cog`, it has to rely on the motion model to carry that state. The plotted path can remain smooth while the motion estimate becomes weaker.

The speed plot follows the same pattern:

<figure>
  <iframe
    src="/plots/sensor-fusion-default/sog.html"
    title="Speed over ground over time"
    loading="lazy"
    style="width:100%;height:760px;border:1px solid rgba(0,0,0,0.12);border-radius:8px;background:#fff;"
  ></iframe>
  <figcaption>Speed over ground from the same run. Motion states are inferred between direct observations; they are not continuously measured.</figcaption>
</figure>

This is the main structural asymmetry in the estimator. Position is heavily supported. Motion is partly inferred. That makes course and speed the first places to look when a track starts to weaken.

## What to watch in practice

These plots point to a short checklist for reading multi-object tracking output:

- Do not treat a smooth map track as evidence that the full state estimate is sound.
- Read NIS and NEES together. A late rise in both is more serious than a noisy start.
- Watch covariance growth in motion states, especially course, before assuming the filter is stable.
- Remember which states are directly observed and which states are being carried by the model.

That is why estimator diagnostics belong in the article at all. They turn a tracking demo into an engineering argument. Instead of asking whether the tracker produced a plausible line, you can ask where it was well supported, where it was extrapolating, and where it stopped being trustworthy.
