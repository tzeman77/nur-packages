{ lib, stdenv, fetchurl, groff, openssl }:

let
  pkg = "qmail";
  ver = "1.03";
  web = http://cr.yp.to;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  queue-fix = stdenv.mkDerivation {
    name = "queue-fix-1.4";
    src = fetchurl {
      url = "http://www.netmeridian.com/e-huss/queue-fix-1.4.tar.gz";
      sha256 = "15h41l5g4a69pd0zshhzx9z1k8b7ishm6nwj73pqyni2wdh67nk3";
    };
    patches = [
      ./queue-fix-errno.patch
    ];
    installPhase = ''
      mkdir -p $out/{bin,doc}
      cp queue-fix $out/bin/
      cp README $out/doc
    '';
  };

  src = fetchurl {
    url = "${web}/software/${pkg}-${ver}.tar.gz";
    sha256 = "123gc80z7l8svd7qbc6a39fi311b4b43az0rcqm0jmdv5ib6rv91";
  };

  patches = [
    # Avoid need to have secondary groups for compilation
    ./hasshsgr.h.patch

    # auto_uids patches (borrowed from FreeBSD ports)
    ./auto_uids-Makefile.patch ./auto_uids.c.patch

    ./qmail-1.03.errno.patch
    ./ext_todo-20030105.patch
    ./qmailqueue-patch
    ./qregex-20060423-qmail.patch
    ./qmail-smtpd.spam.patch
    ./qmail-103-oversize-dns.patch
    ./qmail-1.03.isoc.patch
    ./notqmail-1.08-tls-20231230-qmail-remote.patch
  ];

  buildFlags = "it man";

  buildInputs = [groff queue-fix openssl];

  installPhase = ''
    # dirs
    for i in alias bin boot control doc users configure; do
      install -d -m 755 $out/$i
    done

    # boot files
    for i in binm1{,+df} binm2{,+df} binm3{,+df} home{,+df} proc{,+df}; do
      install -m 755 $i $out/boot/$i
    done

    # binaries
    install -m 711 qmail-queue $out/bin/qmail-queue
    for i in qmail-lspawn qmail-start qmail-newu qmail-newmrh; do
      install -m 700 $i $out/bin/$i
    done
    for i in qmail-getpw qmail-local qmail-remote qmail-rspawn \
             qmail-clean qmail-send splogger qmail-popup qmail-pw2u \
             qmail-todo; do
      install -m 711 $i $out/bin/$i
    done
    for i in qmail-inject predate datemail mailsubj qmail-showctl \
       qmail-qread qmail-qstat qmail-tcpto qmail-tcpok qmail-pop3d \
             qmail-popup qmail-qmqpc qmail-qmqpd qmail-qmtpd qmail-smtpd \
             sendmail tcp-env qreceipt qsmhook qbiff forward preline \
             condredirect bouncesaying except maildirmake maildir2mbox \
             maildirwatch qail elq pinq; do
      install -m 755 $i $out/bin/$i
    done

    # configure scripts/binaries
    install -m 755 config-fast $out/configure/config-fast

    # install manpages
    for i in bouncesaying except maildir2mbox maildirwatch preline qreceipt \
             condredirect forward maildirmake mailsubj qbiff tcp-env; do
      install -D -m 644 $i.1 $out/man/man1/$i.1
    done
    for i in addresses envelopes mbox qmail-header qmail-users dot-qmail \
             maildir qmail-control qmail-log tcp-environ; do
      install -D -m 644 $i.5 $out/man/man5/$i.5
    done
    for i in forgeries qmail-limits qmail; do
      install -D -m 644 $i.7 $out/man/man7/$i.7
    done
    for i in qmail-clean qmail-newmrh qmail-qmqpd qmail-rspawn qmail-tcpto \
             qmail-command qmail-newu qmail-qmtpd qmail-send splogger \
             qmail-getpw qmail-pop3d qmail-qread qmail-showctl qmail-inject \
             qmail-popup qmail-qstat qmail-smtpd qmail-local qmail-pw2u \
             qmail-queue qmail-start qmail-lspawn qmail-qmqpc qmail-remote \
             qmail-tcpok; do
      install -D -m 644 $i.8 $out/man/man8/$i.8
    done

    # doc files
    for i in `grep 'c(auto_qmail,"doc"' hier.c | cut -d, -f3 | tr -d '"'`; do
      install -m 644 $i $out/doc/$i
    done

    # install concurrencyicoming & defaultdelivery files
    echo 20 > $out/control/concurrencyincoming
    echo ./Maildir/ > $out/control/defaultdelivery
    chmod 644 $out/control/{concurrencyincoming,defaultdelivery}

    # symlink queue-fix
    ln -s ${queue-fix}/bin/queue-fix $out/bin
    ln -s ${queue-fix}/doc/README $out/doc/README.queue-fix
  '';

  meta = {
    description = "A secure, reliable, efficient, SMTP/POP3 server.";
    homepage = "${web}/${pkg}.html";
    license = lib.licenses.publicDomain.shortName;
    platforms = lib.platforms.gnu;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 

