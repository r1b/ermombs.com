(module db (db execute-query execute-insert execute-update)
  (import (chicken base) (chicken format) miscmacros scheme srfi-1 srfi-13 sqlite3)

  ; --------------------------------------------------------------------------

  (define db (open-database "gliva.db"))

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
          (apply (cut bind-parameters! statement <>) params))
        (get-rows statement))))

  ; --------------------------------------------------------------------------

  ; TODO be fUnCtIoNaL
  (define (serialize-update-expr columns data)
    (let ((set-exprs '())
          (parameters '()))
      (begin
        (for-each (lambda (column)
                    (let ((column-data (assoc column data)))
                      (when column-data
                        (set! set-exprs (cons (sprintf "~A = ?"
                                                   (symbol->string column))
                                          set-exprs))
                        (set! parameters (cons (cdr column-data) parameters)))))
                  columns)
        (values (string-join set-exprs ", ") parameters))))

  (define (execute-update table data id)
    (let-values (((set-expr parameters) (serialize-update-expr (cdr table) data)))
      (apply (cut execute-query
                  (sprintf "update ~A set ~A where rowid = ?;"
                           (car table)
                           set-expr)
                  <>)
             (append parameters (list id)))))

  ; --------------------------------------------------------------------------

  (define (serialize-insert-expr columns data)
    (let ((column-exprs '())
          (parameters '()))
      (begin
        (for-each (lambda (column)
                  (let ((column-data (assoc column data)))
                        (when column-data
                          (set! column-exprs (cons (symbol->string column) column-exprs))
                          (set! parameters (cons (cdr column-data) parameters)))))
                columns)
        (values (string-join column-exprs ", ")
                (string-join (make-list (length column-exprs) "?") ", ")
                parameters))))

  (define (execute-insert table data)
    (let-values (((columns-expr values-expr parameters) (serialize-insert-expr (cdr table) data)))
      (execute-query (sprintf "insert into ~A (~A) values (~A);"
                              (car table)
                              columns-expr
                              values-expr)
                     parameters))))
