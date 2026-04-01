---
title: "LaunchPad Manager"
date: 2026-03-15
tags: ["swift", "macos", "native-app", "devtools"]
draft: false
---

## A native macOS app for managing launchd services

macOS uses `launchd` to manage background services, scheduled tasks, and daemons. The built-in tooling for this is `launchctl` — a CLI tool with inconsistent syntax and no visual interface. LaunchPad Manager fixes that.

**What it does:**

A SwiftUI app with three main sections:

**Dashboard** — Shows all registered services with live status indicators, filtering by domain (user/system/global), sorting by name or status, and hover-accessible actions (start, stop, unload). Status auto-refreshes every 10 seconds via the `launchctl` actor.

**Visual Builder** — A form-based interface for creating launchd property lists. Instead of hand-editing XML, you fill in collapsible sections for identity, program arguments, scheduling (with presets and calendar pickers), environment variables, and resource throttling. An XML preview shows exactly what will be written to disk.

**Service Detail** — Full configuration summary for any service, plus a log viewer with search, auto-refresh, and error highlighting.

**Architecture:** 3,300 lines of Swift across 16 files in three layers — Models (LaunchJob data type, PlistParser for XML/binary plists, LaunchctlService actor), ViewModels (DashboardViewModel with discovery and auto-refresh, BuilderViewModel with validation and XML generation), and Views (NavigationSplitView shell with sidebar navigation).

**Stack:** Swift, SwiftUI, macOS 13+, Concurrency (actors)
