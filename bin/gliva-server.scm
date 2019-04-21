; FIXME wat
(include "gliva")
(import gliva scheme spiffy)

(server-port 80)
(spiffy-user "nobody")
(spiffy-group "nobody")

(vhost-map `(("localhost" . ,route-request)))

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
