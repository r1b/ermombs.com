(module data (select-info
               select-series-by-slug
               select-series-sidebar
               select-sidebar
               select-work-by-slug)
  (import db scheme)

  ; --------------------------------------------------------------------------

  ; home page & artist metadata

  (define (select-info)
    (execute-query "select * from info;"))

  ; --------------------------------------------------------------------------

  ; navs

  (define (select-series-sidebar slug)
    (execute-query "select work.title, slugify_series_work(?,work.slug) as slug, work.year, series.slug from work left join series on work.series_id = series.id where series.slug = ? order by work.year desc;" slug slug))

  (define (select-sidebar)
    (execute-query "select work.title, slugify_work(work.slug) as slug, work.year from work where work.series_id is null union select series.title, slugify_series(series.slug) as slug, year from series left join (select work.series_id, max(work.year) as year from work) on series.id = series_id order by year desc, title;"))

  ; --------------------------------------------------------------------------

  ; pages

  (define (select-series-by-slug slug)
    (execute-query "select * from series where slug = ?" slug))

  (define (select-work-by-slug slug)
    (execute-query "select * from work where slug = ?;" slug)))
