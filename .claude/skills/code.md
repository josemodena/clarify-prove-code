---
name: code
description: "Phase 3. Transpiles verified Dafny logic into production Rust or Zig. Run after /prove passes."
---

# Code Protocol

## Trigger
`/code`

## Prerequisites
- `logic/*.dfy` must exist and have passed `dafny verify` with zero errors.
- If this is unmet, stop and redirect to `/prove`.

## Steps

1. **Verify precondition.** Confirm the `.dfy` file is present and verification has passed. If not, stop.

2. **Read the full Dafny spec** before writing a single line of code. Build a mental (or written) map of:
   - Each `method` → its target function in `src/`
   - Each `ensures` clause → its corresponding runtime check or type constraint
   - Each `requires` clause → its corresponding input validation

3. **Write production code** to `src/`:
   - **Zig:** Every allocation must use an explicit `std.mem.Allocator` passed as a parameter. No `@import("std").heap` globals.
   - **Rust:** Apply `#![forbid(unsafe_code)]` at the crate root unless `unsafe` is required and that requirement is proven in the spec.
   - No business logic not present in the Dafny spec may be introduced. If you find logic missing from the spec, stop and return to `/prove`.

4. **Write traceability summary** as `docs/TRACE.md`:

   | `src/` function | `logic/*.dfy` method | PRD requirement |
   |---|---|---|
   | `transfer()` | `Transfer` method | PRD §3.1 — funds conservation |

5. **Build check:**
   - Zig: `zig build`
   - Rust: `cargo build`
   - Fix compile errors. Do not push code that does not compile.

6. **Notify the human.** Present the traceability summary and confirm every PRD requirement is covered.

## Constraints
- No new business logic in this phase. Code and spec must be isomorphic.
- The traceability summary is mandatory, not optional.
- If a requirement from the PRD cannot be expressed in the compiled code, escalate to the human before proceeding.
