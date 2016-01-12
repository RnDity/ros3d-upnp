Ros3D Rig Controller UPnP
=========================

Universal Plug and Play support for Ros3D KR component. The purpose of
this component is mainly to provide support for discovery in Microsoft
Windows based environments. Once `ros3d-upnp` is started, the device
will announce its presence and should become visible when browsing
network environment with the usual Microsoft Windows tools.

The bulk of configuration is done via device XML file.

It is assumed that the device XML will configure a `presentationURL`
that will be accessed by user after a connection attempt to the device
(ex. double clicking under Microsoft Windows explorer). Once a HTTP
request is done to the `presentationURL` the browser will be
automatically redirected to configured URL.

Usage
-----

Running::

  ros3d-upnp -x <path-to-device-xml> -t <redirection URL>

Assuming that the device XML is in ros3d-upnp's `$(datadir)` and there
is a WebUI provided on port 80, the service can be started as follows::

  ros3d-upnp -x /usr/share/ros3d-upnp/device.xml -t http://0.0.0.0 -d
