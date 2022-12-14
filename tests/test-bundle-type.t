bundle w/o type option

  $ hg init t1
  $ hg init t2
  $ cd t1
  $ echo blablablablabla > file.txt
  $ hg ci -Ama
  adding file.txt
  $ hg log | grep summary
  summary:     a
  $ hg bundle ../b1 ../t2
  searching for changes
  1 changesets found

  $ cd ../t2
  $ hg unbundle ../b1
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files
  new changesets c35a0f9217e6 (1 drafts)
  (run 'hg update' to get a working copy)
  $ hg up
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg log | grep summary
  summary:     a
  $ cd ..

Unknown compression type is rejected

  $ hg init t3
  $ cd t3
  $ hg -q unbundle ../b1
  $ hg bundle -a -t unknown out.hg
  abort: unknown is not a recognized bundle specification
  (see 'hg help bundlespec' for supported values for --type)
  [10]

  $ hg bundle -a -t unknown-v2 out.hg
  abort: unknown compression is not supported
  (see 'hg help bundlespec' for supported values for --type)
  [10]

  $ cd ..

test bundle types

  $ testbundle() {
  >   echo % test bundle type $1
  >   hg init t$1
  >   cd t1
  >   hg bundle -t $1 ../b$1 ../t$1
  >   f -q -B6 -D ../b$1; echo
  >   cd ../t$1
  >   hg debugbundle ../b$1
  >   hg debugbundle --spec ../b$1
  >   echo
  >   cd ..
  > }

  $ for t in "None" "bzip2" "gzip" "none-v2" "v2" "v1" "gzip-v1"; do
  >   testbundle $t
  > done
  % test bundle type None
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  none-v2
  
  % test bundle type bzip2
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {Compression: BZ}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  bzip2-v2
  
  % test bundle type gzip
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {Compression: GZ}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  gzip-v2
  
  % test bundle type none-v2
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  none-v2
  
  % test bundle type v2
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {Compression: BZ}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  bzip2-v2
  
  % test bundle type v1
  searching for changes
  1 changesets found
  HG10BZ
  c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  bzip2-v1
  
  % test bundle type gzip-v1
  searching for changes
  1 changesets found
  HG10GZ
  c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  gzip-v1
  

Compression level can be adjusted for bundle2 bundles

  $ hg init test-complevel
  $ cd test-complevel

  $ cat > file0 << EOF
  > this is a file
  > with some text
  > and some more text
  > and other content
  > EOF
  $ cat > file1 << EOF
  > this is another file
  > with some other content
  > and repeated, repeated, repeated, repeated content
  > EOF
  $ hg -q commit -A -m initial

  $ hg bundle -a -t gzip-v2 gzip-v2.hg
  1 changesets found
  $ f --size gzip-v2.hg
  gzip-v2.hg: size=468

  $ hg --config experimental.bundlecomplevel=1 bundle -a -t gzip-v2 gzip-v2-level1.hg
  1 changesets found
  $ f --size gzip-v2-level1.hg
  gzip-v2-level1.hg: size=475

  $ hg --config experimental.bundlecomplevel.gzip=1 --config experimental.bundlelevel=9 bundle -a -t gzip-v2 gzip-v2-level1.hg
  1 changesets found
  $ f --size gzip-v2-level1.hg
  gzip-v2-level1.hg: size=475

  $ cd ..

#if zstd

  $ for t in "zstd" "zstd-v2"; do
  >   testbundle $t
  > done
  % test bundle type zstd
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {Compression: ZS}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  zstd-v2
  
  % test bundle type zstd-v2
  searching for changes
  1 changesets found
  HG20\x00\x00 (esc)
  Stream params: {Compression: ZS}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  cache:rev-branch-cache -- {} (mandatory: False)
  zstd-v2
  

Explicit request for zstd on non-generaldelta repos

  $ hg --config format.usegeneraldelta=false init nogd
  $ hg -q -R nogd pull t1
  $ hg -R nogd bundle -a -t zstd nogd-zstd
  1 changesets found

zstd-v1 always fails

  $ hg -R tzstd bundle -a -t zstd-v1 zstd-v1
  abort: compression engine zstd is not supported on v1 bundles
  (see 'hg help bundlespec' for supported values for --type)
  [10]

zstd supports threading

  $ hg init test-compthreads
  $ cd test-compthreads
  $ hg debugbuilddag +3
  $ hg --config experimental.bundlecompthreads=1 bundle -a -t zstd-v2 zstd-v2-threaded.hg
  3 changesets found
  $ cd ..

#else

zstd is a valid engine but isn't available

  $ hg -R t1 bundle -a -t zstd irrelevant.hg
  abort: compression engine zstd could not be loaded
  [255]

#endif

test garbage file

  $ echo garbage > bgarbage
  $ hg init tgarbage
  $ cd tgarbage
  $ hg pull ../bgarbage
  pulling from ../bgarbage
  abort: ../bgarbage: not a Mercurial bundle
  [255]
  $ cd ..

test invalid bundle type

  $ cd t1
  $ hg bundle -a -t garbage ../bgarbage
  abort: garbage is not a recognized bundle specification
  (see 'hg help bundlespec' for supported values for --type)
  [10]
  $ cd ..

Test controlling the changegroup version

  $ hg -R t1 bundle --config experimental.changegroup3=yes -a -t v2 ./v2-cg-default.hg
  1 changesets found
  $ hg debugbundle ./v2-cg-default.hg --part-type changegroup
  Stream params: {Compression: BZ}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  $ hg debugbundle ./v2-cg-default.hg --spec
  bzip2-v2
  $ hg -R t1 bundle --config experimental.changegroup3=yes -a -t 'v2;cg.version=02' ./v2-cg-02.hg
  1 changesets found
  $ hg debugbundle ./v2-cg-02.hg --part-type changegroup
  Stream params: {Compression: BZ}
  changegroup -- {nbchanges: 1, version: 02} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  $ hg debugbundle ./v2-cg-02.hg --spec
  bzip2-v2
  $ hg -R t1 bundle --config experimental.changegroup3=yes -a -t 'v2;cg.version=03' ./v2-cg-03.hg
  1 changesets found
  $ hg debugbundle ./v2-cg-03.hg --part-type changegroup
  Stream params: {Compression: BZ}
  changegroup -- {nbchanges: 1, version: 03} (mandatory: True)
      c35a0f9217e65d1fdb90c936ffa7dbe679f83ddf
  $ hg debugbundle ./v2-cg-03.hg --spec
  bzip2-v2;cg.version=03
