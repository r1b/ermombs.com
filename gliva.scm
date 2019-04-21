(include "data")

(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          data
          intarweb
          scheme
          spiffy
          sxml-serializer
          templates
          utf8)

  (define-constant *NOT-FOUND* "Ask and it will be given to you; seek and you will find; knock and the door will be opened to you.\n\n- Gliva 7:7")

  (define (send-home-page)
    (let-values (((info works) (select-home-page-data)))
      (send-response status: 'ok
                     body: (serialize-sxml (base-template (sidebar-template info works)
                                                          (featured-content-template info))))))

  (define (send-work-page work-slug)
    (let-values (((info work works) (select-work-page-data)))
      (send-response status: 'ok
                     body: (serialize-sxml (base-template (sidebar-template info works)
                                                          (work-template info work))))))
  (define (send-404-page)
    (send-response status: 'not-found body: *NOT-FOUND*))

  (define (route-request continue)
    (let ((path (uri-path (request-uri (current-request)))))
      (begin
        (cond
          ((irregex-match? '(bos "/" eos) path) (send-home-page))
          ((irregex-match '(bos "/static/" (=> filename (+ nonl)) eos) path)
           => (lambda (match-object) (send-static-file (irregex-match-subchunk match-object
                                                                               "filename"))))
          ((irregex-match '(bos "/work/" (=> slug (+ nonl)) eos) path)
           => (lambda (match-object) (send-work-page (irregex-match-subchunk match-object
                                                                             "slug"))))
          (else (send-404-page)))
        (continue))))
