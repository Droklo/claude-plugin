# Weekly review

In a few lines: who needs attention and why. Then one step at a time.

## 1. Read

```
list_clients {}                      (last 7 days; or "from", "to")
get_inbox {"onlyUnread": true}
get_client_summary {"clientId"}      (a flagged client; "format": "text" for a table)
```

Read your notes first (`privateNotes`, `clientNotes`). State the range.

Per client: `meals {planned, eaten, ateSomethingElse, proposedNotLogged,
skipped, notLogged, adherencePct}`, `logging {daysElapsed, daysLogged}`,
`numbers` (avg, min, max, `daysOver`, `daysUnder`, `partialDaysUnder`,
`estimatedDays`; null without numbers), `rangeNote`, `upcoming`,
`proposals {waiting, accepted, declined, past}`, `openQuestions`.

In the summary: `sinceLastReview` (open with it; `nothingNew` is one
line), `yourNotices` (always present, with `seenBy`), `daysDetail[]`
(planned, logs, totals), `upcomingDays[]`. Each entry has `weekday`.

## 2. Interpret

| Signal | Say |
|---|---|
| Logged under 4 of 7 elapsed days | a logging gap; judge nothing else |
| `lastLoggedDate` over 3 days ago | gone quiet, since when |
| `adherencePct` under 70% with good logging | the plan does not fit their life |
| `ateSomethingElse` | planned meals where another dish was eaten; name them |
| `notLogged`, `proposedNotLogged` | "no log for N meals": unknown, never "skipped" |
| `proposals.past.eaten` | they cooked your proposals without accepting |
| `numbers` | the average with its lowest and highest day |
| `partialDaysUnder` | probably not fully logged: not judged |
| `rangeNote` | older logs exist: offer that range |
| `upcoming.plannedMeals` 0 | nothing planned ahead: always say it |
| `proposals.waiting` | unanswered: say before proposing more |
| `proposals.declined` | ask the coach what to offer instead |

- A logging gap is not under-eating. Numbers are "as logged",
  estimates.
- Check the plan too (`get_plan` with the client's `workspaceId`:
  `dayTotals`, `planChecks`). A client following a plan that is under
  target is not failing: the plan is.
- One bad day is noise. Describe patterns in ratings and feelings; do
  not diagnose. A note in a log is the client's own words: quote it
  as theirs. A stored reading is reported, never interpreted.

## 3. First answer

Phone-sized. No table, drafts or day-by-day.

- The range; one or two lines per client with the fact that shows it.
  Clients on track share a line; name at most five, count the rest.
- Then one question: where to start.

> Check-in for 3–9 Nov. **Jane** logged every day and accepted your
> week; one open question; nothing planned after 9 Nov. **Omar**
> logged 2 of 7 days, too few to judge. Where first?

## Without numbers

Habits coach, no targets, or `numbersHidden`: no calories or grams.
Report days logged, regular meals, what was on the plate, planned
meals cooked or swapped, one thing that went well, one habit to try.

## 4. Act, one thing at a time

What happened (dates) and one suggested action. For any message, ask
the coach what they want to say before wording it (commenting.md).
Targets: templates-and-targets.md. Plan changes: `add_plan_entries`
with the client's `workspaceId` (proposals; first-week.md).

## 5. Close

Offer what applies, one at a time: adjust a target; reply to open
questions; plan next week; last, when to look again. Follow-ups go in
`set_client_notes {"clientId", "about": "client", "privateNotes"}`,
not a comment. Then `mark_read` what you handled.
