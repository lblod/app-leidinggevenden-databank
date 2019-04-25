# Leidinggevenden databank

APIs on top of the Mandaat model and application profile as defined on:
* http://data.vlaanderen.be/ns/mandaat
* http://data.vlaanderen.be/doc/applicatieprofiel/mandatendatabank

Some parts of the model have been extended, the defintion (for now) may be found in
 * https://github.com/lblod/domain-files/blob/master/master-leidinggevenden-domain.lisp

## Running the application
```
docker-compose up
```

The stack is built starting from [mu-project](https://github.com/mu-semtech/mu-project).

OpenAPI documentation can be generated using [cl-resources-openapi-generator](https://github.com/mu-semtech/cl-resources-openapi-generator).