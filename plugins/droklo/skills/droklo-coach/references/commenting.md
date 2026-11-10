# Commenting and answering questions

Comments are how the coach talks to a client about specific meals and days.
They appear on the client's timeline, in their inbox and to their AI agent.

## Where to attach a comment

Always pass the client's household: `workspaceId: <client.workspace.id>`.
Comment tools refuse your practice id with `INVALID`, and a `familyMemberId`
that is not your client gets `FORBIDDEN`.

| About | `target` | Notes |
|---|---|---|
| A meal the client ate | `{"type": "mealLog", "id": "<log id>"}` | Best for feedback; `familyMemberId` is inferred. |
| A planned (future) meal | `{"type": "planEntry", "id": "<entry id>"}` | Suggestions before they cook ("add a side salad"). |
| A day | `{"type": "day", "date": "YYYY-MM-DD"}` + `familyMemberId` | Daily patterns ("protein was low all day"). |
| The week or anything general | `{"type": "general"}` + `familyMemberId` | Weekly summary, logging nudges, welcome. |
| A recipe in their household library | `{"type": "recipe", "id": "<recipe id>"}` | Tweaks to a recipe they cook often. |

`kind`: `"comment"` for feedback, `"question"` when you need an answer from the
client. A question stays open for the client until the thread is resolved.
It also works as a reply (`parentId`): the thread then counts as a question
from whoever asked last.

## Tone

- **Specific:** name the meal, the day and the number ("Tuesday's lunch had
  about 20 g protein").
- **Actionable:** one or two concrete next steps, not a lecture
  ("add 150 g Greek yogurt at breakfast").
- **Warm and brief:** start with what went well; two to four sentences.
- **Neutral about food:** no "bad food", "cheat meal", guilt or body
  comments. Talk about meals and habits, not weight or appearance.
- **Within scope:** general wellness only; no diagnosis or treatment claims
  (scope-of-practice.md).
- **Plain English:** comments are stored in English; plain words, no
  jargon.

Good: "Great job logging every day this week! Your dinners hit your protein
goal; breakfasts were around 10 g. Want to try eggs or Greek yogurt in the
mornings this week?"

Avoid: "You failed your protein target again. You need to stop eating so
many carbs."

## Privacy and visibility

- The client's whole household can read comments on their plan, days and
  logs. Keep sensitive topics (weight, health, emotional eating) neutral, or
  suggest discussing them privately.
- You see household-level threads (`general`, `day`, `planEntry`, `recipe`
  without `familyMemberId`) and threads about your own clients, never
  threads about other family members.
- One client per comment. Never mention other clients or compare them.

## Answering client questions

1. Find questions:
   ```
   get_inbox {"onlyUnread": true}
     → threads: [{root: {id: "c_q1", kind: "question", target: {type: "mealLog", id: "ml_456"},
                  body: "Should I add more rice?", familyMemberId: "fm_john"},
                  workspace: {id: "ws_smith", …}, unread: true, replies: []}],
       openQuestionCount: 1
   ```
   `list_clients[].openQuestions` also counts them per client.
2. Read the context of the question (the meal log, the day's totals, the
   client's targets) before drafting: `get_client_summary` for that date.
3. Draft the answer for the coach in their voice; post after approval, or at
   once if the coach dictated the answer:
   ```
   add_comment {"workspaceId": "ws_smith",
     "parentId": "c_q1",
     "kind": "comment",
     "body": "Yes, add about half a cup more rice and some edamame; that keeps you in range and should hold you until bedtime."}
   ```
   A reply needs only `parentId` = the root comment id (no `target`).
4. `resolve_thread {"workspaceId": "ws_smith", "threadId": "c_q1"}` when the
   question is fully answered; it leaves the inbox (skip it if you asked
   something back).
5. `mark_read {"threadIds": ["c_q1"]}` for threads you showed the coach.

If a question is outside the coach's scope (medication, symptoms, a medical
condition), draft a kind referral instead (scope-of-practice.md).

## Reading comment history

`list_comments {"workspaceId": "ws_smith", "target": {"type": "mealLog", "id": "ml_456"}}`
for one target, or `{"workspaceId": …, "from": "2026-11-02", "to": "2026-11-08"}`
for all threads with activity in a range. Check earlier threads before
repeating advice.
