# Schema reference

Codes are stored and exchanged exactly as written here (lowercase English).
The web app translates them for people; you translate them in your replies.

## Dates and times

- Calendar dates: `YYYY-MM-DD` in the household timezone
  (`get_context.household.timezone`). "Today" is `get_context.today`, never
  your own clock.
- Timestamps (`eatenAt`, `cookedAt`, `createdAt`): ISO 8601 with offset, e.g.
  `2026-11-09T19:30:00-05:00`.
- Ranges (`from`, `to`) are inclusive.

## Meal types (`mealType`)

| Code | Use for |
|---|---|
| `breakfast` | Morning meal |
| `lunch` | Midday meal |
| `dinner` | Evening meal |
| `snack` | Anything between meals |
| `other` | Anything else; put the name in `label` ("Pre-workout", "Birthday party", "Brunch") |

`label` can also annotate a standard type (`dinner` + `label: "Date night"`).

## Weekdays (`nutritionRules.mealSchedule[].day`)

`mon`, `tue`, `wed`, `thu`, `fri`, `sat`, `sun`. Only the household's usual
rhythm uses weekdays; plan entries and logs always use dates.

Meal schedule slot fields: `id`, `name` (a meal type code; a custom slot is
`"other"` plus `customName`), `label` (`home` = eaten at home, `out` = eaten
away), `maxPrepMinutes`, `memberAttendance[]` with `memberId` and `status`
`home`, `out` or `skip`.

## Food restrictions (`restrictions`, `foodRestrictions`, `allergyMarkers`, `excludeAllergyMarkers`)

| Code | Meaning | Avoid (examples) |
|---|---|---|
| `gluten` | Gluten-free (celiac disease or intolerance) | wheat, barley, rye, spelt, regular pasta and bread, couscous, beer, regular soy sauce |
| `dairy` | Dairy-free (lactose intolerance or milk allergy) | milk, cheese, yogurt, cream, butter, ghee, whey, casein |
| `nuts` | Nut-free (tree nuts and peanuts) | almonds, walnuts, cashews, hazelnuts, pistachios, peanuts, nut butters and milks, pesto |
| `shellfish` | Shellfish-free | shrimp, crab, lobster, mussels, oysters, scallops, squid, octopus, oyster sauce, shrimp paste |
| `soy` | Soy-free | soy sauce, tamari, tofu, tempeh, edamame, miso, soy milk |
| `eggs` | Egg-free | eggs, mayonnaise, meringue, fresh egg pasta, most baked goods |
| `ultra-processed` | Avoid ultra-processed foods (NOVA group 4) | additives such as artificial sweeteners and colorings, instant noodles, packaged snacks, processed meats, sweetened flavored yogurts |
| `cancer-related` | Avoid foods WHO/IARC classify as carcinogenic, limit probable ones | processed and cured meats (bacon, ham, salami, sausages), smoked meats, nitrites; keep red meat moderate (about 500 g a week) |

A member's `restrictions` apply whenever they attend a meal; the household's
`nutritionRules.foodRestrictions` apply to every meal.

## Diets (`nutritionRules.selectedDiets`)

`none`, `mediterranean`, `bodybuilding` (high protein), `keto`,
`vegetarian`, `vegan`, `lowcarb`, `low-cholesterol`, `custom` (see the rule
text). Use the same words, lowercase, in recipe `dietTags`.

## Recipe categories (`recipeCategory`, `filters.recipeCategories`)

| Code | Meaning |
|---|---|
| `complete-meal` | Protein, carbs and vegetables in one dish |
| `main-course` | Main dish that needs a side (`garnishSuggestion`, `sideRecipeId`) |
| `soup` | Soups and stews |
| `salad` | Salads (side or main) |
| `side-dish` | Sides and garnishes |
| `breakfast` | Breakfast dishes |
| `snack` | Small bites, appetizers |
| `dessert` | Sweets, cakes, pastries |
| `drink` | Drinks and smoothies |
| `sauce-dip` | Sauces, dips, dressings |
| `bread-pastry` | Savory breads and pastries |
| `preserve` | Jams, pickles, ferments |

Meal type to categories: breakfast → `breakfast`, `snack`; lunch and dinner
→ `complete-meal`, `main-course`, `soup`, `salad`; snack → `snack`, `dessert`.

## Primary protein sources (`primaryProteinSource`, `filters.primaryProteinSources`)

`fish` (fish and seafood), `poultry`, `red-meat` (beef, pork, lamb), `eggs`,
`legumes`, `dairy`, `tofu-tempeh` (also seitan), `nuts-seeds`,
`grain-protein`, `none` (desserts, drinks, sauces).

## Processing levels (`processingLevel`)

`whole` (NOVA 1), `minimally-processed` (NOVA 1–2), `processed` (NOVA 3),
`ultra-processed` (NOVA 4). Examples are in recipe-capture.md.

## Shopping categories (`category`)

| Code | Contents |
|---|---|
| `vegetables` | Vegetables, potatoes, onions, garlic, mushrooms |
| `greens` | Leafy greens, lettuce, spinach, fresh herbs |
| `fruit` | Fruit and berries, lemons and limes, avocados |
| `meat-fish` | Meat, poultry, fish, seafood |
| `dairy` | Milk, cheese, yogurt, butter, cream, eggs |
| `canned` | Canned and jarred goods, stock, tomato paste, coconut milk |
| `grains` | Rice, pasta, flour, oats, bread, tortillas, quinoa, dried legumes |
| `nuts-seeds` | Nuts, seeds, nut butters |
| `oils` | Oils, vinegars |
| `spices` | Salt, pepper, spices, dried herbs |
| `other` | Everything else, including tofu, sauces, frozen foods and non-food items |

## Shopping units (`unit`, `defaultUnit`)

`g` (grams), `ml` (millilitres), `pcs` (pieces). Items may also have
free-text `quantityText` ("2 cans") and `quantityUnknown: true` when the
recipe gave no amount.

List statuses: `active`, `completed`, `archived`. Item `source`: `plan`
(computed from the plan) or `manual`.

## Meal ratings and feelings

- `rating` on logs: `liked`, `neutral`, `disliked`. `rate_recipe` takes only
  `liked` or `disliked`.
- `feeling`: `great`, `ok`, `heavy`, `bloated`, `still-hungry`,
  `low-energy` (mapping from everyday words is in logging-and-feedback.md).

## Comments

- `target.type`: `planEntry`, `mealLog`, `recipe` (with `id`), `day` (with
  `date`), `general` (neither `id` nor `date`).
- `kind`: `comment`, `question` (stays in the inbox until resolved).
- Replies: `parentId` = the root comment id; `target` can be omitted.

## People and workspaces

- Workspace `kind`: `family` (a household) or `practice` (a coach's
  practice with templates and a recipe library).
- Roles (`actor.role`): `owner` (full control, invites people), `member`
  (plans, logs, shops; cannot change members or invites), `specialist`
  (coach: reads the household plan and shopping list, and logs, targets and
  goals of assigned clients; can add and edit plan entries, comment, and set
  and lock clients' targets and the household rules; cannot log meals,
  delete plan entries or change shopping lists).
- Specialist titles: `coach`, `dietitian`, `doctor`, `trainer`.
- Invitation kinds for `invite_member`: `member`, `specialist`.

## Nutrition fields

- Recipe `nutritionPerPortion`: `caloriesKcal`, `proteinG`, `carbsG`,
  `fatG`, `fibreG`, `sugarsG`, `saturatedFatG`, `saltG` (per portion), with
  `nutritionEstimated`.
- Meal log `nutrition`: `caloriesKcal`, `proteinG`, `carbsG`, `fatG` (totals
  for the portion eaten), with `estimated`.
- Member `targets`: `dailyCaloriesKcal`, `dailyProteinG`, `dailyFatG`,
  `dailyCarbsG` (per day; null = not set).
- Energy check: kcal ≈ 4 × protein g + 4 × carbs g + 9 × fat g.

## Units for people

1 oz = 28.35 g, 1 lb = 453.6 g, 1 US cup = 240 ml, 1 tbsp = 15 ml,
1 tsp = 5 ml, 1 fl oz = 29.6 ml, 1 US quart = 946 ml, 1 US gallon = 3.785 l.
Show US households customary units and everyone else metric; always store
grams and millilitres.

## Errors

`NOT_A_MEMBER`, `FORBIDDEN`, `LOCKED`, `NOT_FOUND`, `INVALID`, `INTERNAL`
(what to do for each is in SKILL.md, "Errors").

## Limits

- `add_plan_entries`: 1–50 entries per call; `delete_plan_entries`: up to
  100 ids.
- `search_recipes`: `limit` up to 50; page with `offset`.
- Date ranges: `get_plan`, `get_meal_logs` and `create_shopping_list` span at
  most 366 days; coach tools (`list_clients`, `get_client_summary`) at most
  92. Split longer ranges.
- History in `get_context`: last 14 days by default; upcoming: next 7 days.
- Arguments are flat, except `save_recipe {recipe}` and the `patch` of
  `update_plan_entry` / `update_meal_log`. Unknown keys are rejected with
  `INVALID`. Optional arguments may be `null` (treated as omitted); inside a
  patch `null` clears a value.

## Plan entry servings

`servings`: `null` = one portion per attendee; a number = portions to cook
(guests, extra for leftovers); `0` = a leftovers meal: keep the `recipeId`,
nothing is cooked or bought, nutrition still counts when it is logged.
