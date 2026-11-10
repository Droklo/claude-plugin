# Changes and swaps

The plan must say what will happen and what did. Find the entry first
(`get_plan`; date, meal, dish; two in one slot: ask which). Every
write returns, and you handle in the same turn:

- `planChecks`: fix or explain.
- `dependents`: meals that hung on the changed one (leftovers before
  their dish, a lunchbox from a dinner that is gone). Move or replace
  each and say so.
- `notesToReview`: notes naming a dish the entry no longer has.
  Rewrite or clear (`notes: null`).
- `shoppingLists`: report in a line (shopping.md). Close with `planUrl`.

## Which tool

| Situation | Tool |
|---|---|
| Two meals trade places | `swap_plan_entries {"entryIdA", "entryIdB"}` |
| A meal goes to another day or slot | `move_plan_entry {"id", "date", "mealType"?}` (a taken slot keeps both: ask) |
| Same slot, other dish; who eats, servings, notes | `update_plan_entry {"id", …fields}` (keeps comments and logs; prefer it to delete and add) |
| The meal will not happen | Move it to the next free evening when the food is bought; `delete_plan_entries` only on their word |
| A whole planning run undone | `delete_plan_entries {"batchId"}` after a yes |
| A meal out | eating-out.md |

A one-off ("Tomas is away Thursday") changes that entry only
(`attendeeIds`); do not archive the member or change the profile.

## Common cases

- **Cooked on another day** ("we had Tuesday's curry tonight"): swap
  with tonight's dinner, or move it to today and offer something for
  Tuesday; then `log_meal` with its `planEntryId`.
- **Ate something else:** `log_meal` with `dishName`, no entry; then
  move the planned meal.
- **Replace a dish:** `update_plan_entry` with the new `dishName`,
  `recipeId`, `cookingTimeMin`, `notes: null`. Weekly rules ("fish
  twice a week") are yours to watch: say when the swap breaks one.
- **The store had no X, they bought Y:** check Y against every eater's
  restrictions (name what to read on a label); say what changes in the
  cooking. If the dish changes, save a variant under its own name
  ("Turkey bolognese"; the same name and `sourceUrl` would overwrite
  the original) and point the entry at it; otherwise a line in `notes`.
  Tick the bought item. Do not put bought food back on a list.
- **Leftovers:** a leftovers meal is its own entry with the original
  `recipeId` and `servings: 0`. Extra for later: raise `servings` on
  the cooking entry, set `leftoversNote`, add the leftovers entry.
  Unplanned leftovers: `log_meal` with the `recipeId` and a `portion`.

## Locked

Coaches lock rules and targets, not entries. A change that conflicts
with a locked value: say so and offer to ask the coach (`add_comment`,
`kind: "question"`, on that entry).
