# dp-sanity-sync

Slik setter du opp for å teste lokalt:

- `cp .env.example .env`
- hent token fra https://www.sanity.io/manage -> `dp-sanity-cms` -> api -> Add API tokenn
- sleng det inn i `SANITY_TOKEN` i .env
- `deno task sync`

Da vil du muligens kunne se:

```
Fetched 246 existing documents from Sanity
Done! Synced 246 opplysninger in one transaction
```

Jippi!