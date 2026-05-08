---
description: Development philosophy for building automated production workflows
alwaysApply: true
---

# Development Workflow Philosophy

## The Core Project Goal

Always: You are building the onboarding system automation for the restaurant onboarding project. You are not actually onboarding real restaurants. The onboarding system development project refers to automated workflows that will onboard establishments in the future. The current restaurant (Fred's Italian Bistro) is a test vehicle only. The expendable test data is only used to test the onboarding automation.

You can and should:
- Destroy the expendable test data and recreate it repeatedly
- Treat errors as automation bugs, which are valuable learning opportunities

You are forbidden from:
- Manually processing 1400 or more days of data
- "Finishing" Fred's onboarding in production
- Treating the expendable test data as precious production data

## Core Principle

Always: You must never manually fix things. Instead:
- Always identify why the automation failed
- Always fix the workflow so it handles the issue automatically
- Always ensure the workflow runs unattended for onboarding
- Always build monitoring and self-healing capabilities into the system

## STOP Checklist (Before Any Action)

Always: Ask yourself before executing any command, SQL query, or entity framework call:

1. **Are you manually processing data?** → This is forbidden. Stop.
 - If you are: calling orchestrators, calling workers, or processing pending jobs
 - Ask yourself: "How should the system process this automatically?"

2. **Are you manually fixing a stuck state?** → This is forbidden. Stop.
 - If you are: resetting status, purging queues, or triggering a process
 - Ask yourself: "Why didn't automation detect and fix this?"

3. **Are you running something just to test if it works?** → This is forbidden for repeated tests. Stop.
 - One test call is allowed, but multiple calls or sequences require building an automated system
 - Ask yourself: "What automated system should do this?"

4. **Will you need to repeat this action tomorrow, next week, or for the next establishment?** → This is forbidden. Stop.
 - If the answer is yes: This needs automation, not a manual run
 - Ask yourself: "What system should handle this automatically?"

### Actions That Are Allowed (For Debug and Investigation Only)
- SELECT queries
- Reading logs
- Deploying code
- One test call
- Creating pg_cron jobs

### Actions That Are Forbidden (Never Acceptable)
- Calling orchestrators (n8n or the system should do this)
- Calling workers (pg_cron or the orchestrator should do this)
- Purging queues and re-running (fix why duplicates occurred instead)
- Multiple sequential manual triggers

## When You Catch Yourself About to Act Manually

Always: Stop and write the following:
1. "I was about to [describe the manual action]"
2. "The automation gap is: [explain why the system didn't do this automatically]"
3. "The fix needed is: [describe how to make the system do this automatically]"
4. "Should I proceed? (Y/N)"

Then wait for the user to respond.

## Soviet Extractor Workflow Context

The goal is to build onboarding automation that:
1. Fetches CSV from Soviet SFTP
2. Uploads to Supabase Storage
3. Auto-imports into database
4. Monitors progress and handles errors
5. Must run completely unattended for new establishments

By "onboarding" we mean: when a new restaurant signs up, the workflow processes 1400 or more days of historical data. It runs without manual intervention, detects and recovers from errors automatically, and notifies you when complete (or only if true manual intervention is genuinely needed).

### Current Development Phase Architecture
- n8n orchestrates the entire process
- Supabase Edge Functions handle heavy processing
- PGMQ manages job queues
- Workers handle parallel processing
- Status checker monitors progress
- n8n detects when processes get stuck and restarts the orchestrator

## When Manual Intervention Is Appropriate

Always: Manual action is acceptable only for:
1. Deploying code (running migrations and Edge Framework changes)
2. Testing specific components (to verify a fix works)
3. Investigating root causes (querying the database to understand a failure)
4. One-time setup (creating pg_cron jobs and initial configuration)

Manual action is forbidden for:
- Processing pending data (workers should do this)
- Restarting stuck processes (auto-restart should handle this)
- Fixing data issues that recur (prevent the root cause instead)

## Remember These Principles

Always:
- Your goal is automation, not manual intervention
- Evaluate every decision by asking: "Will this work for onboarding a new restaurant?"
- Can this run unattended?
- Does this make the system more robust?

---

## What This Means in Practice

This philosophy document establishes a hard boundary between what constitutes legitimate debugging and what constitutes taking shortcuts that will break the system at scale. The key insight is that Fred's Italian Bistro is not a real customer—it's a testing vehicle for automation, and testing data can be destroyed and recreated freely. The moment you find yourself manually processing data, manually fixing state, running one-off tests without building systems around them, or repeating actions that should be automated, you are building technical debt, not automation.

The practical impact is that every manual intervention must trigger a question: "Why didn't the system handle this automatically, and what system change do I need to make so it does in the future?" The "STOP Checklist" serves as a circuit breaker—it forces you to pause before acting and either identify the automation gap or confirm that the action genuinely falls into the small allowed set (debugging, deploying, investigating).

For the Soviet Extractor workflow specifically, this means the entire onboarding process must work end-to-end without you touching anything once it starts. Monitoring, self-healing, and error recovery are not nice-to-have features—they are core requirements because production will not have a human ready to intervene every time something gets stuck.
