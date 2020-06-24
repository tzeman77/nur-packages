{ stdenv, pkgs, qmail, dkimpy, mess822 }:

let
  pkg = "qmail-queue-dkimsign";
  # qmailqueue = "${qmail}/bin/qmail-queue"; 
  qmailqueue = "/var/qmail/bin/qmail-queue";  # need to use setuid wrapper
  dkimsign = "${dkimpy}/bin/dkimsign";
  from_field = "${mess822}/bin/822field From";

in pkgs.writers.writeBashBin "${pkg}" ''
    DKIM_DIR=''${DKIM_DIR:-/etc/dkim}

    t=$(mktemp)
    cat > $t
    dom=$(cat $t | ${from_field} | tr '[A-Z]' '[a-z]' | sed -ne 's/[^@]\+@\([a-z0-9\.]\+\).*/\1/p')
    rc=1
    signed=0
    env | egrep 'PLUGIN_|USER|DOMAIN' | sed -e "s/^/dkimsign[$$]: /" >&2
    if [ -n "$dom" ] && [ -n "$DKIM_SELECTOR" ] && \
      [ -r "$DKIM_DIR/$DKIM_SELECTOR.$dom.key" ] ; then
      ${dkimsign} "$DKIM_SELECTOR" "$dom" "$DKIM_DIR/$DKIM_SELECTOR.$dom.key" < $t > $t.sig
      if [ $? -eq 0 ]; then
        ${qmailqueue} < $t.sig
        rc=$?
        signed=1
        from=$(${from_field} < $t)
        echo "dkimsign[$$]: remote $TCPREMOTEHOST:$TCPREMOTEIP:$TCPREMOTEPORT" >&2
        echo "dkimsign[$$]: DKIM signed with: $DKIM_SELECTOR.$dom for: $from" >&2
      fi
      rm -f $t.sig
    fi

    if [ $signed -eq 0 ]; then
      cat $t | ${qmailqueue}
      rc=$?
    fi
    rm -f $t
    env | grep PLUGIN | sort >&2
    exit $rc
  ''

# vim: et ts=2 sw=2 

