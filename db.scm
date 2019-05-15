(module db (execute-query)
  (import (chicken base) scheme sqlite3)

  ; --------------------------------------------------------------------------

  (define db (open-database "gliva.db"))

  ; --------------------------------------------------------------------------

  (define-function db
                   slugify_series
                   1
                   (lambda (slug)
                     (concat "/series/" slug)))

  (define-function db
                   slugify_series_work
                   2
                   (lambda (series-slug work-slug)
                     (concat "/series/" series-slug "/" work-slug)))

  (define-function db
                   slugify_work
                   1
                   (lambda (slug)
                     (concat "/work/" slug)))

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

  (define (get-rows statement #!optional (rows '()))
    (if (not (step! statement))
        (if (= (length rows) 1) (car rows) rows)
        (get-rows statement (append rows (list (row->result statement))))))

  (define (execute-query sql . params)
    (let-values (((statement _) (prepare db sql)))
      (begin
        (unless (null? params)
          (apply (cut bind-parameters! statement <...>) params))
        (get-rows statement)))))
