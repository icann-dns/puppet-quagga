# @summary Frr routing server.
# @param owner The owner of the frr configuration files.
# @param group The group of the frr configuration files.
# @param mode The mode of the frr configuration files.
# @param package The package to install.
# @param service The service to manage.
# @param enable Whether to enable the zebra daemon.
# @param content The content of the zebra configuration file.
# @param bgp_listenon The IP address to listen on for BGP.
class frr (
  String                        $owner   = 'frr',
  String                        $group   = 'frr',
  Stdlib::Filemode              $mode    = '0664',
  String                        $package = 'frr',
  String                        $service = 'zebra',
  Boolean                       $enable  = true,
  String                        $content = "hostname ${facts['networking']['fqdn']}",
  Optional[Stdlib::IP::Address] $bgp_listenon = undef
) {
  ensure_packages([$package])
  file {
    default:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => Package[$package],
      notify  => Service[$service];
    '/etc/frr':
      ensure  => directory;
    '/etc/frr/zebra.conf':
      content => $content;
    '/etc/frr/debian.conf':
      content => template('frr/debian.conf.erb');
  }
  file { '/usr/local/bin/frr_status.sh':
    ensure  => file,
    mode    => '0555',
    content => template('frr/frr_status.sh.erb'),
  }
  file { '/etc/frr/vtysh.conf':
    ensure => file,
    mode   => $mode,
    source => 'puppet:///modules/frr/vtysh.conf',
  }
  file { '/etc/profile.d/vtysh.sh':
    ensure => file,
    source => 'puppet:///modules/frr/vtysh.sh',
  }
  service { $service:
    ensure => running,
    enable => true,
  }
  ini_setting { 'zebra':
    ensure  => present,
    path    => '/etc/frr/daemons',
    section => '',
    setting => 'zebra',
    value   => $enable.bool2str('yes','no'),
    require => Package[$package],
    notify  => Service[$service],
  }
}
