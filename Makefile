CC=gcc -g 
CFLAGS :=  -Os -Wall $(shell pkg-config fuse --cflags)
CPPFLAGS := -Wall -DUSE_AUTH -D_XOPEN_SOURCE=500 -D_ISOC99_SOURCE
THR_CPPFLAGS := -DUSE_THREAD
THR_LDFLAGS := -lpthread
SSL_CPPFLAGS := -DUSE_SSL $(shell pkg-config openssl --cflags)
SSL_LDFLAGS := $(shell pkg-config openssl --libs)
LDFLAGS := $(shell pkg-config fuse --libs | sed -e s/-lrt// -e s/-ldl//)

intermediates =

binaries = httpfs2 #httpfs2_ssl

manpages = $(addsuffix .1,$(binaries))

intermediates += $(addsuffix .xml,$(manpages))

targets = $(binaries) $(manpages)

all: $(targets)

httpfs2: httpfs2.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) httpfs2.c -o httpfs2

httpfs2_ssl: httpfs2.c
	$(CC) $(CPPFLAGS) $(THR_CPPFLAGS) $(SSL_CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(THR_LDFLAGS) $(SSL_LDFLAGS) httpfs2.c -o httpfs2_ssl

httpfs2_ssl.1: httpfs2.1
	ln -sf httpfs2.1 httpfs2_ssl.1

clean:
	rm -f $(targets) $(intermediates)

%.1: %.1.txt
	a2x -f manpage $<

# Rules to automatically make a Debian package

package = $(shell parsechangelog | grep ^Source: | sed -e s,'^Source: ',,)
version = $(shell parsechangelog | grep ^Version: | sed -e s,'^Version: ',, -e 's,-.*,,')
revision = $(shell parsechangelog | grep ^Version: | sed -e -e 's,.*-,,')
architecture = $(shell dpkg --print-architecture)
tar_dir = $(package)-$(version)
tar_gz   = $(tar_dir).tar.gz
pkg_deb_dir = pkgdeb
unpack_dir  = $(pkg_deb_dir)/$(tar_dir)
orig_tar_gz = $(pkg_deb_dir)/$(package)_$(version).orig.tar.gz
pkg_deb_src = $(pkg_deb_dir)/$(package)_$(version)-$(revision)_source.changes
pkg_deb_bin = $(pkg_deb_dir)/$(package)_$(version)-$(revision)_$(architecture).changes

deb_pkg_key = CB8C5858

debclean:
	rm -rf $(pkg_deb_dir)

deb: debsrc debbin

debbin: $(unpack_dir)
	cd $(unpack_dir) && dpkg-buildpackage -b -k$(deb_pkg_key)

debsrc: $(unpack_dir)
	cd $(unpack_dir) && dpkg-buildpackage -S -k$(deb_pkg_key)

$(unpack_dir): $(orig_tar_gz)
	tar -zxf $(orig_tar_gz) -C $(pkg_deb_dir)

$(pkg_deb_dir):
	mkdir $(pkg_deb_dir)

$(pkg_deb_dir)/$(tar_gz): $(pkg_deb_dir)
	hg archive -t tgz $(pkg_deb_dir)/$(tar_gz)

$(orig_tar_gz): $(pkg_deb_dir)/$(tar_gz)
	ln -s $(tar_gz) $(orig_tar_gz)

