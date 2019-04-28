(module gliva (route-request)
  (import (chicken base)
          (chicken irregex)
          (chicken process-context)
          config
          data
          intarweb
          matchable
          miscmacros
          multipart-form-data
          pages
          scheme
          serializers
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
           (string=? (alist-ref 'username credentials)
                     (alist-ref 'username config))
           (string=? (alist-ref 'password credentials)
                     (alist-ref 'password config)))))

  (define (call-with-authorization route-handler . route-params)
    (if (authorized-for-request?)
        (apply route-handler route-params)
        (send-response status: 'unauthorized
                       headers: `((www-authenticate . (#(basic ((realm . "gliva")))))))))

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

  (define (handle-admin-page)
    (send-response status: 'found headers: '((location . (uri-reference "/admin/info")))))

  (define (handle-admin-info-page)
    (let ((request (current-request)))
      (case (request-method request)
        ((GET) (send-response status: 'ok
                               body: (render-admin-info-page (serialize-info (select-info)))))
        ((POST) (begin
                  ; Special case: info is a singleton
                  (update-info (deserialize-info (read-multipart-form-data (current-request))) 1)
                  (send-response status: 'ok
                                 body: (render-admin-info-page (serialize-info (select-info))))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-works-page)
    (let ((request (current-request)))
      (case (request-method request)
        ((GET) (send-response status: 'ok
                               body: (render-admin-works-page (map serialize-work (select-works)))))
        ((POST) (begin
                   (insert-work (deserialize-work (read-multipart-form-data (current-request))))
                   (send-response status: 'created
                                  body: (render-admin-works-page (map serialize-work (select-works))))))
        (else (send-response status: 'method-not-allowed)))))

  (define (handle-admin-work-page id)
    (let ((request (current-request)))
      (case (request-method request)
        ((GET) (send-response status: 'ok
                               body: (render-admin-work-page (serialize-work (select-work-by-id id)))))
        ((POST) (begin
                  (update-work (deserialize-work (read-multipart-form-data (current-request))) id)
                  (send-response status: 'ok
                                 body: (render-admin-work-page (serialize-work (select-work-by-id id))))))
        ((DELETE) (begin
                    (delete-work id)
                    (send-response status: 'no-content)))
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
          (('/ "favicon.ico") (send-static-file "favicon.ico"))
          (('/ "static" filename) (send-static-file filename))
          (('/ "work" slug) (handle-work-page slug))
          (('/ "admin" tail ...) (call-with-authorization route-admin-request
                                                          tail))
          (_ (handle-404-page)))
        (continue)))))
