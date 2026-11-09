# Droklo plugin for Claude

Connects Claude to [Droklo](https://www.droklo.com), the household nutrition
system of record, and teaches Claude how to use it. It works on claude.ai, in
the Claude desktop and mobile apps, in Cowork and in Claude Code.

It bundles:

- **MCP connector** `Droklo` → `https://www.droklo.com/api/mcp` (Streamable
  HTTP, OAuth). You sign in with your Droklo account the first time you
  connect it.
- **Skill `droklo`**: meal planning for any horizon, web recipe search,
  recipe capture (links, Instagram, photos, text), moving and swapping meals,
  meal logging with ratings and feelings, questions to your coach, and
  shopping lists with store hand-off.
- **Skill `droklo-coach`**: client onboarding, templates and locked targets,
  weekly reviews, commenting, scope of practice, practice recipe library.

## Install on claude.ai and the Claude apps

The plugin is published to the public marketplace repository
[Droklo/claude-plugin](https://github.com/Droklo/claude-plugin).
New versions arrive when you check the marketplace for updates (or
automatically, if the repository owner turned on **Sync automatically**):

1. In Claude, open **Customize → Plugins**, select **Add → Add marketplace →
   Add from a repository**, enter `Droklo/claude-plugin` and select
   **Sync**.
2. Install **Droklo** from the marketplace.
3. Open the Droklo plugin, go to its **Connectors** tab, select **Connect**,
   keep the suggested settings, then sign in to Droklo and allow access.
4. In a new chat, ask "What's for dinner this week?"

Without marketplaces, download
[droklo-plugin.zip](https://www.droklo.com/downloads/droklo-plugin.zip) and
upload it under **Customize → Plugins → Add → Upload plugin** (no automatic
updates). If your plan allows neither, add a custom connector with the address
above in **Customize → Connectors**, and upload
[droklo.zip](https://www.droklo.com/downloads/droklo.zip) (and
[droklo-coach.zip](https://www.droklo.com/downloads/droklo-coach.zip) for
coaches) in **Customize → Skills**.

## Install in Claude Code

```
/plugin marketplace add Droklo/claude-plugin
/plugin install droklo@droklo
```

Droklo's hosted marketplace works too:
`/plugin marketplace add https://www.droklo.com/downloads/marketplace.json`.

Then run `/mcp`, pick `Droklo` and sign in. Ask, for example, "Plan our
dinners for next week" or "Log my lunch".

From a checkout of this repository (development):

```
claude --plugin-dir ./plugins/droklo
```

If you already added Droklo as an MCP server yourself (`claude mcp add`), you
will see its tools twice; remove one of the two.

### Personal access token instead of OAuth

To use a personal access token instead of OAuth (create one in Droklo under
Settings → Connect your AI assistant, `/settings/connect`), add the server
yourself and use the skills from the plugin:

```
claude mcp add --transport http droklo https://www.droklo.com/api/mcp \
  --header "Authorization: Bearer drk_..."
```

For local development against `http://localhost:3000/api/mcp`, add that URL
the same way.

## ChatGPT

Add the MCP server as an app/connector (developer mode). The same rules reach
ChatGPT through the server instructions and `get_context.guidance`; skill
zips can be uploaded where ChatGPT Skills are available.

## Layout

```
plugins/droklo/
├── .claude-plugin/plugin.json   manifest (name, version, metadata)
├── .mcp.json                    the Droklo MCP connector (HTTP)
├── assets/icon.png              1024 px plugin icon
├── README.md
└── skills/                      GENERATED copy of agent-skills/*
    ├── droklo/
    └── droklo-coach/
```

## Maintaining

The skills are single-sourced in `agent-skills/` (the Agent Skills standard
layout). Plugins cannot reference files outside the plugin directory (paths
with `..` are rejected and installed plugins are copied to a cache), so
`scripts/build-skills.ts` copies them into `skills/` here.

1. Edit `agent-skills/<skill>/…` and, for the golden rules,
   `src/lib/agent-guidance.ts` (the build copies them into each SKILL.md).
2. Bump `version` in `.claude-plugin/plugin.json` **and** `metadata.version`
   in each SKILL.md (the build checks they match). Claude keeps users on a
   version until it changes.
3. Run `npx tsx scripts/build-skills.ts`. It validates the skills (frontmatter
   limits, tool names against `docs/rework/mcp-tools.md`, codes against
   `src/types/domain.ts`), refreshes `skills/`, and rebuilds
   `public/downloads/{droklo,droklo-coach,droklo-plugin}.zip`,
   `public/downloads/marketplace.json` and the repository marketplace
   `.claude-plugin/marketplace.json`.
4. Run `claude plugin validate plugins/droklo`.
5. Commit the generated files. `npx tsx scripts/build-skills.ts --check` fails
   when they are out of date.
6. Run `pnpm publish:plugin` to push the plugin to the public marketplace
   repository (`--dry-run` shows the changes first).

## Privacy

See Droklo's [privacy policy](https://www.droklo.com/privacy).

Never edit `skills/` here directly; the next build overwrites it.
