(module gliva (route-request)
  (import (chicken base)
          data
          intarweb
          matchable
          pages
          scheme
          spiffy
          uri-common)

  ; --------------------------------------------------------------------------

  (define (handle-home-page)
    (send-response status: 'ok
                   body: (render-home-page (select-info)
                                           (select-sidebar-links))))

  ; (define (handle-series-page slug)
  ;   (send-response status: 'ok
  ;                  body: (render-series-page (select-info)
  ;                                            (select-series-by-slug slug)
  ;                                            (select-series-sidebar-links slug))))

  ; (define (handle-series-work-page series-slug work-slug)
  ;   (send-response status: 'ok
  ;                  body: (render-series-work-page (select-info)
  ;                                                 (select-series-sidebar-links series-slug)
  ;                                                 (select-series-by-slug series-slug)
  ;                                                 (select-work-by-slug work-slug))))

  (define (handle-work-page slug)
    (send-response status: 'ok
                   body: (render-work-page (select-info)
                                           (select-sidebar-links)
                                           (select-work-by-slug slug))))

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
        ; (('/ "series" series-slug work-slug) (handle-series-work-page series-slug work-slug))
        ; (('/ "series" slug) (handle-series-page slug))
        (('/ "static" filename) (send-static-file filename))
        (('/ "work" slug) (handle-work-page slug))
        (_ (handle-404-page))))))
