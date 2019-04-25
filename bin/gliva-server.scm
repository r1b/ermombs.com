(import (chicken base)
        (chicken file posix)
        (chicken process-context)
        gliva
        scheme
        spiffy)

(server-port 80)
(spiffy-user "nobody")
(spiffy-group "nobody")

; FIXME pull from environment
(root-path "/Users/rcj/scheme/mattgliva.com/static")

(vhost-map `(("localhost" . ,route-request)))

(unless (and (get-environment-variable "GLIVA_USERNAME")
             (get-environment-variable "GLIVA_PASSWORD"))
  (begin
    (display "`GLIVA_USERNAME` and `GLIVA_PASSWORD` are not defined.\n"
             (open-output-file* 2))
    (exit 1)))

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
