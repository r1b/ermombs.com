(module data (select-info
               select-series-by-slug
               select-series-sidebar-links
               select-sidebar-links
               select-work-by-slug)
  (import db scheme)


  ; --------------------------------------------------------------------------

  ; home page & artist metadata

  (define (select-info)
    (execute-query "select * from info;"))

  ; --------------------------------------------------------------------------

  ; navs

  (define (select-series-sidebar-links slug)
    (execute-query "select work.title, work.slug from work left join series on work.series_id = series.id where series.slug = ? order by work.year desc;" slug))

  (define (select-sidebar-links)
    (execute-query "select work.title, work.slug, work.year, \"work\" as type from work where work.series_id is null union select series.title, series.slug, year, \"series\" as type from series left join (select work.series_id, max(work.year) as year from work) on series.id = series_id order by year desc, title;"))

  ; --------------------------------------------------------------------------

  ; pages

  (define (select-series-by-slug slug)
    (execute-query "select * from series where slug = ?" slug))

  (define (select-work-by-slug slug)
    (execute-query "select * from work where slug = ?;" slug)))
