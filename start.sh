#!/bin/bash

apachectl stop
service nagios start
apachectl -D FOREGROUND

