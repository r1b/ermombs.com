(module pages (render-home-page
                render-work-page)
  (import sxml-serializer scheme templates)

  (define (render sxml)
    (string-append "<!DOCTYPE html>"
                   (serialize-sxml sxml indent: #f method: 'html)))

  (define (render-home-page info works)
    (render (base-template (sidebar-template info works)
                                   (featured-content-template info))))

  (define (render-work-page info work works)
    (render (base-template (sidebar-template info works)
                                   (work-template work)))))
