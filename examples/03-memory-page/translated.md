---
title: React Stale Closure Pattern
tags: [react, hooks, debugging, performance]
updated: 2026-05-04
source: claude-history-ingest / DabaBase session 2026-04-12
---

# React Stale Closure Pattern

## Summary

In every turn: a stale closure is when a function closes over a variable from component scope and retains the OLD value instead of the current value.

  Cause: JavaScript closures capture the value at function-creation-time, not call-time.
  Common: useEffect with an incorrect or empty dependency array; event-listeners registered once.

## What Is Stale Closure

In every turn, a stale closure occurs when:

  A function defined inside a component closes over a component-scope variable.
  The function retains a reference to the OLD value (not current).
  JavaScript closures capture the value at creation-time (not call-time).

Most common (in React):

  useEffect with an incorrect or empty dependency array.
  Event-listeners registered once, never updated.

## Common Causes

### Empty Dependency Array with Dynamic Values

In every turn:

  An empty dependency array combined with useEffect referencing state or props is a BUG.
  An empty dependency array tells React: run once (mount-only).
  The callback captures the INITIAL variable values.
  If those variables change later, the callback still sees the OLD values.

```javascript
function Counter() {
  const [count, setCount] = useState(0);
  useEffect(() => {
    const interval = setInterval(() => {
      // BUG: count always 0 · closure created when count=0
      console.log('Current count:', count);
    }, 1000);
    return () => clearInterval(interval);
  }, []); // Empty DA -> closure forever count=0
}
```

### Event Listeners

In every turn:

  `addEventListener` combined with useEffect whose dependency array does not include all the variables used inside the listener produces stale values.
  The listener captures old values from closure-time.

## Solutions

### Option 1: Add Variable to Dependency Array

```javascript
useEffect(() => {
  const interval = setInterval(() => {
    console.log('Current count:', count);
  }, 1000);
  return () => clearInterval(interval);
}, [count]); // Correctly re-runs when count changes
```

### Option 2: Use Ref to Track Current Value

```javascript
const countRef = useRef(count);
countRef.current = count;
useEffect(() => {
  const interval = setInterval(() => {
    console.log('Current count:', countRef.current); // Always current
  }, 1000);
  return () => clearInterval(interval);
}, []); // Safe · reading from ref · not closure
```

### Option 3: Functional Form of setState

```javascript
setCount(currentCount => currentCount + 1); // Always uses latest
```

## When to Suspect Stale Closure

In every turn, suspect a stale closure when:

  A value inside useEffect, useCallback, or an event-listener always shows the initial value (not the current one).
  Unexpected behavior occurs after state-updates.
  An interval or timeout is operating on old data.
  ESLint's exhaustive-deps rule is flagging a missing dependency.

## Related Patterns

- [[useCallback and useMemo memoization]]
- [[React dependency array rules]]
- [[Event listener cleanup in useEffect]]

## Sources

Extracted from Data Development Project session 2026-04-12, discussion of dashboard real-time update bug. The bug was a stale closure in a WebSocket event listener.
