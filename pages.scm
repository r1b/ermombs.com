(module pages (render-admin-page
                render-admin-info-page
                render-admin-work-page
                render-admin-works-page
                render-home-page
                render-work-page)
  (import sxml-serializer scheme templates)

  (define (render sxml)
    (string-append "<!DOCTYPE html>"
                   (serialize-sxml sxml indent: #f method: 'html)))

  (define (render-admin-page)
    (render (admin-base-template)))

  (define (render-admin-info-page info)
    (render (admin-base-template (admin-info-template info))))

  (define (render-admin-work-page work)
    (render (admin-base-template (admin-update-work-template work))))

  (define (render-admin-works-page works)
    (render (admin-base-template (admin-works-template works))))

  (define (render-home-page info works)
    (render (base-template (sidebar-template info works)
                                   (featured-content-template info))))

  (define (render-work-page info work works)
    (render (base-template (sidebar-template info works)
                                   (work-template work)))))
