# @summary bgpd class
# @param my_asn The local ASN number
# @param router_id The router_id
# @param enable if to enable bgpd
# @param networks4 List of v4 networks to advertise
# @param failsafe_networks4 List of v4 failsafe networks to advertise
# @param networks6 List of v6 networks to advertise
# @param failsafe_networks6 List of v6 failsafe networks to advertise
# @param rejected_v4 list of v4 networks to reject
# @param rejected_v6 list of v6 networks to reject
# @param reject_bogons_v4 list of v4 bogons to reject
# @param reject_bogons_v6 list of v6 bogons to reject
# @param failover_server If this is a failover server
# @param enable_advertisements weather we should advertise bgp networks
# @param enable_advertisements_v4 weather we should advertise bgp v4networks
# @param enable_advertisements_v6 weather we should advertise bgp v6networks
# @param conf_file location of bgp config file
# @param bgpd_cmd location of bgp config comand
# @param debug_bgp Debug options
# @param log_stdout Log to stdout
# @param log_stdout_level Logging level
# @param log_file Log to file
# @param log_file_path The log file to use
# @param log_file_level The log level to use
# @param logrotate_enable Enable logrotate
# @param logrotate_rotate how many rotated files to keep
# @param logrotate_size rotation size
# @param log_syslog log to syslog
# @param log_syslog_level syslog level
# @param log_syslog_facility syslog facility
# @param log_monitor log to monitor
# @param log_monitor_level log to level
# @param log_record_priority
# @param log_timestamp_precision logging precission
# @param fib_update update the local fib
# @param peers A hash of peers
class frr::bgpd (
  Integer[1,4294967295]                $my_asn                   = undef,
  Stdlib::IP::Address::V4              $router_id                = undef,
  Boolean                              $enable                   = true,
  Array[Stdlib::IP::Address::V4::CIDR] $networks4                = [],
  Array[Stdlib::IP::Address::V4::CIDR] $failsafe_networks4       = [],
  Array[Stdlib::IP::Address::V6::CIDR] $networks6                = [],
  Array[Stdlib::IP::Address::V6::CIDR] $failsafe_networks6       = [],
  Array[Stdlib::IP::Address::V4::CIDR] $rejected_v4              = [],
  Array[Stdlib::IP::Address::V6::CIDR] $rejected_v6              = [],
  Boolean                              $reject_bogons_v4         = true,
  Boolean                              $reject_bogons_v6         = true,
  Boolean                              $failover_server          = false,
  Boolean                              $enable_advertisements    = true,
  Boolean                              $enable_advertisements_v4 = true,
  Boolean                              $enable_advertisements_v6 = true,
  Stdlib::Absolutepath                 $conf_file                = '/etc/frr/bgpd.conf',
  Stdlib::Absolutepath                 $bgpd_cmd                 = '/usr/sbin/bgpd',
  Array                                $debug_bgp                = [],
  Boolean                              $log_stdout               = false,
  Frr::Log_level                    $log_stdout_level         = 'debugging',
  Boolean                              $log_file                 = false,
  Stdlib::Absolutepath                 $log_file_path            = '/var/log/frr/bgpd.log',
  Frr::Log_level                    $log_file_level           = 'debugging',
  Boolean                              $logrotate_enable         = false,
  Integer[1,100]                       $logrotate_rotate         = 5,
  String                               $logrotate_size           = '100M',
  Boolean                              $log_syslog               = false,
  Frr::Log_level                    $log_syslog_level         = 'debugging',
  Stdlib::Syslogfacility               $log_syslog_facility      = 'daemon',
  Boolean                              $log_monitor              = false,
  Frr::Log_level                    $log_monitor_level        = 'debugging',
  Boolean                              $log_record_priority      = false,
  Integer[0,6]                         $log_timestamp_precision  = 1,
  Boolean                              $fib_update               = true,
  Hash                                 $peers                    = {},
) {
  include frr

  ini_setting { 'bgpd':
    setting => 'bgpd',
    value   => $enable.bool2str('yes','no'),
    path    => '/etc/frr/daemons',
    section => '',
    notify  => Service[$frr::service],
    require => Package[$frr::package],
  }
  # the frr validate command runs without CAP_DAC_OVERRIDE
  # this means that even if running the command as root it cant
  # read files owned by !root
  # further to this the validate command is indeterminate. if the
  # file allready exists then the temp file created for the validate_cmd
  # has the permissions of the original user.  if the file does not exits
  # then the temp file is created with root user permissions.
  # As such we need this hack
  exec { "/usr/bin/touch ${conf_file}":
    creates => $conf_file,
    user    => $frr::owner,
    before  => Concat[$conf_file],
  }
  service { 'bgpd':
    ensure  => running,
    enable  => true,
    require => Concat[$conf_file],
  }

  concat { $conf_file:
    require      => Package[$frr::package],
    owner        => $frr::owner,
    group        => $frr::group,
    mode         => $frr::mode,
    validate_cmd => "${bgpd_cmd} -u ${frr::owner} -C -f %",
    notify       => Service['bgpd'],
  }
  concat::fragment { 'frr_bgpd_head':
    target  => $conf_file,
    content => template('frr/bgpd.conf.head.erb'),
    order   => '01',
  }
  concat::fragment { 'frr_bgpd_v6head':
    target  => $conf_file,
    content => "!\n address-family ipv6\n",
    order   => '30',
  }
  concat::fragment { 'frr_bgpd_v6foot':
    target  => $conf_file,
    content => template('frr/bgpd.conf.v6foot.erb'),
    order   => '50',
  }
  concat::fragment { 'frr_bgpd_acl':
    target  => $conf_file,
    content => template('frr/bgpd.conf.acl.erb'),
    order   => '80',
  }
  concat::fragment { 'frr_bgpd_foot':
    target  => $conf_file,
    content => "line vty\n!\n",
    order   => '99',
  }
  if $log_file and $logrotate_enable {
    logrotate::rule { 'frr_bgp':
      path       => $log_file_path,
      rotate     => $logrotate_rotate,
      size       => $logrotate_size,
      compress   => true,
      postrotate => '/bin/kill -USR1 `cat /var/run/frr/bgpd.pid 2> /dev/null` 2> /dev/null || true',
    }
  }
  create_resources(frr::bgpd::peer, $peers)
}
