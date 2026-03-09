---
title: Multi-Source Vessel Tracking Is the Practical Baseline
subtitle: What a small sensor-fusion project makes clear about maritime visibility.

summary: A plain-language argument for multi-source vessel tracking, connected to the design choices behind the sensor-fusion project.

authors:
  - admin

tags:
  - Maritime
  - Sensor Fusion
  - Tracking
  - AIS
  - Software Architecture

categories:
  - Engineering
  - Maritime Technology

date: '2026-03-09T00:00:00Z'
lastmod: '2026-03-09T00:00:00Z'
draft: false
featured: false
projects: []
---

[`sensor-fusion`](https://github.com/dimidagd/sensor-fusion) started as a software project: ingest AIS messages, maintain track state, expose the result through an API, and display it on a map. The work quickly moved past UI and message plumbing. It led to a more basic question: what kind of vessel picture is actually trustworthy?

The answer is not complicated. A system that relies on one feed inherits the weaknesses of that feed. In maritime tracking, that is a serious limitation.

AIS is useful because it gives structured vessel-reported identity, position, speed, and course. It is also cooperative by design. The vessel has to transmit, the signal has to arrive, and the message has to be accepted as meaningful. When any of that fails, a single-source system loses ground immediately. Coverage drops. Messages arrive late. Transponders go silent. Positions can be wrong. Identities can be spoofed. GNSS interference can degrade what looks like normal telemetry.[1][4][5][6]

That is the operational reason multi-source vessel tracking keeps becoming the default. The point is not to collect data for its own sake. The point is to cross-check one partial view of the world against another.

Satellite imagery and SAR do not depend on a vessel deciding to broadcast. AIS does. Historical state and telemetry add continuity across time. A filtering layer adds a disciplined way to carry uncertainty from one observation to the next. Once those pieces are combined, the system can ask better questions:

- Is a vessel visible without a corresponding AIS identity?
- Is the transmitted track consistent with recent motion?
- Is the claimed position consistent with another source?
- How much confidence should be attached to the current state estimate?

Those questions matter in exactly the places where maritime monitoring matters most: dark-vessel detection, sanctions screening, illegal fishing enforcement, infrastructure protection, and compliance review.[3][4][6][11]

The `sensor-fusion` project does not attempt to solve the whole problem. It is a prototype. It works with live AIS ingestion, a streaming layer, a processing API, persistent state, and a map UI. Even at that scale, the architecture makes the limits of a single-source setup obvious.

The current system has a producer that ingests AIS messages, a durable stream in the middle, a worker that converts messages into observations, and a FastAPI layer that handles association and track updates. The processing logic is exposed through separate endpoints for assignment and update:

- `POST /api/v1/processing/assign`
- `POST /api/v1/processing/update`

That separation is useful because vessel tracking is not one operation. It includes ingestion, normalization, correlation, filtering, persistence, and presentation. A clean output on a map depends on every step before it.

The filtering layer in [`app/sfu/filtering.py`](https://github.com/dimidagd/sensor-fusion/blob/main/app/sfu/filtering.py) makes the same point in a more concrete form. Track state is predicted forward and then corrected based on the type of measurement that arrives. Some measurements update lat/lon only. Others update lat/lon, speed, and course. The filter carries covariance and computes innovation against the current estimate. That matters because vessel observations are uneven. Without a state estimator, the system becomes a sequence of replacements. Each new message overrides the last one, and every noisy or partial observation leaks straight into the displayed track.

That is a software concern, but it is also an operational one. A system that cannot represent uncertainty is easy to mistake for a system that has removed uncertainty.

The streaming layer exposes another part of the same problem. Tracking is temporal. Ordering, replay, retry behavior, and checkpointing are not infrastructure details sitting off to the side. They determine what the processing layer actually sees and what can be reconstructed later. That is why the AWS deployment in the project moved from Kafka/MSK to Amazon Kinesis Data Streams. The requirement was not Kafka itself. The requirement was a durable ordered stream between ingestion and processing without carrying the overhead of managing broker infrastructure in a small deployment. The architecture followed the operational constraint.

This is the main lesson from the project: once vessel tracking is treated as an evidence problem instead of a feed-display problem, the system design changes.

A single AIS stream is enough to render markers on a map. It is not enough to support strong claims about what is happening at sea.

A multi-source system changes the standard. Each input becomes one piece of evidence rather than the full picture. The job of the software stops being "show the latest message" and becomes "maintain the best current explanation of vessel state, given incomplete and uneven inputs over time." That is a harder problem. It is also the real one.

The longer report in [`sensor-fusion/journal/report.md`](https://github.com/dimidagd/sensor-fusion/blob/main/journal/report.md) makes that argument at the industry level. The project makes it visible at the engineering level. Single-source tracking is easy to start with because the pipeline is simpler and the outputs look convincing very early. Multi-source tracking becomes necessary as soon as accuracy, resilience, and defensibility matter.

The next steps in the project follow directly from that conclusion:

- add non-AIS observations so cooperative and non-cooperative detections can be compared directly
- expose uncertainty and diagnostics more clearly in the API and UI
- strengthen historical reasoning around continuity and anomaly detection
- make the source-to-track path easier to inspect

Those changes would not just improve the demo. They would move it closer to the actual standard maritime systems need to meet.

## References

[1] CLS. (2024). *Discover MAS: Smart data fusion for comprehensive maritime understanding.* https://maritime-intelligence.groupcls.com/discover-mas-smart-data-fusion-for-comprehensive-maritime-understanding/

[3] DataWalk. (2025, September 23). *Identifying emerging security threats through satellite data fusion.* https://datawalk.com/illuminating-the-invisible-how-ubotica-is-revolutionising-dark-vessel-detection/

[4] Polestar Global. (2025, February 17). *Vessel tracking.* https://www.polestarglobal.com/use-cases/vessel-tracking/

[5] ShipUniverse. (2025, November 30). *Digital maritime surveillance made simple: 2026 update.* https://www.shipuniverse.com/tech/digital-maritime-surveillance-made-simple-2026-update/

[6] Ubotica. (2025, March 12). *How Ubotica is revolutionising dark vessel detection.* https://ubotica.com/illuminating-the-invisible-how-ubotica-is-revolutionising-dark-vessel-detection/

[11] Kpler. (2025, January 1). *Maritime compliance landscape shifting from reactive to predictive 2026.* https://www.kpler.com/blog/maritime-compliance-landscape-shifting-reactive-predictive-2026
