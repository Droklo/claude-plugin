# A client's first week of meals

The coach says "build this client a week" and gets one the client can
shop for and cook.

## 1. Read

`list_clients` (targets, lock, `workspace.id`, notes), then
`get_client_summary {"clientId"}` and `get_context {"workspaceId"}`
(food profile, meal schedule, members, upcoming plan).

## 2. Ask

- First the coach's own rules or sample meals: the week is theirs.
- Then only what is not stored, one question per reply. Open with two
  lines on what is already set.
- A fact about the client that nobody stored (what they tolerate,
  what their week looks like) is not yours to guess: ask the coach,
  or the client with a `kind: "question"` comment.
- Kitchen and shopping belong to the household profile; a coach
  cannot edit it (`FORBIDDEN`). Training days:
  `update_client_targets {"trainingDays"}`.

## 3. Plan

- Start on a day the client can have shopped for: after their next
  shopping day, not before the day after tomorrow.
- Quick meals on training and late evenings; times from the recipe.
- Whole recipes; extra portions become lunches or go to the freezer.
- A dinner the family eats is for the family: set `attendeeIds`, and
  check everyone's restrictions.
- Show one line per meal (weekday, meal, minutes); numbers only for a
  coach who works with them.
- Preview with `add_plan_entries {…, "dryRun": true}` and fix what it
  returns.

**What you save is a proposal.** Say so before the first write: the
client sees it as the coach's proposal and accepts what suits them.
Save on a yes. Taking one back: `delete_plan_entries {"workspaceId",
"ids"}`, your own entries, after a yes.

## 4. Read the result

- `planChecks`: fix each or tell the coach. `no_shopping_list` is
  expected: the list follows acceptance.
- `dates_unconfirmed`: nobody said whether those dates are normal.
  Ask the coach what the client told them and pass `datesConfirmed
  {from, to, note}` with the write. Do not answer for the client.
- `dayTotals`: read days here, never add up. Part of the day planned:
  ask whether to add the rest or leave it to the client.
- `coverage` (planned meals still open), `planUrl` (give this link),
  `note` (how the family learns of it: say that, not your version).

## 5. The client and the note

The proposal shows in the client's Droklo inbox and their assistant
raises it next conversation. No email. Accepting puts the meals on
their shopping list; a coach cannot make their list.

A note is worth it for what only the coach can say (what the week is
for, what it does not cover, what to buy for a dish without a recipe).
Ask the coach for the words, preview and post (commenting.md).

## 6. Close

One line: what was written and its `url`; one offer: when to look for
their answer. It shows as `accepted` / `declined` in `get_inbox`,
`proposals` and `sinceLastReview`; proposals never logged show as
`proposedNotLogged`.

## Reuse a week

Other clients with the same goal: offer once to keep it as a template.

1. Its recipes must be in the practice library (practice-library.md).
2. `save_template {"id", "weekPlan": [{"dayOffset": 0, "mealType",
   "dishName", "recipeId", "cookingTimeMin"}]}`. `withoutRecipe` meals
   reach no list, `withoutNumbers` meals leave totals unknown: tell
   the coach.
3. Preview and apply: templates-and-targets.md, "apply_template".
