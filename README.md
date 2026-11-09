# Droklo plugin for Claude

The official plugin marketplace for [Droklo](https://www.droklo.com), the
household nutrition system of record. The Droklo plugin connects Claude to
your Droklo household and teaches Claude how to plan meals, capture recipes,
log what was eaten, build shopping lists and work with a nutrition coach.

It bundles:

- **The Droklo connector** (`https://www.droklo.com/api/mcp`). You sign in
  with your Droklo account when you connect it.
- **Skill `droklo`** for households: planning for any horizon, recipe search
  and capture, moving and swapping meals, meal logs, shopping lists.
- **Skill `droklo-coach`** for nutrition coaches: client onboarding, templates
  and locked targets, weekly reviews, comments, the practice recipe library.

## Install on claude.ai and the Claude apps

1. Open **Customize → Plugins**, select **Add → Add marketplace → Add from a
   repository**, enter `egidijukas/droklo-claude-plugin` and select **Sync**.
2. Install **Droklo** from the marketplace.
3. Open the Droklo plugin, go to its **Connectors** tab, select **Connect**,
   keep the suggested settings, then sign in to Droklo and allow access.
4. In a new chat, ask "What's for dinner this week?"

Claude keeps the plugin up to date from this repository.

## Install in Claude Code

```
/plugin marketplace add egidijukas/droklo-claude-plugin
/plugin install droklo@droklo
```

Then run `/mcp`, choose `droklo` and select **Authenticate**.

## Privacy

See Droklo's [privacy policy](https://www.droklo.com/privacy).

---

This repository is generated from the Droklo source by
`scripts/publish-plugin-repo.ts`; changes made here directly are overwritten.
