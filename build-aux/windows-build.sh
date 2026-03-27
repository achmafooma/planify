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

# copy GStreamer and the necessary plugins (otherwise task-complete sound doesn't work and crashes)
cp -rv /ucrt64/lib/gstreamer-1.0 dist/lib/
for dll in dist/lib/gstreamer-1.0/*.dll; do
    # make sure we have all the necessary dependencies too
    ldd "$dll" | grep '/ucrt64.*\.dll' -o | xargs -i cp -vu {} dist/bin
done

# copy the libical time zone data
cp -rv /ucrt64/share/libical dist/share

# get the latest CLDR mapping of Windows time zones to standard libical/tzdata zones
# UNICODE LICENSE v3: https://github.com/unicode-org/cldr/blob/main/LICENSE
curl -o dist/share/windowsZones.xml https://raw.githubusercontent.com/unicode-org/cldr/refs/heads/main/common/supplemental/windowsZones.xml
