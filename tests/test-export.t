  $ hg init repo
  $ cd repo
  $ touch foo
  $ hg add foo
  $ for i in 0 1 2 3 4 5 6 7 8 9 10 11; do
  >    echo "foo-$i" >> foo
  >    hg ci -m "foo-$i"
  > done

  $ for out in "%nof%N" "%%%H" "%b-%R" "%h" "%r" "%m"; do
  >    echo
  >    echo "# foo-$out.patch"
  >    hg export -v -o "foo-$out.patch" 2:tip
  > done
  
  # foo-%nof%N.patch
  exporting patches:
  foo-01of10.patch
  foo-02of10.patch
  foo-03of10.patch
  foo-04of10.patch
  foo-05of10.patch
  foo-06of10.patch
  foo-07of10.patch
  foo-08of10.patch
  foo-09of10.patch
  foo-10of10.patch
  
  # foo-%%%H.patch
  exporting patches:
  foo-%617188a1c80f869a7b66c85134da88a6fb145f67.patch
  foo-%dd41a5ff707a5225204105611ba49cc5c229d55f.patch
  foo-%f95a5410f8664b6e1490a4af654e4b7d41a7b321.patch
  foo-%4346bcfde53b4d9042489078bcfa9c3e28201db2.patch
  foo-%afda8c3a009cc99449a05ad8aa4655648c4ecd34.patch
  foo-%35284ce2b6b99c9d2ac66268fe99e68e1974e1aa.patch
  foo-%9688c41894e6931305fa7165a37f6568050b4e9b.patch
  foo-%747d3c68f8ec44bb35816bfcd59aeb50b9654c2f.patch
  foo-%5f17a83f5fbd9414006a5e563eab4c8a00729efd.patch
  foo-%f3acbafac161ec68f1598af38f794f28847ca5d3.patch
  
  # foo-%b-%R.patch
  exporting patches:
  foo-repo-2.patch
  foo-repo-3.patch
  foo-repo-4.patch
  foo-repo-5.patch
  foo-repo-6.patch
  foo-repo-7.patch
  foo-repo-8.patch
  foo-repo-9.patch
  foo-repo-10.patch
  foo-repo-11.patch
  
  # foo-%h.patch
  exporting patches:
  foo-617188a1c80f.patch
  foo-dd41a5ff707a.patch
  foo-f95a5410f866.patch
  foo-4346bcfde53b.patch
  foo-afda8c3a009c.patch
  foo-35284ce2b6b9.patch
  foo-9688c41894e6.patch
  foo-747d3c68f8ec.patch
  foo-5f17a83f5fbd.patch
  foo-f3acbafac161.patch
  
  # foo-%r.patch
  exporting patches:
  foo-02.patch
  foo-03.patch
  foo-04.patch
  foo-05.patch
  foo-06.patch
  foo-07.patch
  foo-08.patch
  foo-09.patch
  foo-10.patch
  foo-11.patch
  
  # foo-%m.patch
  exporting patches:
  foo-foo_2.patch
  foo-foo_3.patch
  foo-foo_4.patch
  foo-foo_5.patch
  foo-foo_6.patch
  foo-foo_7.patch
  foo-foo_8.patch
  foo-foo_9.patch
  foo-foo_10.patch
  foo-foo_11.patch

Doing it again clobbers the files rather than appending:
  $ hg export -v -o "foo-%m.patch" 2:3
  exporting patches:
  foo-foo_2.patch
  foo-foo_3.patch
  $ grep HG foo-foo_2.patch | wc -l
  \s*1 (re)
  $ grep HG foo-foo_3.patch | wc -l
  \s*1 (re)

Using bookmarks:

  $ hg book -f -r 9 @
  $ hg book -f -r 11 test
  $ hg export -B test
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID 5f17a83f5fbd9414006a5e563eab4c8a00729efd
  # Parent  747d3c68f8ec44bb35816bfcd59aeb50b9654c2f
  foo-10
  
  diff -r 747d3c68f8ec -r 5f17a83f5fbd foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -8,3 +8,4 @@
   foo-7
   foo-8
   foo-9
  +foo-10
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID f3acbafac161ec68f1598af38f794f28847ca5d3
  # Parent  5f17a83f5fbd9414006a5e563eab4c8a00729efd
  foo-11
  
  diff -r 5f17a83f5fbd -r f3acbafac161 foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -9,3 +9,4 @@
   foo-8
   foo-9
   foo-10
  +foo-11

Exporting 4 changesets to a file:

  $ hg export -o export_internal 1 2 3 4
  $ grep HG export_internal | wc -l
  \s*4 (re)

Doing it again clobbers the file rather than appending:
  $ hg export -o export_internal 1 2 3 4
  $ grep HG export_internal | wc -l
  \s*4 (re)

Exporting 4 changesets to stdout:

  $ hg export 1 2 3 4 | grep HG | wc -l
  \s*4 (re)

Exporting revision -2 to a file:

  $ hg export -- -2
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID 5f17a83f5fbd9414006a5e563eab4c8a00729efd
  # Parent  747d3c68f8ec44bb35816bfcd59aeb50b9654c2f
  foo-10
  
  diff -r 747d3c68f8ec -r 5f17a83f5fbd foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -8,3 +8,4 @@
   foo-7
   foo-8
   foo-9
  +foo-10

Exporting wdir revision:

  $ echo "foo-wdir" >> foo
  $ hg export 'wdir()'
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID ffffffffffffffffffffffffffffffffffffffff
  # Parent  f3acbafac161ec68f1598af38f794f28847ca5d3
  
  
  diff -r f3acbafac161 foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -10,3 +10,4 @@
   foo-9
   foo-10
   foo-11
  +foo-wdir
  $ hg revert -q foo

Templated output to stdout:

  $ hg export -Tjson 0
  [
   {
    "branch": "default",
    "date": [0, 0],
    "desc": "foo-0",
    "diff": "diff -r 000000000000 -r 871558de6af2 foo\n--- /dev/null\tThu Jan 01 00:00:00 1970 +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -0,0 +1,1 @@\n+foo-0\n",
    "node": "871558de6af2e8c244222f8eea69b782c94ce3df",
    "parents": [],
    "user": "test"
   }
  ]

Templated output to single file:

  $ hg export -Tjson 0:1 -o out.json
  $ cat out.json
  [
   {
    "branch": "default",
    "date": [0, 0],
    "desc": "foo-0",
    "diff": "diff -r 000000000000 -r 871558de6af2 foo\n--- /dev/null\tThu Jan 01 00:00:00 1970 +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -0,0 +1,1 @@\n+foo-0\n",
    "node": "871558de6af2e8c244222f8eea69b782c94ce3df",
    "parents": [],
    "user": "test"
   },
   {
    "branch": "default",
    "date": [0, 0],
    "desc": "foo-1",
    "diff": "diff -r 871558de6af2 -r d1c9656e973c foo\n--- a/foo\tThu Jan 01 00:00:00 1970 +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,1 +1,2 @@\n foo-0\n+foo-1\n",
    "node": "d1c9656e973cfb5aebd5499bbd2cb350e3b12266",
    "parents": ["871558de6af2e8c244222f8eea69b782c94ce3df"],
    "user": "test"
   }
  ]

Templated output to multiple files:

  $ hg export -Tjson 0:1 -o 'out-{rev}.json'
  $ cat out-0.json
  [
   {
    "branch": "default",
    "date": [0, 0],
    "desc": "foo-0",
    "diff": "diff -r 000000000000 -r 871558de6af2 foo\n--- /dev/null\tThu Jan 01 00:00:00 1970 +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -0,0 +1,1 @@\n+foo-0\n",
    "node": "871558de6af2e8c244222f8eea69b782c94ce3df",
    "parents": [],
    "user": "test"
   }
  ]
  $ cat out-1.json
  [
   {
    "branch": "default",
    "date": [0, 0],
    "desc": "foo-1",
    "diff": "diff -r 871558de6af2 -r d1c9656e973c foo\n--- a/foo\tThu Jan 01 00:00:00 1970 +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,1 +1,2 @@\n foo-0\n+foo-1\n",
    "node": "d1c9656e973cfb5aebd5499bbd2cb350e3b12266",
    "parents": ["871558de6af2e8c244222f8eea69b782c94ce3df"],
    "user": "test"
   }
  ]

Template keywrods:

  $ hg export 0 -T '# {node|shortest}\n\n{diff}'
  # 8715
  
  diff -r 000000000000 -r 871558de6af2 foo
  --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -0,0 +1,1 @@
  +foo-0

No filename should be printed if stdout is specified explicitly:

  $ hg export -v 1 -o -
  exporting patch:
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID d1c9656e973cfb5aebd5499bbd2cb350e3b12266
  # Parent  871558de6af2e8c244222f8eea69b782c94ce3df
  foo-1
  
  diff -r 871558de6af2 -r d1c9656e973c foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -1,1 +1,2 @@
   foo-0
  +foo-1

Checking if only alphanumeric characters are used in the file name (%m option):

  $ echo "line" >> foo
  $ hg commit -m " !\"#$%&(,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]"'^'"_\`abcdefghijklmnopqrstuvwxyz{|}~"
  $ hg export -v -o %m.patch tip
  exporting patch:
  ___________0123456789_______ABCDEFGHIJKLMNOPQRSTUVWXYZ______abcdefghijklmnopqrstuvwxyz____.patch

Template fragments in file name:

  $ hg export -v -o '{node|shortest}.patch' tip
  exporting patch:
  197e.patch

Backslash should be preserved because it is a directory separator on Windows:

  $ mkdir out
  $ hg export -v -o 'out\{node|shortest}.patch' tip
  exporting patch:
  out\197e.patch

Still backslash is taken as an escape character in inner template strings:

  $ hg export -v -o '{"out\{foo}.patch"}' tip
  exporting patch:
  out{foo}.patch

Invalid pattern in file name:

  $ hg export -o '%x.patch' tip
  abort: invalid format spec '%x' in output filename
  [255]
  $ hg export -o '%' tip
  abort: incomplete format spec in output filename
  [255]
  $ hg export -o '%{"foo"}' tip
  abort: incomplete format spec in output filename
  [255]
  $ hg export -o '%m{' tip
  hg: parse error at 3: unterminated template expansion
  (%m{
      ^ here)
  [10]
  $ hg export -o '%\' tip
  abort: invalid format spec '%\' in output filename
  [255]
  $ hg export -o '\%' tip
  abort: incomplete format spec in output filename
  [255]

Catch exporting unknown revisions (especially empty revsets, see issue3353)

  $ hg export
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID 197ecd81a57f760b54f34a58817ad5b04991fa47
  # Parent  f3acbafac161ec68f1598af38f794f28847ca5d3
   !"#$%&(,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
  
  diff -r f3acbafac161 -r 197ecd81a57f foo
  --- a/foo	Thu Jan 01 00:00:00 1970 +0000
  +++ b/foo	Thu Jan 01 00:00:00 1970 +0000
  @@ -10,3 +10,4 @@
   foo-9
   foo-10
   foo-11
  +line

  $ hg export ""
  hg: parse error: empty query
  [10]
  $ hg export 999
  abort: unknown revision '999'
  [10]
  $ hg export "not all()"
  abort: export requires at least one changeset
  [10]

Check for color output
  $ cat <<EOF >> $HGRCPATH
  > [color]
  > mode = ansi
  > [extensions]
  > color =
  > EOF

  $ hg export --color always --nodates tip
  # HG changeset patch
  # User test
  # Date 0 0
  #      Thu Jan 01 00:00:00 1970 +0000
  # Node ID * (glob)
  # Parent * (glob)
   !"#$%&(,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
  
  \x1b[0;1mdiff -r f3acbafac161 -r 197ecd81a57f foo\x1b[0m (esc)
  \x1b[0;31;1m--- a/foo\x1b[0m (esc)
  \x1b[0;32;1m+++ b/foo\x1b[0m (esc)
  \x1b[0;35m@@ -10,3 +10,4 @@\x1b[0m (esc)
   foo-9
   foo-10
   foo-11
  \x1b[0;32m+line\x1b[0m (esc)


  $ cd ..
