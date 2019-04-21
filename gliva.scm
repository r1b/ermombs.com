(include "db")

(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          db
          intarweb
          scheme
          spiffy
          sql-null
          sxml-serializer)

  (define (select-home-page-data)
    (let ((info (execute-query "select * from gliva_info;"))
          ; sorry about the mess - we want to order the works in a somewhat
          ; intelligent way so that a series with recent works bubbles up
          (works (execute-query "select title,series,slug,year,coalesce(max_year, year) as year_order from gliva_work left join (select series as series_group, max(year) as max_year from gliva_work where series_group is not null group by series_group) on series = series_group order by year_order desc, series;")))
      (values info works)))

  (define (select-work-page-data slug)
    (execute-query "select * from gliva_work where slug = ?;" slug))

  (define (base-template sidebar-template featured-content-template)
    `(html (head (title "Matt Gliva")
                 (meta (@ (charset "utf-8")))
                 (meta (@ (name "description") (description "Matt Gliva")))
                 (meta (@ (name "viewport") (content "width=device-width, initial-scale=1"))))
           (body ,sidebar-template
                 ,featured-content-template))`)

  (define (render-work work)
    (let ((slug (cdr (assoc 'slug work)))
          (title (cdr (assoc 'title work))))
      `(li (a (@ (href ,(string-append "/" slug))) ,title))))

  (define (render-series works rendered-series rendered-works this-series)
    (if (or (null? works)
            (sql-null? (cdr (assoc 'series (car works))))
            (not (string=? (cdr (assoc 'series (car works))) this-series)))
        (render-works works
                      (append rendered-works
                              (list (cons 'ol rendered-series))))
        (render-series (cdr works)
                       (append rendered-series
                               (list (render-work (car works))))
                       rendered-works
                       this-series)))

  (define (render-works works #!optional (rendered-works '()))
    (if (null? works)
        (cons 'ol rendered-works)
        (let* ((work (car works))
               (series (cdr (assoc 'series work))))
          (if (sql-null? series)
              (render-works (cdr works)
                            (append rendered-works
                                    (list (render-work work))))
              (render-series (cdr works)
                             (list `(span ,series) (render-work work))
                             rendered-works
                             series)))))

  (define (sidebar-template info works)
    (let ((cv-filename (cdr (assoc 'cv_filename info)))
          (email (cdr (assoc 'email info))))
      `(div (@ class "sidebar")
          (div (@ (class "info"))
               (h1 "Matt Gliva")
               (ul (li (a (@ (href ,(string-append "/" cv-filename))) "cv"))
                   (li (a (@ (href ,(string-append "mailto:" email))) "email"))))
          (nav (@ (class "navbar"))
               ,(render-works works)))))

  (define (featured-content-template info)
    (let ((featured-image-filename (cdr (assoc 'featured_image_filename info))))
      `(div (@ (class "featured-content"))
          (img (@ (src ,(string-append "/" featured-image-filename)))))))

  (define (render-home-page)
    (let-values (((info works) (select-home-page-data)))
      (send-response status: 'ok
                     body: (serialize-sxml (base-template (sidebar-template info works)
                                                          (featured-content-template info))))))
  ; TODO irregex
  (define (route-request continue)
    (begin (render-home-page)
           (continue))))
