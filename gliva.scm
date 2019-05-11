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
                                           (map serialize-work (select-sidebar-works)))))

  (define (handle-work-page slug)
    (send-response status: 'ok
                   body: (render-work-page (serialize-info (select-info))
                                           (serialize-work (select-work-by-slug slug))
                                           (map serialize-work (select-sidebar-works)))))

  ; --------------------------------------------------------------------------

  (define (handle-404-page)
    (send-response status: 'not-found body: "Life is complicated. Or is it?"))

  ; --------------------------------------------------------------------------

  (define (route-request _)
    (let ((path (uri-path (request-uri (current-request)))))
      (match path
        (('/ "") (handle-home-page))
        (('/ "favicon.ico") (send-static-file "favicon.ico"))
        (('/ "robots.txt") (send-static-file "robots.txt"))
        (('/ "static" filename) (send-static-file filename))
        (('/ "work" slug) (handle-work-page slug))
        (_ (handle-404-page))))))
