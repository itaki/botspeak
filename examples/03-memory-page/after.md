---
title: React Stale Closure Pattern
tags: [react, hooks, debugging, performance]
updated: 2026-05-04
source: claude-history-ingest / DabaBase session 2026-04-12
---

@defs
  SC = stale closure
  DA = dependency array
  EF = useEffect
  CB = useCallback
  ref = useRef hook
  ELD = empty DA
  fSS = functional form setState
@end

# React Stale Closure Pattern

## Summary

[ALWAYS] SC = function closes over variable from component-scope · retains OLD value instead of current
  cause: JS closures capture value at function-creation-time · not call-time
  common: EF + incorrect/empty DA · event-listeners registered once

## What Is Stale Closure

[ALWAYS] SC occurs when:
  function defined inside component -> closes over component-scope variable
  function retains reference to OLD value (not current)
  JS closure captures at creation-time (not call-time)

most-common (React):
  EF with incorrect || empty DA
  event-listeners registered once · never updated

## Common Causes

### Empty Dependency Array with Dynamic Values

[ALWAYS]
  ELD + EF referencing state/props = BUG
  ELD tells React: run once (mount-only)
  callback captures INITIAL variable values
  if variables change later: callback still sees OLD values

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

[ALWAYS]
  addEventListener + EF with DA not including all used-variables = stale-values
  listener captures old values from closure-time

## Solutions

### Option 1: Add Variable to Dependency Array

```javascript
useEffect(() => {
  const interval = setInterval(() => {
    console.log('Current count:', count);
  }, 1000);
  return () => clearInterval(interval);
}, [count]); // Now correctly re-runs when count changes
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
}, []); // Safe because we're reading from ref, not closure
```

### Option 3: Functional Form of setState

```javascript
setCount(currentCount => currentCount + 1); // Always uses latest value
```

## When to Suspect Stale Closure

[ALWAYS] suspect when:
  value in EF · CB · event-listener always shows initial (not current)
  unexpected behavior after state-updates
  interval/timeout operating on old-data
  ESLint exhaustive-deps flagging missing-dependency

## Related Patterns

- [[useCallback · useMemo memoization]]
- [[React DA rules]]
- [[Event listener cleanup in EF]]

## Sources

Data Development Project session 2026-04-12 · dashboard real-time update bug · stale closure in WebSocket event-listener
