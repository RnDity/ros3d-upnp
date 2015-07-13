bin_PROGRAMS = ros3d-upnp

ros3d_upnp_SOURCES = \
	src/main.vala \
	src/upnpdevice.vala


ros3d_upnp_LDADD = $(ROS3D_UPNP_LIBS)
ros3d_upnp_CFLAGS = $(ROS3D_UPNP_CFLAGS) -Isrc

VALAFLAGS = $(ROS3D_UPNP_VALAFLAGS) --no-color

BUILT_SOURCES=$(ros3d_upnp_SOURCES:.vala=.c)
CLEANFILES = $(BUILT_SOURCES)

