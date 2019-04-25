(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          (chicken port)
          (chicken process-context)
          data
          intarweb
          matchable
          miscmacros
          multipart-form-data
          pages
          scheme
          spiffy
          srfi-1
          srfi-13
          uri-common
          utf8)

  ; --------------------------------------------------------------------------

  (define (authorized-for-request?)
    (let* ((headers (request-headers (current-request)))
           (authorization-method (header-value 'authorization headers))
           (credentials (header-params 'authorization headers)))
      (and (eqv? authorization-method 'basic)
           (string=? (cdr (assoc 'username credentials))
                     (get-environment-variable "GLIVA_USERNAME"))
           (string=? (cdr (assoc 'password credentials))
                     (get-environment-variable "GLIVA_PASSWORD")))))

  (define (call-with-authorization route-handler . route-params)
    (if (authorized-for-request?)
        (apply route-handler route-params)
        (send-response status: 'unauthorized
                       headers: `((www-authenticate . (#(basic ((realm . "gliva")))))))))

  ; --------------------------------------------------------------------------

  (define (save-multipart-file multipart-file)
    ; FIXME: so many things wrong with this
    (let ((filename (multipart-file-filename multipart-file)))
      (begin
        (with-output-to-file (string-join (root-path) "/" filename)
                             (lambda ()
                               (copy-port (multipart-file-port multipart-file)
                                          (current-output-port))))
        #f)))

  (define (handle-multipart-form-data)
    (let ((form-data (read-multipart-form-data (current-request))))
      (filter-map (lambda (form-input)
                    (if (multipart-file? (cdr form-input))
                        (save-multipart-file (cdr form-input))
                        form-input))
                  form-data)))

  ; --------------------------------------------------------------------------

  (define (handle-home-page)
    (send-response status: 'ok
                   body: (render-home-page (select-info) (select-works))))

  (define (handle-work-page slug)
    (send-response status: 'ok
                   body: (render-work-page (select-info)
                                           (select-work slug)
                                           (select-works))))

  ; --------------------------------------------------------------------------

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
                  (update-info (handle-multipart-form-data) 1)
                  (send-response status: 'ok
                                 body: (render-admin-info-page (select-info)))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-works-page)
    (let ((request (current-request)))
      (case (request-method request)
        ('(get) (send-response status: 'ok
                               body: (render-admin-works-page (select-works))))
        ('(post) (begin
                   (insert-work (handle-multipart-form-data))
                   (send-response status: 'ok
                                  body: (render-admin-works-page (select-works)))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-work-page id)
    (let ((request (current-request)))
      (case (request-method request)
        ('(get) (send-response status: 'ok
                               body: (render-admin-work-page (select-work id))))
        ('(post) (begin
                  (update-work (handle-multipart-form-data) id)
                  (send-response status: 'ok
                                 body: (render-admin-work-page (select-work id)))))
        (else (send-response status: 'method-not-allowed)))))

  ; --------------------------------------------------------------------------

  (define (handle-404-page)
    (send-response status: 'not-found body: "Life is complicated. Or is it?"))

  ; --------------------------------------------------------------------------

  (define (route-admin-request admin-path)
    (match admin-path
      (() (handle-admin-page))
      (("info") (handle-admin-info-page))
      (("works") (handle-admin-works-page))
      (("work" id) (handle-admin-work-page id))
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
          (('/ "admin" tail ...) (call-with-authorization route-admin-request
                                                          tail))
          (_ (handle-404-page)))
        (continue)))))
