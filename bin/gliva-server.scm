(import (chicken base)
        config
        gliva
        scheme
        spiffy)

(server-port (alist-ref 'port config))
(spiffy-user (alist-ref 'user config))
(spiffy-group (alist-ref 'group config))
(root-path (alist-ref 'static-root config))
(vhost-map `((,(alist-ref 'host config) . ,route-request)))

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
