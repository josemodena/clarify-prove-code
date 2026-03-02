# /prove — Formal Verification with Dafny

Translate each Prove-tier component from the approved PRD into Dafny and formally verify it.

## Prerequisites

- `docs/PRD.md` must exist and be marked as approved by the human (run `/clarify` first).
- Dafny must be installed. If not present, run:
  ```
  bash scripts/install-dafny.sh
  ```
  Then verify with `dafny --version`.

## Steps

1. **Read `docs/PRD.md`** in full. Find Section 9 (Verification Scope). Collect every
   component marked **Prove**. These are the only components processed in this phase.
   Components marked **Direct** are skipped here — they proceed straight to `/code`.

2. **Write Dafny spec** for each Prove component to `logic/<component-name>.dfy`.
   Use `templates/SPEC_TEMPLATE.md` as a structural guide:
   - Map each entity to a Dafny `datatype` or `class`.
   - Express invariants as `predicate` functions.
   - Express operations as `method` with `requires` / `ensures` clauses.
   - Use `ghost` variables where needed for specification-only state.
   - Add `decreases` clauses for recursive or iterative operations.

3. **Verify** — run the verifier:
   ```bash
   dafny verify logic/*.dfy
   ```
   Iterate until all goals verify. Common strategies:
   - Add intermediate `assert` statements to guide the solver.
   - Split complex postconditions into helper lemmas.
   - Use `calc` blocks for arithmetic reasoning.

4. **If verification fails:**
   - Read the counter-example output.
   - Explain the failure in plain English to the human.
   - Fix the `.dfy` file.
   - Re-run the verifier.
   - Repeat until zero errors.

5. **Document unverifiable assumptions** in `docs/PROOF.md`. If any property cannot be
   verified (e.g. it depends on external system behaviour), record it explicitly.

6. **Produce `docs/PROOF.md`:**
   ```markdown
   # Proof Summary

   ## Verified Components
   <list each Prove-tier component and what was proved>

   ## Verification Command
   dafny verify logic/*.dfy

   ## Dafny Version
   <output of dafny --version>

   ## Unverified Assumptions
   <list any properties assumed but not proved, with justification>

   ## Known Limitations
   <e.g. integer overflow not modelled, external I/O not in scope>
   ```

7. **Notify the human.** Report what was proved and remind them to run `/code` next.
   If no components are marked Prove, skip this phase entirely and proceed to `/code`.

## Notes
- Do not write implementation code during this phase.
- Do not modify `docs/PRD.md` — if a contradiction is found, report it and return to `/clarify`.
- The Dafny spec is the authoritative source for all Prove-tier components.
- Ghost code in Dafny does not need to be translated to the implementation language.
- If the spec is too large to verify in one pass, split it into independent modules.
