# Profile questions and where the answers go

Ask in the user's language; the English wording below is a guide, not a
script. Offer the options as a short lettered list and accept free text.
Save right after each answer. Ids below are examples (`fm_…`); use the ids
from `get_context`.

## people: who eats

Usually done during web onboarding. Ask only when `people` is missing or the
user mentions someone new.

- "Who eats at home most days? Just names; children's ages help with
  portions."
- "Which one of them is you?" (only if no member has
  `linkedUserId === actor.userId`)

Onboarding usually leaves names only. If a child has no age in `notes`, ask
for ages in the first safety turn; portions and dishes depend on them.

```
add_family_member {"name": "Lily", "notes": "9 years old, small portions"}
update_family_member {"id": "fm_ben", "notes": "Works late on Tuesdays"}
```

Regular guests who eat with the household weekly can be members; one-off
guests are not.

## safety: allergies and diets

Ask for every person by name, children through the parent.

Turn A:

- "Does anyone have a food allergy or intolerance? (a) No one (b) Yes:
  who, and to what?"
- "How old are Sofia and Leo?" (only children without an age in `notes`)

Turn B:

- "Is there anything someone never eats for other reasons: religion,
  ethics, or they just never have?"
- "Does the household follow a diet? (a) No (b) Vegetarian (c) Vegan
  (d) Mediterranean (e) Low-carb (f) Something else: halal, pescatarian, …"

Allergy and intolerance codes (`restrictions`, per person; the household-wide
list is `foodRestrictions`): `gluten`, `dairy`, `nuts`, `shellfish`, `soy`,
`eggs`, plus `ultra-processed` and `cancer-related` (processed and smoked
meat) as habits to cut back on.

- Use the code whenever a food makes the person unwell, even partly ("milk
  upsets him, yogurt is fine" → `dairy` plus a note with the exceptions).
  Codes are what planners must avoid; notes are only information.
- `nuts` covers peanuts and tree nuts; say which in `notes`.
- Anything without a code (sesame, fish, kiwi) and anything someone never
  eats for other reasons (pork, beef) goes into that person's `notes`, in
  plain words and with "never include".

```
update_family_member {"id": "fm_lily", "restrictions": ["nuts"],
  "notes": "9 years old, small portions. Peanut allergy (tree nuts untested). Sesame allergy: never include."}
update_family_member {"id": "fm_leo", "restrictions": ["dairy"],
  "notes": "6 years old. Lactose: milk and soft cheese upset him; hard cheese and yogurt are fine."}
update_family_member {"id": "fm_ben", "notes": "Never eats pork (not an allergy): never include."}
update_nutrition_rules {"patch": {"selectedDiets": ["vegetarian"]}}
update_nutrition_rules {"patch": {"bannedFoods": [{"group": "Pork",
  "items": ["pork", "bacon", "ham", "gelatin"], "note": "Halal"}]}}
```

Diet codes (`selectedDiets`): `none`, `mediterranean`, `bodybuilding`,
`keto`, `vegetarian`, `vegan`, `lowcarb`, `low-cholesterol`, `custom`.
Keep the existing `bannedFoods` items when you add one (the list is replaced).

Nobody has anything:

```
update_household {"setupDone": ["safety"]}
```

## rhythm: when you eat and cook

Start from `nutritionRules.mealSchedule` (seven days, each with meal slots):
onboarding set a rough pattern. Ask what differs from it.

- "On weekdays, which meals do you eat at home? (a) All of them
  (b) Breakfast and dinner, lunch is at work or school (c) Only dinner"
- "How long can dinner take on a weekday? (a) 20 min (b) 30–40 min
  (c) An hour is fine"
- "And at the weekend?" / "Is anyone usually away for some meals?"

Change only the days and meals the answer was about (a weekend answer leaves
weekdays alone), then send all seven days back (the list is replaced). A slot
is `{"id", "name": mealType, "label": "home" | "out", "maxPrepMinutes",
"memberAttendance": [{"memberId", "status": "home" | "out" | "skip"}]}`;
keep the existing `id`s.

```
update_nutrition_rules {"patch": {"mealSchedule": [
  {"day": "mon", "meals": [
    {"id": "mon-breakfast", "name": "breakfast", "label": "home", "maxPrepMinutes": 10},
    {"id": "mon-lunch", "name": "lunch", "label": "out"},
    {"id": "mon-dinner", "name": "dinner", "label": "home", "maxPrepMinutes": 30,
     "memberAttendance": [{"memberId": "fm_ben", "status": "out"}]}]},
  … the other six days …]}}
```

Saving the schedule marks the step done. If the pattern is already right:
`update_household {"setupDone": ["rhythm"]}`.

## taste: what you love

Two turns.

Turn A:

- "Which cuisines do you cook or order most happily?" (free text: Italian,
  Thai, Lithuanian, …)
- "Three or four dishes the whole family is always happy to see?"
- "Anything nobody here likes? Taste only, allergies are already saved."

Turn B:

- "Spice: (a) mild (b) medium (c) hot"
- "New dishes: (a) mostly favourites (b) a mix (c) lots of new things"
- "Does anyone love or refuse something in particular?"

```
update_household {"foodProfile": {"cuisines": ["Italian", "Thai"],
  "favoriteDishes": ["lasagne", "fish tacos", "pancakes"],
  "dislikes": ["coriander"], "spice": "mild", "variety": "mix"}}
update_family_member {"id": "fm_lily", "likes": ["pancakes", "pasta"],
  "dislikes": ["mushrooms"]}
```

`spice`: `mild`, `medium`, `hot`. `variety`: `familiar`, `mix`,
`adventurous`. "Too bland" or "a bit dry" is a cooking note for one recipe,
not a dislike.

## kitchen: skills, equipment, leftovers

- "How do you like to cook? (a) Keep it simple (b) Confident home cook
  (c) Bring on a challenge" → (a) `beginner`, (b) `home-cook`,
  (c) `confident`
- "Any equipment beyond a hob and an oven? Air fryer, slow cooker,
  pressure cooker, grill, …"
- "Leftovers: (a) love them, cook once eat twice (b) now and then
  (c) rather not"

```
update_household {"foodProfile": {"cookingSkill": "home-cook",
  "equipment": ["air fryer", "slow cooker"], "leftovers": "love"}}
```

`cookingSkill`: `beginner`, `home-cook`, `confident`. `leftovers`: `love`,
`ok`, `avoid`. Routines that fit nowhere else ("Sunday is batch-cooking day",
"leftovers become next day's lunches") go into `householdNotes`; keep the
existing text when you add to it.

## sources: recipe sites and chefs

- "Where do your favourite recipes come from? Websites, chefs, cookbooks,
  YouTube or Instagram creators."

A site gets a favourite source (agents search it first). Fill in the URL
yourself only for a site you know for certain (its home page, and a
`site:` search hint); otherwise ask, or keep the name in `chefs`. `chefs`
holds chefs, cookbooks and creators without a site of their own ("Salt Fat
Acid Heat (cookbook)").

```
add_favorite_source {"name": "Budget Bytes", "url": "https://www.budgetbytes.com/",
  "searchHint": "site:budgetbytes.com"}
update_household {"foodProfile": {"chefs": ["Ottolenghi", "Jamie Oliver"]}}
```

No favourites: `update_household {"setupDone": ["sources"]}`.

## shopping: stores, days, budget

- "Where do you usually shop, in store or online?"
- "Which days do you usually shop?"
- "Budget for food: (a) tight (b) moderate (c) flexible"

```
update_household {"favoriteStores": ["Trader Joe's", "Costco"],
  "foodProfile": {"shoppingDays": ["sat"], "budget": "moderate"}}
```

`shoppingDays` uses `mon` … `sun`. `budget`: `tight`, `moderate`,
`flexible`. `favoriteStores` is the full list. Which store goes with which
day ("Costco on Saturdays, a top-up on Wednesdays") goes into
`householdNotes`.

## goals (optional)

- "Is anyone working toward something with food: more energy, more protein
  for training, a child eating more vegetables? Or do you work with a
  nutrition coach?"

```
update_family_member {"id": "fm_ben", "goals": "More protein for training", "dailyProteinG": 140}
```

Calorie and protein targets are numbers: when the user gives one, set the
target and keep the reason in `goals`. Work out a target only when they ask,
and say it is an estimate. Skip targets a coach locked. A coach is
invited by the household owner in Droklo (Settings → Members); don't send
invitations from this interview. No goals:
`update_household {"setupDone": ["goals"]}`.

## A short example

User: "Set up my Droklo profile"

```
get_context {"client": "droklo-setup-skill/0.2.6"}
  → setup: {done: 3, total: 9, missing: ["safety", "rhythm", "taste", "kitchen", "sources", "shopping"]}
    members: Maya (fm_maya, you), Ben (fm_ben), Lily (fm_lily)
```

Assistant: "Droklo already knows who's at your table: 3 of 9 steps. Six quick
questions to go, and you can skip any. First, safety: does Maya, Ben or
Lily have a food allergy or intolerance?"

User: "Lily is allergic to nuts. That's it."

```
update_family_member {"id": "fm_lily", "restrictions": ["nuts"]}
```

Assistant: "Saved: Lily avoids nuts in every meal she eats. Does the
household follow a diet: (a) no (b) vegetarian (c) something else?"
