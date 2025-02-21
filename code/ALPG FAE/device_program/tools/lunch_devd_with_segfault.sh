#!/bin/bash

export LD_PRELOAD=/lib/i386-linux-gnu/libSegFault.so
export SEGFAULT_SIGNALS=all

/opt/itcconv/bin/devd -d
