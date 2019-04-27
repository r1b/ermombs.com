(import db scheme sqlite3)

(define ensure-info-table-sql "
  create table if not exists gliva_info
  (cv_filename text not null, email text not null, featured_image_filename text not null, featured_text text default '' not null constraint singleton check (rowid = 1));")

(define ensure-work-table-sql "
  create table if not exists gliva_work
  (title text not null, year integer not null, dimensions text, materials text, image_filename text not null, series text, slug text not null unique);")

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
             ('foo', 2019, '1 x 1', 'paper', 'image.png', null, 'foo'),
             ('bar', 2018, '1 x 1', 'ink', 'image.png', null, 'bar'),
             ('baz', 2017, '1 x 1', 'paint', 'image.png', 'series', 'baz'),
             ('qux', 2016, '1 x 1', 'pencil', 'image.png', 'series', 'qux'),
             ('hamburger', 2015, '1 x 1', 'hamburger', 'image.png', null, 'hamburger');")))

(ensure-tables)
(insert-seed-data)
