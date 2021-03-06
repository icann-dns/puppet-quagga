# quagga::bgpd::peer
#
define quagga::bgpd::peer (
  Optional[Array[Stdlib::IP::Address::V4]] $addr4             = [],
  Optional[Array[Stdlib::IP::Address::V6]] $addr6             = [],
  String                                   $desc              = undef,
  Quagga::Routes_acl                       $inbound_routes    = 'none',
  Optional[Array]                          $communities       = [],
  Optional[Integer[1,254]]                 $multihop          = undef,
  Optional[String]                         $password          = undef,
  Optional[Integer[1,32]]                  $prepend           = undef,
  Boolean                                  $default_originate = false,
) {

  include ::quagga::bgpd

  $my_asn             = $::quagga::bgpd::my_asn

  if count($addr4) > 0 or count($addr6) > 0 {
    concat::fragment{"bgpd_peer_${name}":
      target  => $::quagga::bgpd::conf_file,
      content => template('quagga/bgpd.conf.peer.erb'),
      order   => '10',
    }
  }
  if count($addr6) > 0 {
    concat::fragment{"bgpd_v6peer_${name}":
      target  => $::quagga::bgpd::conf_file,
      content => template('quagga/bgpd.conf.v6peer.erb'),
      order   => '40',
    }
  }
  concat::fragment{ "quagga_bgpd_routemap_${name}":
    target  => $::quagga::bgpd::conf_file,
    content => template('quagga/bgpd.conf.routemap.erb'),
    order   => '90',
  }
  if $::quagga::bgpd::manage_nagios {
    if $::quagga::bgpd::enable_advertisements {
      if $::quagga::bgpd::enable_advertisements_v4 and count($addr4) > 0 {
        quagga::bgpd::peer::nagios {$addr4:
          routes => concat($::quagga::bgpd::networks4, $::quagga::bgpd::failsafe_networks4),
        }
      }
      if $::quagga::bgpd::enable_advertisements_v6 and count($addr6) > 0 {
        quagga::bgpd::peer::nagios {$addr6:
          routes => concat($::quagga::bgpd::networks6, $::quagga::bgpd::failsafe_networks6),
        }
      }
    }
  }
}
