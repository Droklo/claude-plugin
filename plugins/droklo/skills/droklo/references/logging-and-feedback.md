# Logging and feedback

Meal logs record what each family member actually ate. They feed the coach's
review (adherence, calories, protein), the household's taste history and the
plan's "cooked" marks. Log what really happened, not what was planned.

## log_meal

```
log_meal {
  "familyMemberIds": ["fm_me"],          // or "all"
  "date": "2026-11-09",
  "mealType": "dinner",
  "planEntryId": "pe_tue",               // optional link to the plan entry
  "recipeId": null,                      // optional; derived from the entry
  "dishName": null,                      // required without planEntryId or recipeId
  "portion": 1,                          // portions eaten, default 1
  "rating": "liked",                     // liked | neutral | disliked
  "feeling": "heavy",                    // see codes below
  "note": "Too much rice for me",
  "eatenAt": null,                       // ISO timestamp, only if the user gave a time
  "nutrition": null                      // totals for the portion eaten, see below
}
```

The result is `{ logs: [...] }`, one log per member. Keep the ids: you need
them to comment on a log.

### Who

- "I ate" → the user's own member (`members[]` with
  `linkedUserId === actor.userId`).
- "We ate" → `"familyMemberIds": "all"`. With `planEntryId` it means that
  entry's attendees (all active members when the entry has none); without a
  plan entry it means all active members. Pass explicit ids when only some
  of them ate.
- Named people → their ids. If a name matches nobody, ask.
- Different portions per person (a child ate half) → one `log_meal` call per
  distinct `portion`.

### What and when

- **Planned meal:** pass `planEntryId`; dish and recipe come from the entry
  and the entry is marked cooked.
- **Planned leftovers** (an entry with the recipe and `servings: 0`): log it
  like any planned meal with `planEntryId`; nutrition comes from the recipe.
- **Unplanned meal:** `dishName` (and `recipeId` if it is a library recipe;
  `search_recipes` to find it).
- `date` is the household-local date the meal was eaten; resolve "yesterday"
  and weekday names from `today`. Use `eatenAt` only when the user gives a
  time, as an ISO timestamp with the household's offset.
- `mealType` follows when it was eaten: an afternoon bite is `snack` even if
  it was planned as lunch.

### Nutrition

- With `planEntryId` or `recipeId`, omit `nutrition`: Droklo derives it from
  the recipe × `portion`.
- Without a recipe, use real numbers (package label, restaurant menu
  nutrition) with `"estimated": false`, or a reasonable estimate from a
  standard reference with `"estimated": true`; tell the user it is an
  estimate. If you cannot estimate sensibly, leave nutrition out.
- `nutrition` holds totals for what was eaten (`caloriesKcal`, `proteinG`,
  `carbsG`, `fatG`), not per 100 g.

## Rating and feeling

Map the user's words to codes; do not ask for a rating every time. Ask once,
lightly, when the user is chatting about a meal ("How was it?").

| User says | `rating` |
|---|---|
| loved it, great, delicious, make again | `liked` |
| fine, okay, nothing special | `neutral` |
| didn't like it, too bland, never again | `disliked` |

| User says | `feeling` |
|---|---|
| felt great, energized, light | `great` |
| fine, normal | `ok` |
| too full, heavy, stuffed, sluggish after | `heavy` |
| bloated, gassy | `bloated` |
| still hungry, not filling, hungry an hour later | `still-hungry` |
| tired, sleepy, low energy, crashed | `low-energy` |

Anything that does not fit goes in `note` with `feeling` null. Keep notes
short and factual ("kids picked out the peppers").

**Household preference.** When the user states a lasting preference ("we all
loved it, put it in rotation", "never make this again"), also call
`rate_recipe {"recipeId": …, "rating": "liked" | "disliked", "reason": …}`
(or `dishName` without a recipe). It feeds `history.liked` and
`history.disliked` for future planning.

## Correct or remove a log

- `get_meal_logs {"from": …, "to": …, "familyMemberId": …}` to find it.
- `update_meal_log {"id": …, "patch": {"portion": 1.5, "rating": "neutral"}}`
  (changed fields only; `null` clears; a new `portion` rescales nutrition).
- `delete_meal_log {"id": …}` only after the user confirms; its comment
  threads are deleted too.

## Ask the coach

`get_context.specialists` lists the household's coaches. If it is empty, say
there is no coach connected; the household owner can invite one with
`invite_member {"email": …, "kind": "specialist"}` and then choose who the
coach works with:
`set_client_assignments {"membershipId": <the coach's membershipId from list_members>, "familyMemberIds": [...]}`
(the full list; `[]` removes all and releases the coach's locks).

Attach the question to what it is about, so the coach sees it in context:

| About | `target` |
|---|---|
| A meal they ate | `{"type": "mealLog", "id": "<log id>"}` |
| A planned meal | `{"type": "planEntry", "id": "<entry id>"}` |
| A recipe | `{"type": "recipe", "id": "<recipe id>"}` |
| A whole day | `{"type": "day", "date": "2026-11-09"}` |
| Anything else | `{"type": "general"}` |

```
add_comment {"target": {"type": "mealLog", "id": "ml_123"},
  "body": "Was this too much rice for my goal? I felt heavy afterwards.",
  "kind": "question"}
```

- Use `kind: "question"` when the user expects an answer, `"comment"` for
  remarks.
- For a day or general question about a specific family member, add
  `familyMemberId` (it is inferred for meal logs).
- Who sees it: the whole household, plus coaches for household-level threads
  (no `familyMemberId`) and for threads about their own clients. A coach does
  not see a thread about a member they do not coach, so ask about the
  coached member (or without `familyMemberId`). Tell the user if they share
  something sensitive.
- Write the question in the user's words and language. Do not add your own
  advice to the question.
- Do not answer the question yourself on the coach's behalf. You may give
  general information in chat, clearly as your own.

## Read and answer coach replies

- `get_context.openQuestions` and `get_inbox {"onlyUnread": true}` show
  threads with new replies or unanswered questions.
- Present them by meal and date. Reply in a thread with
  `add_comment {"parentId": "<root comment id>", "body": …}` (no `target`
  needed for a reply).
- `mark_read {"threadIds": [...]}` (root comment ids) after showing the user
  new replies.
- `resolve_thread {"threadId": …}` when the user says the question is
  answered; it leaves the inbox (`"resolved": false` reopens it).

## Worked example (log, rate, ask)

User: "Had the salmon bowl for dinner, loved it but I was hungry again by 9.
Can you ask Coach Ana if I should add more rice?"

```
get_context {}                         → today 2026-11-09, me = fm_me
get_plan {"from": "2026-11-09", "to": "2026-11-09"}
                                       → pe_dinner "Salmon poke bowl", attendees []
log_meal {"familyMemberIds": ["fm_me"], "date": "2026-11-09", "mealType": "dinner",
  "planEntryId": "pe_dinner", "rating": "liked", "feeling": "still-hungry",
  "note": "Hungry again by 9 pm"}
                                       → logs[0].id = "ml_456"
add_comment {"target": {"type": "mealLog", "id": "ml_456"},
  "body": "I loved the salmon bowl but was hungry again by 9 pm. Should I add more rice?",
  "kind": "question"}
```

Reply: "Logged the salmon bowl for you (liked, still hungry later) and asked
Coach Ana on that meal. You'll see her answer in Droklo, or ask me to check
your inbox."
