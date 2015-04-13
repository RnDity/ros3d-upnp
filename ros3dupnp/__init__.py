#
# Copyright (c) 2015, Open-RnD Sp. z o.o.  All rights reserved.
#
import logging
import urlparse
import xml.etree.ElementTree as xmlet
from gi.repository import GUPnP, Soup
import os.path

_log = logging.getLogger(__name__)


class UPnPDevice(object):

    def __init__(self, device_xml_path, target):

        _log.debug('parse redirect target address')
        self.target = urlparse.urlparse(target)

        _log.debug('create context...')
        self.ctx = GUPnP.Context.new(None, None, 0)


        dirname = os.path.dirname(device_xml_path)
        filename = os.path.basename(device_xml_path)

        _log.debug('load device from %s', device_xml_path)

        self.dev = GUPnP.RootDevice.new(self.ctx, filename, dirname)

        presentation_url = UPnPDevice._find_presentation_url(device_xml_path)
        _log.debug('presentation URI: %s', presentation_url)

        # add handler for presentation URL
        self.ctx.get_server().add_handler(presentation_url,
                                          self._handle_presentation, None)
        # advertise the device
        self.dev.set_available(True)

        _log.debug('location address http://%s:%d',
                   self.ctx.props.host_ip, self.ctx.props.port)

    def _handle_presentation(self, server, message, path, query, client, user_param):
        """Callback handler to presentation"""

        _log.debug('handle URI: %s', path)
        _log.debug('address: %s', message.get_address().get_name())

        # redirect target may be <host>:<port>
        _log.debug('redirect to: %s', self.target)
        hosttuple = self.target[1].split(':')

        if hosttuple[0] == '0.0.0.0':
            address = message.get_address().get_name()
        else:
            address = self.target[1]
        # if port was passed, add it to address
        if len(hosttuple) > 1:
            address += ':' + hosttuple[1]

        redirect_url = '{scheme}://{address}{path}'.format(scheme=self.target[0],
                                                            address=address,
                                                            path=self.target[2])
        _log.debug('redirect to %s', redirect_url)
        message.set_redirect(Soup.Status.FOUND, redirect_url)

    @classmethod
    def _find_presentation_url(cls, device_xml):
        """Find a presentation URL inside device xml file """
        root = xmlet.parse(device_xml).getroot()

        # setup upnp device namespace handling
        ns = {'ud': 'urn:schemas-upnp-org:device-1-0'}

        url = root.find('ud:device/ud:presentationURL', ns).text
        _log.debug('%s config URL: %s', device_xml, url)

        return url

