#!/bin/sh
set -e

IAM="$(readlink -f "$0")"

BASEDIR="$(dirname "$IAM")"

export EPICS_HOST_ARCH="$("$BASEDIR"/epics-base/startup/EpicsHostArch)"

if [ ! -x "$BASEDIR/epics-base/bin/$EPICS_HOST_ARCH/softIoc" ]; then
  echo "Need to run ./build-epics.sh first"
  exit 1
fi

echo "Create $BASEDIR/eactivate"

cat <<EOF > "$BASEDIR"/eactivate
# source me to enable

_OLD_EPICS_PATH="\$PATH"

[ "\$EPICS_HOST_ARCH" ] || export EPICS_HOST_ARCH="$("$BASEDIR"/epics-base/startup/EpicsHostArch)"

# caget et al
export PATH=$BASEDIR/epics-base/bin/\$EPICS_HOST_ARCH:\$PATH

edeactivate() {
    PATH="\$_OLD_EPICS_PATH"
    unset _OLD_EPICS_PATH
    unset edeactivate
}
EOF

chmod -R a-w "$BASEDIR"

cat <<EOF
System package dependencies

  # RHEL/CentOS 8
  dnf install glibc make readline libtirpc

To begin using run:
. $BASEDIR/eactivate
EOF
