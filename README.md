# Leidinggevenden databank

APIs on top of the Mandaat model and application profile as defined on:

* http://data.vlaanderen.be/ns/mandaat
* http://data.vlaanderen.be/doc/applicatieprofiel/mandatendatabank

Some parts of the model have been extended, the defintion (for now) may be
found in

 * https://github.com/lblod/domain-files/blob/master/master-leidinggevenden-domain.lisp

## Running the application

```bash
docker compose up -d
```

The stack is built starting from
[mu-project](https://github.com/mu-semtech/mu-project).

OpenAPI documentation can be generated using
[cl-resources-openapi-generator](https://github.com/mu-semtech/cl-resources-openapi-generator).

## Ingesting data

The app comes with little to no data, because it depends on external
datasources and it is read-only. For production, the datasource for
Leidinggevenden data will be
[Loket](https://loket.lokaalbestuur.vlaanderen.be/) and [Organisatie
Portaal](https://organisaties.abb.vlaanderen.be/) for publicly available
organisational data. Ingesting data is done with `delta-consumer`s and run on
regular intervals.

To start the consumers:

1. Make sure the app is up and running, and the migrations have run.

```bash
docker compose up -d migrations
docker compose logs --tail 1000 -f migrations
```

2. In `docker-compose.override.yml` (preferably) override the following
   parameters for `leidinggevenden-consumer` and `op-public-consumer`:

```yaml
leidinggevenden-consumer:
  environment:
    DISABLE_INITIAL_SYNC: 'false'
    DCR_DISABLE_DELTA_INGEST: "false"
    DCR_WAIT_FOR_INITIAL_SYNC: "true"
    SYNC_BASE_URL: 'https://loket.lblod.info' # PROD Loket
    DCR_CRON_PATTERN_DELTA_SYNC: '15 * * * *' # every 15 past the hour
    #SLEEP_BETWEEN_BATCHES: "1" # only for speedy initial ingest

op-public-consumer:
  #links:
  #  - virtuoso:database # only for speedy initial ingest
  environment:
    DCR_DISABLE_INITIAL_SYNC: "false"
    DCR_DISABLE_DELTA_INGEST: "false"
    DCR_WAIT_FOR_INITIAL_SYNC: "true"
    DCR_SYNC_BASE_URL: "https://organisaties.abb.vlaanderen.be" # PROD OP
    DCR_CRON_PATTERN_DELTA_SYNC: '30 * * * *' # every half past the hour
    #SLEEP_BETWEEN_BATCHES: "1" # only for speedy initial ingest
```

3. Start the ingestion of the data. This can take a while, depending on the
   speedy options from above and the volume of data.

```bash
docker compose up -d op-public-consumer leidinggevenden-consumer
```

4. Check the consumer logs. At some point this message should show up for both
   consumers:
   `Initial sync was success, proceeding in Normal operation mode: ingest deltas`
   or check in the triplestore with the following SPARQL query:

```sparql
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX task: <http://redpencil.data.gift/vocabularies/tasks/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX cogs: <http://vocab.deri.ie/cogs#>

SELECT ?s ?status ?created WHERE {
  VALUES ?operation {
    <http://redpencil.data.gift/id/jobs/concept/JobOperation/deltas/consumer/initialSync/leidinggevenden>
    <http://redpencil.data.gift/id/jobs/concept/JobOperation/deltas/consumer/initialSync/op-public>
  }
  ?s
    a <http://vocab.deri.ie/cogs#Job> ;
    adms:status ?status ;
    task:operation ?operation ;
    dct:created ?created ;
    dct:creator <http://data.lblod.info/services/id/mandatendatabank-consumer> .
}
ORDER BY DESC(?created)
```

5. A restart of `resources` and `cache` might be needed after the intial sync.
   Usually not necessary, but this is quick and easy:

```bash
docker compose restart cache resource
```

6. If you used speedy settings for the ingestion, don't forget to remove them
   or use more relaxed settings to not overload the server.
