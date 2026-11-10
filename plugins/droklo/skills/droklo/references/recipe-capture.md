# Recipe capture

Turn a link, post, photo, pasted text or a dish told in chat into one
`save_recipe` call. Droklo fetches nothing and stores no photos: you
extract and send. Save in English (translate; keep metric amounts and
proper names).

## Steps

1. **Get the content.**
   - URL: fetch it; prefer the schema.org `Recipe` JSON-LD, else the
     visible text. Paywalled or blocked: do not retry; take another
     source or ask them to paste it.
   - Instagram, TikTok: ask for the caption or a screenshot.
   - Photo: read it; book title and author become `sourceName`.
   - Their own dish: their name and words, rough amounts (your gram
     estimate), `sourceName` "Family recipe", no `sourceUrl`,
     `nutritionEstimated: true`. Ask for nothing they did not give.
2. **Dedupe.** `search_recipes {"query": "<dish>"}`. Same recipe: reuse
   its id; improve it with `save_recipe` and its `id` (send only
   changed fields; `null` clears; `ingredients` replaces the list).
   `editable: false` is the coach's: reuse, never copy. A variant gets
   a different name.
3. **Save** `save_recipe {"recipe": {…}}`.
4. **Confirm:** name, portions, time, allergens marked; offer to plan
   it. `planChecks` in the result: the recipe now breaks a planned
   meal; fix or say it. Say nutrition only to someone who follows
   numbers, with "estimated" when it is.

## Recipe fields

- `name`: English, no "best" or "easy". `portions`: lower end of a
  range; inferred if missing (say so; ask if you cannot tell).
- `sourceUrl`: canonical, https, no tracking parameters or fragments;
  Instagram `https://www.instagram.com/p/<code>/`. `sourceName`: site,
  book or creator.
- `instructions`: short numbered steps in your own words.
- `imageUrl`: a stable public image only; never an expiring link or
  the user's photo.
- `prepTimeMin` (hands-on; estimate it), `cookingTimeMin`,
  `totalTimeMin` (start to table, without long marinating or rising).
- `recipeCategory`, `isCompleteMeal`, `garnishSuggestion` (for a
  `main-course`), `primaryProteinSource`, `cuisineTag` (lowercase),
  `dietTags` (diet codes, `gluten-free`, `dairy-free`, `nut-free`).
- `ingredients` (structured); `ingredientsText` only as a fallback.

## Ingredient fields

- `name`: as the recipe says, without the amount; it is the shopping
  line.
- `canonicalName`: lowercase, singular, generic ("chicken breast",
  "canned chickpeas"); keep a variety that changes what you buy
  ("greek yogurt", "brown rice"). Lists are summed by it: reuse the
  names the library already has.
- `quantityText` (original amount), `quantityGrams` (converted; null
  for "to taste"), `notes` ("finely chopped", "optional").
- `isMain`: the 1–3 ingredients that define the dish.
- `category`: `vegetables`, `greens`, `fruit`, `meat-fish`, `dairy`
  (eggs too), `canned`, `grains`, `nuts-seeds`, `oils`, `spices`,
  `other`.
- `allergyMarkers`: every restriction code it triggers. Wheat, pasta,
  bread, couscous, oats (unless gluten-free), beer: `gluten`. Soy
  sauce: `soy`, `gluten`. Butter, ghee, cheese, whey: `dairy`. Tree
  nuts: `nuts`; peanuts: `peanuts`, `nuts`. Any fish, fish sauce,
  anchovy: `fish`. Shrimp, mussels, oyster sauce: `shellfish`. Tahini:
  `sesame`. Mayonnaise, egg pasta: `eggs`. Bacon, ham, sausages:
  `cancer-related`. Instant noodles, additive-heavy sauces:
  `ultra-processed`.
- `processingLevel`: `whole` (fresh produce, raw meat, dried legumes),
  `minimally-processed` (milk, flour, pasta, oils, plain canned
  beans), `processed` (cheese, bread, tofu, bacon), `ultra-processed`.
- `defaultUnit`: `g`, `ml` or `pcs`; `gramsPerUnit` for pieces (egg
  50, onion 110, lemon 100, can of tomatoes 400).

Leave out water. Keep salt, pepper and frying oil.

## Grams
Prefer the recipe's own grams; otherwise convert and estimate.

## Nutrition

`nutritionPerPortion`: `caloriesKcal`, `proteinG`, `carbsG`, `fatG`,
optional `fibreG`, `sugarsG`, `saturatedFatG`, `saltG`, per portion of
the stated yield.

- From the source, for the same yield: `nutritionEstimated: false`.
- Otherwise estimate from the gram amounts and standard per-100 g
  values, `nutritionEstimated: true`. Say "estimated", never
  "calculated". Rescale when you change the yield.
- Check: 4 × protein + 4 × carbs + 9 × fat within about 10% of kcal.
  Cannot estimate: leave it out and say so.

## Missing amounts

Use typical amounts for the servings, `quantityText` "not stated",
your grams, `nutritionEstimated: true`, and say they are estimates.
