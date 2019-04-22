(include "db")
(module data (select-home-page-data select-work-page-data)
  (import db scheme)

  (define (select-info)
    (execute-query "select * from gliva_info;"))

  (define (select-work slug)
    (execute-query "select * from gliva_work where slug = ?;" slug))

  (define (select-works)
    ; sorry about the mess - we want to order the works in a somewhat
    ; intelligent way so that a series with recent works bubbles up
    (execute-query "select title,series,slug,year,coalesce(max_year, year) as year_order from gliva_work left join (select series as series_group, max(year) as max_year from gliva_work where series_group is not null group by series_group) on series = series_group order by year_order desc, series;"))

  (define (select-home-page-data)
    (let ((info (select-info))
          (works (select-works)))
      (values info works)))

  (define (select-work-page-data slug)
    (let ((info (select-info))
          (work (select-work slug))
          (works (select-works)))
      (values info work works))))
