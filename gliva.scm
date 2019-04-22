(include "data")

(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          data
          intarweb
          matchable
          scheme
          spiffy
          sxml-serializer
          templates
          uri-common
          utf8)

  (define-constant *NOT-FOUND* "Ask and it will be given to you; seek and you will find; knock and the door will be opened to you.\n\n- Gliva 7:7")

  (define (send-home-page)
    (let-values (((info works) (select-home-page-data)))
      (send-response status: 'ok
                     body: (serialize-sxml (base-template (sidebar-template info works)
                                                          (featured-content-template info))))))

  (define (send-work-page slug)
    (let-values (((info work works) (select-work-page-data slug)))
      (send-response status: 'ok
                     body: (serialize-sxml (base-template (sidebar-template info works)
                                                          (work-template work))))))
  (define (send-404-page)
    (send-response status: 'not-found body: *NOT-FOUND*))

  (define (route-request continue)
    (let ((path (uri-path (request-uri (current-request)))))
      (begin
        (match path
          (('/ "") (send-home-page))
          (('/ "static" filename) (send-static-file filename))
          (('/ "work" slug) (send-work-page slug))
          (_ (send-404-page)))
        (continue)))))
