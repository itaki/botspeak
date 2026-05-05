---
topic: react-stale-closure
tags: [react, hooks, debugging]
updated: 2026-05-04
source: DishData/2026-04-12
summary: closure captures old var value · effect/listener sees stale state
---

[brief] useEffect/listener closed over var → gets initial value · not current

@defs
  SC = stale-closure
  DA = dependency-array
  CB = callback
@end

cause: fn created at render-time → captures var-at-creation / not var-at-call
trigger: empty DA `[]` + dynamic-var inside · addEventListener + state ref

⚠️ suspect SC when:
  value stuck at initial · interval shows old data · ESLint exhaustive-deps fires

# patterns

🔴 anti: `useEffect(() => { ...count... }, [])` → count = forever-0
✅ fix-1: add var to DA → effect re-runs on change
✅ fix-2: ref pattern → `const r = useRef(val); r.current = val;` read r inside CB → always current
✅ fix-3: `setState(curr => curr + 1)` → functional form bypasses SC

# decision tree
SC in setState → functional-form
SC in interval/listener + need stable CB → ref pattern
SC in effect + ok to re-run → add to DA

ref: [[useCallback-useMemo]] · [[dep-array-rules]] · [[effect-cleanup]]
