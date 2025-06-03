# @summary set up bgpd peer
# @param addr4 The IPv4 address of the peer.
# @param addr6 The IPv6 address of the peer.
# @param desc The description of the peer.
# @param inbound_routes The inbound routes to accept.
# @param communities The communities to accept.
# @param multihop The multihop value.
# @param password The password to use.
# @param prepend The prepend value.
# @param default_originate Whether to default originate.
define quagga::bgpd::peer (
  Boolean                        $default_originate = false,
  Quagga::Routes_acl             $inbound_routes    = 'none',
  String                         $desc              = undef,
  Array                          $communities       = [],
  Array[Stdlib::IP::Address::V4] $addr4             = [],
  Array[Stdlib::IP::Address::V6] $addr6             = [],
  Optional[Integer[1,254]]       $multihop          = undef,
  Optional[String]               $password          = undef,
  Optional[Integer[1,32]]        $prepend           = undef,
) {
  include quagga::bgpd

  $my_asn = $quagga::bgpd::my_asn

  unless ($addr4 + $addr6).empty {
    concat::fragment { "bgpd_peer_${name}":
      target  => $quagga::bgpd::conf_file,
      content => template('quagga/bgpd.conf.peer.erb'),
      order   => '10',
    }
  }
  unless $addr6.empty {
    concat::fragment { "bgpd_v6peer_${name}":
      target  => $quagga::bgpd::conf_file,
      content => template('quagga/bgpd.conf.v6peer.erb'),
      order   => '40',
    }
  }
  concat::fragment { "quagga_bgpd_routemap_${name}":
    target  => $quagga::bgpd::conf_file,
    content => template('quagga/bgpd.conf.routemap.erb'),
    order   => '90',
  }
}
