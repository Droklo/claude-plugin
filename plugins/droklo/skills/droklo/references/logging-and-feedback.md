# Logging and feedback

Logs record what each member really ate. They feed the coach's review,
taste history and the plan's "cooked" marks. Never make logging a
chore or a condition.

## log_meal

```
log_meal {"familyMemberIds": ["fm_me"], "date": "2026-11-09",
  "mealType": "dinner", "planEntryId": "pe_tue", "portion": 1,
  "rating": "liked", "feeling": "heavy", "note": "Too much rice for me"}
```

Keep the returned log ids for comments.

- **Who.** "I" = the member linked to `actor.userId`. "We" =
  `"familyMemberIds": "all"` (the entry's attendees with `planEntryId`).
  Unknown name: ask. Different portions: one call per `portion`.
- **What.** Planned meal (leftovers too): `planEntryId`. They ate
  something else that night: `dishName` without the entry, so the plan
  is not marked eaten as planned. Unplanned: `dishName`, plus
  `recipeId` when it is in the library.
- **When.** The household date it was eaten, from `today`; a future
  date is refused. `eatenAt` only when they give a time. `mealType`
  follows when it was eaten.
- **Portion.** Left out = the entry's share; `0` = served, not eaten.
- **Nutrition.** With an entry or recipe, omit it. Otherwise estimate
  a typical portion (`"estimated": true`; `false` only for numbers
  read in this conversation) or leave it out. Never ask the person for
  numbers.
- **A reading** (`reading` with `kind`, `value`, `unit` as said, optional
  `timing`; kinds `glucose`, `ketones`,
  `blood-pressure`, `weight`, `other`) goes on that meal's log, not in
  the note. Do not interpret or reassure. Say it is saved and who sees
  it: the household, and a coach only when one is assigned to that
  person.

## Rating and feeling

Map their words; do not ask for a rating every time.

- `liked`: loved it, make again. `neutral`: fine. `disliked`: never
  again.
- `great`, `ok`, `heavy` (too full, sluggish), `bloated`,
  `still-hungry`, `low-energy` (tired, crashed). Anything else goes in
  a short factual `note`.
- A lasting verdict: `rate_recipe {"recipeId", "rating", "reason"}`
  (or `dishName`). Disliked dishes stay out of later plans.
- A fixable complaint ("too bland", "took longer than it said") is
  fixed in the recipe, not stored as a dislike.

## Correct or remove

`get_meal_logs {"from", "to", "familyMemberId"}`, then
`update_meal_log {"id", …}` (changed fields; `null` clears; a new
`portion` rescales nutrition). `delete_meal_log` only after a yes; its
threads go too.

## Ask the coach

`get_context.specialists` empty: say nobody outside the household sees
the logs. The owner can invite one: ask for the email (never guess),
`invite_member {"email", "kind": "specialist"}`, read back `delivery`,
then `set_client_assignments {"membershipId", "familyMemberIds"}` (the
full list; `[]` removes all and releases locks).

```
add_comment {"target": {"type": "mealLog", "id": "ml_123"},
  "body": "Was this too much rice for my goal? I felt heavy afterwards.",
  "kind": "question"}
```

- Target: `mealLog`, `planEntry`, `recipe` (with `id`), `day` (with
  `date`) or `general`. For a day or general question about one
  person add `familyMemberId`.
- `question` when they expect an answer. Their words, in English; add
  no advice of yours and do not answer for the coach.
- The result's `delivery` says who can read it: tell them. A coach
  does not see a thread about a member they do not coach.

## Coach replies

- Replies arrive in the Droklo inbox (`get_inbox` gives the `url`),
  never by email. Say so the first time.
- `get_context.openQuestions` and `get_inbox {"onlyUnread": true}`
  show new replies; each thread's `about` says which meal and date.
- Reply with `add_comment {"parentId": <root id>, "body"}`;
  `mark_read {"threadIds"}` after showing them; `resolve_thread
  {"threadId"}` when answered.
