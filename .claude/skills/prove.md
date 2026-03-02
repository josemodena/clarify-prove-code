---
name: prove
description: "Phase 2. Converts approved PRD into Dafny logic and runs the verifier. Run after /clarify is approved."
---

# Prove Protocol

## Trigger
`/prove`

## Prerequisites
- `docs/PRD.md` must exist and be marked as approved by the human.
- If either condition is unmet, stop and redirect to `/clarify`.

## Steps

1. **Read `docs/PRD.md`** in full. Extract every invariant, pre-condition, and post-condition.

2. **Write Dafny spec** to `logic/<module-name>.dfy`. Use `templates/SPEC_TEMPLATE.md` as a structural guide.
   - Every invariant from the PRD must appear as a Dafny `ensures` or `invariant` clause.
   - Every failure mode from the PRD must appear as a `requires` clause or an explicit error return.
   - Use `ghost` variables where needed to track logical state not visible in the runtime representation.

3. **Run the verifier:**
   ```
   dafny verify logic/*.dfy
   ```

4. **If verification fails:**
   - Read the counter-example output.
   - Explain the failure in plain English to the human (e.g., "The invariant breaks if two concurrent writes happen before the lock is acquired").
   - Fix the `.dfy` file.
   - Re-run the verifier.
   - Repeat until zero errors.

5. **When verification passes:**
   - Notify the human: "Logic verified. All invariants hold. Ready for `/code`."
   - Do not proceed to code generation until the human issues `/code`.

## Constraints
- Do not write Rust or Zig during this phase.
- Do not modify `docs/PRD.md` — if a contradiction is found, report it and return to `/clarify`.
- The Dafny spec is the source of truth. No business logic may exist in `src/` that is not first expressed in `logic/`.
