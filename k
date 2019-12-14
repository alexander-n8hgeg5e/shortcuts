#!/usr/bin/python3

from subprocess import call
from os import environ

env=dict(environ)
env.update({'PULSE_SERVER': 'unix:/tmp/pulseaudio@tmrl' })

call(['sudo','-u', 'kodi','kodi'],env=env)
