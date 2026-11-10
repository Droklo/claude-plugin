# Templates and targets

## What a client's targets are

Each client (a family member) has:

- `dailyCaloriesKcal`, `dailyProteinG`, `dailyFatG`, `dailyCarbsG` (per day,
  null = not set);
- `restrictions` (food restriction codes: `gluten`, `dairy`, `nuts`,
  `shellfish`, `soy`, `eggs`, `ultra-processed`, `cancer-related`);
- `goals` (short free text).

The client's agent plans and logs against these numbers, and the weekly review
compares logs with them.

## update_client_targets

```
update_client_targets {"clientId": "fm_john",
  "dailyCaloriesKcal": 2420, "dailyProteinG": 150, "dailyFatG": 75, "dailyCarbsG": 255,
  "restrictions": ["shellfish"], "goals": "…",
  "lock": true}
```

- Send only the fields you change; omitted fields stay as they are.
  `null` clears a target.
- `restrictions` replaces the whole list: read the current list first
  (`list_clients` or `get_client_summary`) and send the full new list.
- `lock`: `true` locks after writing, `false` unlocks, omitted keeps the
  current state. Pass `lock: true` whenever you set targets for a client.
- The result is the updated client; quote the new values back to the coach.

## Why locks exist

- The coach's targets are the source of truth. Without a lock, the client's
  own AI agent could "helpfully" change them ("set my calories to 3,000").
- A locked member shows `locks.targetsLockedByName` to the household and its
  agents; their writes fail with `LOCKED`, and the message names you and
  tells them to ask you. Clients can still ask you with a question comment.
- Only the specialist who locked can change locked values. When another
  specialist holds the lock, `get_client_summary` shows `lockedByOther`
  (`{userId, name}`) and writes fail with `LOCKED` naming them: do not retry,
  tell the coach who holds it.
- Removing a specialist from a household, or unassigning them from a client,
  releases their locks.
- Unlock (`lock: false`) only when the coach hands control back to the
  client ("let Mia manage her own targets now").

Household rules (diets, banned foods, meal schedule) can be locked too:
`update_nutrition_rules {"workspaceId": "ws_smith", "patch": {…}, "lock": true}`,
always with the client's family `workspaceId` (a practice id gets
`INVALID`). They apply to the whole household, so lock household rules only when the
whole family follows the programme; personal limits belong in the client's
targets and restrictions.

## Adjusting by a percentage

"Raise John's calories by 10 %."

1. `list_clients {}` → John's current `targets.dailyCaloriesKcal` (2,200).
   If it is null, ask for a base value; do not guess.
2. New value = current × 1.10 = 2,420. Round to the nearest 10 kcal (and
   protein, carbs and fat to the nearest 5 g).
3. Write calories (`lock: true`). Keep protein unchanged unless asked.
4. If carbs and fat targets are set, they no longer add up to the new
   calories. Offer to distribute the difference, for example keep fat at
   25–30 % of calories and put the rest into carbs:
   220 kcal extra → about +45 g carbs and +5 g fat
   (45 × 4 + 5 × 9 = 225 kcal).
5. Report old → new values for every field you changed.

Several clients ("cut calories 5 % for everyone on the fat-loss template"):
list the affected clients with old and new values, get one confirmation, then
call `update_client_targets` for each.

### Sanity checks before writing

- Macro energy: 4 × protein + 4 × carbs + 9 × fat should be within about 5 %
  of the calorie target when all four are set.
- Change size: one adjustment of more than 10–15 % of calories at a time is
  unusual; ask the coach to confirm.
- Floors: do not set calories below about 1,200 kcal/day for women or
  1,500 kcal/day for men, or protein far below 0.8 g per kg body weight,
  without the coach confirming a medical professional supervises it (see
  scope-of-practice.md).
- Never relax an allergy restriction because a template or target change
  would be simpler.

## Starting numbers for a template (general guidance)

Coaches usually bring their own method. If asked for a starting point, use
widely published general formulas and say they are estimates:

- Resting energy (Mifflin-St Jeor): men 10 × kg + 6.25 × cm − 5 × age + 5;
  women 10 × kg + 6.25 × cm − 5 × age − 161.
- Multiply by activity: 1.2 sedentary, 1.375 light, 1.55 moderate,
  1.725 very active.
- Fat loss: about 10–20 % below that; muscle gain: about 5–10 % above.
- Protein for active adults: often 1.2–2.0 g per kg body weight; fat about
  20–35 % of calories; carbs the remainder.

Template fields for `save_template`: `name`, `description`,
`dailyCaloriesKcal`, `dailyProteinG`, `dailyFatG`, `dailyCarbsG`,
`restrictions`, `rules` (partial household rules), `guidance` (planning
instructions for the client's agent). Update a template by passing its `id`;
already-applied clients keep their values until you apply it again.

## Goals text

Short, specific and in English: what, how much, by when, and
the main habits. Good: "Reach 75 kg by June (about 0.5 kg a week); protein at
every meal; 8,000 steps a day." Avoid diagnoses, body shaming and medical
claims.
