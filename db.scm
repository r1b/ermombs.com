(module db (execute-query)
  (import (chicken base) config scheme sqlite3)

  ; --------------------------------------------------------------------------

  (define db (open-database (alist-ref 'database config)))

  ; --------------------------------------------------------------------------

  (define (row->result statement)
    (letrec ((n (column-count statement))
             (get-columns
               (lambda (index #!optional (result '()))
                 (if (< index 0)
                     result
                     (get-columns (sub1 index)
                                  (append result  ; FIXME just cons?
                                          (list (cons (string->symbol (column-name statement index))
                                                      (column-data statement index)))))))))
      (get-columns (sub1 n))))

  (define (get-rows statement many #!optional (rows '()))
    (if (not (step! statement))
        (if (not many) (car rows) rows)
        (get-rows statement many (append rows (list (row->result statement))))))

  (define (execute-query sql #!key (many #f) (params '()))
    (let-values (((statement _) (prepare db sql)))
      (begin
        (unless (null? params)
          (apply (cut bind-parameters! statement <...>) params))
        (get-rows statement many)))))
