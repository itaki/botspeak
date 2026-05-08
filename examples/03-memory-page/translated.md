# React Stale Closure Pattern

**Document metadata:**
- Tags: react and hooks and debugging and performance
- Updated: 2026-05-04
- Source: claude-history-ingest / session 2026-04-12

## Summary

**In every turn:**

A stale closure occurs when a function closes over a variable from component scope and retains the OLD value instead of the current value. The underlying cause is that JavaScript closures capture their values at function-creation-time, not at call-time. In React, this is most commonly seen when using useEffect with an incorrect or empty dependency array, or when event-listeners are registered once and never updated.

## What Is Stale Closure

**In every turn:**

A stale closure occurs when:
- A function is defined inside a component and closes over a component-scope variable
- The function retains a reference to the OLD value, not the current value
- JavaScript closure captures the value at creation-time (not at call-time)

The most common occurrence in React happens with:
- useEffect with an incorrect or empty dependency array
- Event-listeners that are registered once and never updated

## Common Causes

### Empty Dependency Array with Dynamic Values

**In every turn:**

When an empty dependency array is used with useEffect that references state or props, this creates a bug. An empty dependency array tells React to run the effect only once at mount time. The callback captures only the INITIAL variable values. If those variables change later, the callback continues to see the OLD values because of the stale closure.

```javascript
function Counter() {
 const [count, setCount] = useState(0);
 useEffect(() => {
 const interval = setInterval(() => {
 // BUG: count always 0 · closure created when count=0
 console.log('Current count:', count);
 }, 1000);
 return () => clearInterval(interval);
 }, []); // Empty dependency array -> closure forever sees count=0
}
```

### Event Listeners

**In every turn:**

When using addEventListener with useEffect where the dependency array does not include all the variables that are used within the listener, you get stale values. The listener captures old values from the time the closure was created.

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

**In every turn:**

Suspect a stale closure when:
- A value in useEffect, useCallback, or an event-listener always shows the initial value instead of the current value
- You observe unexpected behavior after state updates
- An interval or timeout operates on old data
- ESLint's exhaustive-deps rule is flagging a missing dependency

## Related Patterns

- useCallback and useMemo memoization
- React dependency array rules
- Event listener cleanup in useEffect

## Sources

From Data Development Project session 2026-04-12: dashboard real-time update bug where a stale closure occurred in a WebSocket event-listener.

---

## What this means in practice

When you're working with useEffect, useCallback, or event listeners in React and notice that your callbacks are always using old values of state or props, you're likely encountering a stale closure. The most reliable fix is to include all variables your effect or callback depends on in the dependency array. If that causes too many re-renders, use useRef to track the current value without triggering re-runs, or switch to the functional form of setState which always provides the latest state value. Always enable ESLint's exhaustive-deps rule to catch these patterns early.
