{
  lib, fetchurl, stdenv, openssh, rsync,
  asciidoc, libxml2, docbook_xml_dtd_45, libxslt, docbook_xsl # man pages
}:

let

  pkg = "ccollect";
  ver = "2.9";
  web = https://nico.schottelius.org/software/ccollect;

in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";
  src = fetchurl {
    url = "${web}/download/${pkg}-${ver}.tar.bz2";
    sha256 = "0gbbdwhjr5dcqqf34k3wl4gwb1mkkm8mm5mx5zz5hcyqyj24s5ja";
  };

  propagatedBuildInputs = [ openssh rsync ];
  buildInputs = [ asciidoc libxml2 docbook_xml_dtd_45 libxslt docbook_xsl ];

  installPhase = ''
    make install-script install-man prefix=$out
    for i in ccollect_add_source \
    ccollect_analyse_logs \
    ccollect_archive_config \
    ccollect_check_config \
    ccollect_delete_source \
    ccollect_list_intervals \
    ccollect_logwrapper \
    ccollect_push \
    ccollect_stats; do
      install -m 755 tools/$i $out/bin
    done
    ddir=$out/share/doc
    mkdir -p $ddir
    cp README $ddir
    cp doc/ccollect.text $ddir
  '';

  meta = {
    description = "(pseudo) incremental backup with different exclude lists using hardlinks and rsync";
    homepage = web;
    license = lib.licenses.gpl2;
  };
}

# vim: et ts=2 sw=2 
