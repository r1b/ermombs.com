(module serializers (serialize-info serialize-work)
  (import scheme sql-null srfi-1)

  ; TODO: These should be like the query helpers and iterate over known fields

  ; --------------------------------------------------------------------------

  (define (serialize-info info)
    (filter-map (lambda (field)
                  (case (car field)
                    ((rowid) (cons 'rowid (number->string (cdr field))))
                    (else field)))
                info))

  ; --------------------------------------------------------------------------

  (define (serialize-work work)
    (filter-map (lambda (field)
                  (case (car field)
                    ((rowid) (cons 'rowid (number->string (cdr field))))
                    ((year) (cons 'year (number->string (cdr field))))
                    ((series) (if (sql-null? (cdr field)) (cons 'series "") field))
                    (else field)))
                work)))
