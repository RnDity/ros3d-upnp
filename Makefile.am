# Copyright (c) 2015 Open-RnD Sp. z o.o.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

xmldatadir = $(datadir)/ros3d-upnp

bin_PROGRAMS = ros3d-upnp

ros3d_upnp_SOURCES = \
	src/main.vala \
	src/upnpdevice.vala


ros3d_upnp_LDADD = $(ROS3D_UPNP_LIBS)
ros3d_upnp_CFLAGS = $(ROS3D_UPNP_CFLAGS) -Isrc

VALAFLAGS = $(ROS3D_UPNP_VALAFLAGS) --no-color

xmldata_DATA = \
	xml/device.xml

BUILT_SOURCES=$(ros3d_upnp_SOURCES:.vala=.c)
CLEANFILES = $(BUILT_SOURCES)

