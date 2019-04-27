(import (chicken base)
        config
        gliva
        scheme
        spiffy)

(server-port (cdr (assoc 'port config)))
(spiffy-user (cdr (assoc 'user config)))
(spiffy-group (cdr (assoc 'group config)))
(root-path (cdr (assoc 'static-root config)))
(vhost-map `((,(cdr (assoc 'host config)) . ,route-request)))

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
