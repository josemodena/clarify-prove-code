---
name: clarify
description: "Phase 1. Interrogates the human idea, produces a full-app PRD, and proposes a Verification Scope. Run before /prove."
---

# Clarify Protocol

## Trigger
`/clarify [idea]`

## Steps

1. **Read the idea** from the user's prompt. Do not assume anything not stated.

2. **Interrogate.** Ask exactly 3–5 questions. Each question must target one of:
   - **State invariants** — what must always be true, no matter what?
   - **Edge cases** — what happens at the boundaries (empty input, max load, concurrent access)?
   - **Failure modes** — what must never happen? What is the blast radius if it does?
   - **Security boundaries** — who can read, write, or execute each operation?
   - **Performance contracts** — are there latency or memory bounds that are non-negotiable?

3. **Wait.** Do not write any document or code until the human has answered.

4. **Draft `docs/PRD.md`** using `templates/PRD_TEMPLATE.md`. Fill every section. Do not leave placeholders.
   - The scope may be a single component or the entire application. Either is valid.
   - If the idea describes a full application, identify all significant components and document each one.
   - If the idea is too broad to fit one PRD, propose a decomposition into sub-units and confirm with the human which unit to start with.

5. **Propose Verification Scope (Section 9 of the PRD).** Analyse every component identified in the PRD and assign each a tier:
   - **Prove** — must go through Dafny verification before code is written.
     Apply this tier to: financial or payment logic, access control and permissions,
     data integrity guarantees, state machines with complex transitions, external-facing
     security boundaries, safety-critical behaviour.
   - **Direct** — goes straight from PRD to code; no Dafny required.
     Apply this tier to: UI components, API glue and data transformation, configuration
     loading, logging and monitoring, scripts, prototypes.

   Fill Section 9 of the PRD with a table: component, tier, one-line rationale.

6. **Request sign-off.** Present the full PRD (including Section 9) to the human:
   > "PRD written to `docs/PRD.md`. Please review the requirements and the Verification Scope in Section 9, then reply 'approved' to proceed to `/prove`."

7. **Do not proceed** until the human approves both the requirements and the triage.

## Constraints
- No code of any kind during this phase.
- If the human's answers contradict each other, flag the contradiction before drafting.
- If the human disagrees with a triage assignment, update Section 9 to reflect their decision before requesting sign-off again.
