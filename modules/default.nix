{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  axfrdns-runit = ./axfrdns-runit.nix;
  clamd = ./clamd.nix;
  dnscache-runit = ./dnscache-runit.nix;
  ids = ./ids.nix;
  firehol = ./firehol.nix;
  phpfpm-runit = ./phpfpm-runit.nix;
  pure-ftpd = ./pure-ftpd.nix;
  qmail-runit = ./qmail-runit.nix;
  runit = ./runit.nix;
  tinydns-runit = ./tinydns-runit.nix;
  zabbix-runit = ./zabbix-runit.nix;
}

