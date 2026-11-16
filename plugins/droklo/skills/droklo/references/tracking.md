# Activities and numbers

Beside food a person keeps **activities** (workouts, supplements,
medicines, other things they do) and **numbers** (weight, steps, sleep,
calories burned, lab values). Both are personal: each person sees their
own unless they share. Meals and the shopping list stay shared.

## Activities

```
save_activities {"activities": [
  {"activity": "run", "date": "2026-11-18", "time": "07:00"},
  {"activity": "strength", "date": "2026-11-16", "status": "done", "durationMin": 60},
  {"activity": "Vitamin D", "group": "supplement", "date": "2026-11-16", "status": "done", "amountText": "2000 IU"}]}
```

- `activity`: a catalogue type by name ("run", "road ride", "pool swim",
  "strength", "yoga", "football", "sauna"…). A supplement or medicine is
  named as they say it, with `group` the first time ("supplement",
  "medicine", "other", "workout"). An error names the type to use: use it.
- `status`: `planned` (default), `done`, `skipped`. Done or skipped is
  never in the future.
- A workout may carry `durationMin`, `distanceKm`, `effort` (easy,
  moderate, hard); a supplement or medicine `amountText`. Nothing else.
- Change: `{"id", …}`. Remove: `{"id", "remove": true}`.
- Repeats ("vitamin D every day", "run Tue, Thu, Sat"):
  `set_tracking {"routines": [{"activity", "weekdays": ["tue","thu","sat"], "time"}]}`.
  Tick a routine's day: `{"routineId", "date", "status": "done"}`.
- Read: `get_tracking {"from", "to"}`; an activity with `id: null` is a
  routine's day nobody answered yet.
- Medicine: record what they say they took. Never suggest a dose, a
  change or an interaction; point to their doctor.

## Numbers

```
save_metrics {"metrics": [
  {"metric": "weight", "value": 82.4},
  {"metric": "steps", "value": 9300, "date": "2026-11-15"},
  {"metric": "blood pressure", "value": 128, "value2": 82},
  {"metric": "glucose", "value": 7.8, "timing": "2h after dinner"}]}
```

- `metric` by name: weight, body fat, steps, distance, calories burned,
  active calories, sleep, sleep score, resting heart rate, glucose,
  ketones, LDL, water… A value outside the metric's range is refused:
  check the unit (pass `unit` when they give pounds, miles or mg/dL:
  it is converted).
- Record only what the person gave or asked to keep. Do not interpret
  a health number or reassure.
- Not in the catalogue: add it once with `set_tracking {"metricKinds":
  [{"name", "unit", "reading": "total|level|spot", "decimals", "min",
  "max"}]}`. `total` = a day's entries add up (steps); `level` = one
  value a day (weight); `spot` = each entry stands alone (glucose).
- What shows on Progress, with an optional goal:
  `set_tracking {"metrics": [{"metric": "steps", "goal": 8000, "direction": "reach"}, "weight"]}`
  (the whole list). Two series together:
  `{"links": [["food:calories", "metric:calories-burned"]]}`.
- Progress over time: `get_goal_status {"history": "3m"}` carries
  `tracking` (metrics, workouts, routines, links). Numbers hidden: none.

## Who sees it

Only the person, by default. `set_tracking {"shared": true}` shows it to
the household; a coach sees a client's workouts, supplements and numbers,
medicines only with `{"medicinesToCoach": true}`. Never show one person's
activities or numbers to another unless that person shared them.
