# Planning workflow

Droklo has no weekly plan. A plan is any number of entries on dates: one
dinner, three lunches, a week of everything, a birthday party. Use the same
workflow for every horizon.

## 1. Load context

```
get_context {}
```

Collect:

- `today` and `household.timezone`: every date you write is a calendar date
  in that timezone.
- `members[]`: `id`, `name`, `isActive`, `restrictions`, `targets`
  (`dailyCaloriesKcal`, `dailyProteinG`, `dailyFatG`, `dailyCarbsG`), `goals`,
  `locks`.
- `nutritionRules`: `selectedDiets`, `foodRestrictions` (household-wide),
  `bannedFoods`, `requiredFoods`, `recommendedFoods`,
  `weeklyFoodGroupBalance` (for example fish 2 times per week),
  `specialRules`, `recipeChecklist`, `carbLimit`, `searchTips`,
  `defaultGuidance` and `mealSchedule`.
- `mealSchedule[]`: per weekday (`day`: `mon` … `sun`) the usual `meals`,
  each with `name` (a meal type code; custom slots are `"other"` with a
  `customName`, which you use as the plan entry `label`), `label` (`home` or
  `out`), `maxPrepMinutes` and `memberAttendance[]` (`memberId` with status
  `home`, `out` or `skip`). This tells you which meals to plan by default, who is home and how
  much cooking time there is.
- `history.logs`, `history.liked`, `history.disliked`: what they ate, loved
  and rejected recently.
- `upcoming[]`: what is already planned for the next 7 days.
- `household.householdNotes`: kitchen equipment, budget, skills, picky eaters.

## 2. Pin down the request

Work out, asking only for what you cannot infer:

| Question | Default when the user does not say |
|---|---|
| Which dates? | "this week" = today to the coming Sunday; "next week" = next Monday to Sunday; "the weekend" = the coming Saturday and Sunday. On a Saturday or Sunday, "this week" usually means the week starting next Monday: say which dates you used. |
| Which meals? | The meals in `mealSchedule` with `label: "home"` for those weekdays; otherwise the meal types the user named. |
| Who eats? | Members with `memberAttendance` status `home` for that slot; otherwise all active members (omit `attendeeIds`). |
| How much time? | `maxPrepMinutes` of the slot; otherwise 30 minutes on weekdays, 60 at weekends. |
| Guests? | None. For guests, ask how many and about their allergies. |

Then check what is already there:

```
get_plan {"from": "2026-11-09", "to": "2026-11-15"}
```

Do not plan a slot twice. If a slot already has an entry, keep it unless the
user asked to replace it (then use `update_plan_entry`, see
changes-and-swaps.md).

## 3. Build the constraint set

For each meal, the constraint set is the union of:

- the `restrictions` of every attendee and `nutritionRules.foodRestrictions`;
- `bannedFoods` (never) and the diets in `selectedDiets`;
- the slot's time limit;
- variety: no dish that appears in `history.logs` or `upcoming` within the
  last 14 days, and no `history.disliked` dish; rotate primary proteins
  (`fish`, `poultry`, `red-meat`, `legumes`, `eggs`, …) across the horizon;
- `weeklyFoodGroupBalance` and `requiredFoods` across the horizon
  (for example "fish 2 times per week" in a 7-day plan means at least 2 fish
  meals);
- targets of attendees who have them (see step 6).

## 4. Find recipes: library first

```
search_recipes {"query": "salmon", "filters": {
  "maxCookingTimeMin": 30,
  "recipeCategories": ["complete-meal", "main-course"],
  "excludeAllergyMarkers": ["nuts", "gluten"],
  "minProteinPerPortion": 30
}, "limit": 20}
```

- `recipeCategories` by meal type: breakfast → `breakfast`, `snack`;
  lunch and dinner → `complete-meal`, `main-course`, `soup`, `salad`;
  snack → `snack`, `dessert`.
- `excludeAllergyMarkers` takes restriction codes. Put every allergen-type
  restriction of the attendees there (`gluten`, `dairy`, `nuts`, `shellfish`,
  `soy`, `eggs`) and also `ultra-processed` or `cancer-related` when the
  household restricts them.
- Prefer `history.liked` dishes and recipes with nutrition
  (`caloriesPerPortion`, `proteinPerPortion` not null).
- A recipe with `recipeCategory: "main-course"` needs a side: pick a side-dish
  recipe for `sideRecipeId`, or write the side in `notes`.
- Before planning a library recipe for someone with an allergy that the
  filter could not cover (for example a restriction added after the recipe was
  saved), open it with `get_recipe` and check `ingredients[].allergyMarkers`
  and the ingredient names yourself.

Only when the library has nothing suitable, search the web (read
web-recipe-search.md). Save every web recipe with `save_recipe` and use the
returned `recipe.id`. Never plan a web recipe that is not saved; a bare
`recipeUrl` without `recipeId` gives no shopping items and no nutrition.

## 5. Portions, leftovers and sides

- `servings: null` (or omitted) cooks one portion per attendee. Set
  `servings` explicitly when portions differ from heads: guests, teenagers
  eating double, or cooking extra for leftovers.
- Leftovers: on the cooking entry set `servings` to attendees + extra
  portions and `leftoversNote` (for example `"2 portions for Wed lunch"`).
  Add the leftovers meal as its own entry with the **same `recipeId`** and
  **`servings: 0`**, a `dishName` such as `"Chili (leftovers)"` and
  `notes: "Leftovers from Tue dinner"`. `servings: 0` means nothing is
  cooked: the entry adds nothing to shopping lists, but it shows on the
  timeline and its nutrition counts for whoever eats it when it is logged.
- Several dishes in one meal (party buffet, dinner plus dessert): one entry
  per dish with the same `date` and `mealType` (they stack), ordered with `sortOrder`
  0, 1, 2…

## 6. Check against targets

When attendees have targets, check each planned main meal per portion:

- dinner or lunch: about 30–35 % of the person's daily calories and at least
  30 % of daily protein;
- breakfast: about 20–25 %; snacks: about 10–15 %.

These are planning heuristics, not rules. If a member's targets are far from
the family's (for example a coach set 180 g protein for one person), suggest a
per-person addition in `notes` ("Tomas: add 150 g extra chicken") rather than
a different dish. Nutrition numbers come only from recipes; when a recipe has
no nutrition, say so instead of guessing.

## 7. Draft, confirm, write

For 3 or more new entries, show a compact draft and wait for a yes, unless the
user said to just do it:

| Date | Meal | Dish | Time | kcal / protein per portion | Source |
|---|---|---|---|---|---|
| Mon 9 Nov | dinner | Sheet-pan salmon with potatoes | 30 min | 610 / 41 g | Library |
| Tue 10 Nov | dinner | Black bean chili | 35 min | 520 / 24 g (estimated) | budgetbytes.com |

Then write all entries in one call (1–50 entries; split larger plans into
several calls) with a batch title and a one-paragraph summary of your
reasoning. The batch lets the user undo the whole run with
`delete_plan_entries {"batchId": …}` (after asking).

```
add_plan_entries {
  "entries": [
    {"date": "2026-11-09", "mealType": "dinner",
     "dishName": "Sheet-pan salmon with potatoes", "recipeId": "rc_salmon_potatoes",
     "cookingTimeMin": 30},
    {"date": "2026-11-10", "mealType": "dinner",
     "dishName": "Black bean chili", "recipeId": "rc_bean_chili",
     "cookingTimeMin": 35, "servings": 6, "leftoversNote": "2 portions for Wed lunch"},
    {"date": "2026-11-11", "mealType": "lunch",
     "dishName": "Black bean chili (leftovers)", "recipeId": "rc_bean_chili",
     "servings": 0, "notes": "Leftovers from Tue dinner",
     "attendeeIds": ["fm_ana", "fm_tomas"]}
  ],
  "batch": {
    "title": "Dinners 9–15 Nov",
    "summary": "Fish twice (rule), one legume dinner, max 35 min on weekdays, nut-free for Ana; chili doubles as Wednesday lunch."
  }
}
```

`newRecipe` inside an entry saves a brand-new recipe in the same call. Prefer
a separate `save_recipe` first, so you can dedupe and check the saved result.

## 8. Report and follow up

- List what was added (dates, meals, dishes) and anything you could not fill,
  each meal with its `url` (opens it in Droklo).
- Mention estimated nutrition as estimated.
- If the result's `shoppingLists` is not empty, an active list covering these
  dates has already taken in the new meals: say what it added, with the list's
  `url`. Otherwise offer `create_shopping_list` for the planned range (see
  shopping.md).

## Variations

**One meal.** Skip the draft: search, pick, `add_plan_entries` with one entry,
report.

**A few meals ("3 dinners this week, I'll do the rest").** Ask which days only
if it matters; otherwise pick the evenings with the most cooking time
(`maxPrepMinutes`) and say which you chose.

**A party or guests.** Ask for the number of guests, their allergies and the
style (buffet, sit-down, kids). Use one entry per dish, `mealType` of the
occasion (`dinner`, or `other` with `label: "Birthday party"`), `servings` =
total portions including guests, and `attendeeIds` for the household members
who attend. Guests' allergies are not stored in Droklo; check them yourself
and write them in `notes` ("Guests: one gluten-free").

**Someone is away.** Pass `attendeeIds` without that member. Do not archive
members who are only travelling.

**Batch cooking.** One cooking entry with `servings` for all meals and
`leftoversNote`, plus one leftovers entry per later meal with the same
`recipeId` and `servings: 0`.

**The user only wants ideas.** Suggest dishes in chat without writing. Offer to
add the ones they like.

## Worked example: a week of dinners for a family of four

Context: today `2026-11-08` (Sunday). Members Ana (nuts), Tomas (coach-locked
targets 2,400 kcal and 160 g protein), Ema (8) and Jonas (5). Rules: fish
twice a week; weekday `maxPrepMinutes` 30; Thursday dinner is `out` for Tomas.

1. `get_context {}`, then `get_plan {"from": "2026-11-09", "to": "2026-11-15"}`
   → Saturday already has "Pizza night".
2. `search_recipes` twice: fish (`primaryProteinSources: ["fish"]`,
   `maxCookingTimeMin: 30`, `excludeAllergyMarkers: ["nuts"]`) and other
   mains. The library gives 4 good options; 2 are missing (a legume dinner and
   a quick soup).
3. Web search for the missing two from `favoriteSources` first, then
   `save_recipe` for each (see recipe-capture.md) → `rc_lentil_soup`,
   `rc_bean_tacos`.
4. Draft: Mon salmon, Tue chicken stir-fry, Wed lentil soup, Thu bean tacos
   (attendees without Tomas), Fri cod, Sat pizza (existing), Sun roast chicken
   with leftovers for Monday lunch. Tomas: dinners at 650–750 kcal and 45–55 g
   protein, with "Tomas: extra portion of chicken" in notes on Tuesday.
5. User agrees → one `add_plan_entries` call with 7 entries (6 dinners plus
   Monday's leftovers lunch) and a batch summary.
6. Report and offer: "Want a shopping list for 9–15 Nov?"
