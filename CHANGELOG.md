# Changelog
## v1.11.0
- Modernize frontend
- Modernize dispatcher
### Deploy notes

Move the `VIRTUAL_HOST` and `LETSENCRYPT` environment variables from the `leidinggevenden` to the `identifier` service. Also make sure the `networks` config is moved.

```
drc up -d identifier dispatcher leidinggevenden
```

## v1.9.0
- Sync from OP public [DL-6212]

### Deploy notes

WARNING The sync should be deployed after https://github.com/lblod/app-digitaal-loket/pull/644

```
drc down;
```
Update `docker-compose.override.yml` to remove the config of `op-public-consumer` and replace it by:
```
  op-public-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://organisaties.abb.vlaanderen.be" # or another endpoint
      DCR_LANDING_ZONE_DATABASE: "virtuoso" # for the initial sync, we go directly to virtuoso
      DCR_REMAPPING_DATABASE: "virtuoso" # for the initial sync, we go directly to virtuoso
      DCR_DISABLE_INITIAL_SYNC: "false"
      DCR_DISABLE_DELTA_INGEST: "true"
```
Then:
```
drc up -d virtuoso migrations
drc up -d database op-public-consumer
# Wait until success of the previous step
```
Then, update `docker-compose.override.yml` to:
```
  op-public-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://organisaties.abb.vlaanderen.be" # or another endpoint
      DCR_LANDING_ZONE_DATABASE: "database"
      DCR_REMAPPING_DATABASE: "database"
      DCR_DISABLE_DELTA_INGEST: "false"
      DCR_DISABLE_INITIAL_SYNC: "false"
```
```
drc up -d
```
