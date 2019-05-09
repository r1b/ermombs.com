(module templates (admin-base-template
                    admin-info-template
                    admin-update-work-template
                    admin-works-template
                    base-template
                    featured-content-template
                    sidebar-template
                    work-template)
  (import (chicken base) (chicken format) scheme srfi-13)

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
          ,(render-work-info work)))

  ; ---------------------------------------------------------------------------

  (define (admin-header-template)
    `(nav (@ class "admin-navbar")
          (ul (li (a (@ (href "/admin/info")) "info"))
              (li (a (@ (href "/admin/works")) "works")))))

  (define (admin-base-template #!optional content)
    `(html (head (title "Matt Gliva - Administration")
                 (meta (@ (charset "utf-8")))
                 ; FIXME: For some reason this breaks if I don't add empty content
                 (script (@ (src "/static/gliva.js") (type "text/javascript")) ""))
           (body (div (@ (class "wrapper"))
                      ,(admin-header-template)
                      ,content))))

  (define (admin-info-template info)
    `(div (@ (class "admin-info"))
          (h1 "Info")
          (form (@ (action "/admin/info")
                   (enctype "multipart/form-data")
                   (method "post"))
                (fieldset
                  (div (label (@ (for "cv")) "cv")
                       (input (@ (name "cv") (type "file"))))
                  (div (label (@ (for "email")) "email")
                       (input (@ (name "email")
                                 (type "text")
                                 (value ,(alist-ref 'email info)))))
                  (div (label (@ (for "featured_image")) "featured_image")
                       (input (@ (name "featured_image") (type "file"))))
                  (div (label (@ (for "featured_text")) "featured_text")
                       (textarea (@ (name "featured_text"))
                                 ,(alist-ref 'featured_text info)))
                  (input (@ (type "submit") (value "Update")))))))

  (define (admin-add-work-template)
    `(div (@ (class "admin-add-work"))
          (form (@ (action "/admin/works")
                   (enctype "multipart/form-data")
                   (method "post"))
                (fieldset
                  (div (label (@ (for "title")) "title")
                       (input (@ (name "title")
                              (type "text"))))
                  (div (label (@ (for "year")) "year")
                       (input (@ (name "year")
                              (type "text"))))
                  (div (label (@ (for "dimensions")) "dimensions")
                       (input (@ (name "dimensions")
                              (type "text"))))
                  (div (label (@ (for "materials")) "materials")
                       (input (@ (name "materials")
                              (type "text"))))
                  (div (label (@ (for "image")) image)
                       (input (@ (name "image") (type "file"))))
                  (div (label (@ (for "series")) "series")
                       (input (@ (name "series")
                              (type "text"))))
                  (div (label (@ (for "slug")) "slug")
                       (input (@ (name "slug")
                              (type "text"))))
                  (input (@ (type "submit") (value "Add")))))))

  ; TODO: DRY
  (define (admin-update-work-template work)
    `(div (@ (class "admin-work"))
          (form (@ (action ,(string-append "/admin/work/" (alist-ref 'rowid work)))
                   (enctype "multipart/form-data")
                   (method "post"))
                (fieldset
                  (div (label (@ (for "title")) "title")
                       (input (@ (name "title")
                              (type "text")
                              (value ,(alist-ref 'title work)))))
                  (div (label (@ (for "year")) "year")
                       (input (@ (name "year")
                              (type "text")
                              (value ,(alist-ref 'year work)))))
                  (div (label (@ (for "dimensions")) "dimensions")
                       (input (@ (name "dimensions")
                              (type "text")
                              (value ,(alist-ref 'dimensions work)))))
                  (div (label (@ (for "materials")) "materials")
                       (input (@ (name "materials")
                              (type "text")
                              (value ,(alist-ref 'materials work)))))
                  (div (label (@ (for "image")) image)
                       (input (@ (name "image") (type "file"))))
                  (div (label (@ (for "series")) "series")
                       (input (@ (name "series")
                              (type "text")
                              (value ,(alist-ref 'series work)))))
                  (div (label (@ (for "slug")) "slug")
                       (input (@ (name "slug")
                              (type "text")
                              (value ,(alist-ref 'slug work)))))
                  (input (@ (type "submit") (value "Update")))))))


  (define (render-admin-work work)
    `(tr (td (a (@ (href ,(string-append "/admin/work/" (alist-ref 'rowid work))))
                ,(alist-ref 'rowid work)))
         (td ,(alist-ref 'title work))
         (td ,(alist-ref 'year work))
         (td ,(alist-ref 'dimensions work))
         (td ,(alist-ref 'materials work))
         (td ,(alist-ref 'image_filename work))
         (td ,(alist-ref 'series work))
         (td ,(alist-ref 'slug  work))
         (td (button (@ (onclick ,(sprintf "deleteWork(~A)" (alist-ref 'rowid work)))) "Delete"))))

  (define (admin-works-template works)
    `(div (@ (class "admin-works"))
          ,(admin-add-work-template)
          (table (thead (tr (td "id")
                            (td "title")
                            (td "year")
                            (td "dimensions")
                            (td "materials")
                            (td "image_filename")
                            (td "series")
                            (td "slug")
                            (td)))
                 (tbody ,(map render-admin-work works))))))
