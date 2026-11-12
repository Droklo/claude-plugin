# Planning workflow

A plan is entries on dates: one dinner, a week, a party. Same workflow
for every horizon.

## 1. Before the draft

- **Dates.** "This week" = today to Sunday; "next week" = Monday to
  Sunday. Say which dates you used. Entries come back with `weekday`:
  quote it, never work it out.
- **Meals and eaters.** The `home` meals of `nutritionRules.mealSchedule`
  and the members at home for each slot, unless they say otherwise.
  Regular guests are seated by Droklo.
- **Time.** `get_context.timeLimits`: start to table. Plan inside it.
- **Intake.** First visit: `planning.onboarding` as its `howTo` says.
  Otherwise ask `planning.intake` as worded, all in one reply, then
  draft. Save answers as each `save` says; unanswered parts go to
  `update_household {"asked": [key]}`. If they wave the questions away,
  plan on defaults; a safety question is still asked.
- **The dates answer** (guests, someone away, "nothing different") goes
  with the write:

```
add_plan_entries {"entries": [ … ],
  "datesConfirmed": {"from": "2026-11-09", "to": "2026-11-15",
    "note": "Guests on Saturday; nothing else different",
    "guests": [{"name": "Zoe", "restrictions": ["gluten"], "dates": ["2026-11-14"]}]}}
```

  No entries that turn: `update_household {"datesConfirmed": …}`.
  `guestFollowUp`: when, and how to save it, as its `save` says.
- **Start day.** Meals that need shopping start after
  `planning.nextShop`; an evening delivery does not feed that evening.
  Earlier days, tonight included, are planned from what is at home (the
  stored pantry; one question about fresh food if needed) or left open,
  and you say which.
- `get_plan` for the range first: do not plan a slot twice. Deal with
  `planChecks` on saved plans before adding more.

## 2. Choose dishes

The server checks restrictions, diets, dislikes, time, targets,
freshness and variety. Choosing well first is still yours:

- Read ingredients, not titles, for every eater and guest.
- Fit `foodProfile.equipment` and `foodProfile.cooking`.
- Most dishes serve the health goal; say how in one line. Save what a
  person says about their health on them that turn (`pregnant`,
  `watch`, `carbsPerMealG`, `strictAllergy`; doctor's words in `goals`).
- A stated budget picks the dish: cheaper of two, ingredients reused
  across days, few one-use leftovers. Give your estimate and what it
  covers. Droklo knows no prices.
- Dishes they already cook: `save_recipe` each that turn (their words,
  rough amounts, `nutritionEstimated: true`) and plan by id.
- Follow `weeklyFoodGroupBalance` and `requiredFoods`. Prefer
  `history.liked`, `returnVisit.bringBack`; skip `history.disliked`,
  `keepOut` and the last two weeks' dishes.
- Fresh meat and fish right after the shop.

## 3. Recipes: library first

```
search_recipes {"query": "salmon", "filters": {"maxTotalTimeMin": 30,
  "recipeCategories": ["complete-meal", "main-course"],
  "excludeAllergyMarkers": ["nuts", "gluten"]}}
```

A `main-course` needs a `sideRecipeId`; a side only in `notes` reaches
no list. Nothing suitable: web-recipe-search.md, then `save_recipe`
before planning. An entry with only a `recipeUrl` gives no shopping
items and no nutrition.

## 4. Portions

- `servings` omitted = one per eater, guests included.
- **Leftovers:** cooking entry with `servings` = eaters + extra and a
  `leftoversNote`; the later meal is its own entry, same `recipeId`,
  `servings: 0`, "Chili (leftovers)", reheating minutes as
  `cookingTimeMin`. Cook whole packs.
- **Extra for some eaters:** `additions` (`name`, `grams`, `memberIds`).
- **A different dish for one person:** a second entry in the slot with
  them in `attendeeIds`; the main entry without them.
- Several dishes in a meal: one entry each, `sortOrder`.
- No recipe (takeaway, toast): add a rough `nutrition` estimate
  yourself; never ask the person for numbers.

## 5. Draft, then write

Pick recipes first so the minutes are real. Run the write with
`"dryRun": true`, fix what `planChecks` and `dayTotals` show, then show
the draft: one line per day (day, dish, minutes). End with what a yes
will do: "Say yes and I save these five dinners and make the shopping
list for Saturday." Takeaway and eating-out nights are entries too.

Write all entries in one call with a `batch` (`title`, `summary` of
your reasoning). Undo a batch with `delete_plan_entries {"batchId"}`
after asking.

## 6. Act on the result

- `planUrl`: the only link you give.
- `planChecks`: fix or state each. `over_time`: swap or move the dish, do
  not ask for more time; unattended dish: put the start time in
  `notes`; default limit: do nothing. `meal_limit`: change portion or
  dish. `health`: change the dish, or write how the person settled it
  in `notes` ("pasteurised"); a label they read: `checkedLabels`, on
  their word only. Never call a meal safe for a strict allergy while a
  label finding stands. `fresh_early`: do what it says.
- `assumptions`: state in one line, ask nothing.
- `coverage`: one line if asked for those days; no placeholder.
- `dayTotals`: `partial`, `uncounted` or `sharedFood` rows are not a
  whole day; never say someone eats too little from them. A day off
  target: fix with `servings`, `additions` or a snack.
- `notOnList`: say which dishes add nothing to the list.
- `no_shopping_list`: do what the message says.

Then make the list in the same turn and report (shopping.md). For one
meal, offer the list instead.

## 7. When they come back

Notices first. Do what `returnVisit.opening` says: with `ask`, that is
the reply's only question; name `unlogged` meals in one line and offer
to log them in one go. With `upcoming` and no `ask`, say what is coming.
Never re-ask `latestRatings`. Save what they say (`log_meal` with
`planEntryId`, `rate_recipe`, tastes, corrected times); move or remove
a meal only if asked; use bought food first. An urgent request comes
before all of this. A plan that ran out before today: say so and offer
the next stretch.

## Variations

- **One meal:** no draft; search, write, report.
- **Guests:** `guests` on the entries (`name`, `restrictions`, `diet`,
  `note`). Droklo checks and shops for them. For an allergy or medical
  diet, ask the host exactly what to avoid and how strict; make one
  filling dish safe by nature and say which; say what the guest skips.
- **Who cooks:** `cookMemberId`; a rota is one line in `householdNotes`.
- **Coach proposals** (`proposal` notice, `status: "draft"`): say what
  and when; accept with `accept_proposals {"batchId"}` only when asked;
  on `shoppingNote` offer a list; decline with `delete_plan_entries`.
- **Away:** leave them out of `attendeeIds`; never archive a traveller.
- **One more meal in a shopped week:** build on what is left; add the
  few missing things to the active list.
- **Batch cooking:** ask session length and storage; two or three
  dishes for two hours; order of work in the first entry's `notes`;
  later meals are leftovers entries.
- **Two diets:** `foodProfile.sharedTable`. `one-dish`: shared base
  plus `additions`; `separate-dishes`: own entry. The diet is saved on
  the person; `selectedDiets` only for the whole household.
- **Religious rules:** ask once what it covers; save the diet and
  `bannedFoods`; read for wine, stock, gelatin.
- **Baby or small child:** feeding advice belongs to their health
  professional; you may say which dinners a plain portion comes from.
- **Low energy, illness, newborn:** one cook session for the hard
  evenings, no-cook food for the rest.
- **Shift work:** limits-and-fit.md.
- **Only ideas:** suggest without writing.
