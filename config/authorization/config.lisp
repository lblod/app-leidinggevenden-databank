;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;(add-delta-logger)
(add-delta-messenger "http://deltanotifier/")

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
;(setf *log-sparql-query-roundtrip* t)
(setf *backend* "http://virtuoso:8890/sparql")
(setf dexador.util:*default-connect-timeout* 60)
(setf dexador.util:*default-read-timeout* 60)

(in-package :server)
(setf *log-incoming-requests-p* nil)

;;;;;;;;;;;;;;;;;
;;; access rights
(in-package :acl)

(define-prefixes
  :schema "http://schema.org/"
  :leidinggevenden "http://data.lblod.info/vocabularies/leidinggevenden/"
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  :locn "http://www.w3.org/ns/locn#"
  :person "http://www.w3.org/ns/person#"
  :prov "http://www.w3.org/ns/prov#")

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("leidinggevenden:Bestuursfunctie" -> _)
  ("leidinggevenden:Functionaris" -> _)
  ("leidinggevenden:FunctionarisStatusCode" -> _)
  ("besluit:Bestuurseenheid" -> _)
  ("besluit:Bestuursorgaan" -> _)
  ("ext:BestuurseenheidClassificatieCode" -> _)
  ("ext:BestuursfunctieCode" -> _)
  ("ext:BestuursorgaanClassificatieCode" -> _)
  ("schema:ContactPoint" -> _)
  ("locn:Address" -> _)
  ("person:Person" -> _)
  ("prov:Location" -> _))

(supply-allowed-group "public")

(grant (read)
  :to-graph (public)
  :for-allowed-group "public")
