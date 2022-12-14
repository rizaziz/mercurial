
Issue835: qpush fails immediately when patching a missing file, but
remaining added files are still created empty which will trick a
future qrefresh.

  $ cat > writelines.py <<EOF
  > import sys
  > encode = lambda x: x.encode('utf-8').decode('unicode_escape').encode('utf-8')
  > path = sys.argv[1]
  > args = sys.argv[2:]
  > assert (len(args) % 2) == 0
  > 
  > f = open(path, 'wb')
  > for i in range(len(args) // 2):
  >    count, s = args[2 * i:2 * i + 2]
  >    count = int(count)
  >    s = encode(s)
  >    f.write(s * count)
  > f.close()
  > EOF

  $ echo "[extensions]" >> $HGRCPATH
  $ echo "mq=" >> $HGRCPATH

  $ hg init normal
  $ cd normal
  $ "$PYTHON" ../writelines.py b 10 'a\n'
  $ hg ci -Am addb
  adding b
  $ echo a > a
  $ "$PYTHON" ../writelines.py b 2 'b\n' 10 'a\n' 2 'c\n'
  $ echo c > c
  $ hg add a c
  $ hg qnew -f changeb
  $ hg qpop
  popping changeb
  patch queue now empty
  $ hg rm b
  $ hg ci -Am rmb

Push patch with missing target:

  $ hg qpush
  applying changeb
  unable to find 'b' for patching
  (use '--prefix' to apply patch relative to the current directory)
  2 out of 2 hunks FAILED -- saving rejects to file b.rej
  patch failed, unable to continue (try -v)
  patch failed, rejects left in working directory
  errors during apply, please fix and qrefresh changeb
  [2]

Display added files:

  $ cat a
  a
  $ cat c
  c

Display rejections:

  $ cat b.rej
  --- b
  +++ b
  @@ -1,3 +1,5 @@
  +b
  +b
   a
   a
   a
  @@ -8,3 +10,5 @@
   a
   a
   a
  +c
  +c

Test missing renamed file

  $ hg qpop
  popping changeb
  patch queue now empty
  $ hg up -qC 0
  $ echo a > a
  $ hg mv b bb
  $ "$PYTHON" ../writelines.py bb 2 'b\n' 10 'a\n' 2 'c\n'
  $ echo c > c
  $ hg add a c
  $ hg qnew changebb
  $ hg qpop
  popping changebb
  patch queue now empty
  $ hg up -qC 1
  $ hg qpush
  applying changebb
  patching file bb
  Hunk #1 FAILED at 0
  Hunk #2 FAILED at 7
  2 out of 2 hunks FAILED -- saving rejects to file bb.rej
  b not tracked!
  patch failed, unable to continue (try -v)
  patch failed, rejects left in working directory
  errors during apply, please fix and qrefresh changebb
  [2]
  $ cat a
  a
  $ cat c
  c
  $ cat bb.rej
  --- bb
  +++ bb
  @@ -1,3 +1,5 @@
  +b
  +b
   a
   a
   a
  @@ -8,3 +10,5 @@
   a
   a
   a
  +c
  +c

  $ cd ..


  $ echo "[diff]" >> $HGRCPATH
  $ echo "git=1" >> $HGRCPATH

  $ hg init git
  $ cd git
  $ "$PYTHON" ../writelines.py b 1 '\x00'
  $ hg ci -Am addb
  adding b
  $ echo a > a
  $ "$PYTHON" ../writelines.py b 1 '\x01' 1 '\x00'
  $ echo c > c
  $ hg add a c
  $ hg qnew -f changeb
  $ hg qpop
  popping changeb
  patch queue now empty
  $ hg rm b
  $ hg ci -Am rmb

Push git patch with missing target:

  $ hg qpush
  applying changeb
  unable to find 'b' for patching
  (use '--prefix' to apply patch relative to the current directory)
  1 out of 1 hunks FAILED -- saving rejects to file b.rej
  patch failed, unable to continue (try -v)
  patch failed, rejects left in working directory
  errors during apply, please fix and qrefresh changeb
  [2]
  $ hg st
  ? b.rej

Display added files:

  $ cat a
  a
  $ cat c
  c

Display rejections:

  $ cat b.rej
  --- b
  +++ b
  GIT binary patch
  literal 2
  Jc${No0000400IC2
  
  $ cd ..

Test push creating directory during git copy or rename:

  $ hg init missingdir
  $ cd missingdir
  $ echo a > a
  $ hg ci -Am adda
  adding a
  $ mkdir d
  $ hg copy a d/a2
  $ hg mv a d/a
  $ hg qnew -g -f patch
  $ hg qpop
  popping patch
  patch queue now empty
  $ hg qpush
  applying patch
  now at: patch

  $ cd ..

