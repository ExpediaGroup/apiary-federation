#!/bin/bash

if [ ! -e /usr/bin/ansible ]; then
    yum -y --enablerepo=epel install ansible
fi

