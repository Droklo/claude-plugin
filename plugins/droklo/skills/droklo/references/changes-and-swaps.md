# Changes and swaps

Plans change: a dinner is cooked a day early, someone eats out, a dish is
replaced. Keep the timeline true to what happened and what will happen, so
the shopping list and the coach's view stay right.

## Pick the operation

| Situation | Operation | Tool |
|---|---|---|
| Two planned meals trade places ("swap Monday and Tuesday dinner") | swap | `swap_plan_entries` |
| One meal goes to another date or meal ("move the curry to Thursday") | move | `move_plan_entry` |
| Same slot, different dish ("make pasta instead of the fish on Friday") | replace | `update_plan_entry` |
| Change who eats, servings, notes, time | edit | `update_plan_entry` |
| The meal will not happen at all | skip | `move_plan_entry` to a later date, or `delete_plan_entries` (ask first) |
| They ate something else instead (takeout, restaurant, friend's house) | ate out | `log_meal` what was eaten, then move or delete the planned entry |
| A planned dish was cooked on another day than planned | early or late | `swap_plan_entries` or `move_plan_entry`, then `log_meal` |
| Undo a whole planning run | undo batch | `delete_plan_entries {"batchId": …}` (ask first) |

Always find the entries first:

```
get_plan {"from": "2026-11-09", "to": "2026-11-10"}
```

Identify entries by date, `mealType` and `dishName`. When two entries share a
slot (sortOrder), ask which one if it is not obvious.

## Tool semantics

- `swap_plan_entries {"entryIdA": A, "entryIdB": B}` exchanges `date`,
  `mealType` and `sortOrder` of the two entries. Everything else (dish,
  recipe, attendees, comments, logs) stays with each entry.
- `move_plan_entry {"id": A, "date": "…", "mealType": "…"}` moves one entry;
  `mealType` and `sortOrder` are optional. If the target slot already has an
  entry, the moved one is appended after it (both stay; pass `sortOrder` to
  put it first). Ask whether the other one should move or go.
- `update_plan_entry {"id": A, "patch": {…}}` changes fields in place
  (`dishName`, `recipeId`, `sideRecipeId`, `notes`, `attendeeIds`,
  `servings`, `cookingTimeMin`, `leftoversNote`, `cookedAt`, …). Comments and
  logs stay attached, so prefer it over delete-and-add.
- `delete_plan_entries {"ids": [...]}` (up to 100 ids) or `{"batchId": …}`,
  never both, deletes entries and their comment threads; meal logs keep the
  dish name. Always ask before deleting, and prefer moving when the
  ingredients are already bought.

## "I ate Tuesday's dinner on Monday"

Today is Monday 2026-11-09. Plan: Monday dinner "Fish tacos" (`pe_mon`),
Tuesday dinner "Chicken curry" (`pe_tue`).

1. `get_context {}`; your member is `fm_me` (linkedUserId = actor.userId).
2. `get_plan {"from": "2026-11-09", "to": "2026-11-10"}` → find `pe_mon` and
   `pe_tue`.
3. Both exist, so the natural reading is that the fish tacos move to Tuesday:
   ```
   swap_plan_entries {"entryIdA": "pe_mon", "entryIdB": "pe_tue"}
   ```
   (If Monday had no dinner planned, use
   `move_plan_entry {"id": "pe_tue", "date": "2026-11-09", "mealType": "dinner"}`
   and offer to plan something for Tuesday.)
4. Log what was eaten, linked to the entry that is now on Monday:
   ```
   log_meal {"familyMemberIds": ["fm_me"], "date": "2026-11-09",
     "mealType": "dinner", "planEntryId": "pe_tue"}
   ```
   "I ate" logs the user only; "we ate" uses `"familyMemberIds": "all"`,
   which resolves to the entry's attendees (all active members when it has
   none). Ask for a rating or feeling only if
   the user volunteered one or seems open to it (see
   logging-and-feedback.md).
5. Shopping: a swap inside one list's date range changes nothing. If an entry
   moved into or out of the range of `activeShoppingList`, offer
   `refresh_shopping_list`.
6. Reply: "Done: chicken curry is now Monday's dinner and logged for you; fish
   tacos moved to Tuesday."

## Replace a dish

"Make pasta instead of the salmon on Friday."

1. `get_plan` for Friday → `pe_fri` (salmon).
2. Find the new recipe (`search_recipes`, or web search and `save_recipe`).
3. ```
   update_plan_entry {"id": "pe_fri", "patch": {
     "dishName": "Spaghetti with tomato and tuna", "recipeId": "rc_tuna_pasta",
     "cookingTimeMin": 20, "notes": null}}
   ```
4. Check the new dish against the attendees' restrictions and the weekly rules
   (replacing the only fish meal may break "fish twice a week": say so).
5. Offer `refresh_shopping_list` when a list covers Friday.

## Skip a meal

"We're not cooking Wednesday, too busy."

- Ask: move it (ingredients are bought) or drop it? If move (say to
  Thursday): `move_plan_entry {"id": "pe_wed", "date": "2026-11-12"}`.
- If drop, confirm, then `delete_plan_entries {"ids": ["pe_wed"]}` and offer
  `refresh_shopping_list`.
- If they will eat something easy instead and want it tracked, add or log it
  (below).

## Ate out instead

"We had pizza at a restaurant tonight instead of the stir-fry."

1. Log what they actually ate:
   ```
   log_meal {"familyMemberIds": ["fm_ana", "fm_tomas"], "date": "2026-11-09",
     "mealType": "dinner", "dishName": "Restaurant pizza",
     "note": "Ate out instead of the planned stir-fry"}
   ```
   Add `nutrition` only from real data (menu nutrition info) or as a clearly
   rough estimate with `"estimated": true`, and tell the user it is an
   estimate. Without either, leave nutrition out.
2. Ask what happens to the planned stir-fry: move it to another day
   (ingredients bought) or delete it. Then act and offer a shopping list
   refresh if a list covers the range.

## Leftovers

A leftovers meal is its own plan entry with the original `recipeId` and
`servings: 0`: it shows on the timeline, its nutrition counts for whoever
eats it, and it adds nothing to shopping lists.

- Leftovers already planned: log them like any planned meal
  (`log_meal` with `planEntryId`); nutrition comes from the recipe.
- Unplanned leftovers ("we had the rest of yesterday's chili for lunch"):
  `log_meal` with the chili's `recipeId`, `mealType: "lunch"`, and a `portion`
  that matches what they ate. If a different lunch was planned, ask whether to
  move it.
- Cooking extra for later: `update_plan_entry` on the cooking entry
  (`servings` = attendees + extra portions, `leftoversNote`), then
  `add_plan_entries` for the leftovers meal:
  ```
  add_plan_entries {"entries": [{"date": "2026-11-11", "mealType": "lunch",
    "dishName": "Chili (leftovers)", "recipeId": "rc_bean_chili", "servings": 0,
    "notes": "Leftovers from Tue dinner"}]}
  ```
  Offer `refresh_shopping_list`: the extra servings on the cooking entry
  change quantities.
- Turning a normal entry into leftovers ("we'll just eat Monday's leftovers
  on Wednesday"): `update_plan_entry` with `{"recipeId": <Monday's recipe>,
  "servings": 0, "dishName": "… (leftovers)"}`, then offer a refresh.

## Who eats changes

"Tomas is away Thursday" → `update_plan_entry {"id": "pe_thu", "patch":
{"attendeeIds": ["fm_ana", "fm_ema"]}}`. Shopping quantities follow attendees,
so offer a refresh. Do not archive a member who is only away.

## Locked or forbidden

Plan entries are not locked by coaches, but rules and targets are. If a change
conflicts with a coach-locked rule (for example a banned food), tell the user
and offer to ask the coach with `add_comment` (`kind: "question"`) on that
plan entry.
