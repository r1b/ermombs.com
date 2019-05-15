(module templates (base-template
                    featured-content-template
                    sidebar-template
                    work-template)
  (import (chicken base) (chicken format) scheme)

  ; ---------------------------------------------------------------------------

  (define (slugify-series slug)
    (string-append "/series/" slug))

  (define (slugify-series-work series-slug work-slug)
    (string-append "/series/" series-slug "/" work-slug))

  (define (slugify-static filename)
    (string-append "/static/" filename))

  (define (slugify-work slug)
    (string-append "/work/" slug))

  ; FIXME dumb
  (define (slugify-sidebar slug type)
    (if (string=? type "series")
        (slugify-series slug)
        (slugify-work slug)))

  ; --------------------------------------------------------------------------

  (define (base-template sidebar-template featured-content-template)
    `(html (@ (lang "en"))
           (head (title "Matt Gliva - Portfolio")
                 (meta (@ (charset "utf-8")))
                 (meta (@ (name "description") (content  "Matt Gliva is a Brooklyn-based artist")))
                 (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
                 (link (@ (href ,(slugify-static "gliva.css")) (rel "stylesheet"))))
           (body (div (@ (class "wrapper"))
                      ,sidebar-template
                      ,featured-content-template))))

  ; ---------------------------------------------------------------------------

  (define (render-sidebar-link link)
    (let ((slug (alist-ref 'slug link))
          (title (alist-ref 'title link))
          (type (alist-ref 'type link)))
      `(li (a (@ (href ,(slugify-sidebar slug type))) ,title))))

  (define (sidebar-template info links)
    (let ((cv-filename (alist-ref 'cv_filename info))
          (email (alist-ref 'email info)))
      `(div (@ (class "sidebar"))
            (div (@ (class "info"))
                 (h1 (a (@ (class "homepage-link") (href "/")) "Gliva"))
                 (ul (li (a (@ (href ,(slugify-static cv-filename))) "⚖"))
                     (li (a (@ (href ,(string-append "mailto:" email))) "$"))))
            (nav (@ (class "navbar"))
                 ,(cons 'ol (map render-sidebar-link links))))))

  ; ---------------------------------------------------------------------------

  (define (featured-content-template info)
    (let ((featured-image-filename (alist-ref 'featured_image_filename info))
          (featured-text (alist-ref 'featured_text info)))
      `(div (@ (class "featured-content"))
            (img (@ (src ,(slugify-static featured-image-filename))
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
    (let ((image-filename (alist-ref 'image_filename work))
          (title (alist-ref 'title work)))
      `(div (@ (class "work"))
            (div (@ (class "work-image"))
                 (img (@ (src ,(slugify-static image-filename))
                         (alt ,title))))
            ,(render-work-info work)))))
