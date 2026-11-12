# Web recipe search

Droklo never searches the web. You do, then `save_recipe`. Library
(`search_recipes`) first. A post they sent: recipe-capture.md.

## Where to look

1. `favoriteSources` (`site:<url> <dish>` plus its `searchHint`; search
   a foreign-language site in its language, save in English) and
   `nutritionRules.searchTips`.
2. Well-known sites with tested recipes.
3. The open web.

Match the household's region (`timezone`) for ingredients. Two or
three candidates per meal, pick the best. They love a new site: offer
`add_favorite_source {"name", "url", "searchHint"}`.

## A good recipe

Has full amounts and a yield, times that fit the slot, a real author
or many reviews, supermarket ingredients, and equipment the household
owns (`foodProfile.equipment`). A nutrition figure in a post is a
claim.

Skip pages without the recipe itself (follow to the original), vague
content-farm pages and dishes that depend on a banned food. Paid
content: only a recipe they cook, from text they give, never in bulk.

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

- A reliable swap is fine: save one recipe, the safe one ("gluten-free
  tamari"), and say "changed from the original".
- The dish depends on the allergen: pick another.
- Never relax a restriction because they "probably" tolerate it.

## Before you plan it

- Open the page; never plan from a snippet. Save the canonical
  `sourceUrl`, the creator and amounts as written; plan by
  `recipe.id`.
- A site refuses to open: try once, then use one that opens. Never
  cite a page you did not read.
- Nothing opens, or the dish is simple: your own version, no
  `sourceUrl`, `nutritionEstimated: true`; say "my own version, not
  from a site".

## Offering choices

One line each: name, source, minutes, why it fits. Save what they
pick.
