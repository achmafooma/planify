#!/usr/bin/env bash

# remove dist directory
rm -rf dist

# create new dist directory
mkdir -p dist/bin

# copy all dependencies (most automatic; a few have to be done manually)
ldd src/io.github.alainm23.planify.exe | grep '/ucrt64.*\.dll' -o | xargs -i cp -v {} dist/bin
ldd core/libplanify-0.dll | grep '/ucrt64.*\.dll' -o | xargs -i cp -v {} dist/bin
cp -v /ucrt64/bin/gdbus.exe dist/bin
cp -v /ucrt64/bin/libgnutls* dist/bin

# copy the built Planify executable and library
cp -v src/io.github.alainm23.planify.exe dist/bin
cp -v core/libplanify-0.dll dist/bin

# copy the necessary icon themes
mkdir -p dist/share/icons
cp -rv /ucrt64/share/icons/Adwaita dist/share/icons
cp -rv /ucrt64/share/icons/hicolor dist/share/icons
cp -rv ../data/icons/hicolor dist/share/icons

# copy the translation files
mkdir -p dist/share/locale
cp -rv po/* dist/share/locale/

# copy the necessary glib schemas
mkdir -p dist/share/glib-2.0/schemas
cp -v /ucrt64/share/glib-2.0/schemas/gschemas.compiled dist/share/glib-2.0/schemas

# copy the necessary gio module (otherwise TLS/SSL doesn't work)
mkdir -p dist/lib/gio/modules
cp -v /ucrt64/lib/gio/modules/libgioopenssl.dll dist/lib/gio/modules/
