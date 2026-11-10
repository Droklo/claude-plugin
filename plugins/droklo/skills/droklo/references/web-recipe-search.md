# Web recipe search

Droklo never searches the web. You do, with your own tools, then
`save_recipe`. Search the library (`search_recipes`) first.

## Where to look

1. `favoriteSources` (`site:<url> <dish>` plus its `searchHint`; search
   a foreign-language site in its language, save in English) and
   `nutritionRules.searchTips`.
2. Well-known sites with tested recipes.
3. The open web.

Match the household's region (`timezone`) for units and ingredients.
Two or three candidates per meal, pick the best. They love a new site:
offer `add_favorite_source {"name", "url", "searchHint"}`.

## A good recipe

Has full amounts and a yield, times that fit the slot, nutrition on
the page, a real author or many reviews, supermarket ingredients, and
equipment the household owns (`foodProfile.equipment`).

Skip paywalled pages (unless they subscribe), pages without the recipe
itself (follow to the original), vague content-farm pages, and dishes
that depend on a banned food.

## Read every ingredient

Sauces, marinades, toppings and ready-made parts included.

| Restriction | Hides in |
|---|---|
| `gluten` | soy sauce, breadcrumbs, couscous, bulgur, seitan, beer, malt, oats, flour-thickened sauces, stock cubes |
| `dairy` | butter, ghee, cream, parmesan in pesto, yogurt marinades, whey, casein |
| `nuts` | pesto, satay, marzipan, nut milks, praline, some curry pastes, granola |
| `peanuts` | satay, peanut oil, Asian sauces, snack bars |
| `sesame` | tahini, hummus, sesame oil, seeded buns, Asian dressings |
| `fish` | fish sauce, anchovies (Caesar, Worcestershire), some curry pastes |
| `shellfish` | shrimp paste, oyster sauce, seafood stock |
| `soy` | soy sauce, tamari, miso, tofu, tempeh, edamame, vegan substitutes |
| `eggs` | mayonnaise, fresh pasta, batters, meringue, baked goods |

- A reliable swap is fine: save the recipe with the swapped ingredient
  ("gluten-free tamari") so the list and checks see it.
- The dish depends on the allergen: pick another.
- Never relax a restriction because they "probably" tolerate it.

## Before you plan it

- Open the page; never plan from a search snippet. Save with the
  canonical `sourceUrl` (recipe-capture.md) and plan by `recipe.id`.
- A site refuses to open: do not retry it. Use one that opens, or ask
  them to paste the page.
- Nothing opens, or the dish is simple: write your own version, no
  `sourceUrl`, `nutritionEstimated: true`, and say "my own version,
  not from a site". Never cite a page you did not read.

## Offering choices

One line each: name, source, minutes, why it fits. Save only what they
pick or you plan.
