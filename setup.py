#
# Copyright (c) 2015, Open-RnD Sp. z o.o.  All rights reserved.
#
from setuptools import setup, find_packages
import os

NAME='ros3dupnp'
VERSION = '0.1'

install_requires = []
tests_require = []

ROOT = os.path.dirname(__file__)

def read(fpath):
    """Load file contents"""
    with open(os.path.join(ROOT, fpath)) as inf:
        return inf.read()


setup(
    name=NAME,
    version=VERSION,
    packages=find_packages(exclude=['tests', 'tests.*']),
    description="Ros3D UPnP",
    long_description=read("README.rst"),
    install_requires=install_requires,
    tests_require=tests_require,
    author='OpenRnD',
    author_email='ros3d@open-rnd.pl',
    license='closed',
    entry_points = {
        'console_scripts': [
            'ros3d-upnp = ros3dupnp.cmd:main'
        ]
    }
)
