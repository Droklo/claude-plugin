# Web recipe search

Droklo never searches the web or fetches pages itself. You do, with your own
web search and page-fetch tools, then save the result with `save_recipe`.
Search the household library (`search_recipes`) first; go to the web only for
what the library cannot cover.

## Inputs to collect first

From `get_context`:

- **Constraints:** restrictions of every attendee, `nutritionRules`
  (`foodRestrictions`, `bannedFoods`, `selectedDiets`, `carbLimit`), time limit
  of the slot, `householdNotes` (equipment, skills, budget).
- **Taste:** `history.liked`, `history.disliked`, recent dishes (avoid repeats).
- **Where to look:** `favoriteSources[]` (`name`, `url`, `searchHint`) and
  `nutritionRules.searchTips`.
- **Region:** `timezone`. For US households prefer US sites, US grocery
  ingredients and US units; for European households prefer metric sites. A
  favourite source may be in another language: search it in its own language,
  then translate the recipe into English when you save it (recipe-capture.md).

## Search order

1. **Favorite sources.** For each relevant favorite source, query the site
   directly and add its `searchHint` when present:
   - `site:budgetbytes.com chickpea curry`
   - `site:chefkoch.de kichererbsen curry` (a German site, searched in German)
   If `site:` returns little, try natural phrasing with the source name
   (`chickpea curry budget bytes`) and one or two rewordings before moving on.
2. **Well-known recipe sites** with tested recipes and structured data.
3. **The open web**, filtered by the quality signals below.

Collect two or three candidates per meal, then pick the best fit. When the
user loves a new site, offer `add_favorite_source {"name": …, "url": …,
"searchHint": …}`.

## Quality signals

Prefer a recipe that has:

- a complete ingredient list with quantities and a stated yield (servings);
- times (prep, cook or total) that fit the slot;
- nutrition per serving on the page (or in its schema.org `Recipe` data):
  it saves estimation and is more accurate;
- schema.org `Recipe` markup (most recipe sites have it; see
  recipe-capture.md);
- a real author or test kitchen, and many ratings or reviews;
- ingredients available in an ordinary supermarket for this household;
- equipment the household has (`householdNotes`).

Avoid:

- paywalled or login-only recipes (for example subscription cooking sites)
  unless the user says they subscribe;
- pages without the actual recipe (aggregators, Pinterest pins, video-only
  posts): follow them to the original;
- content farms and AI-generated pages with vague quantities or impossible
  times;
- recipes that need an ingredient the household bans, even "optional"
  toppings, unless you remove it and the dish still works.

## Allergy and rule cross-check

Read the **whole** ingredient list, including sauces, marinades, toppings and
"store-bought" components. Watch for hidden sources:

| Restriction | Hidden in |
|---|---|
| `gluten` | soy sauce, teriyaki, breadcrumbs, couscous, bulgur, seitan, beer, malt, flour-thickened sauces and gravies, many stock cubes |
| `dairy` | butter, ghee, cream, cheese (also parmesan in pesto), yogurt marinades, whey, casein, milk chocolate |
| `nuts` | pesto, satay and peanut sauces, marzipan, nut butters, nut milks, praline, some curry pastes and granolas |
| `shellfish` | shrimp paste in Thai and Malaysian curry pastes, oyster sauce, some fish sauces, seafood stock |
| `soy` | soy sauce and tamari, miso, tofu, tempeh, edamame, many vegan meat and cheese substitutes |
| `eggs` | mayonnaise and aioli, fresh pasta, breading and batters, meringue, most baked goods, some dressings |
| `ultra-processed` | instant noodles, processed meats, flavored yogurts, ready sauces and snacks |
| `cancer-related` | processed and cured meats (bacon, ham, salami, sausages), smoked meats; red meat should stay moderate |

- A simple, reliable swap is fine; write it in the plan entry `notes`
  (for example "use gluten-free tamari instead of soy sauce"). Tamari is still
  soy.
- If the dish depends on the allergen (peanut satay for a nut allergy), reject
  it and pick another.
- Never relax a restriction because the user's family "probably" tolerates it.
  Restrictions are facts; only the user or their coach changes them.

## Verify before you use it

1. Fetch the page and confirm it loads, is the recipe you meant, and is not
   behind a paywall. Never plan from a search snippet.
2. Extract the recipe (recipe-capture.md) and save it:
   `save_recipe {"recipe": {…, "sourceUrl": "<canonical URL>"}}`.
3. Use the returned `recipe.id` in `add_plan_entries`.

## Present choices

When the user is choosing, give each option on one line: name, source, time,
kcal and protein per portion (mark estimates), and why it fits ("nut-free,
25 min, uses the leftover rice"). Save only the recipes the user picks or
you plan.

## Example

Goal: a vegetarian dinner under 30 minutes for a household with `dairy`
restricted and `favoriteSources` = Budget Bytes (`searchHint`: "vegetarian").

```
search_recipes {"query": "vegetarian", "filters": {"maxCookingTimeMin": 30,
  "excludeAllergyMarkers": ["dairy"], "primaryProteinSources": ["legumes", "tofu-tempeh"]}}
  → 2 items, both eaten in the last week
```

Web: `site:budgetbytes.com vegetarian chickpea 30 minutes` → "Coconut
Chickpea Curry", 30 min total, 4 servings, nutrition per serving on the page,
coconut milk instead of cream (dairy-free). Fetch, extract, then:

```
save_recipe {"recipe": {
  "name": "Coconut Chickpea Curry", "sourceUrl": "https://www.budgetbytes.com/coconut-chickpea-curry/",
  "sourceName": "Budget Bytes", "portions": 4, "cookingTimeMin": 30,
  "nutritionPerPortion": {"caloriesKcal": 480, "proteinG": 13, "carbsG": 52, "fatG": 25},
  "nutritionEstimated": false, "recipeCategory": "complete-meal",
  "primaryProteinSource": "legumes", "dietTags": ["vegetarian", "vegan"],
  "ingredients": [ … ]
}}
```

(Numbers here are illustrative; always take them from the actual page.)
