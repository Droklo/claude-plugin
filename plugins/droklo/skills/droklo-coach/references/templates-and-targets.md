# Templates and targets

A target is general guidance the coach sets, not a prescription. The
numbers are the coach's: never invent one.

## What a client carries

`dailyCaloriesKcal`, `dailyProteinG`, `dailyFatG`, `dailyCarbsG`;
`restrictions` (`gluten`, `dairy`, `nuts`, `peanuts`, `sesame`,
`fish`, `shellfish`, `soy`, `eggs`, `ultra-processed`,
`cancer-related`); `diet` (`vegetarian`, `vegan`, `pescatarian`,
`halal`, `kosher`) with `dietDays`; `trainingDays`, `trainingTargets`
(only the values that differ); `numbersHidden`; `goals` (short text
the client reads: nothing private, no diagnosis).

`dietHint` on a client: their notes name a diet the field lacks; ask
the coach whether to set it. Weight is not tracked: a weight the
coach mentions goes in `set_client_notes` (`about: "client"`).

## update_client_targets

```
update_client_targets {"clientId": "fm_john", "dailyCaloriesKcal": 2300,
  "dailyProteinG": 140, "dryRun": true}
```

- Send only what changes; `null` clears. `restrictions` replaces the
  list: send the full new one and never drop an allergy.
- **Preview first, always** (`dryRun: true`): show `wouldChange` (old
  → new), `wouldLock`, `notice` (what the household will read) and
  `delivery`. Write only after the coach's yes on those lines; a
  changed request needs a new preview.
- After writing, quote `changed`. `delivery.notified` empty: nobody
  was told, so do not claim a notice went out. Opened or not:
  `get_client_summary.yourNotices[].seenBy`.
- The household gets a notice naming the fields, not the values (in
  Droklo and through their assistant; no email). A comment that
  explains the change goes first.
- `numbersHidden: true`: the client's assistant and app leave numbers
  out; they are still stored. Do not read them out another way.
- By a percentage: read the current value (null: ask for a base),
  round calories to 10 and grams to 5, change only what was asked.
  Several clients: one preview each, one table, one yes.
- Sanity before a write: protein × 4 + carbs × 4 + fat × 9 within
  about 5% of calories; a change over 10–15% at once: confirm; the
  floors in scope-of-practice.md.

## Locks

**Lock only when the coach asks.** `lock: true` locks, `false`
unlocks, omitted keeps the state. If the coach worries the client may
change a value, explain in a line and let them choose: "Locked means
only you can change these; the client sees them marked as set by you."

- One lock covers targets, training targets, restrictions and
  exceptions, diet, no-numbers mode and goals text. Not notes, plan
  or logs.
- Never lock a guess: a number worked out from an unconfirmed weight
  or activity level is a proposal until the coach confirms.
- `lockedByOther` / `LOCKED`: another specialist's lock. Do not
  retry; tell the coach.
- Being removed or unassigned releases your locks.
- Who changed what: `get_client_summary {"clientId", "changes": 20}`.

## Household rules and health marks

- `update_nutrition_rules {"workspaceId": "<family id>", "patch",
  "lock"?, "dryRun": true}` binds everyone at the table: only when
  the whole family follows the programme. Preview (`changed`,
  `rules`), then write. List items are added or replace the same
  name; `"remove": {"bannedFoods": ["Pork"]}`; `selectedDiets`,
  `foodRestrictions`, `mealSchedule` are replaced whole.
- `pregnant`, `watch`, `carbsPerMealG`, `strictAllergy`:
  `update_family_member` with the household's `workspaceId`. No
  `dryRun`: tell the coach first that the household gets a notice
  naming the setting.

## Templates

`save_template {"name", "description", targets, "restrictions",
"rules", "guidance", "weekPlan"}`; `id` updates. Clients keep applied
values until you apply again.

- `missing` (also in `list_templates`) names what the coach has not
  given (calories, protein, the split, a sample week): ask in one
  question or confirm it is left out on purpose. `dryRun: true`
  returns `wouldSave`: show it before saving.
- Template `restrictions` are programme rules: applying adds them and
  never removes a client's own.
- `guidance` is concrete planning instruction for the client's
  assistant.

## apply_template

```
apply_template {"templateId", "clientIds": [...], "startDate": "2026-11-16",
  "targetKcal"?: 2400, "householdMeals"?: ["dinner"], "lock"?: true, "dryRun": true}
```

- Preview every time. Show per client: `wouldChange`, `wouldLock`,
  each day against their level (`days[].verdict`) and every finding
  (`restriction`, `target`, `over_time`).
- A client at another level: pass `targetKcal`; the result's `scale`
  says how the week was scaled. Shared household meals keep the
  recipe's numbers; the portion is in the entry notes.
- `householdMeals` proposes those meals for the whole household and
  checks everyone's restrictions.
- `lock` is off unless the coach asked for it.
- Apply after the yes. Read `planChecks` (the whole day), `delivery`
  and `recipesLeftOut`; fix or raise each before anything else. The
  same start date again adds nothing (`alreadyLaidOut`); without
  `startDate` only targets apply.

## Starting numbers, only when the coach asks

Estimates from published formulas; say so. Mifflin-St Jeor: 10 × kg +
6.25 × cm − 5 × age + 5 (men) or − 161 (women); × 1.2 sedentary,
1.375 light, 1.55 moderate, 1.725 very active. Fat loss 10–20% below,
gain 5–10% above. Protein 1.2–2.0 g/kg, fat 20–35% of calories.
