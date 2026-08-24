---
name: diagnosing-workflow-defects
description: Use when the workflow itself misbehaves and the cause is unknown — endless review rounds, stalled or churning queues, scope that keeps growing, tasks that never close, corrections that don't stick, agents "acting as planner" — and the defect could live in skills, rules, memories, prompts, or the model.
---

# Diagnosing Workflow Defects

## Overview

A misbehaving workflow is a bug in a distributed program whose source code is the process corpus (rules, skills, prompts, tracker text). Diagnose it like code: reproduce the mechanism from evidence, blame text at file:line, date the blame, fix without regressing what the blamed text was protecting.

**Core principle: blame a loop, not a villain.** If your diagnosis needs an agent to have bad intent, it is wrong — find the written text that makes an *obedient* agent produce the failure.

## The procedure

1. **Pin the symptom as behavior**, not cause: "every task takes 3+ rounds", "task bodies grow between rounds". Quantify it from durable state first — git history shape (commit messages, fix-round counts, merges-per-commit), tracker trails — cheap, and it tells you where to dig.
2. **Reconstruct the loop from transcripts.** Dispatch one analyst subagent per session transcript (they are multi-MB; never read inline) with extraction recipes and this question: who produced the signal, who converted it into an obligation, what text licensed the conversion, what carried it to the next cycle. The output is a causal chain: `signal → converter → license → amplifier`.
3. **Blame text, with dates.** Grep the corpus for the licensing text. For each blamed clause run `git log -S"<clause>"` in the corpus repo: when it landed, and — from the commit message and notes glosses — what failure it was fixing. A clause that landed days before the blow-up is a lead; its original rationale is a constraint on your fix.
4. **Test the interaction, not the instance.** Individually sane clauses form ratchets: one removes an exit, one mandates bundling, one forbids re-grading — together every signal becomes an obligation. Name the combination. A single clean pass does NOT clear a clause; instead ask what distinguished the clean case — that distinction is both your mechanism check and your regression counterexample.
5. **Discriminate model vs text — as a likelihood, not a verdict.** A different model/executor hitting the same wall under the same text raises the odds it is the text (shared model biases and model×text interactions still exist). Assign the model primary blame only after a model-by-corpus comparison: the failure follows the model across corpora and stays away from other models under the same corpus.
6. **Fix minimally, preserving every blamed clause's recorded rationale.** State per clause: what it was protecting (cite the measurement or incident), and how the fix keeps that protection. A fix that shifts authority to another actor usually rebuilds the ratchet in mirror image — check the new text against the same loop. Corpus edits are proposals to the owner, never self-applied.

## Deliverable

The causal chain with file:line and introduction date per blamed clause; the minimal fix with per-clause rationale preservation; the counterexample that must keep working.

## Red flags — your diagnosis is not done

- "Almost certainly", "clearly the X was abusing" — intent language in place of a licensing citation. Authorship and intent are facts to collect (comment history, session ids), never to infer: an unverified provenance claim is written as "author unverified" and goes in the evidence list, even mid-narrative.
- A single actor or single task blamed while a corpus-wide metric (commit shape, round counts) stays unexplained.
- No introduction date on any blamed clause.
- A proposed fix that grants an actor new authority, or that would have blocked the case where the machinery worked correctly.
- The model blamed without a cross-executor or cross-corpus discriminator.
