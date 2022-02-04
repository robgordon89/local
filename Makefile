ifplist := /Library/LaunchDaemons/ruled.io.ifconfig.plist
init := $(HOME)/.localdev
BREW_PREFIX := $(shell brew --prefix)

#.SILENT: all
.PHONY: all
all: $(init) caddyfile trust $(ifplist) restart

$(init):
	echo "Setting up loopback for 127.0.0.2"
	sudo ifconfig lo0 alias 127.0.0.2
	echo "Setting up pf rules for 127.0.0.2:80 -> 8080 127.0.0.2:443 -> 8443 "
	cat conf/pfrules.conf | sudo pfctl -a 'com.apple/localdev' -f -
	echo "Reloading PF"
	-sudo pfctl -F all -ef /etc/pf.conf
	echo "Installing Brew Packages"
	brew install caddy nss
	touch $(init)

caddyfile:
	echo "Setting Up Custom Caddyfile"
	sudo conf/Caddyfile $(BREW_PREFIX)/etc/Caddyfile

$(ifplist):
	echo "Setting up persistant loopback for 127.0.0.2"
	sudo cp conf/ifconfig.plist $(ifplist)

logs:
	tail -f $(BREW_PREFIX)/var/log/caddy.log

trust:
	echo "Setting Up Caddy TLS Trust"
	caddy trust

restart:
	brew services restart caddy

stop:
	brew services stop caddy

clean: stop
	-sudo ifconfig lo0 -alias 127.0.0.2
	-caddy untrust
	-brew uninstall caddy nss
	-sudo rm -rf $(ifplist)
	-rm -rf $(init)
	-rm -rf $(BREW_PREFIX)/etc/Caddyfile
	-echo "" | sudo pfctl -a 'com.apple/localdev' -f -
	-sudo pfctl -F all -ef /etc/pf.conf
