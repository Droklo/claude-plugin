# Commenting and answering questions

Comments show in Droklo only: on the client's plan, in the household
inbox and through their assistant. No email.

## The words are the coach's

1. Show the facts (meal, date, question) and ask what the coach wants
   to say. If they delegate ("write something encouraging"), draft it.
2. Word it from their points; add no advice of your own.
3. Preview: `add_comment {…, "dryRun": true}` → `wouldPost`,
   `delivery`. Show the text as is and who can read it.
4. Post on an explicit yes; an edit needs a new yes.
5. Show `posted` and where a reply will appear (`delivery.repliesAt`).

## Where it goes

Always the client's `workspaceId`.

| About | `target` |
|---|---|
| A meal eaten | `{"type": "mealLog", "id"}` |
| A planned meal | `{"type": "planEntry", "id"}` |
| A day | `{"type": "day", "date"}` + `familyMemberId` |
| The week, a welcome, a nudge | `{"type": "general"}` + `familyMemberId` |
| A recipe | `{"type": "recipe", "id"}` |

`kind`: `comment`, or `question` when an answer is needed (stays open
until resolved). A reply needs only `parentId` (the root id).

## Tone

Name the meal and date (weekday from the tool result). What went well
first; one or two next steps in food; two to four sentences. No
judging words, guilt or body comments. Numbers only for a client who
tracks them, never with `numbersHidden`. A reading gets "I saw it",
nothing more.

> You logged every day, and the dinners were just what we planned.
> Breakfast is the light spot: want to try eggs or yogurt?

## Privacy

Every login in the household and the client's assigned specialists
read a comment (`delivery.visibleTo`; it names members without a
login). No comment is private: keep weight and health neutral. One
client per comment. The coach's own remarks go in `set_client_notes`.

## Questions from clients

1. `get_inbox {"onlyUnread": true}`: each thread's `about` gives the
   dish, date and meal. Show the question; ask what to answer.
2. Word, preview, post (`parentId`).
3. `resolve_thread` when fully answered; leave open if you asked
   back. `mark_read {"threadIds"}` for what the coach saw (notice ids
   too).

Out of scope: a kind referral, in the coach's words.

A household fact the coach cannot write (`FORBIDDEN` names the
fields): ask the client with a `question` comment.

## Seen, answered, history

`get_inbox.awaitingReply[]`: the coach's messages without an answer,
with `seenBy`. Say "seen by … on …, no answer yet", never "ignored".
Earlier threads: `list_comments {"workspaceId", "familyMemberId"}`;
check before repeating advice.
