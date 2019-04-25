(import db scheme sqlite3)

; TODO: enforce info singleton
(define ensure-info-table-sql "
  create table if not exists gliva_info
  (cv_filename text, email text, featured_image_filename text, featured_text text);")

(define ensure-work-table-sql "
  create table if not exists gliva_work
  (title text, year text, dimensions text, materials text, image_filename text, series text, slug text unique);")

(define (ensure-tables)
  (begin
    (execute db ensure-info-table-sql)
    (execute db ensure-work-table-sql)))

(define (insert-seed-data)
  (begin
    (execute db "
             insert into gliva_info values
             ('cv.pdf', 'mattgliva@gmail.com', 'image.png', 'sometimes i get all jacked up\nsometimes i get all worked up\nsometimes i get all wound up');")
    (execute db "
             insert into gliva_work values
             ('foo', '2019', '1 x 1', 'paper', 'image.png', null, 'foo'),
             ('bar', '2018', '1 x 1', 'ink', 'image.png', null, 'bar'),
             ('baz', '2017', '1 x 1', 'paint', 'image.png', 'series', 'baz'),
             ('qux', '2016', '1 x 1', 'pencil', 'image.png', 'series', 'qux'),
             ('hamburger', '2015', '1 x 1', 'hamburger', 'image.png', null, 'hamburger');")))

(ensure-tables)
(insert-seed-data)
