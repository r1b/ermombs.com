(include "db")
(import db scheme sqlite3)

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
             ('foo', '2019', '1 x 1', 'paper', 'image.jpg', null, 'foo'),
             ('bar', '2018', '1 x 1', 'ink', 'image.jpg', null, 'bar'),
             ('baz', '2017', '1 x 1', 'paint', 'image.jpg', 'series', 'baz'),
             ('qux', '2016', '1 x 1', 'pencil', 'image.jpg', 'series', 'qux'),
             ('hamburger', '2015', '1 x 1', 'hamburger', 'image.jpg', null, 'hamburger');")))

(ensure-tables)
(insert-seed-data)
