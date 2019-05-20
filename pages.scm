(module pages (render-404-page
                render-home-page
                render-series-page
                render-series-work-page
                render-work-page)
  (import sxml-serializer scheme templates)

  (define (render sxml)
    (string-append "<!DOCTYPE html>"
                   (serialize-sxml sxml indent: #f method: 'html)))

  (define (render-404-page)
    (render `(h1 "NoT fOuNd")))

  (define (render-home-page info links)
    (render (base-template (sidebar-template info links)
                           (featured-content-template info))))

  (define (render-work-page info links work)
    (render (base-template (sidebar-template info links)
                           (work-template work))))

  (define (render-series-page info links series)
    (render (base-template (sidebar-template info links)
                           (featured-content-template series))))

    (define (render-series-work-page info links work)
      (render (base-template (sidebar-template info links)
                             (work-template work)))))
