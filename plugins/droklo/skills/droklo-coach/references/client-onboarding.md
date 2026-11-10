# Client onboarding

Goal: a new client joins the coach's practice, gets targets from a template
(locked), and receives a welcome message, with their own allergies intact.

## 0. Check the practice

```
list_workspaces {}
  → [{"id": "ws_practice", "kind": "practice", "role": "owner", "name": "Lean & Strong Coaching"}, …]
```

No `kind: "practice"` workspace means the coach has not finished coach
onboarding. Tell them to choose "I'm a coach" in Droklo on the web; there is
no tool for creating a practice.

## 1. Pick or create a template

```
list_templates {}
  → templates: [{"id": "tpl_fatloss", "name": "Fat loss, moderate", "dailyCaloriesKcal": 1900,
                 "dailyProteinG": 140, "dailyFatG": 60, "dailyCarbsG": 190,
                 "restrictions": [], "guidance": "…", "appliedCount": 4}, …]
```

If none fits, create one with the coach (see templates-and-targets.md for the
numbers):

```
save_template {
  "name": "Muscle gain, lean",
  "description": "Small surplus, high protein, 3–4 training days a week.",
  "dailyCaloriesKcal": 2700, "dailyProteinG": 170, "dailyFatG": 80, "dailyCarbsG": 320,
  "restrictions": [],
  "guidance": "Protein at every meal (35–45 g). Carbs around training. Two portions of vegetables at lunch and dinner. Plan simple batch-cooked lunches."
}
```

- Template `restrictions` are for programme rules (for example a dairy-free
  programme), not for individual allergies; leave them empty in general
  templates.
- `guidance` is free text the client's agent reads when planning: write
  concrete planning instructions, not motivational slogans.
- `rules` (optional) can carry household rule fields such as
  `selectedDiets`; keep them for templates where the whole household follows
  the programme.

## 2. Invite the client

```
create_client_invite {"email": "john@example.com"}
  → invite: {"url": "https://www.droklo.com/invite/…", "email": "john@example.com",
             "expiresAt": "2026-11-22T…"}
```

- `email` is optional. With it, only that address can accept; without it,
  anyone with the link can.
- Give the coach the `url` to send themselves (text, email, their app) and
  say when it expires. Droklo does not email it.
- The client opens the link, signs in, creates or chooses their household,
  and becomes your client.

## 3. Apply the template once the client has joined

```
list_clients {}             → John Smith (fm_john, workspace ws_smith), targets all null
get_client_summary {"clientId": "fm_john", "from": "2026-11-02", "to": "2026-11-08"}
                            → restrictions: ["shellfish"], goals: null
apply_template {"templateId": "tpl_fatloss", "clientIds": ["fm_john"]}
                            → applied: ["fm_john"], skipped: []
```

- Applying copies the template's non-null targets onto the client,
  **adds** the template's restrictions to the client's own (allergies such as
  `shellfish` are never removed) and locks the result. The template's
  guidance reaches the client's agent through `get_context.guidance`.
- `skipped[]` has `{clientId, reason, message}`. The reason says the member
  is not your client (the household owner must assign them to you), another
  specialist holds their lock, or they were not found (wrong id or
  archived). Report each one with its `message`.
- Confirm the client list before applying to several clients.

## 4. Personalize

Adjust what the template cannot know, with the coach's numbers:

```
update_client_targets {"clientId": "fm_john", "dailyProteinG": 160,
  "goals": "Lose 5 kg by March at about 0.5 kg a week; strength training 3x a week; protein at every meal.",
  "lock": true}
```

`goals` is short, specific text the client and their agent see. Write it in
English.

## 5. Welcome message

Draft it, show the coach, then post in the client's household:

```
add_comment {"workspaceId": "ws_smith",
  "target": {"type": "general"}, "familyMemberId": "fm_john",
  "kind": "comment",
  "body": "Welcome, John! Your daily targets are set: 1,900 kcal and 160 g protein. Log your meals in Droklo (or ask your AI assistant to do it) and add a question on any meal you're unsure about. We'll review together every Sunday."}
```

## Intake checklist

Ask the coach (or suggest they ask the client) for anything missing:

- goal and timeline, current activity and training days;
- allergies and intolerances (stored as `restrictions`; only the client or
  coach changes them, never relax one without the client confirming);
- medical conditions, medications, pregnancy or breastfeeding, age under 18
  (if any apply, read scope-of-practice.md before setting targets);
- household: who else eats with them, who cooks, cooking time on weekdays;
- food preferences and dislikes.

## Several clients at once

"Apply the fat-loss template to Ana and Leo." Confirm the two names against
`list_clients`, show the change, then one call:
`apply_template {"templateId": "tpl_fatloss", "clientIds": ["fm_ana", "fm_leo"]}`.
Report `applied` and every `skipped` entry with its reason.
