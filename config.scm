(module config (config)
  (import (chicken base)
          (chicken file posix)
          (chicken format)
          (chicken process-context)
          scheme)

  (define (ensure-config-value env-var #!optional (deserialize identity))
    (let ((value (get-environment-variable env-var)))
      (if value
          (deserialize value)
          (begin
            (fprintf (open-output-file* 2)
                       "`~A` unset\n"
                       env-var)
            (exit 1)))))

  (define config `((group . ,(ensure-config-value "GLIVA_GROUP"))
                   (host . ,(ensure-config-value "GLIVA_HOST"))
                   (password . ,(ensure-config-value "GLIVA_PASSWORD"))
                   (port . ,(ensure-config-value "GLIVA_PORT" string->number))
                   (static-root . ,(ensure-config-value "GLIVA_STATIC_ROOT"))
                   (user . ,(ensure-config-value "GLIVA_USER"))
                   (username . ,(ensure-config-value "GLIVA_USERNAME")))))
