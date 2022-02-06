#!/usr/bin/env bash
echo ""
echo "Self-Extracting Installer"
echo ""

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXX`

ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

# decompress the appended archive into the temp directory
tail -n+$ARCHIVE $0 | tar xzv -C $TMPDIR

# run the installation script that will replace all the
# necessary files into their right place.
CDIR=`pwd`
cd $TMPDIR
./deploy-crostini.sh

cd $CDIR
rm -rf $TMPDIR

exit 0

__ARCHIVE_BELOW__
