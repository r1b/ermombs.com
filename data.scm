(module data (select-info
               select-sidebar-works
               select-work-by-slug
               select-works)
  (import db scheme)

  ; --------------------------------------------------------------------------

  (define (select-info)
    (execute-query "select rowid, * from gliva_info;"))

  ; --------------------------------------------------------------------------

  (define (select-sidebar-works)
    ; sorry about the mess - we want to order the works in a somewhat
    ; intelligent way so that a series with recent works bubbles up
    (execute-query "select title,series,slug,year,coalesce(max_year, year) as year_order from gliva_work left join (select series as series_group, max(year) as max_year from gliva_work where series_group is not null group by series_group) on series = series_group order by year_order desc, series;"))

  (define (select-work-by-slug slug)
    (execute-query "select rowid, * from gliva_work where slug = ?;" slug))

  (define (select-works)
    (execute-query "select rowid, * from gliva_work;")))
