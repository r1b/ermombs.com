(module data (delete-work select-info select-work select-works update-info update-work)
  (import db scheme)

  ; TODO: Remove bin/seed-db.scm, move types into *-table defs

  ; --------------------------------------------------------------------------

  (define info-table '(info . (cv_filename email featured_image_filename featured_text)))

  (define (select-info)
    (execute-query "select * from gliva_info;"))

  (define (update-info data id)
    (execute-update info-table data id))

  ; --------------------------------------------------------------------------

  (define work-table '(work . (title year dimensions materials image_filenam series slug)))

  (define (select-works)
    ; sorry about the mess - we want to order the works in a somewhat
    ; intelligent way so that a series with recent works bubbles up
    (execute-query "select title,series,slug,year,coalesce(max_year, year) as year_order from gliva_work left join (select series as series_group, max(year) as max_year from gliva_work where series_group is not null group by series_group) on series = series_group order by year_order desc, series;"))

  (define (select-work slug)
    (execute-query "select * from gliva_work where slug = ?;" slug))

  (define (insert-work data)
    (execute-insert work-table data))

  (define (update-work data id)
    (execute-update work-table data id))

  (define (delete-work id)
    (execute-query (sprintf "delete from ~A where rowid = ?;" (car work-table)) id))
