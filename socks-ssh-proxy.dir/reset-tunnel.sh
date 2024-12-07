#!/bin/bash

pkill -9 ssh
ssh -D8080 -fCqN root@88.99.21.177 -p 3306

pkill -9 stunnel
stunnel /Users/Shared/config.dir/stunnel.conf
