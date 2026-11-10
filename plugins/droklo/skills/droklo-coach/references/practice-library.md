# Practice recipe library

Recipes saved in the coach's **practice** workspace are visible, read-only,
to every client household and their agents (`search_recipes` returns them
with `owner.kind: "practice"` and `editable: false`). Clients' agents can plan
them by id, which gives clients the coach's tested recipes with nutrition.

## Find the practice id

```
list_workspaces {}  → {"id": "ws_practice", "kind": "practice", …}
```

Pass `workspaceId: "ws_practice"` to `search_recipes`, `save_recipe`,
`get_recipe` and `delete_recipe` for library work. These recipe tools are the
ones that accept a practice id (household tools refuse it). Without it, the
tools act on your default workspace, which may be a client's or your own
household. Only the practice owner can edit its library; other members of
the practice get `FORBIDDEN`.

## Add a recipe

Same rules as any Droklo recipe (the `droklo` skill's recipe-capture
reference has the full detail if it is installed). The essentials:

1. Get the recipe content: fetch the URL, or read the pasted text or photo.
   Droklo does not fetch pages itself.
2. Dedupe: `search_recipes {"workspaceId": "ws_practice", "query": "<name>"}`.
   Update an existing one by passing its `id`.
3. `save_recipe {"workspaceId": "ws_practice", "recipe": {…}}` with:
   - `name`, `portions` (required), `sourceUrl` and `sourceName` when there is
     a source, `instructions`, `cookingTimeMin`;
   - `ingredients[]` with `name`, lowercase English singular
     `canonicalName`, `quantityText`, `quantityGrams`, shopping `category`
     code, `allergyMarkers` (restriction codes) and `processingLevel`;
   - `nutritionPerPortion` (`caloriesKcal`, `proteinG`, `carbsG`, `fatG`)
     from the source with `nutritionEstimated: false`, or estimated from
     USDA FoodData Central with `nutritionEstimated: true`;
   - `recipeCategory`, `primaryProteinSource`, `isCompleteMeal`, `dietTags`.
4. Confirm to the coach: name, portions, kcal and protein per portion
   (estimated or not), allergens marked.

Coaches' own recipes (no URL) are welcome: `sourceName` = the practice name,
`sourceUrl` null.

## Keep the library useful

- Complete nutrition on every recipe: clients' agents rank recipes with
  nutrition higher, and logs derive nutrition from them.
- Mark allergens accurately: clients' agents exclude recipes by
  `allergyMarkers`.
- Name recipes clearly, in English.
- Deleting a practice recipe (`delete_recipe`, ask first) hides it from all
  clients; plan entries and logs that used it keep their dish names.

## Recommend a library recipe to a client

- Mention it in a comment on the client's plan entry or day
  (`add_comment` with the client's `workspaceId`), naming the recipe; or
- when the coach asks, plan it in the client's household:
  `add_plan_entries {"workspaceId": "ws_smith", "entries": [{"date": …,
  "mealType": "lunch", "dishName": "<recipe name>", "recipeId": "<practice recipe id>"}]}`.
  Check the household's restrictions and the slot first.
