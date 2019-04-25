(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          (chicken process-context)
          data
          intarweb
          matchable
          multipart-form-data
          pages
          scheme
          spiffy
          uri-common
          utf8)

  (define (authorized-for-request?)
    (let ((authorization (header-value 'authorization (request-headers (current-request)))))
      (and (vector? authorization)
           (eqv? (vector-ref authorization 0) 'basic)
           (string=? (cdr (assoc 'username (vector-ref authorization 1)))
                     (get-environment-variable "GLIVA_USERNAME"))
           (string=? (cdr (assoc 'password (vector-ref authorization 1)))
                     (get-environment-variable "GLIVA_PASSWORD")))))

  (define (call-with-authorization route-handler . route-params)
    (if (authorized-for-request?)
        (apply route-handler route-params)
        (send-response status: 'unauthorized
                       headers: `((www-authenticate . (#(basic ((realm . "gliva")))))))))

  (define (handle-home-page)
    (send-response status: 'ok
                   body: (render-home-page (select-info) (select-works))))

  (define (handle-work-page slug)
    (send-response status: 'ok
                   body: (render-work-page (select-info) (select-work slug) (select-works))))

  ; TODO edge cases for all admin pages!

  (define (handle-admin-page)
    (send-response status: 'ok body: (render-admin-page)))

  (define (handle-admin-info-page)
    (let ((request (current-request)))
      (case (request-method request)
        ('(get) (send-response status: 'ok
                               body: (render-admin-info-page (select-info))))
        ('(post) (begin
                  ; Special case: info is a singleton
                  (update-info (read-urlencoded-request-data request) 1)
                  (send-response status: 'ok
                                 body: (render-admin-info-page (select-info)))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-works-page)
    (let ((request (current-request)))
      (case (request-method request)
        ('(get) (send-response status: 'ok
                               body: (render-admin-works-page (select-works))))
        ('(post) (begin
                   (insert-work (read-urlencoded-request-data request))
                   (send-response status: 'ok
                                  body: (render-admin-works-page (select-works)))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-work-page id)
    (let ((request (current-request)))
      (case (request-method request)
        ('(get) (send-response status: 'ok
                               body: (render-admin-work-page (select-work id))))
        ('(post) (begin
                  (update-work (read-urlencoded-request-data request) id)
                  (send-response status: 'ok
                                 body: (render-admin-work-page (select-work id)))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-upload-file)
    (let ((file (read-multipart-form-data (current-request))))
      (begin
        (with-output-to-file (multipart-file-filename file)  ; FIXME: so wrong
                             (lambda ()
                               (copy-port (multipart-file-port file)
                                          (current-output-port))))
        (send-response status: 'ok))))

  (define (handle-404-page)
    (send-response status: 'not-found body: "Life is complicated. Or is it?"))

  (define (route-admin-request admin-path)
    (match admin-path
      (() (handle-admin-page))
      (("info") (handle-admin-info-page))
      (("works") (handle-admin-works-page))
      (("work" id) (handle-admin-work-page id))
      (("upload") (handle-upload-file))
      (_ (handle-404-page))))

  (define (route-request continue)
    (let ((path (uri-path (request-uri (current-request)))))
      (begin
        (match path
          (('/ "") (handle-home-page))
          ; FIXME: serve static files w / nginx
          (('/ "favicon.ico") (send-static-file "favicon.ico"))
          (('/ "static" filename) (send-static-file filename))
          (('/ "work" slug) (handle-work-page slug))
          (('/ "admin" tail ...) (call-with-authorization route-admin-request tail))
          (_ (handle-404-page)))
        (continue)))))
