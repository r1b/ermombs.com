(module templates (base-template
                    featured-content-template
                    sidebar-template
                    work-template)
  (import (chicken base) (chicken format) scheme)

  ; ---------------------------------------------------------------------------

  (define (base-template sidebar-template featured-content-template)
    `(html (@ (lang "en"))
           (head (title "Matt Gliva - Portfolio")
                 (meta (@ (charset "utf-8")))
                 (meta (@ (name "description") (content  "Matt Gliva is a Brooklyn-based artist, musician and professional fuck-face.")))
                 (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
                 (link (@ (href "/static/gliva.css") (rel "stylesheet"))))
           (body (div (@ (class "wrapper"))
                      ,sidebar-template
                      ,featured-content-template))))

  ; ---------------------------------------------------------------------------

  (define (render-work work)
    (let ((slug (alist-ref 'slug work))
          (title (alist-ref 'title work)))
      `(li (a (@ (href ,(string-append "/work/" slug))) ,title))))

  (define (render-series works rendered-series rendered-works this-series)
    (if (or (null? works)
            (string=? (alist-ref 'series (car works)) "")
            (not (string=? (alist-ref 'series (car works)) this-series)))
        (render-works works
                      (append rendered-works
                              (list `(li ,this-series) (cons 'ol rendered-series))))
        (render-series (cdr works)
                       (append rendered-series
                               (list (render-work (car works))))
                       rendered-works
                       this-series)))

  (define (render-works works #!optional (rendered-works '()))
    (if (null? works)
        (cons 'ol rendered-works)
        (let* ((work (car works))
               (series (alist-ref 'series work)))
          (if (string=? series "")
              (render-works (cdr works)
                            (append rendered-works
                                    (list (render-work work))))
              (render-series (cdr works)
                             (list (render-work work))
                             rendered-works
                             series)))))

  (define (sidebar-template info works)
    (let ((cv-filename (alist-ref 'cv_filename info))
          (email (alist-ref 'email info)))
      `(div (@ (class "sidebar"))
            (div (@ (class "info"))
                 (h1 (a (@ (class "homepage-link") (href "/")) "Gliva"))
                 (ul (li (a (@ (href ,(string-append "/static/" cv-filename))) "⚖"))
                     (li (a (@ (href ,(string-append "mailto:" email))) "$"))))
            (nav (@ (class "navbar"))
                 ,(render-works works)))))

  ; ---------------------------------------------------------------------------

  (define (featured-content-template info)
    (let ((featured-image-filename (alist-ref 'featured_image_filename info))
          (featured-text (alist-ref 'featured_text info)))
      `(div (@ (class "featured-content"))
            (img (@ (src ,(string-append "/static/" featured-image-filename))
                    (alt "Featured image")))
            (span (@ (class "featured-text")) ,featured-text))))

  ; ---------------------------------------------------------------------------

  (define (render-work-info work)
    (let ((title (alist-ref 'title work))
          (year (alist-ref 'year work))
          (dimensions (alist-ref 'dimensions work))
          (materials (alist-ref 'materials work)))
      `(div (@ (class "work-info"))
            (ol (li ,(sprintf "~A, ~A" title year))
                (div (@ (class "work-metadata"))
                     (li ,dimensions)
                     (li ,materials))))))

  (define (work-template work)
    `(div (@ (class "work"))
          (div (@ (class "work-image"))
               (img (@ (src ,(string-append "/static/"
                                            (alist-ref 'image_filename work)))
                       (alt ,(alist-ref 'title work)))))
          ,(render-work-info work))))
