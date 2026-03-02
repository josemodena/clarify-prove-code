# /clarify — Domain Analysis and Specification

Perform a structured domain analysis of the current task and produce a formal specification.

## Steps

1. **Read context** — examine any files the user has shared, the issue description, or the stated goal.

2. **Domain analysis** — identify:
   - Key entities and their relationships
   - State space: what can change, what stays constant
   - Invariants: properties that must always hold
   - Preconditions: what must be true before the operation
   - Postconditions: what must be true after the operation
   - Edge cases and failure modes

3. **Ask clarifying questions** — if any of the following are ambiguous, ask before proceeding:
   - Behaviour on invalid input
   - Concurrency or ordering requirements
   - Performance constraints that affect correctness (e.g. overflow, truncation)
   - External dependencies whose behaviour is not fully specified

4. **Produce SPEC.md** — write a structured specification file with the following sections:

```markdown
# Specification: <title>

## Problem Statement
<one paragraph>

## Entities
<table or list of entities with types and descriptions>

## Invariants
<numbered list of properties that must always hold>

## Operations
For each operation:
### <operation name>
- Preconditions: ...
- Postconditions: ...
- Error cases: ...

## Edge Cases
<numbered list>

## Assumptions
<numbered list of things assumed true but not verified>

## Open Questions
<any questions still requiring user input>
```

5. **Summarise** — tell the user what was produced and remind them to run `/prove` next.

## Notes

- Do not start coding during this phase.
- If the user already has a partial spec, refine it rather than replacing it.
- Flag any requirements that are difficult to express in first-order logic, as these may be hard to prove.
