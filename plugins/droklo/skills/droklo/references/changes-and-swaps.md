# Changes and swaps

Find the entry first (`get_plan`; two in one slot: ask which). Handle
what every write returns, that turn:

- `planChecks`: fix or explain.
- `dependents`: meals that hung on the changed one (leftovers, a
  lunchbox). Move or replace each; say so.
- `notesToReview`: notes naming a dish the entry no longer has:
  rewrite or clear (`notes: null`).
- `shoppingLists`: report in a line (shopping.md). Close with `planUrl`.
- `scope`, `spare`, `open`: pass each on; change only what they asked
  for.

## Which tool

| Situation | Tool |
|---|---|
| Two meals trade places | `swap_plan_entries {"entryIdA", "entryIdB"}` |
| A meal goes to another day or slot | `move_plan_entry {"id", "date", "mealType"?}` (a taken slot keeps both: ask) |
| Same slot, other dish; who eats, servings, notes | `update_plan_entry {"id", …fields}` (keeps comments and logs) |
| The meal will not happen | `delete_plan_entries`, or `move_plan_entry` to the day they name; offer a day, do not pick one |
| A whole planning run undone | `delete_plan_entries {"batchId"}` after a yes |
| A meal out | eating-out.md |

A one-off absence changes that entry only (`attendeeIds`); do not
archive the member or change the profile.

## Common cases

- **Cooked on another day:** swap with tonight's dinner, or move it
  to today and offer something for its old day; then `log_meal` with
  its `planEntryId`.
- **Ate something else:** `log_meal` with `dishName`, no entry; offer
  to move the planned meal.
- **A fact they cannot check now** (a use-by date, a freezer count):
  make the change, say what to check before cooking.
- **Replace a dish:** `update_plan_entry` with the new `dishName`,
  `recipeId`, `notes: null`. Weekly rules ("fish
  twice a week") are yours: say when a swap breaks one.
- **The store had no X, or the delivery came short:** check what they
  got instead against every eater's restrictions (name what to read on a label); say what changes in
  cooking. If the dish changes, save a variant under its own name
  ("Turkey bolognese"; the same name and `sourceUrl` would overwrite
  the original) and point the entry at it; otherwise a line in `notes`.
  Untick what did not come. Never put bought food back on a list.
- **Leftovers:** a leftovers meal is its own entry with the original
  `recipeId` and `servings: 0`. Extra for later: raise `servings` on
  the cooking entry, set `leftoversNote`, add the leftovers entry.
  Unplanned leftovers: `log_meal` with the `recipeId` and a `portion`.

## Locked

Coaches lock rules and targets, not entries. A change that conflicts
with a locked value: say so and offer to ask the coach (`add_comment`,
`kind: "question"`, on that entry).
