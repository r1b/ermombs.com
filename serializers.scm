(module serializers (deserialize-info deserialize-work serialize-info serialize-work)
  (import (chicken base)
          (chicken io)
          (chicken port)
          (chicken string)
          multipart-form-data
          scheme
          spiffy
          sql-null
          srfi-1
          srfi-13)

  ; TODO: These should be like the query helpers and iterate over known fields

  ; --------------------------------------------------------------------------

  (define (rename-file-key key)
    (string->symbol (string-append (symbol->string key) "_filename")))

  (define (save-multipart-file multipart-file basename)
    (let ((filename (string-append basename
                                   "."
                                   (last (string-split (multipart-file-filename multipart-file)
                                                       ".")))))
      (begin
        (with-output-to-file (string-append (root-path) "/" filename)
                             (lambda ()
                               ; FIXME: This is slow for large files.
                               (write-string (read-string #f (multipart-file-port multipart-file))
                                             #f
                                             (current-output-port))))
        filename)))

  (define (handle-file-field field basename)
    (if (multipart-file? (cdr field))
        (cons (rename-file-key (car field))
              (save-multipart-file (cdr field) basename))
        #f))

  ; --------------------------------------------------------------------------

  (define (deserialize-info info)
    (filter-map (lambda (field)
                  (case (car field)
                    ((cv featured_image) (handle-file-field field (symbol->string (car field))))
                    (else field)))
                info))

  (define (serialize-info info)
    (filter-map (lambda (field)
                  (case (car field)
                    ((rowid) (cons 'rowid (number->string (cdr field))))
                    (else field)))
                info))

  ; --------------------------------------------------------------------------

  (define (deserialize-work work)
    (filter-map (lambda (field)
                  (case (car field)
                    ((image) (handle-file-field field (alist-ref 'slug work)))
                    ((year) (cons 'year (string->number (cdr field))))
                    ((series) (if (eof-object? (cdr field)) (cons 'series (sql-null)) field))
                    (else field)))
                work))

  (define (serialize-work work)
    (filter-map (lambda (field)
                  (case (car field)
                    ((rowid) (cons 'rowid (number->string (cdr field))))
                    ((year) (cons 'year (number->string (cdr field))))
                    ((series) (if (sql-null? (cdr field)) (cons 'series "") field))
                    (else field)))
                work)))
