# CxCarPlay Implementation Plan

Combine-native reactive layer for CarPlay templates. Part of the neonindigo/Cx ecosystem.

## Scope (v1)

| Template | Binding | Interaction |
|---|---|---|
| `CPListTemplate` | `cx.bind(sections:) → AnyCancellable` | `cx.itemSelected: AnyPublisher<Selection, Never>` |
| `CPGridTemplate` | `cx.bind(gridButtons:) → AnyCancellable` | none |
| `CPTabBarTemplate` | `cx.bind(templates:) → AnyCancellable` | none |
| `CPTemplate` | none | none |

**Selection** — wraps `CPListItem` + mandatory `complete()`. Debug-asserts if dropped uncalled.  
**Zero magic** — no delegate installation, no swizzling. Handlers injected at bind time.  
**Platform:** iOS 15+ / macOS 12+, Swift 6.2, Combine.  
**Dependency:** `Cx` (neonindigo/Cx) for `CxCocoa`-style `.cx` namespace pattern.

## Wave map

```
Wave 0 — FOUNDATION (sequential, 1 agent)
  └─ Package.swift, all stubs, Selection type, .cx namespace scaffolding → PR#1 → merge

Wave 1 — FEATURES (parallel, 3 agents)
  ├─ feat/list     → CPListTemplate.cx (bind + itemSelected)         → PR#2
  ├─ feat/grid     → CPGridTemplate.cx (bind)                        → PR#3
  └─ feat/tabbar   → CPTabBarTemplate.cx (bind)                      → PR#4

INTEGRATION PASS (you)
  └─ full swift test on merged master
```

## What is not parallelisable

- Foundation must be done first — all three Wave 1 agents build on the `Selection` type and `.cx` namespace stubs
- Wave 1 agents own disjoint files: `CPListTemplate+Cx.swift`, `CPGridTemplate+Cx.swift`, `CPTabBarTemplate+Cx.swift`

## Key design decisions

- See `docs/adr/0001-per-item-handler-injection-not-delegate.md`
- See `docs/adr/0002-selection-value-type-not-tuple.md`
