# Practice recipe library

Recipes in the coach's practice workspace are readable by every
client household (`owner.kind: "practice"`, `editable: false`). A
template's week uses only these.

- The practice id: `list_workspaces` → `kind: "practice"`. Pass it as
  `workspaceId` to `search_recipes`, `save_recipe`, `get_recipe`,
  `delete_recipe`. Only the practice owner edits.
- **Add:** read the page, text or photo yourself; search first and
  update by `id`; `save_recipe {"workspaceId", "recipe"}` with
  ingredients, `allergyMarkers` and nutrition per portion
  (`nutritionEstimated: true` when estimated), also for a practice
  without numbers. The coach's own recipe: `sourceName` the practice
  name, no `sourceUrl`. Confirm name, portions, allergens and `url`.
- `delete_recipe` (ask first) hides it from all clients.
- **Recommend:** name it in a comment, or propose it with
  `add_plan_entries {"workspaceId": "<client household>", "entries":
  [{"date", "mealType", "dishName", "recipeId"}]}` and read
  `planChecks`.
