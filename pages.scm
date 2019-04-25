(module pages (render-admin-page
                render-admin-info-page
                render-admin-work-page
                render-admin-works-page
                render-home-page
                render-work-page)
  (import sxml-serializer scheme templates)

  (define (render-admin-page)
    (serialize-sxml (admin-base-template)))

  (define (render-admin-info-page info)
    (serialize-sxml (admin-base-template (admin-info-template info))))

  (define (render-admin-work-page work)
    (serialize-sxml (admin-base-template (admin-work-template work))))

  (define (render-admin-works-page works)
    (serialize-sxml (admin-base-template (admin-works-template works))))

  (define (render-home-page info works)
    (serialize-sxml (base-template (sidebar-template info works)
                                   (featured-content-template info))))

  (define (render-work-page info work works)
    (serialize-sxml (base-template (sidebar-template info works)
                                   (work-template work)))))
