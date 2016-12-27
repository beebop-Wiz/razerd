install:
	install -m 755 razerd /usr/local/bin/

copy-config:
	cp -rv example-config ~/.razerd/
