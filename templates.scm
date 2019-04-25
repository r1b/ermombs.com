(module templates (base-template featured-content-template sidebar-template work-template)
  (import (chicken format) scheme styles sql-null)

  ; ---------------------------------------------------------------------------

  (define (base-template sidebar-template featured-content-template)
    `(html (head (title "Matt Gliva")
                 (meta (@ (charset "utf-8")))
                 (meta (@ (name "description") (description "Matt Gliva")))
                 (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
                 (style (@ type "text/css") ,(render-styles)))
           (body (div (@ (class "wrapper"))
                      ,sidebar-template
                      ,featured-content-template)))`)

  ; ---------------------------------------------------------------------------

  (define (render-work work)
    (let ((slug (cdr (assoc 'slug work)))
          (title (cdr (assoc 'title work))))
      `(li (a (@ (href ,(string-append "/work/" slug))) ,title))))

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
                             (list `(li (b ,series)) (render-work work))
                             rendered-works
                             series)))))

  (define (sidebar-template info works)
    (let ((cv-filename (cdr (assoc 'cv_filename info)))
          (email (cdr (assoc 'email info))))
      `(div (@ (class "sidebar"))
          (div (@ (class "info"))
               (h1 (a (@ (class "homepage-link") (href "/")) "Gliva"))
               (ul (li (a (@ (href ,(string-append "/static/" cv-filename))) "⚖"))
                   (li (a (@ (href ,(string-append "mailto:" email))) "$"))))
          (nav (@ (class "navbar"))
               ,(render-works works)))))

  ; ---------------------------------------------------------------------------

  (define (featured-content-template info)
    (let ((featured-image-filename (cdr (assoc 'featured_image_filename info)))
          (featured-text (cdr (assoc 'featured_text info))))
      `(div (@ (class "featured-content"))
          (img (@ (src ,(string-append "/static/" featured-image-filename))))
          (pre (@ (class "featured-text")) ,featured-text))))

  ; ---------------------------------------------------------------------------

  (define (render-work-info work)
    (let ((title (cdr (assoc 'title work)))
          (year (cdr (assoc 'year work)))
          (dimensions (cdr (assoc 'dimensions work)))
          (materials (cdr (assoc 'materials work))))
      `(div (@ (class "work-info"))
            (ol (li (b ,(sprintf "~A, ~A" title year)))
                (li ,dimensions)
                (li ,materials)))))

  (define (work-template work)
    (let ((image-filename (cdr (assoc 'image_filename work))))
      `(div (@ (class "work"))
          (div (@ (class "work-image"))
               (img (@ (src ,(string-append "/static/" image-filename)))))
          ,(render-work-info work)))))
