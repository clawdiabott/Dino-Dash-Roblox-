# Text-to-Production Intake

Patrick can send rough text. RobloxMax converts it to production.

## Minimum prompt

```text
Build a Roblox game where <hook>. Genre: <genre>. Monetization: <passes/products/subscriptions/private servers>. Target audience: <kids/teens/all ages>. Use experience slug <slug>.
```

## RobloxMax output contract

For each game/update, produce:

1. Scope and MVP.
2. Exact file changes.
3. Strict Luau modules.
4. Security notes.
5. Monetization IDs needed.
6. Build command.
7. Publish dry-run command.
8. Manual Roblox Dashboard steps Patrick must do.
9. Playtest checklist.

## No guesswork rule

If IDs are required, use the registry or credentials file. If absent, stop and ask Patrick for:

- Universe ID
- Place ID
- API key env var name
- Group ID if group-owned
