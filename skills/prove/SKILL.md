---
name: prove
description: "/prove — Formal Verification with Dafny"
---

# Prove Protocol

## Trigger
`/prove`

## Prerequisites
- `docs/PRD.md` must exist and be marked as approved by the human.
- If either condition is unmet, stop and redirect to `/define`.

## Steps

1. **Read `docs/PRD.md`** in full. Find Section 9 (Verification Scope). Collect every
   component marked **Prove**. These are the only components processed in this phase.
   Components marked **Direct** are skipped here — they proceed straight to `/code`.

2. **Write Dafny specs.**
   - **Single component:** write `logic/<component-name>.dfy` directly.
   - **Multiple components:** launch one subagent per component in parallel. Each subagent
     receives the relevant PRD sections for its component and writes `logic/<component-name>.dfy`.
     Wait for all subagents to finish before proceeding to verification.
   - In every spec, use `templates/SPEC_TEMPLATE.md` as a structural guide:
     - Every invariant from the PRD must appear as a Dafny `ensures` or `invariant` clause.
     - Every failure mode must appear as a `requires` clause or an explicit error return.
     - Use `ghost` variables where needed to track logical state not visible at runtime.

3. **Run the verifier:**
   ```
   dafny verify logic/*.dfy
   ```

4. **If verification fails:**
   - Read the counter-example output.
   - Explain the failure in plain English to the human (e.g., "The invariant breaks if two
     concurrent writes happen before the lock is acquired").
   - Fix the `.dfy` file.
   - Re-run the verifier.
   - Repeat until zero errors.

5. **When all Prove components pass:**
   - Write `docs/PROOF.md` summarising what was proved and any unverified assumptions.
   - Notify the human: "Logic verified. All invariants hold for Prove-tier components. Ready for `/code`."
   - Do not proceed to code generation until the human issues `/code`.

## Constraints
- Do not write implementation code during this phase.
- Do not modify `docs/PRD.md` — if a contradiction is found, report it and return to `/define`.
- The Dafny spec is the authoritative source for any component marked Prove. No business logic
  may exist in `src/` for those components that is not first expressed in `logic/`.
- If no components are marked Prove, skip this phase and proceed directly to `/code`.
- If Dafny is not installed, direct the user to run `scripts/install-dafny.sh`.
