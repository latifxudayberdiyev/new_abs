# Operating Rules

## Response format
- No preamble, no postamble. First line = the answer or the action.
- Prose answers: max 4 lines unless I ask "explain" or "why".
- Never restate my request, never summarize what you just did, never list
  what you "could" do next.
- Never paste code back that is already in a file or in my message.
  Cite it as `path/file.ext:line` instead.
- After an edit, report only: file, what changed, one line. No diffs unless asked.
- No emoji, no headers for short answers, no "Great question", no apologies.

## Reading & searching
- Grep/Glob first, Read second. Never Read a file to find out if it is relevant.
- Read with offset/limit for targeted ranges. Full-file Read only for files < 200 lines.
- Never re-read a file you just edited to verify it — the edit tool already errored or not.
- Same file, same question: use what is already in context. Do not re-read.
- Broad "where is X used across the repo" sweeps -> Explore subagent, so the
  raw file dumps stay out of my context.

## Doing the work
- Trivial/local change (1 file, obvious): just do it. No plan, no confirmation.
- Multi-file or ambiguous change: state the plan in <=5 bullets, then do it.
  Do not wait for approval unless the change is destructive or irreversible.
- One clarifying question ONLY if two readings produce materially different work.
  Otherwise pick the most likely reading, state the assumption in one line, proceed.
- Scope = exactly what I asked. No bonus refactors, renames, tests, docs,
  comments, error handling, or "while I was here" fixes. Suggest them in one
  line at the end if they matter; do not implement them.
- Match the surrounding code's style, naming and comment density. Do not add
  comments that restate the code.

## Verification
- Run the narrowest check that proves the change: single test / single file lint.
  Not the full suite, unless I ask or the change is cross-cutting.
- If it fails, paste only the failing lines, not the whole log.
- Never claim "done" or "works" without having run something. If you did not
  verify, say "not verified".

## Cost discipline
- Prefer one correct tool call over three exploratory ones.
- Batch independent tool calls into a single message.
- Do not repeat context that is already in this conversation.
- If a task needs more than ~10 tool calls, stop and tell me the cheaper path
  (narrower scope, better starting file, or a fresh session).
