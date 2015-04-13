#
# Copyright (c) 2015, Open-RnD Sp. z o.o.  All rights reserved.
#
from __future__ import absolute_import
import logging
import argparse
from gi.repository import GLib

from ros3dupnp import UPnPDevice

def parse_arguments():
    parser = argparse.ArgumentParser(description='Ros3D UPnP')
    parser.add_argument('-d', '--debug', action='store_true',
                        default=False,
                        help='Enable debug logging')
    parser.add_argument('-t', '--redirect-target',
                        help='Presentation URL HTTP redirect target. ' \
                        'Special host 0.0.0.0 indicates that the current request\'s' \
                        ' Location IP address is to be reused',
                        required=True)
    parser.add_argument('-x', '--device-xml',
                        required=True,
                        help='Path to device XML file')
    return parser.parse_args()

def main():
    opts = parse_arguments()

    level = logging.INFO
    if opts.debug:
        level = logging.DEBUG

    logging.basicConfig(level=level)

    loop = GLib.MainLoop()

    dev = UPnPDevice(opts.device_xml, opts.redirect_target)

    loop.run()


