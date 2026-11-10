# Shopping

A shopping list covers any date range. Droklo computes its items from the
plan entries in that range that have a recipe (portions = attendees or
`servings`, scaled from the recipe's yield) and keeps manual items and checked
marks. Lists sync live between the web app, other family members and agents.

## Create a list for a range

"Make a shopping list for Friday to Sunday."

1. `get_context {}` → `today` (say 2026-11-09, Monday) and
   `activeShoppingList`.
2. Resolve the range: Friday `2026-11-13` to Sunday `2026-11-15`.
3. Look for an existing list first:
   `list_shopping_lists {"status": "active"}`. If one already covers this
   range, use it instead of creating a duplicate (it is already up to date
   with the plan); ask if unsure.
4. Check the plan: `get_plan {"from": "2026-11-13", "to": "2026-11-15"}`.
   Entries without `recipeId` (eating out, dishes planned by name only) and
   leftovers entries (`servings: 0`) add nothing. Tell the user which meals
   will not contribute (leftovers need no mention), and
   offer to link a recipe or add items manually.
5. Create it:
   ```
   create_shopping_list {"from": "2026-11-13", "to": "2026-11-15",
     "name": "Weekend 13–15 Nov"}
   ```
6. Review the result (`list.items`):
   - items with `quantityUnknown: true` → mention them, or set a quantity with
     `update` if the user knows it;
   - pantry staples (oil, salt, spices, flour, rice): ask once "Do you already
     have any of these?" and **check** the ones they have (do not remove them:
     plan-derived items come back when the plan changes, checked marks survive
     unless more is needed).
7. Show the list grouped by category in the user's units (below) with its
   `url` (opens it in Droklo) and offer the next step: add extras, export, or
   send to a store.

## Change items

`update_shopping_items` takes the list id and any of `add`, `update`,
`remove`, `check`, `uncheck` in one call:

```
update_shopping_items {
  "listId": "sl_weekend",
  "add": [
    {"name": "Milk", "quantityText": "2 l", "quantityGrams": 2000, "unit": "ml", "category": "dairy"},
    {"name": "Bananas", "quantityText": "6", "unit": "pcs", "category": "fruit"},
    {"name": "Dish soap", "category": "other"}
  ],
  "update": [{"id": "si_rice", "patch": {"quantityText": "1 kg", "quantityGrams": 1000, "unit": "g"}}],
  "check": ["si_olive_oil", "si_salt"],
  "uncheck": [],
  "remove": []
}
```

- Manual items need only `name`; add `quantityText`, `quantityGrams` with
  `unit` (`g`, `ml` or `pcs`) and `category` when you know them. Non-food
  items are fine (`category: "other"`).
- "I bought the milk and eggs" → `get_shopping_list {"listId": …}`, match the
  names, then `check` those ids. Ask when a name matches several items.
- `remove` is for manual items the user no longer wants. A removed
  plan-derived item comes back with the next plan change; to drop it for good,
  change the plan or check it.

## Keep the list in sync with the plan

Droklo keeps active lists in step with the plan by itself. Every plan tool
(`add_plan_entries`, `update_plan_entry`, `move_plan_entry`,
`swap_plan_entries`, `delete_plan_entries`) and every plan change in the web
app refreshes the active lists whose range contains a date it touched (the old
and the new date of a move). Do not call `refresh_shopping_list` after them.

The plan tool's result says what happened in `shoppingLists` (empty when no
active list covers the dates):

```
"shoppingLists": [{
  "listId": "sl_weekend", "name": "Weekend 13–15 Nov", "url": "https://www.droklo.com/shopping/sl_weekend",
  "added":   [{"itemId": "si_cream", "name": "Cream", "quantity": "200 ml"}],
  "removed": [{"name": "Feta", "quantity": "150 g", "wasChecked": false}],
  "changed": [{"itemId": "si_pasta", "name": "Pasta", "before": "300 g", "after": "450 g"}],
  "recheck": [{"itemId": "si_chicken", "name": "Chicken breast", "before": "500 g", "after": "750 g"}]
}]
```

Tell the user in a line or two what changed, with the list's `url`. Name every
`recheck` item: the user had checked it (bought it or has it), but the plan
now needs clearly more (at least 20 % and 10 g or ml more), so Droklo
unchecked it and it shows again with the new total. Ask whether they already
have the extra amount; if they do, `check` it again. Smaller top-ups,
quantity drops and pantry staples (`oils`, `spices`) stay checked.

Moving or swapping a meal into the list's dates puts its ingredients in
`added` as still to buy, even when the user already has them (for example,
they cooked tomorrow's dinner tonight). If the user said they have them,
`check` those items right away.

Call `refresh_shopping_list {"listId": …}` yourself only when something other
than the plan changed what a list needs: a planned recipe's ingredients or
portions (`save_recipe`), or a family member archived or back. Its result has
the same `changes`. Leftovers entries (`servings: 0`) never add items: the
cooking entry carries the extra servings.

## Export

```
export_shopping_list {"listId": "sl_weekend", "format": "markdown"}
```

Returns the list grouped by category, as
markdown checkboxes (the default) or `"text"` for plain text, for example to
paste into a messaging app. Show it as is; do not re-sort.

## Finish, rename or delete a list

- Shopping done: `set_shopping_list_status {"listId": …, "status": "completed"}`.
  `"archived"` hides an old list, `"active"` brings it back. Nothing is
  deleted.
- `rename_shopping_list {"listId": …, "name": "Thanksgiving"}` (`null`
  clears the name).
- `delete_shopping_list {"listId": …}` removes the list and its items for
  good. Ask first, and suggest archiving instead.

## Hand off to a store

If the conversation has tools from a grocery service (for example an
Instacart MCP server or another store connector):

1. `get_shopping_list {"listId": …}` and take the **unchecked** items.
2. For each item, search the store with its `name` and pick a product that
   matches the household's restrictions (gluten-free, dairy-free…) and
   `householdNotes` (budget, organic). Ask when the choice is not obvious.
3. Convert quantities to the store's pack sizes and the user's units: 680 g
   chicken breast → about 1.5 lb; 2000 ml milk → a half gallon; 3 onions →
   3 each. Round up to whole packs.
4. Add them to the store's cart or list with the store's own tools and show
   the user a summary: item, product chosen, quantity, unmatched items.
5. Never place an order or pay without the user's explicit confirmation of
   the items and total in that store's flow.
6. After the user confirms the order, ask whether to mark those items as
   bought, then `check` them in Droklo.

`household.favoriteStores` names the stores the household likes; prefer them
when you have a choice of connector.

Without a store connector, give a clean list instead: the markdown export, or
your own list grouped by category with quantities in the user's units and the
meals each item is for.

## Units for people

Droklo stores grams, millilitres and pieces. When you show quantities:

- US households: ounces and pounds for weight (1 lb = 454 g), fluid ounces,
  cups, quarts or gallons for liquids, "each" for pieces.
- Metric households: g and kg, ml and l.
- Round to sensible shopping amounts (≈ 1.5 lb, 2 cans, 1 bunch).

## Worked example

User (US household): "Weekend shopping list please, and send it to Instacart."

```
get_context {}                                   → today 2026-11-09, no active list
list_shopping_lists {"status": "active"}         → none for 13–15 Nov
get_plan {"from": "2026-11-13", "to": "2026-11-15"}
                                                 → 4 entries, 1 without recipe ("Dinner at grandma's")
create_shopping_list {"from": "2026-11-13", "to": "2026-11-15", "name": "Weekend 13–15 Nov"}
                                                 → 23 items
update_shopping_items {"listId": "sl_1", "check": ["si_oil", "si_salt", "si_cumin"]}
                                                 (user already has these)
get_shopping_list {"listId": "sl_1"}             → 20 unchecked items
```

Then use the Instacart tools to build the cart, show the summary
(20 items, 2 unmatched). After the user places the order and agrees, check
the 18 ordered items with `update_shopping_items` and remind them about the 2
unmatched ones.
