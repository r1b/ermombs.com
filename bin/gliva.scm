(import spiffy)

(server-port 80)
(spiffy-user "nobody")
(spiffy-group "nobody")

(include "router")

(start-server)

(switch-user/group (spiffy-user) (spiffy-group))
