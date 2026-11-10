# Client onboarding

One step at a time: say where the coach is, do the step, offer the
next. The first week of meals: first-week.md.

0. **Practice.** `list_workspaces` must show `kind: "practice"`. If
   not, the coach picks "I'm a coach" in Droklo on the web.
1. **Template.** `list_templates`, or `save_template` with the
   coach's numbers and `guidance` (templates-and-targets.md). A coach
   without numbers saves guidance only.
2. **Invite.** Ask for the client's email; never invent one.
   `create_client_invite {"email"}` → `invite.url`, `expiresAt`,
   `delivery`. Droklo does not email it: the coach sends the link.
   Only that address can accept. A link anyone can use only when the
   coach says so: `{"shareByHand": true}`. A group:
   `{"maxUses": 12}` (2–200). What the client does to join:
   `practice.routine.clientJoins`. Others in the household become
   clients only when its owner assigns them.
3. **Apply once joined.** `get_client_summary` (restrictions, goals,
   `dietHint`), then `apply_template {"templateId", "clientIds",
   "dryRun": true}`. Show old → new and any findings; apply on a yes.
   It copies non-null targets and adds the template's restrictions
   (an allergy is never removed). Lock only if the coach asks
   (`lock: true`). Another level: `targetKcal`. Report each
   `skipped[].message` and read `delivery` back.
4. **Personalise.** `goals` through `update_client_targets` (the
   client reads it: preview, yes). What the coach wants to remember:
   `set_client_notes {"clientId", "about": "client" | "household",
   "privateNotes"}`; it replaces the text, so send old plus new.
5. **Welcome.** Ask what it should say; preview and post as a
   `general` comment with the client's `familyMemberId`
   (commenting.md). With targets set in the same sitting, post the
   welcome first.

## Intake

Use what is stored and read it back once. Ask only what blocks the
next step, one question per reply: goal and timeline, training days;
allergies (never relaxed without the client); conditions, medication,
pregnancy, under 18 (scope-of-practice.md before any target); who
eats and cooks, weekday time; likes and dislikes. Household facts are
the client's to fill in: ask with a `question` comment.

## Several clients

Check names against `list_clients`, preview per client, one
`apply_template` for all. In a group each participant has their own
household: say who has joined and who has not, and what a group does
not get (limits-and-fit.md).
