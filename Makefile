CC=gcc -g 
CFLAGS :=  -Os -Wall $(shell pkg-config fuse --cflags)
CPPFLAGS := -Wall -DUSE_AUTH -D_XOPEN_SOURCE=500 -D_ISOC99_SOURCE
THR_CPPFLAGS := -DUSE_THREAD
THR_LDFLAGS := -lpthread
SSL_CPPFLAGS := -DUSE_SSL $(shell pkg-config openssl --cflags)
SSL_LDFLAGS := $(shell pkg-config openssl --libs)
LDFLAGS := $(shell pkg-config fuse --libs | sed -e s/-lrt// -e s/-ldl//)

targets = httpfs2 httpfs2.1 #httpfs2_ssl httpfs2_ssl.1

all: $(targets)

httpfs2: httpfs2.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) httpfs2.c -o httpfs2

httpfs2_ssl: httpfs2.c
	$(CC) $(CPPFLAGS) $(THR_CPPFLAGS) $(SSL_CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(THR_LDFLAGS) $(SSL_LDFLAGS) httpfs2.c -o httpfs2_ssl

httpfs2.1: httpfs2.1.txt
	a2x -f manpage  httpfs2.1.txt

httpfs2_ssl.1: httpfs2.1
	ln -sf httpfs2.1 httpfs2_ssl.1

clean:
	rm -f $(targets) httpfs.1.xml
