# Shopping

The household has **one shopping list**. Droklo keeps it: a planned meal
with a recipe puts its food on it, a changed meal changes it, an eaten
or past meal leaves it. You never make, date, close or reopen a list.

A tick means **got it**: bought, ordered or already at home. It stays
whatever the plan does next; when a meal is added or grows afterwards,
the list asks only for the rest (`more`).

## Read and hand over

```
get_shopping_list {"from": "2026-11-16", "to": "2026-11-18", "compact": true}
```

- No arguments: everything. `from`/`to`: the meals of those days;
  `entryIds`: those meals. A window shows what its meals need; `later`
  is what later meals need on top.
- After saving several days, or when they go shopping, read it for the
  days this shop feeds and give `summary` and `url`. Say when to shop
  from the stored shopping days. For one meal, offer the list instead.
- `ask.questions`: the one question, as worded (`askLater`: waits).
  Staples answer in one call: `update_shopping_items {"pantry":
  "allLikelyAtHome", "except": ["paprika"]}`; unsure: `"unsure"`.
- `quantity` is the pack to buy; `needed` is what the recipes use.
- `atHome`: not to buy; close with its `check` line. `boughtOn`: bought.
- `notOnList`: meals without a recipe add nothing; say which.
- `planChecks` (`fresh_early`): do what it says. `oneMeal`: when money
  is tight, offer to swap that meal.
- Show it short, by aisle. Paste only from `export_shopping_list`
  (`"print"` for paper, `"text"` for a message); people in
  `readers.withoutLogin` get the text, never the link.

Yours to add: the deciding words in an item name ("gluten-free tamari")
and, for an allergy or a religious rule, the items whose label matters.

## Change items

```
update_shopping_items {
  "add": [{"name": "Milk", "quantityText": "2 l", "category": "dairy"}],
  "update": [{"id": "si_rice", "patch": {"quantityText": "1 kg"}}],
  "remove": ["si_ghee"], "check": ["si_eggs"]}
```

- Bought it all: `{"checkAll": true}`; all but a few: add `"uncheck":
  [ids]`. Nothing else ends a shop. A delivery that came short: untick
  what did not come.
- Shopped for some days only: `"check": [ids], "forDays": {"from",
  "to"}` (or `"forMeals": [entryIds]`); the rest of a line stays.
- Food no meal needs (coffee, bin bags): `add`. Never type a planned
  meal's ingredients; `forMeals.say` tells you when you did.
- Always at home: `pantry`. Ran out: `"ranOut": ["olive oil"]`.
  `noLine`: no meal needs it; offer to add it.
- Two stores or days: `"where": [{"label": "Market", "ids": […]}]`.
- Removed lines stay off until a new meal needs them (`keptOff`).
- On an error nothing was applied: fix and resend the whole call.

## When the plan changes

Plan tools update the list and return `shoppingLists`: relay `say` with
the `url`. `refresh_shopping_list` only after a recipe or member change.

## The shop did not happen

No blame, no why. Ask one question: when the next shop is. Offer to
move the meals before it (`move_plan_entry`, only to days they agree);
the list follows. Part bought: tick it first.

## Budget

Droklo knows no prices; it keeps `weeklyBudget` and your estimate.
`set_shopping_list_estimate {"amount": 135, "currency": "EUR", "note":
"Rough guess"}`, said as a guess with what it covers. `overBudget`: say
`overBy` and offer two or three swaps; else what is `left`. Real total:
`{"actual": 142}`. No budget: `"weeklyBudget": "none"`.

## Also

- `foodProfile.units: "us"` for pounds and cups.
- Completed lists in `list_shopping_lists` are records from before
  there was one list: leave them.
- A store's own tools: unticked, non-pantry items only; never order or
  pay without the person confirming in the store's flow.
