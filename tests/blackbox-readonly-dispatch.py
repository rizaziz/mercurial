import os
from mercurial import (
    dispatch,
    extensions,
    ui as uimod,
)


def testdispatch(cmd):
    """Simple wrapper around dispatch.dispatch()

    Prints command and result value, but does not handle quoting.
    """
    ui = uimod.ui.load()
    extensions.populateui(ui)
    ui.statusnoi18n(b"running: %s\n" % cmd)
    req = dispatch.request(cmd.split(), ui)
    result = dispatch.dispatch(req)
    ui.statusnoi18n(b"result: %r\n" % result)


# create file 'foo', add and commit
f = open(b'foo', 'wb')
f.write(b'foo\n')
f.close()
testdispatch(b"--debug add foo")
testdispatch(b"--debug commit -m commit1 -d 2000-01-01 foo")

# append to file 'foo' and commit
f = open(b'foo', 'ab')
f.write(b'bar\n')
f.close()
# remove blackbox.log directory (proxy for readonly log file)
os.rmdir(b".hg/blackbox.log")
# replace it with the real blackbox.log file
os.rename(b".hg/blackbox.log-", b".hg/blackbox.log")
testdispatch(b"--debug commit -m commit2 -d 2000-01-02 foo")

# check 88803a69b24 (fancyopts modified command table)
testdispatch(b"--debug log -r 0")
testdispatch(b"--debug log -r tip")
