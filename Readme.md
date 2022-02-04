# Alternative Local Dev ENV

This sets up a Mac to be able to serve apps from a diffrent loopback device 127.0.0.2 and enables TLS on any domain given to it.

Requirements
- brew

This will setup a dev enviroment listening on a diffent addr with the following tools

A loopback alias 127.0.0.2 is added and will be enabled on boot.

PF config is used to Port forward 80 -> 8080 and 443 -> 8443 this is required, for caddy to listen on ports that dont require root.

Caddy is used as a revers proxy, and will issue TLS certs from internal acme server.

---

## Setup

- Clone repo
- Run `make`

After setup, you should add the below to your hostfile

```sh
127.0.0.2 domain.test
```

To add new domains (apps) update the conf/Caddyfile with somethgin like the below

```json
domain.test {
    bind 127.0.0.2
    respond "Hello, world!"
    tls internal
}
```

Or reverse proxy to a docker container:

```json
domain.test {
    bind 127.0.0.2
    tls internal

    reverse_proxy 127.0.0.1:8989 {
		transport http {
			keepalive 60s
		}
	}
}
```
