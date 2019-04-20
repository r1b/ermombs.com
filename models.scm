(import miscmacros sqlite3)

(define db (open-database "gliva.db"))

(define ensure-info-table-sql "
  create table if not exists gliva_info
  (cv_filename text, email text, featured_image_filename text);")

(define ensure-work-table-sql "
  create table if not exists gliva_work
  (title text, year text, dimensions text, materials text, image_filename text, series text, slug text);")

(define (ensure-tables)
  (begin
    (execute db ensure-info-table-sql)
    (execute db ensure-work-table-sql)))

(define (insert-seed-data)
  (begin
    (execute db "
             insert into gliva_info values
             ('cv.pdf', 'mattgliva@gmail.com', 'image.jpg');")
    (execute db "
             insert into gliva_work values
             ('foo', '2019', '1 x 1', 'paper', 'image.jpg', null);")))

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
      rows
      (get-rows statement (append rows (row->result statement)))))

(define (execute-query sql . params)
  (let-values (((statement _) (prepare db sql)))
    (begin
      (unless (null? params)
        ((cut bind-parameters! statement <...>) params))
      (get-rows statement))))

(define (select-home-page-data)
  (let ((info (execute-query "select * from gliva_info;"))
        (works (execute-query "select title, series from gliva_work;")))
    (begin
      (display info)
      (display works))))

(define (main _) (select-home-page-data))
