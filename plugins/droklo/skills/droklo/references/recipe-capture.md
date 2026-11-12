# Recipe capture

Turn what they sent (link, post, screenshot, PDF, pasted text, a dish
told in chat) into `save_recipe`. Droklo stores no images: you read,
then send text. Save in English; a dish keeps its own name first:
"Frango com quiabo (chicken with okra)".

## What you read

- Try a link once. Videos, voice notes and most Instagram, TikTok,
  Facebook, WhatsApp and paid pages do not open. No recipe text: say
  so in one sentence and ask for one thing: the caption pasted,
  screenshots of the ingredients, or the recipe in their words.
- Never say you read, watched or opened what you did not. Never swap
  in a similar recipe; offer it as another one, by name and source.
- Keep the link and creator even when the link did not open. Unknown:
  `sourceName` "TikTok screenshot, creator unknown". Their own: their
  words ("Carol's notebook").
- `capture`: `via` = what you really read (a `screenshot` is not
  `link-opened`); cut-off or unreadable parts in `missing`; what you
  added (an amount, a step, servings) in `estimated`. Say it: "From
  the post: … Mine: …". Ask about gaps once, in one question; no
  answer: they stay estimates. "Tell me what's missing first": save
  after they answer.
- A nutrition figure in a post is a claim: `capture.claimed`; store
  your own estimate.
- Paid content (e-book, newsletter): only recipes they cook, from
  text they give; steps in your own words; title, author, page as
  source. Never in bulk.
- An allergy or doctor's limit: one recipe, the safe one; each swap
  in `capture.changedFromOriginal`; say "changed from the original".
  Never the allergen as optional. A taste change: a variant with
  another name. Portions: servings on the planned meal.
- Many at once: `recipes` (up to 10). Links you cannot open and they
  will not paste now: `name`, `sourceUrl`, their label in `dietTags`,
  nothing more. That is "not written out yet": never plan it; say how
  many wait. Boards and folders become `dietTags`.
- "Made it last night" is `log_meal`. A tip after cooking is
  `add_comment` on the recipe.

## Steps

1. **Dedupe.** `search_recipes {"query": "<words>"}`. Same recipe:
   save with its `id` (changed fields; `null` clears; `ingredients`
   replaces the list). `editable: false` is the coach's: reuse.
2. **Save.** A page you opened: prefer its schema.org `Recipe`.
3. **Confirm:** name, portions, time, allergens marked. Act on
   `captureNotes`, `amountsMissing` (ask once), `planChecks`. Numbers
   only to someone who follows them, with "estimated".

## Recipe fields

- `portions`: lower end of a range; inferred if missing (say so).
- `sourceUrl`: canonical, https, no tracking parameters; Instagram
  `https://www.instagram.com/p/<code>/`.
- `instructions`: short numbered steps in your own words.
- `imageUrl`: a stable public image; never their photo.
- `cuisineTag`: lowercase. `dietTags`: their tags, diet codes,
  `gluten-free`, `dairy-free`, `nut-free`.

## Ingredient fields

- `name`: as written, without the amount. `canonicalName`: lowercase,
  singular, generic ("chicken breast"); keep what changes the buy
  ("greek yogurt") and a name with no English ("varškė"; gloss in
  `notes`). Reuse the library's names.
- `quantityText`: the amount as written, any measure ("2 cups",
  "1 stiklinė"), always. `quantityGrams`: theirs, else converted
  (null for "to taste"); grams are for the list.
- `isMain`: the 1–3 that define the dish. `category`: the shop
  aisle; eggs are `dairy`.
- `allergyMarkers`: every restriction code it triggers. Wheat, pasta,
  bread, couscous, oats (unless gluten-free), beer: `gluten`. Soy
  sauce: `soy`, `gluten`. Butter, ghee, cheese, whey: `dairy`. Tree
  nuts: `nuts`; peanuts: `peanuts`, `nuts`. Any fish, fish sauce,
  anchovy: `fish`. Shrimp, mussels, oyster sauce: `shellfish`. Tahini:
  `sesame`. Mayonnaise, egg pasta: `eggs`. Bacon, ham, sausages:
  `cancer-related`. Instant noodles, additive-heavy sauces:
  `ultra-processed`.
- `processingLevel`: `whole`, `minimally-processed` (milk, flour,
  oils), `processed` (cheese, bread, bacon), `ultra-processed`.
- `defaultUnit`: `g`, `ml`, `pcs`; `gramsPerUnit` for pieces (egg 50,
  onion 110, lemon 100).

Leave out water. Keep salt, pepper and frying oil.

## Nutrition

`nutritionPerPortion`: from a page you opened, same yield:
`nutritionEstimated: false`. Else estimate from the grams, `true`,
say "estimated". Check 4 × protein + 4 × carbs + 9 × fat within 10%
of kcal. Cannot estimate: leave it out.
