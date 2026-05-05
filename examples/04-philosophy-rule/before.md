---
description: "Development philosophy for building automated, production-ready workflows"
alwaysApply: true
---

# Development Workflow Philosophy

## 🚨 THIS PROJECT IS TO DEVELOP AN ONBOARDING SOLUTION, NOT TO ACTUALLY ONBOARD ESTABLISHMENTS 🚨

### READ THIS FIRST - WHAT THIS PROJECT ACTUALLY IS

**WE ARE BUILDING THE ONBOARDING SYSTEM. WE ARE NOT ONBOARDING RESTAURANTS.**

This is a **DEVELOPMENT PROJECT** to create automated workflows that will onboard establishments in the future.

**What we ARE doing:**
- ✅ Building scripts, Edge Functions, and n8n workflows that WILL onboard establishments
- ✅ Creating automation that can process 1400+ days of data unattended
- ✅ Developing monitoring, error handling, and self-healing systems
- ✅ Testing with real data that we can destroy and recreate repeatedly
- ✅ Writing code that will run automatically when future restaurants sign up

**What we ARE NOT doing:**
- ❌ Actually onboarding the current restaurant (Fred's Italian Bistro) into production
- ❌ Manually processing their data to "get it done"
- ❌ Running one-off commands to fix their specific data issues
- ❌ Treating this data as precious production data
- ❌ Trying to "finish" onboarding this specific establishment

### The Current Data is EXPENDABLE TEST DATA

**The data in the database right now exists ONLY to test the onboarding automation.**

- We can (and should) destroy it and recreate it repeatedly
- We're testing the automation, not doing production work
- Errors in the data are GOOD - they reveal bugs in the automation
- The goal is NOT to have perfect data right now
- The goal IS to have a system that creates perfect data automatically for ANY establishment

### Before Taking ANY Action - Ask This Question:

**"Am I building the system, or am I doing the work the system should do?"**

- About to run a command to process data? → **STOP.** Build the automation that processes data.
- About to fix a data issue manually? → **STOP.** Build the system that prevents/fixes the issue.
- About to trigger workers/orchestrators manually? → **STOP.** Build the system that triggers them automatically.
- About to run a SQL query to "unstick" something? → **STOP.** Build the monitoring that detects and fixes stuck states.

**Exception:** ONE test call to verify a fix works is acceptable. Multiple manual runs = you're doing the work instead of building the system.

---

## Critical Understanding

**This is a DEVELOPMENT PROJECT, not a quick-fix operation.**

The goal is to build **automated, self-sustaining workflows** that run in production without manual intervention. We are not just trying to "get things working right now" - we are building **onboarding systems** and **production infrastructure**.

## Core Principle

**DO NOT manually fix things. BUILD systems that fix themselves.**

### ❌ Wrong Approach:
- Manually triggering Edge Functions to process pending data
- Running one-off SQL queries to fix data issues
- Using terminal commands to "unstick" processes
- Treating symptoms instead of root causes

### ✅ Right Approach:
- Identify WHY the automation failed
- Fix the workflow/system so it handles the issue automatically
- Ensure the workflow can run unattended for onboarding
- Build monitoring and self-healing into the system

## 🛑 STOP Checklist - Before Taking Any Action

Before executing ANY command, SQL query, or Edge Function call, ask:

1. **Am I manually processing data?** → STOP
   - If this involves calling orchestrators, workers, or processing pending jobs
   - ASK: "How should the system process this automatically?"

2. **Am I manually fixing a stuck state?** → STOP
   - If this involves resetting statuses, purging queues, or triggering processes
   - ASK: "Why didn't the automation detect and fix this?"

3. **Am I running this command to test if something works?** → STOP
   - One test is fine, but if you're calling it multiple times or in sequence
   - ASK: "What automated system should be doing this?"

4. **Will I need to run this again tomorrow/next week/for the next establishment?** → STOP
   - If yes, this needs to be automated, not run manually
   - ASK: "What system should handle this automatically?"

### Allowed Manual Actions (Debugging/Investigation Only):
- ✅ Reading database state (SELECT queries)
- ✅ Reading logs
- ✅ Deploying code changes
- ✅ ONE test call to verify a fix works
- ✅ Creating/modifying pg_cron jobs or system configuration

### FORBIDDEN Manual Actions:
- ❌ Calling orchestrators to queue jobs (n8n or system should do this)
- ❌ Calling workers to process data (pg_cron or orchestrator should do this)
- ❌ Purging queues and re-running (fix why queue got duplicates)
- ❌ Multiple sequential manual triggers "to see if it works now"

## When You Catch Yourself About To Do Something Manual

**STOP and write:**
1. "I was about to [manual action]"
2. "The automation gap is: [why system didn't do this automatically]"
3. "The fix needed is: [how to make system do this automatically]"
4. "Should I proceed with this fix? (Y/N)"

Then WAIT for user response.

## Specific Context: Soviet Extractor Workflow

### The Goal

Build an **onboarding workflow** that:
1. Fetches CSV files from Soviet SFTP
2. Uploads them to Supabase Storage
3. Automatically imports them into the database
4. Monitors progress and handles errors
5. **Runs completely unattended** for new establishment onboarding

### What "Onboarding" Means

When a new restaurant signs up:
- The workflow should process **1400+ days of historical data**
- It should run **without any manual intervention**
- It should **detect and recover from errors automatically**
- It should **notify when complete** or when manual intervention is truly needed

### Current Development Phase

We are building and testing the **orchestration and monitoring system**:
- n8n workflow orchestrates the entire process
- Supabase Edge Functions handle heavy processing
- PGMQ manages job queues
- Workers process jobs in parallel
- Status checker monitors progress
- n8n detects stuck states and restarts orchestrator

## When Manual Intervention IS Appropriate

**Only in these cases:**
1. **Deploying code changes** (migrations, Edge Functions)
2. **Testing specific components** (verify a fix works)
3. **Investigating root causes** (query database to understand why something failed)
4. **One-time setup** (creating pg_cron jobs, initial configuration)

**NOT for:**
- Processing pending data that should be handled by workers
- Restarting stuck processes that should auto-restart
- Fixing data issues that will recur on next run

## Remember

**We're building a production onboarding system, not fixing a broken database.**

Every decision should be evaluated through the lens of:
- "Will this work for onboarding a new restaurant?"
- "Can this run unattended?"
- "Does this make the system more robust?"

**The goal is automation, not manual intervention.**
