---
title: Structured Logging in the AIS Stack
summary: How the sensor-fusion services emit consistent JSON logs across the API, producer, and worker, and why that matters operationally.
authors:
  - admin
tags:
  - Logging
  - Observability
  - AIS
  - Sensor Fusion
  - Software Architecture
categories:
  - Engineering
date: '2026-01-26T00:00:00Z'
lastmod: '2026-01-26T00:00:00Z'
draft: false
featured: false
projects: []
---

Structured logging matters in this stack because AIS ingestion and track processing run across separate services, each with its own failure modes, timing issues, and throughput constraints. Plain text logs make it harder to trace a message across those boundaries. Stable event names and machine-readable fields make it practical to inspect rates, isolate bad payloads, correlate failures, and understand what the system did during restarts or degraded periods.

A small local example makes the difference clear. A plain text line such as `producer published 42.7 messages/sec to ais.raw` can be read by a person, but it is harder to filter reliably once formats drift across services. A structured event keeps the same information in fixed fields:

```json
{"timestamp":"2026-03-09T16:05:50.614524Z","level":"info","event":"published_rate","service":"ais-producer","messages_per_second":42.7,"topic":"ais.raw"}
```

That shape supports direct queries on `event`, `service`, or `topic` without having to parse free-form text.

## Step 1: Find where structured logging is configured

Structured logging is implemented with `structlog` in three runtime entry points:

- API: `app/main.py`
- Producer: `app/sfu/ais_kinesis_producer.py`
- Worker: `app/sfu/ais_ingest_worker.py`

All three define a `_configure_logging()` helper that installs a shared pipeline of processors and renders JSON to stdout. This makes logs uniform across services and easy to parse in CloudWatch.

### Shared configuration

Each service uses the same `structlog.configure(...)` settings:

- `TimeStamper(fmt="iso")`
- `add_log_level`
- `StackInfoRenderer()`
- `format_exc_info`
- `UnicodeDecoder()`
- `JSONRenderer()`

This produces JSON log events with ISO timestamps, levels, and serialized exceptions.

## Step 2: See how events are emitted

### API

`app/main.py` binds a logger and emits semantic events:

- `root_endpoint_called`
- `starting_main`

Because the logger is configured before the FastAPI app is created, the API always emits JSON logs even when run directly via `python app/main.py`.

### Producer

`app/sfu/ais_kinesis_producer.py` emits structured events that describe its lifecycle and throughput:

- `producer_config` (startup config: Kafka, topic, bbox count)
- `health_server_listening` (health endpoint bound)
- `published_rate` (messages per second)
- `producer_loop_failed` (exception details + context)
- `signal_received` (graceful shutdown)

Example local output:

```json
{"timestamp":"2026-03-09T16:05:50.614524Z","level":"info","event":"published_rate","service":"ais-producer","messages_per_second":42.7,"topic":"ais.raw"}
```

This is useful when checking whether ingestion slowed down, whether a topic is misconfigured, or whether a producer is alive but underperforming.

### Worker

`app/sfu/ais_ingest_worker.py` emits similar lifecycle and throughput events:

- `worker_config` (startup config: API, Kafka, Redis, batch settings)
- `health_server_listening`
- `incoming_rate`
- `worker_loop_failed`
- `signal_received`
- `invalid_kafka_message` (bad payloads)

These event names are stable and low-cardinality, which makes them easy to filter.

Startup configuration example:

```json
{"timestamp":"2026-03-09T16:05:50.628997Z","level":"info","event":"worker_config","service":"ais-worker","batch_size":100,"api_url":"http://localhost:8000/api/v1/processing/update"}
```

Bad payload example:

```json
{"timestamp":"2026-03-09T16:05:50.638552Z","level":"error","event":"invalid_kafka_message","service":"ais-worker","partition":2,"offset":184,"payload":"{\"mmsi\":\"bad\"}","exception":"ValueError: invalid literal for int() with base 10: 'not-a-number'"}
```

The first helps confirm runtime settings at process start. The second helps trace a specific failure without losing the partition, offset, or payload context.

## Step 3: Understand the log flow

The logging flow is the same across services:

1. Configure Python logging with a minimal formatter.
2. Configure structlog to render JSON.
3. Bind a service name with `logger = structlog.get_logger(...).bind(service=...)`.
4. Emit structured events with explicit fields instead of formatting strings.

### Log flow diagram

```mermaid
flowchart TD
  SUB[Service starts] --> CFG[_configure_logging()]
  CFG --> BIND[Bind service name]
  BIND --> EVT[Emit structured events]
  EVT --> STDOUT[JSON logs to stdout]
  STDOUT --> CW[CloudWatch Logs]
```

## Step 4: Why this design

- Consistency: The same JSON structure is emitted by API, producer, and worker.
- Queryability: Event names and fields are searchable in CloudWatch Insights.
- Safety: Exceptions are serialized and attached to the event, rather than printed raw.
- Low coupling: No external logging service is required; stdout is enough.

## Step 5: Operational usage

### Local

Structured logs appear as JSON on stdout. Example filters:

- Search for `"event": "published_rate"`
- Search for `"event": "worker_loop_failed"`

### AWS

Logs are shipped to CloudWatch via the ECS log driver. The JSON shape allows easy filtering by:

- `service`
- `event`
- `level`
- `timestamp`

## Summary

Structured logging is implemented consistently across the stack with `structlog`. Each service emits semantic event names and attaches context fields, which makes the system observable in both local and AWS environments without adding external log processors.
