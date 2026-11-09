# Weekly review

Goal: in a few minutes, tell the coach which clients need attention and why,
backed by numbers, with ready-to-post comments.

## 1. Overview

```
list_clients {}                                  (last 7 days in each client's timezone)
list_clients {"from": "2026-11-02", "to": "2026-11-08"}   (a calendar week)
```

Each `ClientSummaryDTO` has: `targets`, `lockedByMe`, `appliedTemplateId`,
`range`, `days`, `loggedDays`, `plannedMeals`, `loggedMeals`, `adherencePct`,
`avgCaloriesKcal`, `avgProteinG`, `lastLogAt`, `openQuestions`.

State the range you used ("2–8 Nov") in the answer.

## 2. Interpret

| Metric | Meaning | Flag when |
|---|---|---|
| `loggedDays / days` | How complete the data is | fewer than 4 of 7 days: **logging gap**, judge nothing else |
| `lastLogAt` | Recency | more than 3 days ago |
| `adherencePct` | Logged meals that match a plan entry ÷ planned meals | below 70 % with good logging: the plan does not fit their life |
| `avgProteinG` vs `targets.dailyProteinG` | Protein per **logged day** | below 90 % of target |
| `avgCaloriesKcal` vs `targets.dailyCaloriesKcal` | Energy per **logged day** | more than 10 % above or below target |
| `openQuestions` | Unanswered client questions | any |

Rules of interpretation:

- **Logging gap is not under-eating.** Averages are means over logged days
  (days with at least one log), so a day with only breakfast logged pulls
  the average down. Check `get_client_summary` before saying a client is
  short.
- **Unknown nutrition is left out.** Logs without recipe or nutrition values
  are excluded from sums (not counted as 0), so day totals cover known values
  only. If a day's totals look low for the number of meals logged, treat the
  day as incomplete.
- **Adherence null** means nothing was planned: talk about planning, not
  compliance.
- One bad day is noise; look for patterns across the week (weekends,
  late dinners, skipped breakfasts).
- Ratings and feelings show how the plan feels: repeated `still-hungry`
  suggests more protein, fibre or volume; repeated `heavy` or `bloated`
  after certain meals suggests portion or ingredient changes; `low-energy`
  with low intake suggests the deficit may be too large. Describe patterns;
  do not diagnose.

## 3. Drill into flagged clients

```
get_client_summary {"clientId": "fm_john", "from": "2026-11-02", "to": "2026-11-08"}
```

`daysDetail[]` gives per day: `planned` (plan entries), `logs` (meal logs with
rating, feeling, note, nutrition) and `totals`. Use it to:

- find the days and meals behind a shortfall ("protein dropped on Thu–Sat:
  dinners eaten out, breakfast skipped");
- spot the meals to comment on (a great choice to reinforce, an off-plan
  pattern to address);
- recompute averages over complete days only when logs are partial
  (say you did).

## 4. Report to the coach

One table, then short notes per flagged client:

| Client | Logged | Adherence | kcal avg / target | Protein avg / target | Questions | Flags |
|---|---|---|---|---|---|---|
| John | 6/7 | 82 % | 2,050 / 2,200 | 118 / 150 g | 1 | protein low |
| Leo | 2/7 | – | – | – | 0 | logging gap |
| Mia | 7/7 | 91 % | 1,820 / 1,800 | 126 / 130 g | 0 | on track |

Then for each flagged client: what happened (with dates), one or two
suggested actions (comment, target change, plan tweak), and a draft comment.

## 5. Act

With the coach's approval:

- **Comment on a specific meal** (see commenting.md):
  ```
  add_comment {"workspaceId": "ws_smith",
    "target": {"type": "mealLog", "id": "ml_789"},
    "kind": "comment",
    "body": "Nice choice on Thursday's chicken bowl, that's 45 g protein. Could you add Greek yogurt or eggs at breakfast to close the gap?"}
  ```
- **Comment on a day** (`{"type": "day", "date": "2026-11-06"}` with
  `familyMemberId`) or a weekly summary (`{"type": "general"}` with
  `familyMemberId`).
- **Answer open questions:** `get_inbox {"onlyUnread": true}`, then reply in
  each thread (commenting.md).
- **Targets:** `update_client_targets` (templates-and-targets.md).
- **Plan suggestions** in the client's household when the coach asks:
  `add_plan_entries {"workspaceId": "ws_smith", "entries": [...]}` (they are
  marked as coach-created); respect the household's restrictions and rules
  as any agent must. You can add, edit and move entries but not delete them,
  log meals or change shopping lists; suggest those to the client.

## Example (K3)

Coach: "Weekly review please, and comment on anything worth commenting on."

```
list_clients {"from": "2026-11-02", "to": "2026-11-08"}
get_client_summary {"clientId": "fm_john", "from": "2026-11-02", "to": "2026-11-08"}
get_client_summary {"clientId": "fm_leo", "from": "2026-11-02", "to": "2026-11-08"}
get_inbox {"onlyUnread": true}
```

Present the table, the per-client notes and 3 draft comments (John: meal log
praise plus breakfast suggestion; Leo: friendly logging nudge on the general
thread; John's open question: an answer). After "post them":
three `add_comment` calls with the right `workspaceId`, `target`, and
`parentId` for the reply, then `mark_read` for the threads you handled.
