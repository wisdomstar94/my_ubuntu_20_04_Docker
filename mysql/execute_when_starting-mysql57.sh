#!/bin/bash

export LANG=ko_KR.UTF-8
export PATH=$PATH:/usr/local/git/bin
export PATH=$PATH:/usr/local/go/bin
# service mysql start
pushd /root
./db_init-mysql57
popd

