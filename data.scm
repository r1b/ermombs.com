(module data (delete-work
               insert-work
               select-info
               select-sidebar-works
               select-work-by-id
               select-work-by-slug
               select-works
               update-info
               update-work)
  (import (chicken format) db scheme)

  ; TODO: Remove bin/seed-db.scm, move types into *-table defs

  ; --------------------------------------------------------------------------

  (define info-table '(gliva_info . (cv_filename email featured_image_filename featured_text)))

  (define (select-info)
    (execute-query "select rowid, * from gliva_info;"))

  (define (update-info data id)
    (execute-update info-table data id))

  ; --------------------------------------------------------------------------

  (define work-table '(gliva_work . (title year dimensions materials image_filename series slug)))

  (define (select-sidebar-works)
    ; sorry about the mess - we want to order the works in a somewhat
    ; intelligent way so that a series with recent works bubbles up
    (execute-query "select title,series,slug,year,coalesce(max_year, year) as year_order from gliva_work left join (select series as series_group, max(year) as max_year from gliva_work where series_group is not null group by series_group) on series = series_group order by year_order desc, series;"))

  (define (select-work-by-id id)
    (execute-query "select rowid, * from gliva_work where rowid = ?;" id))

  (define (select-work-by-slug slug)
    (execute-query "select rowid, * from gliva_work where slug = ?;" slug))

  (define (select-works)
    (execute-query "select rowid, * from gliva_work;"))

  (define (insert-work data)
    (execute-insert work-table data))

  (define (update-work data id)
    (execute-update work-table data id))

  (define (delete-work id)
    (execute-query (sprintf "delete from ~A where rowid = ?;" (car work-table)) id)))
