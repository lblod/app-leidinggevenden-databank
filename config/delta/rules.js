export default [
  {
    match: {
      // form of element is {subject,predicate,object}
      // predicate: { type: "uri", value: "http://data.vlaanderen.be/ns/mandaat#einde" }
    },
    callback: {
      url: "http://resource/.mu/delta", method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 250,
      ignoreFromSelf: true
    }
  }
];