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
- **Skill `droklo-setup`**: a short interview that fills in your household
  profile (allergies, when you eat and cook, what you love, your kitchen,
  favourite recipe sites and chefs, shopping, goals). Say "Set up my Droklo
  profile" to start it.
- **An update check for Claude Code and Cowork**: at the start of a session
  it tells you, at most once a day, when a newer Droklo plugin is out. It
  prints nothing otherwise; set `DROKLO_NO_UPDATE_CHECK=1` to turn it off.

## Install on claude.ai and the Claude apps

1. Open **Customize → Plugins**, select **Add → Add marketplace → Add from a
   repository**, enter `Droklo/claude-plugin` and select **Sync**.
2. Install **Droklo** from the marketplace.
3. Open the Droklo plugin, go to its **Connectors** tab, select **Connect**,
   keep the suggested settings, then sign in to Droklo and allow access.
4. In a new chat, say "Set up my Droklo profile", then ask "What's for dinner
   this week?"

To get a new version, open this marketplace in **Customize → Plugins** and check
for updates. Droklo also tells you in the chat when your plugin is out of date.

## Install in Claude Code

```
/plugin marketplace add Droklo/claude-plugin
/plugin install droklo@droklo
```

Then run `/mcp`, choose `droklo` and select **Authenticate**.

Third-party marketplaces don't update by themselves in Claude Code. To get new
versions automatically, run `/plugin`, open **Marketplaces → droklo** and select
**Enable auto-update**. A new version takes effect in your next session or after
`/reload-plugins`.

## Privacy

See Droklo's [privacy policy](https://www.droklo.com/privacy).

---

This repository is generated from the Droklo source by
`scripts/publish-plugin-repo.ts`; changes made here directly are overwritten.
