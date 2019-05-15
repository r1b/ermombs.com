(module gliva (route-request)
  (import (chicken base)
          data
          intarweb
          matchable
          pages
          scheme
          serializers
          spiffy
          uri-common)

  ; --------------------------------------------------------------------------

  (define (handle-home-page)
    (send-response status: 'ok
                   body: (render-home-page (serialize-info (select-info))
                                           (map serialize-work (select-sidebar)))))

  (define (handle-series-page slug)
    (send-response status: 'ok
                   body: (render-series-page (serialize-info (select-info))
                                             (serialize-series (select-series-by-slug slug))
                                             (map serialize-work (select-series-sidebar slug)))))

  (define (handle-series-work-page series-slug work-slug)
    (send-response status: 'ok
                   body: (render-series-work-page (serialize-info (select-info))
                                                  (serialize-series (select-series-by-slug series-slug))
                                                  (serialize-work (select-work-by-slug work-slug))
                                                  (map serialize-work (select-series-sidebar series-slug)))))

  (define (handle-work-page slug)
    (send-response status: 'ok
                   body: (render-work-page (serialize-info (select-info))
                                           (serialize-work (select-work-by-slug slug))
                                           (map serialize-work (select-sidebar)))))

  ; --------------------------------------------------------------------------

  (define (handle-404-page)
    (send-response status: 'not-found body: (render-404-page)))

  ; --------------------------------------------------------------------------

  (define (route-request _)
    (let ((path (uri-path (request-uri (current-request)))))
      (match path
        (('/ "") (handle-home-page))
        (('/ "favicon.ico") (send-static-file "favicon.ico"))
        (('/ "robots.txt") (send-static-file "robots.txt"))
        (('/ "series" series-slug work-slug) (handle-series-work-page series-slug work-slug))
        (('/ "series" slug) (handle-series-page slug))
        (('/ "static" filename) (send-static-file filename))
        (('/ "work" slug) (handle-work-page slug))
        (_ (handle-404-page))))))
