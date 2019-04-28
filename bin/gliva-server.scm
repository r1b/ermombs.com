(import (chicken base)
        config
        gliva
        scheme
        spiffy)

(access-log (alist-ref 'access-log config))
(error-log (alist-ref 'error-log config))
(server-bind-address (alist-ref 'host config))
(server-port (alist-ref 'port config))
(spiffy-user (alist-ref 'user config))
(spiffy-group (alist-ref 'group config))
(root-path (alist-ref 'static-root config))
(vhost-map `((".*" . ,route-request)))
(trusted-proxies '("127.0.0.1"))

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
