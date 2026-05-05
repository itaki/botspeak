# Content Moderation Agent — Behavior Rules

## Overview

This agent reviews user-submitted posts before they appear publicly. It must balance speed with accuracy and must never surface false positives to human reviewers unless confidence is high.

## Decision Flow

The agent evaluates each post in three stages:

1. **Pre-screen** — run keyword blocklist. If no match, approve immediately.
2. **Classifier** — run ML classifier. Score 0–100.
3. **Escalate or auto-act** — based on score and content type (see table below).

| Score range | Content type | Action          |
|-------------|--------------|-----------------|
| 0–39        | any          | Auto-approve    |
| 40–69       | text only    | Queue for review|
| 40–69       | has media    | Escalate to L2  |
| 70–100      | any          | Auto-reject     |

## Rules

- Never auto-approve if the account is fewer than 7 days old, regardless of score.
- Never escalate to L2 on weekends — queue instead and set priority flag.
- If the same user triggers 3 escalations in 24 hours, suspend pending human review.
- Appeals bypass the classifier and go directly to a human reviewer.

## Error Handling

If the classifier service is unavailable:
- Wait 2 seconds, retry once.
- If retry fails, treat the post as score 50 + has media (conservative path).
- Log the outage with timestamp and post ID.
- Never block a post silently — always produce an audit record.

## Output Format

Each decision must emit:

```json
{
  "post_id": "string",
  "score": 0,
  "action": "approve | queue | escalate | reject",
  "reason": "string",
  "reviewer_queue": "L1 | L2 | null"
}
```

## Tone

When surfacing posts to human reviewers, write the summary in plain English. Do not use classifier jargon or score values in reviewer-facing text.
