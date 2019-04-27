(module templates (admin-base-template
                    admin-info-template
                    admin-update-work-template
                    admin-works-template
                    base-template
                    featured-content-template
                    sidebar-template
                    work-template)
  (import (chicken format) scheme srfi-13 styles sql-null)

  ; ---------------------------------------------------------------------------

  (define (handle-sql-null value)
    (if (sql-null? value) "" value))

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
            ,(render-work-info work))))

  ; ---------------------------------------------------------------------------

  (define (admin-header-template)
    `(nav (@ class "admin-navbar")
          (ul (li (a (@ (href "/admin/info")) "info"))
              (li (a (@ (href "/admin/works")) "works")))))

  (define (admin-base-template #!optional content)
    `(html (head (title "Matt Gliva - Administration")
                 (meta (@ (charset "utf-8")))
           (body (div (@ (class "wrapper"))
                      ,(admin-header-template)
                      ,content)))))

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
                                 (value ,(cdr (assoc 'email info))))))
                  (div (label (@ (for "featured_image")) "featured_image")
                       (input (@ (name "featured_image") (type "file"))))
                  (div (label (@ (for "featured_text")) "featured_text")
                       (textarea (@ (name "featured_text"))
                                 ,(cdr (assoc 'featured_text info))))
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

  ; FIXME: DRY
  (define (admin-update-work-template work)
    `(div (@ (class "admin-work"))
          (form (@ (action ,(string-append "/admin/work/" (number->string (cdr (assoc 'rowid work)))))
                   (enctype "multipart/form-data")
                   (method "post"))
                (fieldset
                  (div (label (@ (for "title")) "title")
                       (input (@ (name "title")
                              (type "text")
                              (value ,(cdr (assoc 'title work))))))
                  (div (label (@ (for "year")) "year")
                       (input (@ (name "year")
                              (type "text")
                              (value ,(cdr (assoc 'year work))))))
                  (div (label (@ (for "dimensions")) "dimensions")
                       (input (@ (name "dimensions")
                              (type "text")
                              (value ,(cdr (assoc 'dimensions work))))))
                  (div (label (@ (for "materials")) "materials")
                       (input (@ (name "materials")
                              (type "text")
                              (value ,(cdr (assoc 'materials work))))))
                  (div (label (@ (for "image")) image)
                       (input (@ (name "image") (type "file"))))
                  (div (label (@ (for "series")) "series")
                       (input (@ (name "series")
                              (type "text")
                              (value ,(handle-sql-null (cdr (assoc 'series work)))))))
                  (div (label (@ (for "slug")) "slug")
                       (input (@ (name "slug")
                              (type "text")
                              (value ,(cdr (assoc 'slug work))))))
                  (input (@ (type "submit") (value "Update")))))))


  (define (render-admin-work work)
    `(tr (td (a (@ (href ,(string-append "/admin/work/"
                                         (number->string (cdr (assoc 'rowid work))))))
                ,(number->string (cdr (assoc 'rowid work)))))
         (td ,(cdr (assoc 'title work)))
         (td ,(cdr (assoc 'year work)))
         (td ,(cdr (assoc 'dimensions work)))
         (td ,(cdr (assoc 'materials work)))
         (td ,(cdr (assoc 'image_filename work)))
         (td ,(handle-sql-null (cdr (assoc 'series work))))
         (td ,(cdr (assoc 'slug  work)))
         (td (button (@ (onclick ,(sprintf "fetch('/admin/work/~A', {method: 'DELETE'}).then(() => location.reload())" (number->string (cdr (assoc 'rowid work)))))) "Delete"))))

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
