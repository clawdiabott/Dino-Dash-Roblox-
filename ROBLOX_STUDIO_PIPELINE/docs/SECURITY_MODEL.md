# Roblox Security Model

## Non-negotiables

- Server owns truth.
- Client input is hostile.
- Every remote is rate-limited.
- Every payload is validated.
- Purchases are granted only by server receipt/pass checks.
- Data writes are idempotent and retry-safe.
- Secrets stay outside source code.

## Remote checklist

For every RemoteEvent / RemoteFunction:

- Name
- Direction
- Payload schema
- Max calls per time window
- Server permission checks
- Abuse cases
- Failure behavior

## Monetization checklist

- Developer product receipt handler is idempotent by PurchaseId.
- Game pass checks happen server-side.
- Client purchase prompts are UX only, never authority.
- Unknown product IDs return NotProcessedYet.
- Failed persistence returns NotProcessedYet to allow Roblox retry.
