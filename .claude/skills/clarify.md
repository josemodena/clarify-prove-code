---
name: clarify
description: "Phase 1. Interrogates the human idea and produces a strict PRD. Run before /prove."
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

5. **Request sign-off.** Present the PRD to the human and ask for explicit approval with the message:
   > "PRD written to `docs/PRD.md`. Please review and reply 'approved' to proceed to `/prove`."

6. **Do not proceed** until the human approves.

## Constraints
- No code of any kind during this phase.
- If the human's answers contradict each other, flag the contradiction before drafting.
- If the idea is too broad to specify in one PRD, propose a decomposition into sub-units and confirm with the human which unit to start with.
