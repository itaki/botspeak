---
title: React Stale Closure Pattern
tags: [react, hooks, debugging, performance]
updated: 2026-05-04
source: claude-history-ingest / DabaBase session 2026-04-12
---

# React Stale Closure Pattern

## Summary

This page documents the stale closure problem in React hooks, which is one of the most common sources of subtle bugs when working with `useEffect`, `useCallback`, and event listeners in functional components.

## What Is a Stale Closure?

A stale closure occurs when a function defined inside a React component "closes over" a variable from the component's scope, but the function retains a reference to the *old* value of that variable rather than the current one. This happens because JavaScript closures capture the value of a variable at the time the function is created, not at the time it is called.

In React, this most commonly happens with `useEffect` hooks that have incorrect or empty dependency arrays, or with event listeners that are registered once and never updated.

## Common Causes

### Empty Dependency Array with Dynamic Values

The most common cause is using an empty dependency array `[]` with a `useEffect` that references state or props. The empty array tells React to run the effect only once (on mount), but the callback function captures the initial values of any variables it references. If those variables change later, the callback still sees the old values.

```javascript
function Counter() {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    const interval = setInterval(() => {
      // BUG: count is always 0 here, no matter how many times setCount is called
      // This is because the closure was created when count was 0
      console.log('Current count:', count);
    }, 1000);
    
    return () => clearInterval(interval);
  }, []); // Empty array → closure captures count=0 forever
}
```

### Event Listeners

Event listeners registered with `addEventListener` are another common culprit. If you register a listener in a `useEffect` with a dependency array that doesn't include all the variables the listener uses, the listener will have stale values.

## Solutions

### Option 1: Add the Variable to the Dependency Array

The simplest fix is to add the variable to the dependency array. This causes the effect to re-run (and re-register the listener) whenever the variable changes.

```javascript
useEffect(() => {
  const interval = setInterval(() => {
    console.log('Current count:', count);
  }, 1000);
  return () => clearInterval(interval);
}, [count]); // Now correctly re-runs when count changes
```

### Option 2: Use a Ref to Track the Current Value

When you need a stable callback that always sees the current value without re-running the effect, use a ref:

```javascript
const countRef = useRef(count);
countRef.current = count;

useEffect(() => {
  const interval = setInterval(() => {
    console.log('Current count:', countRef.current); // Always current
  }, 1000);
  return () => clearInterval(interval);
}, []); // Safe because we're reading from ref, not closure
```

### Option 3: Use the Functional Form of setState

If the stale closure is inside a `setState` call, use the functional form to get the current value:

```javascript
setCount(currentCount => currentCount + 1); // Always uses latest value
```

## When to Suspect a Stale Closure

You should suspect a stale closure when:
- A value in a `useEffect`, `useCallback`, or event listener is always showing its initial value rather than the current value
- You're seeing unexpected behavior after state updates
- An interval or timeout seems to be operating on old data
- ESLint's `exhaustive-deps` rule is flagging a missing dependency

## Related Patterns

- [[useCallback and useMemo memoization]]
- [[React dependency array rules]]
- [[Event listener cleanup in useEffect]]

## Sources

Extracted from Data Development Project session 2026-04-12, discussion of dashboard real-time update bug. The bug was a stale closure in a WebSocket event listener.
