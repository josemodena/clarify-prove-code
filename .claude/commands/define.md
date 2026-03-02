# /define — Domain Analysis and Specification

Perform a collaborative domain analysis and produce a full PRD through dialogue,
including an internally reviewed Verification Scope triage for every component
and the target language for the project.

---

## Phase A — Brainstorming Dialogue

This phase is an open-ended dialogue. It ends only when the developer explicitly
signals they are done (e.g. "done", "ready to draft", "proceed").

1. **Read the idea** from the user's prompt. Do not assume anything not stated.

2. **Perform a domain analysis immediately.** Before asking anything, identify:
   - Key entities and their relationships
   - State space and what transitions are possible
   - Likely invariants (what must always be true)
   - Likely failure modes (what must never happen)
   - Security boundaries and trust levels

3. **Share your analysis proactively** and ask clarifying questions based on
   what is genuinely unclear. There is no fixed question count. Ask follow-up
   questions as new information surfaces. Offer expert commentary — suggest
   patterns, flag risks, note when a design decision has hard verification
   consequences.

4. **Establish the target language early.** Ask which language the production
   code should be written in. Then:
   - If any components are likely to be Prove-tier, check that the chosen
     language is one the Dafny compiler can emit. Dafny supports: Python (`py`),
     Go (`go`), Java (`java`), JavaScript/TypeScript (`js`), C# (`cs`), and
     Rust (`rs`, experimental). C and C++ are not Dafny compile targets — if
     the developer wants C/C++ and needs Prove-tier components, flag this
     conflict and discuss alternatives (e.g. generate to a supported language
     and wrap, or move those components to Direct-tier with extra scrutiny).
   - If all components are likely Direct-tier, any language in the supported
     tier system is valid (see `docs/language-support.md`).

5. **The developer has the final decision** on every design choice. Your role is
   to inform and challenge, not to dictate.

6. **Continue the dialogue** until the developer signals they are finished.

---

## Phase B — Internal Draft and Review

This phase runs without developer involvement until the draft passes review.

1. **Draft `docs/PRD.md`** using `templates/PRD_TEMPLATE.md`. Draw entirely from
   the brainstorming record. Fill every section. Leave no placeholders.
   - Set the **Target Language** field in the PRD header from what was agreed
     in Phase A.
   - If the idea covers a full application, identify all significant components
     and document each one.
   - If the scope is too broad for one PRD, flag this before drafting and ask
     the developer which unit to start with.

2. **Launch a Reviewer subagent** to evaluate the draft against:
   - Every decision from the brainstorming is captured — nothing missing,
     nothing contradicted.
   - All PRD template sections are complete with no placeholders.
   - The Target Language field is present and is valid given the Verification
     Scope triage (must be a Dafny compile target if any Prove-tier components exist).
   - The Verification Scope triage in Section 9 is defensible given the
     invariants and failure modes agreed during brainstorming.
   - Edge cases and failure modes in the PRD match what was discussed.

3. **If the reviewer raises issues:** fix the draft and re-run the reviewer.
   Repeat until the reviewer returns a clean pass.

4. **Request developer sign-off:**
   > "PRD drafted to `docs/PRD.md` and internally reviewed. Please check the
   > requirements, the Target Language, and the Verification Scope in Section 9,
   > then reply 'approved' to proceed to `/prove`."

5. **Do not proceed** until the developer approves.

---

## Notes
- No code of any kind during this phase.
- If the developer's answers contradict each other, flag the contradiction
  before entering Phase B.
- If the developer disagrees with a triage assignment in Section 9, update
  the table and re-request approval.
- If a requirement is difficult to express in first-order logic, flag it —
  it may affect the triage decision.
