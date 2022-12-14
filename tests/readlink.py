#!/usr/bin/env python3


import errno
import os
import sys

for f in sys.argv[1:]:
    try:
        print(f, '->', os.readlink(f))
    except OSError as err:
        if err.errno != errno.EINVAL:
            raise
        print(f, '->', f, 'not a symlink')

sys.exit(0)
