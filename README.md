> **Warning**
> This is work in progress so most of the steps are manual and/or are incomplete.

# RuralPipe Image Builder
This project contains the necessary scripts and automation to build a bootable RuralPipe image for Raspberry Pi 4

# Building the cross-compiler toolchain
This project uses [crosstool-ng](https://crosstool-ng.github.io/) as the means of building the cross-compiler toolchain. Due to the fact that RasPiOS (Raspberry Pi OS) is still on [libc 2.31](https://sourceware.org/git/glibc.git), the compiler needs to stay on GCC 10 since as of the time of this writing, later GCC versions fail to compile older libc versions.

Follow the instructions [here](ct-ng-cross-compiler-rpi4/README.md).

# Installing/compiling prerequisites
The RuralPipe Image uses newer versions of Python, DBus and ModemManager than what natively comes with RasPiOS. Because of this, these utilities need to be cross-compiled first. These utilities in turn depend on libraries, which are also quite old on RasPiOS, so these need to be compiled from source as well.

In addition, the PyMM module uses functionality (such as the `case` statement) which is only present in Python 3.10 and later. These are not readily available on RasPiOS, so they need to be compiled from source as well.

In order to start the cross-compilation environment locally, use the following script which will start a sub-shell with the appropriate environment variables configured.
```
./x-compile-env.sh armv8-rpi4-linux-gnueabihf
```

## OPENSSL 3
Openssl-3 is a prerequisite for the Python `_ssl` module.
```
git clone --depth 1 --branch openssl-3.0.7 --single-branch https://github.com/openssl/openssl.git
```

### Local compile
```
./Configure --prefix=/opt/openssl3 --openssldir=/opt/openssl3 -Wl,-rpath=/opt/openssl3/lib -Wl,--enable-new-dtags

make -j9
make install
```

### Cross-compile
```
./Configure linux-generic32 \
  --prefix=/usr/local --openssldir=/usr/local -Wl,-rpath=/usr/local/lib -Wl,--enable-new-dtags

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## ZLIB
zLib is a prerequisite for the Python `_zlib` module.

## Compile from source
```
git clone --depth 1 --branch v1.2.13 --single-branch https://github.com/madler/zlib.git
```

### Local compile
```
NOT NECESSARY
```

### Cross-compile
```
CHOST=arm ./configure --prefix=/usr/local

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## LIBFFI
Libffi is a prerequisite for Python's `_ctypes` module.
```
git clone --depth 1 --branch v3.4.4 --single-branch https://github.com/libffi/libffi.git
```

### Local compile
```
NOT NECESSARY
```

### Cross-compile
```
./autogen.sh
./configure --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## LIBUUID
Libuuid is a prerequisite for Python's `_uuid` module.
```
git clone --depth 1 --branch stable/v2.38 --single-branch https://github.com/util-linux/util-linux.git
sudo apt install autopoint gettext pkg-config
```

### Local compile
```
NOT NECESSARY
```

### Cross-compile
```
./autogen.sh
./configure --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf --disable-all-programs --enable-libuuid

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## LIBNCURSES
Libncurses is a prerequisite for Python's `curses` module.
```
git clone --depth 1 --branch v6.3 --single-branch https://github.com/mirror/ncurses.git
```

### Local compile
```
NOT NECESSARY
```

### Cross-compile
```
./configure --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## LIBEXPAT
Libexpat is a prerequisite for DBus
```
git clone --depth 1 --branch R_2_5_0 --single-branch https://github.com/libexpat/libexpat.git
```

### Local compile
```
NOT NECESSARY
```

### Cross-compile
```
cd expat
./buildconf.sh
./configure --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## PYTHON 3.11
Some of the RuralPipe's modules use functionality from a later Python so we build version 3.11.
```
git clone --depth 1 --branch v3.11.0 --single-branch https://github.com/python/cpython.git
```

### Local compile
```
./configure --prefix=/opt/python/3.11.0/ --with-openssl=/opt/openssl3 --with-openssl-rpath=auto \
   --enable-optimizations --with-computed-gotos

make -j9
sudo make install
```

### Cross-compile
```
echo ac_cv_file__dev_ptc=no >> config.site
echo ac_cv_file__dev_ptmx=no >> config.site

env \
  CONFIG_SITE=config.site \
  CC="$CC -I$X_COMPILE_STAGING_PREFIX/usr/local/include -I$X_COMPILE_STAGING_PREFIX/usr/local/include/ncurses -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
  CXX="$CXX -I$X_COMPILE_STAGING_PREFIX/usr/local/include -I$X_COMPILE_STAGING_PREFIX/usr/local/include/ncurses -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
  LD="$LD -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
./configure -C --with-openssl=$HOME/workspace/rpi/install/usr/local --with-openssl-rpath=/usr/local/lib \
  --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf --build=aarch64-unknown-linux-gnu \
  --with-build-python=/opt/python/3.11.0/bin/python3.11 \
  --enable-optimizations --with-computed-gotos --disable-ipv6

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## DBUS
The dbus library is a prerequisite for the ModemManager service.
```
git clone --depth 1 --branch dbus-1.14.4 --single-branch https://gitlab.freedesktop.org/dbus/dbus.git
```

### Local compile
```
TODO
```

### Cross-compile
```
env \
  CC="$CC -I$X_COMPILE_STAGING_PREFIX/usr/local/include -I$X_COMPILE_STAGING_PREFIX/usr/local/include/ncurses -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
  CXX="$CXX -I$X_COMPILE_STAGING_PREFIX/usr/local/include -I$X_COMPILE_STAGING_PREFIX/usr/local/include/ncurses -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
  LD="$LD -L$X_COMPILE_STAGING_PREFIX/usr/local/lib" \
./autogen.sh --prefix=/usr/local --host=armv7l-unknown-linux-gnueabihf \
  --disable-Werror \
  --with-system-socket=/run/dbus/system_bus_socket \
  --with-session-socket-dir=/var/run/dbus/system_bus_socket

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## GLIBC (Optional)
```
git clone --depth 1 --branch release/2.36/master --single-branch https://sourceware.org/git/glibc.git
```

### Local compile
```
TODO
```

### Cross-compile
```
CHOST=arm ../configure --prefix=/usr/local --host=arm-linux-gnueabihf --disable-sanity-checks

make -j9
make install DESTDIR=$X_COMPILE_STAGING_PREFIX
```

## Tar the whole /usr directory
```
pushd $X_COMPILE_STAGING_PREFIX
tar -zcf usr.tar.gz usr
popd
```
