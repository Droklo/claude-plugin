# Recipe capture

Goal: turn a link, an Instagram post, a photo or pasted text into one clean
`save_recipe` call. Droklo does not fetch URLs or read images; you extract
everything and send it. Photos are used only for extraction; Droklo never
stores them.

Droklo stores recipes in English. When the source is in another language,
translate the name, description, instructions, ingredient names and notes
into natural English before saving (metric amounts stay as they are). Keep
`sourceName` and other proper names as written.

## Steps

1. **Get the content.**
   - **URL:** fetch the page. Prefer its schema.org `Recipe` JSON-LD
     (`<script type="application/ld+json">`): `name`, `recipeYield`,
     `recipeIngredient`, `recipeInstructions`, `prepTime`, `cookTime`,
     `totalTime`, `nutrition`, `image`, `author`. Fall back to the visible
     text. If the page is paywalled or blocked, ask the user to paste the
     recipe.
   - **Instagram or TikTok:** these pages usually need a login. Ask the user
     to paste the caption or share a screenshot. Captions often lack amounts
     (see "Missing quantities").
   - **Photo** (cookbook page, recipe card, screenshot): read it. Take the
     book title and author for `sourceName` when visible.
   - **Pasted text:** parse it as is.
2. **Dedupe.** `search_recipes {"query": "<dish name>", "limit": 10}`. If the
   same recipe is already there (same `sourceUrl`, or same name and source),
   reuse its id; to improve it, call `save_recipe` with its `id`. A match with
   `editable: false` belongs to the coach's library: reuse it, never copy it.
   (`save_recipe` also upserts by `sourceUrl` within the household, so saving
   the same URL twice updates instead of duplicating.) When updating, send
   only the fields you change: `null` clears a field, and `ingredients`, if
   sent, replaces the whole ingredient list.
3. **Normalize** ingredients, times and nutrition (rules below), in English.
4. **Save:** `save_recipe {"recipe": {…}}`.
5. **Confirm** to the user: name, portions, time, kcal and protein per portion
   (say "estimated" when it is), the allergens you marked, and offer to plan it.

## Fields

`save_recipe` takes `recipe` (RecipeInput, plus `id` to update).

| Field | Required | Rule |
|---|---|---|
| `name` | yes | English dish name (translated when the source isn't English), without "recipe", "best", "easy". |
| `portions` | yes | Number of servings the recipe yields. If the source gives a range ("4–6"), use the lower number. If none, infer from quantities and say so. |
| `sourceUrl` | when there is a URL | Canonical URL (see below). Null for photos and pasted text without a link. |
| `sourceName` | yes when known | Site, book or creator: "Budget Bytes", "Ottolenghi, Simple", "@creator on Instagram". |
| `description` | optional | One or two sentences, in English. |
| `instructions` | recommended | Numbered steps in English, one per line. Keep them concise; paraphrase long text. |
| `imageUrl` | optional | A stable public image URL (page `og:image` or JSON-LD `image`). Never an Instagram or other expiring CDN link, never the user's photo. |
| `prepTimeMin`, `totalTimeMin` | when given | As stated by the source. |
| `cookingTimeMin` | recommended | Time to table: hands-on prep plus cooking, excluding passive marinating, rising or chilling (mention those in `instructions`). Used by the time filter. |
| `nutritionPerPortion` | recommended | See "Nutrition". |
| `nutritionEstimated` | with nutrition | `false` only when every number came from the source for this yield. |
| `recipeCategory` | recommended | One code from schema-reference.md (`complete-meal`, `main-course`, `soup`, …). |
| `isCompleteMeal` | recommended | `true` when protein, a carb and vegetables are all in the dish. |
| `garnishSuggestion` | for `main-course` | A fitting side ("rice and a green salad"). |
| `primaryProteinSource` | recommended | One code (`fish`, `poultry`, `red-meat`, `eggs`, `legumes`, `dairy`, `tofu-tempeh`, `nuts-seeds`, `grain-protein`, `none`). |
| `cuisineTag` | optional | Lowercase English, e.g. `"italian"`, `"mexican"`, `"thai"`. |
| `dietTags` | optional | Lowercase tags: diet codes (`vegetarian`, `vegan`, `keto`, `lowcarb`, `mediterranean`) plus `gluten-free`, `dairy-free`, `nut-free` when true for the whole recipe. |
| `ingredients` | strongly recommended | Structured list (below). |
| `ingredientsText` | fallback | Free text, only when the ingredients cannot be structured. |

### Canonical source URL

- Use the page's `<link rel="canonical">` when present.
- Use `https`, strip tracking parameters (`utm_*`, `fbclid`, `igshid`, `ref`),
  fragments and print or AMP variants.
- Instagram: `https://www.instagram.com/p/<code>/` or
  `https://www.instagram.com/reel/<code>/`.

## Ingredients

Each item is a RecipeIngredientInput:

| Field | Rule |
|---|---|
| `name` | Ingredient as written in the recipe, in English (translated when needed), without the amount: `"boneless skinless chicken breasts"`. This is the name the shopping list shows. |
| `canonicalName` | **Lowercase English, singular, generic**: `"chicken breast"`, `"olive oil"`, `"red onion"`, `"canned chickpeas"`. No brands, sizes or preparation words (chopped, large, fresh). Keep a variety when it changes what you buy: `"greek yogurt"` vs `"yogurt"`, `"brown rice"` vs `"white rice"`, `"canned tomatoes"` vs `"tomato"`. Droklo dedupes ingredients and sums shopping lists by this name, so be consistent. |
| `quantityText` | The original amount: `"2"`, `"1 ½ cups"`, `"2 tbsp"`, `"to taste"`. |
| `quantityGrams` | The amount converted to grams (table below). Null for "to taste", "a pinch" or when unknown. |
| `notes` | Preparation and options: `"finely chopped"`, `"divided"`, `"optional"`, `"or tamari"`. |
| `isMain` | `true` for the 1–3 ingredients that define the dish (the protein, the main vegetable or grain). |
| `category` | Shopping category code: `vegetables`, `greens`, `fruit`, `meat-fish`, `dairy`, `canned`, `grains`, `nuts-seeds`, `oils`, `spices`, `other`. |
| `allergyMarkers` | Restriction codes this ingredient triggers (table below). Empty when none. |
| `processingLevel` | `whole`, `minimally-processed`, `processed` or `ultra-processed` (NOVA groups 1–4). |
| `caloriesPer100g`, `proteinPer100g` | Optional, when you know them for this product; they help Droklo's ingredient dictionary. |
| `defaultUnit` | How it is bought: `g` (meat, produce by weight), `ml` (milk, stock, oil), `pcs` (eggs, lemons, cans, avocados). |
| `gramsPerUnit` | For `pcs`: grams per piece (egg 50, medium onion 110, lemon 100, avocado 200, can of tomatoes 400). |
| `ingredientId` | Only when you already have the Droklo id. Usually omit. |

Leave out water. Keep salt, pepper and oil for frying with
`quantityGrams` when the recipe states an amount, else null.

### Allergy markers

| Ingredient examples | `allergyMarkers` |
|---|---|
| wheat flour, pasta, bread, couscous, bulgur, breadcrumbs, beer | `["gluten"]` |
| soy sauce | `["soy", "gluten"]` (tamari: `["soy"]`) |
| butter, ghee, milk, cream, cheese, yogurt, whey | `["dairy"]` |
| almonds, walnuts, cashews, peanuts, peanut butter, almond milk | `["nuts"]` |
| basil pesto (classic) | `["nuts", "dairy"]` |
| shrimp, crab, mussels, squid, oyster sauce, shrimp paste | `["shellfish"]` |
| tofu, tempeh, miso, edamame, soy milk | `["soy"]` |
| eggs, mayonnaise, fresh egg pasta | `["eggs"]` (fresh egg pasta also `gluten`) |
| bacon, ham, salami, sausages, hot dogs | `["cancer-related"]`, plus `ultra-processed` for most packaged ones |
| instant noodles, flavored yogurt, ready-made sauces with additives | `["ultra-processed"]` |

### Processing level (NOVA)

- `whole`: fresh or frozen produce, raw meat and fish, eggs, dried legumes,
  plain grains, plain nuts.
- `minimally-processed`: milk, plain yogurt, flour, pasta, oils, canned beans
  or tomatoes without additives, frozen vegetables, unsweetened nut butter.
- `processed`: cheese, bakery bread, cured fish, canned fish in oil, tofu,
  bacon.
- `ultra-processed`: soft drinks, packaged snacks and sweets, instant noodles,
  hot dogs, most packaged sliced bread with additives, flavored yogurts.

## Unit conversion to grams

Exact units: 1 oz = 28.35 g; 1 lb = 453.6 g; 1 US cup = 240 ml; 1 tbsp =
15 ml; 1 tsp = 5 ml; 1 fl oz = 29.6 ml; metric and Australian cup = 250 ml;
Australian tbsp = 20 ml. For water-like liquids (water, stock, milk, juice,
wine, vinegar) 1 ml ≈ 1 g.

Typical densities and piece weights (approximate; prefer the recipe's own
gram amounts when given):

| Item | Per US cup | Per tbsp | Per piece |
|---|---|---|---|
| all-purpose flour (spooned) | 125 g | 8 g | |
| granulated sugar | 200 g | 12.5 g | |
| brown sugar (packed) | 220 g | 14 g | |
| powdered sugar | 120 g | 8 g | |
| butter | 227 g | 14 g | 1 US stick = 113 g |
| olive or vegetable oil | 216 g | 13.5 g | |
| honey | 340 g | 21 g | |
| maple syrup | 315 g | 20 g | |
| rolled oats | 90 g | | |
| white rice, raw | 185 g | | |
| quinoa, raw | 170 g | | |
| dried lentils | 190 g | | |
| cooked rice | 160 g | | |
| shredded cheese (cheddar, mozzarella) | 113 g | | |
| grated parmesan | 100 g | 6 g | |
| plain yogurt | 245 g | 15 g | |
| peanut butter | 258 g | 16 g | |
| chopped nuts | 120 g | | |
| chopped onion | 160 g | | medium onion 110 g |
| chopped tomato | 180 g | | medium tomato 125 g |
| raw spinach (loosely packed) | 30 g | | |
| fresh herbs, chopped | 40 g | 3 g | 1 bunch ≈ 30–50 g |
| | | | large egg (no shell) 50 g |
| | | | garlic clove 4 g |
| | | | medium carrot 60 g |
| | | | medium potato 210 g |
| | | | medium bell pepper 120 g |
| | | | medium zucchini 200 g |
| | | | boneless chicken breast 200 g |
| | | | lemon: juice ≈ 30 ml, zest ≈ 2 g |
| | | | can of beans (15 oz): 425 g, drained 250 g |
| | | | can of tomatoes: 400 g (EU) or 411 g (14.5 oz) |
| | | | can of coconut milk: 400 ml |

Spoons of dry spices: 1 tsp ground spice ≈ 2–3 g; 1 tsp table salt ≈ 6 g;
1 tsp kosher salt ≈ 3 g.

## Nutrition

`nutritionPerPortion` keys: `caloriesKcal`, `proteinG`, `carbsG`, `fatG`,
optional `fibreG`, `sugarsG`, `saturatedFatG`, `saltG`. Values are **per
portion** of the stated yield.

1. **From the source** (preferred): JSON-LD `nutrition` (`calories`
   "450 kcal", `proteinContent` "30 g", …) or a nutrition table on the page.
   Check it is per serving for the same yield; if it is per 100 g or per whole
   recipe, convert. Set `nutritionEstimated: false`.
2. **Estimated** when the source has none: sum `quantityGrams` × per-100 g
   values from a standard reference (USDA FoodData Central, or the product
   label for packaged foods), divide by `portions`, and set
   `nutritionEstimated: true`. Use raw weights with raw values. Round kcal to
   whole numbers and grams to one decimal.
3. **Sanity check:** 4 × protein + 4 × carbs + 9 × fat should be within about
   10 % of kcal; a main dish portion is usually 350–900 kcal. If you cannot
   estimate reliably (unknown amounts), leave `nutritionPerPortion` out and
   tell the user.

Approximate reference values per 100 g (USDA FoodData Central, raw unless
noted); look up anything not listed:

| Food | kcal | protein g | carbs g | fat g |
|---|---|---|---|---|
| chicken breast, skinless | 120 | 22.5 | 0 | 2.6 |
| ground beef 85 % lean | 215 | 18.6 | 0 | 15 |
| ground turkey 93 % lean | 150 | 18.7 | 0 | 8.3 |
| salmon, farmed | 208 | 20.4 | 0 | 13.4 |
| cod | 82 | 17.8 | 0 | 0.7 |
| shrimp | 85 | 20.1 | 0 | 0.5 |
| egg, whole | 143 | 12.6 | 0.7 | 9.5 |
| lentils, dry | 352 | 24.6 | 63.4 | 1.1 |
| chickpeas, cooked | 164 | 8.9 | 27.4 | 2.6 |
| black beans, cooked | 132 | 8.9 | 23.7 | 0.5 |
| white rice, raw | 365 | 7.1 | 80 | 0.7 |
| pasta, dry | 371 | 13 | 75 | 1.5 |
| all-purpose flour | 364 | 10.3 | 76.3 | 1 |
| potato | 77 | 2 | 17 | 0.1 |
| broccoli | 34 | 2.8 | 6.6 | 0.4 |
| onion | 40 | 1.1 | 9.3 | 0.1 |
| tomato | 18 | 0.9 | 3.9 | 0.2 |
| spinach | 23 | 2.9 | 3.6 | 0.4 |
| avocado | 160 | 2 | 8.5 | 14.7 |
| whole milk | 61 | 3.2 | 4.8 | 3.3 |
| greek yogurt, plain nonfat | 59 | 10.2 | 3.6 | 0.4 |
| cheddar | 403 | 24.9 | 1.3 | 33.1 |
| butter | 717 | 0.9 | 0.1 | 81.1 |
| olive oil | 884 | 0 | 0 | 100 |
| almonds | 579 | 21.2 | 21.6 | 49.9 |
| peanut butter | 588 | 25.1 | 19.6 | 50.4 |
| sugar | 387 | 0 | 100 | 0 |

## Missing quantities

Instagram captions and quick notes often list ingredients without amounts.

- Ask the user for the amounts of the main ingredients if they know them.
- Otherwise use the typical amount for the stated servings, write the
  original text in `quantityText` (e.g. `"some"`), set `quantityGrams` to your
  estimate, say so in your reply, and set `nutritionEstimated: true`.
- If even the servings are unknown, ask; do not save a recipe with
  guessed portions and no warning.

## Worked examples

### From a URL

User: "Save this: https://www.example-recipes.com/lemon-chicken-orzo?utm_source=ig"

Fetch → JSON-LD gives yield 4, prep 10 min, cook 20 min, nutrition per
serving 520 kcal, 41 g protein, 52 g carbs, 15 g fat.

```
search_recipes {"query": "lemon chicken orzo", "limit": 5}   → no match
save_recipe {"recipe": {
  "name": "Lemon Chicken Orzo",
  "sourceUrl": "https://www.example-recipes.com/lemon-chicken-orzo",
  "sourceName": "Example Recipes",
  "portions": 4, "prepTimeMin": 10, "cookingTimeMin": 30, "totalTimeMin": 30,
  "nutritionPerPortion": {"caloriesKcal": 520, "proteinG": 41, "carbsG": 52, "fatG": 15},
  "nutritionEstimated": false,
  "recipeCategory": "complete-meal", "isCompleteMeal": true,
  "primaryProteinSource": "poultry", "cuisineTag": "mediterranean",
  "instructions": "1. Season and sear the chicken, 6 min per side.\n2. Toast the orzo in the same pan, add stock and lemon, simmer 10 min.\n3. Stir in spinach, slice the chicken on top.",
  "ingredients": [
    {"name": "boneless skinless chicken breasts", "canonicalName": "chicken breast",
     "quantityText": "1.5 lb", "quantityGrams": 680, "isMain": true,
     "category": "meat-fish", "processingLevel": "whole",
     "defaultUnit": "g", "allergyMarkers": []},
    {"name": "orzo", "canonicalName": "orzo pasta", "quantityText": "1 cup",
     "quantityGrams": 200, "isMain": true, "category": "grains",
     "processingLevel": "minimally-processed", "allergyMarkers": ["gluten"]},
    {"name": "chicken broth", "canonicalName": "chicken stock", "quantityText": "3 cups",
     "quantityGrams": 720, "category": "canned", "defaultUnit": "ml",
     "processingLevel": "processed", "allergyMarkers": []},
    {"name": "lemon", "canonicalName": "lemon", "quantityText": "1",
     "quantityGrams": 100, "notes": "zest and juice", "category": "fruit",
     "defaultUnit": "pcs", "gramsPerUnit": 100, "allergyMarkers": []},
    {"name": "baby spinach", "canonicalName": "spinach", "quantityText": "2 cups",
     "quantityGrams": 60, "category": "greens", "processingLevel": "whole",
     "allergyMarkers": []},
    {"name": "olive oil", "canonicalName": "olive oil", "quantityText": "1 tbsp",
     "quantityGrams": 13.5, "category": "oils", "defaultUnit": "ml",
     "processingLevel": "minimally-processed", "allergyMarkers": []}
  ]
}}
```

Reply: "Saved Lemon Chicken Orzo (4 portions, 30 min, 520 kcal and 41 g
protein per portion from the source). Contains gluten (orzo). Plan it?"

### From an Instagram caption

The user pastes a caption: "High-protein overnight oats 🥣 oats, greek yogurt,
milk, chia, protein powder, berries. Makes 2 jars." plus the post link.

- `sourceUrl`: `https://www.instagram.com/p/<code>/`, `sourceName`:
  `"@creator on Instagram"`, `imageUrl`: null.
- `portions`: 2. No amounts: use typical ones (80 g oats, 150 g greek yogurt,
  120 ml milk, 10 g chia, 30 g protein powder, 80 g berries for the batch),
  `quantityText` `"not stated"`, `nutritionEstimated: true`.
- `recipeCategory`: `breakfast`; `primaryProteinSource`: `dairy`; mark
  yogurt, milk and whey protein powder with `dairy`.
- Tell the user the amounts and nutrition are estimates and ask whether they
  want to adjust them.

### From a photo of a cookbook page

`sourceName`: "Book title, Author"; `sourceUrl`: null. Dedupe by searching the
name. Copy amounts exactly from the page, write short instructions in your own
words, and never send the photo itself.
