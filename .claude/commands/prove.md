# /prove — Formal Verification with Dafny

Translate the specification from `/clarify` into Dafny and formally verify it.

## Prerequisites

- `SPEC.md` must exist and be complete (run `/clarify` first).
- Dafny must be installed. If not present, run:
  ```
  bash scripts/install-dafny.sh
  ```
  Then verify with `dafny --version`.

## Steps

1. **Read SPEC.md** — parse the invariants, operations, pre/postconditions.

2. **Create `proof/` directory** — write Dafny files there:
   ```
   proof/
   ├── types.dfy        # Entity types, datatypes, enums
   ├── invariants.dfy   # Predicates expressing invariants
   ├── operations.dfy   # Methods with requires/ensures clauses
   └── lemmas.dfy       # Supporting lemmas (add as needed)
   ```

3. **Write Dafny specifications**:
   - Map each entity to a Dafny `datatype` or `class`
   - Express invariants as `predicate` functions
   - Express operations as `method` with `requires` / `ensures` clauses
   - Use `ghost` variables where needed for specification only
   - Add `decreases` clauses for recursive or iterative operations

4. **Verify** — run the verifier:
   ```bash
   dafny verify proof/*.dfy
   ```
   Iterate until all goals verify. Common strategies:
   - Add intermediate `assert` statements to guide the solver
   - Split complex postconditions into helper lemmas
   - Use `calc` blocks for arithmetic reasoning

5. **Document unverifiable assumptions** — if any property cannot be verified
   (e.g. it depends on external system behaviour), record it explicitly in `PROOF.md`.

6. **Produce PROOF.md**:
   ```markdown
   # Proof Summary: <title>

   ## Verified Properties
   <list each proved invariant/postcondition>

   ## Verification Command
   \`\`\`
   dafny verify proof/*.dfy
   \`\`\`

   ## Dafny Version
   <output of dafny --version>

   ## Unverified Assumptions
   <list any properties assumed but not proved, with justification>

   ## Known Limitations
   <e.g. integer overflow not modelled, external I/O not in scope>
   ```

7. **Summarise** — report what was proved and remind the user to run `/code` next.

## Notes

- The Dafny specification is the authoritative source of truth for the Code phase.
- If Dafny cannot prove a property, do not pretend it is proved. Record it as an assumption.
- Ghost code in Dafny does not need to be translated to the implementation language.
- If the spec is too large to verify in one pass, split it into independent modules.
