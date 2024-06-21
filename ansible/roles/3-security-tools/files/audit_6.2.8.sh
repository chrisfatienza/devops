#!/bin/bash
# Added Condition for Symbolik Links for Home Directory - JohnP.

for dir in `cat /etc/passwd | egrep -v '(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
#---- Start Modify -JohnP
  #dirperm=`ls -ld $dir | cut -f1 -d" "`
  dirtype=`ls -ld $dir | cut -f1 -d" "`
  if [[ -L $dir ]]; then
    linkdir=`readlink -f $dir`
    dirperm=`ls -ld $linkdir | cut -f1 -d" "`
  else
    dirperm=$dirtype
  fi
#---- END Modify - JohnP
  if [ `echo $dirperm | cut -c6 ` != "-" ]; then
    echo "Group Write permission set on directory $dir"
  fi
  if [ `echo $dirperm | cut -c8 ` != "-" ]; then
    echo "Other Read permission set on directory $dir"
  fi
  if [ `echo $dirperm | cut -c9 ` != "-" ]; then
    echo "Other Write permission set on directory $dir"
  fi
  if [ `echo $dirperm | cut -c10 ` != "-" ]; then
    echo "Other Execute permission set on directory $dir"
  fi
done
