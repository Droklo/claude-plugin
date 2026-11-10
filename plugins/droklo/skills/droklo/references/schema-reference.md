# Schema reference

Codes are lowercase English, exactly as each tool's schema lists them.
Say them in the person's words. Each result's `message` fields say what
to do; this file covers what the schemas do not explain.

## Dates

`YYYY-MM-DD` in the household timezone; "today" is `get_context.today`,
never your clock. Ranges are inclusive. Timestamps are ISO 8601 with
offset. Weekdays: `mon` … `sun`; entries carry their `weekday`.

## Meals

`mealType`: `breakfast`, `lunch`, `dinner`, `snack`, `other` (name in
`label`). A `mealSchedule` slot: `id`, `name`, `label` (`home`/`out`),
`maxPrepMinutes`, `memberAttendance[]` (`memberId`, `status`
`home`/`out`/`skip`). Send all seven days back when you change one.

## Restrictions and diets

- Restriction codes: `gluten`, `dairy`, `nuts` (tree nuts; peanuts too
  when unknown), `peanuts`, `sesame`, `fish`, `shellfish`, `soy`,
  `eggs`, `ultra-processed`, `cancer-related` (processed and cured
  meat). A member's apply at every meal they attend; the household's
  `foodRestrictions` at every meal.
- Household `selectedDiets`: `none`, `mediterranean`, `bodybuilding`,
  `keto`, `vegetarian`, `vegan`, `lowcarb`, `low-cholesterol`,
  `custom`.
- A person's `diet`: `vegetarian`, `vegan`, `pescatarian`, `halal`,
  `kosher`; `dietDays` limits it to weekdays. Other rules go in their
  `notes`.
- `restrictionExceptions`: foods a person may have despite a rule.
- `update_nutrition_rules {"patch"}`: list items are added (send the
  new item alone); `"remove": {"bannedFoods": ["Pork"]}` takes one
  out; `selectedDiets`, `foodRestrictions`, `mealSchedule` are
  replaced whole; `"dryRun": true` previews.

## Health without a number (member fields)

Save the turn the person says it; `null` clears. General food checks,
never clinical advice.

- `pregnant: true`: foods advised against in pregnancy are flagged.
- `watch`: any of `salt`, `sugars`, `saturatedFat` (cholesterol),
  `carbs`, `iron`.
- `carbsPerMealG`: per-meal carbohydrate limit (a bread unit is 12 g).
- `strictAllergy: true`: "may contain" counts; label-dependent foods
  are flagged.
- `numbersHidden: true` (set by a coach): never say calories, grams or
  targets for that person; keep saving them.

## Food profile (`household.foodProfile`)

`weeknightMinutes`, `weekendMinutes` (win over slot defaults; `0` = no
limit), `sharedTable` (`one-dish`/`separate-dishes`), `regularGuests`
(`name`, `weekdays`, `mealTypes?`, `restrictions?`, `diet?`, `note?`;
`[]` = nobody), `cooking`, `plannedMeals`, `pantry` (names only),
`units` (`metric`/`us`), `budget` (`tight`, `moderate`, `flexible`,
`none`), `weeklyBudget` (`{amount, currency, covers}` or `"none"`),
`equipment`, `cuisines`, `shoppingDays`. What has no field goes in
`householdNotes`.

`update_household` also takes `setupDone` (topics with nothing to
add), `asked` (intake keys asked and not answered), `datesConfirmed`
and `reminderDay`. `household.reminders.email` is true only when
Droklo can send email.

## Plan entries

- `servings`: `null` = one per eater; a number = portions cooked; `0` =
  leftovers (keep `recipeId`).
- `additions`: up to 8 `{name, grams, memberIds}`. `guests`: up to 12
  `{name, restrictions?, diet?, note?}`. `cookMemberId`.
- `nutrition` (`caloriesKcal`, `proteinG`, `carbsG`, `fatG` per
  serving): for a meal without a recipe; an estimate.
- `status: "draft"` is a coach's proposal: on no list and in no total
  until accepted (`accept_proposals`).
- Each entry's `recipe` has `prepTimeMin`, `cookingTimeMin`,
  `totalTimeMin`: quote these.

## Plan checks (`planChecks[]`)
Act on each `message`; usual fixes are in planning-workflow.md, step 6.
A food a person may in fact have: `restrictionExceptions`.
`dates_unconfirmed`: ask the dates question.

## Nutrition fields

Recipe `nutritionPerPortion` + `nutritionEstimated`. Log `nutrition`
(totals eaten) + `estimated`. Member `targets`: `dailyCaloriesKcal`,
`dailyProteinG`, `dailyFatG`, `dailyCarbsG`; `trainingDays` with
`trainingTargets` replace them on those days.

## Logs, ratings, comments

- `rating`: `liked`, `neutral`, `disliked` (`rate_recipe`: liked or
  disliked). `feeling`: `great`, `ok`, `heavy`, `bloated`,
  `still-hungry`, `low-energy`. `reading`: `{kind, value, unit,
  timing?}`, stored, never interpreted.
- Comment `target.type`: `planEntry`, `mealLog`, `recipe` (with `id`),
  `day` (with `date`), `general`. `kind`: `comment` or `question`.
  Replies use `parentId`.
- `notices`: `proposal` (with `batchId`) or `targets`; `mark_read`
  takes the notice `id`.

## Limits and call shape

- `add_plan_entries` up to 50 entries; `delete_plan_entries` 100 ids;
  `search_recipes` `limit` 50 with `offset`; date ranges 366 days
  (coach tools 92).
- Arguments are flat except `save_recipe {recipe}` and
  `update_nutrition_rules {patch}`. Unknown keys fail with `INVALID`.
  On updates `null` clears.
- Errors: `NOT_A_MEMBER`, `FORBIDDEN`, `LOCKED`, `NOT_FOUND`,
  `INVALID`, `INTERNAL`: do what the `message` says.
