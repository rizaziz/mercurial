  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'strip =' >> $HGRCPATH

  $ cat >findbranch.py <<EOF
  > import re
  > import sys
  > 
  > head_re = re.compile(r'^#(?:(?:\\s+([A-Za-z][A-Za-z0-9_]*)(?:\\s.*)?)|(?:\\s*))$')
  > 
  > for line in sys.stdin:
  >     hmatch = head_re.match(line)
  >     if not hmatch:
  >         sys.exit(1)
  >     if hmatch.group(1) == 'Branch':
  >         sys.exit(0)
  > sys.exit(1)
  > EOF

  $ hg init a
  $ cd a
  $ echo "Rev 1" >rev
  $ hg add rev
  $ hg commit -m "No branch."
  $ hg branch abranch
  marked working directory as branch abranch
  (branches are permanent and global, did you want a bookmark?)
  $ echo "Rev  2" >rev
  $ hg commit -m "With branch."

  $ hg export 0 > ../r0.patch
  $ hg export 1 > ../r1.patch
  $ cd ..

  $ if "$PYTHON" findbranch.py < r0.patch; then
  >     echo "Export of default branch revision has Branch header" 1>&2
  >     exit 1
  > fi

  $ if "$PYTHON" findbranch.py < r1.patch; then
  >     :  # Do nothing
  > else
  >     echo "Export of branch revision is missing Branch header" 1>&2
  >     exit 1
  > fi

Make sure import still works with branch information in patches.

  $ hg init b
  $ cd b
  $ hg import ../r0.patch
  applying ../r0.patch
  $ hg import ../r1.patch
  applying ../r1.patch
  $ cd ..

  $ hg init c
  $ cd c
  $ hg import --exact --no-commit ../r0.patch
  applying ../r0.patch
  warning: can't check exact import with --no-commit
  $ hg st
  A rev
  $ hg revert -a
  forgetting rev
  $ rm rev
  $ hg import --exact ../r0.patch
  applying ../r0.patch
  $ hg import --exact ../r1.patch
  applying ../r1.patch

Test --exact and patch header separators (issue3356)

  $ hg strip --no-backup .
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  >>> import re
  >>> p = open('../r1.patch', 'rb').read()
  >>> p = re.sub(br'Parent\s+', b'Parent ', p)
  >>> open('../r1-ws.patch', 'wb').write(p) and None
  $ hg import --exact ../r1-ws.patch
  applying ../r1-ws.patch

  $ cd ..
