# @summary Quagga routing server.
# @param owner The owner of the quagga configuration files.
# @param group The group of the quagga configuration files.
# @param mode The mode of the quagga configuration files.
# @param package The package to install.
# @param service The service to manage.
# @param enable Whether to enable the zebra daemon.
# @param content The content of the zebra configuration file.
# @param bgp_listenon The IP address to listen on for BGP.
class quagga (
  String                        $owner   = 'quagga',
  String                        $group   = 'quagga',
  Stdlib::Filemode              $mode    = '0664',
  String                        $package = 'quagga',
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
    '/etc/quagga':
      ensure  => directory;
    '/etc/quagga/zebra.conf':
      content => $content;
    '/etc/quagga/debian.conf':
      content => template('quagga/debian.conf.erb');
  }
  file { '/usr/local/bin/quagga_status.sh':
    ensure  => file,
    mode    => '0555',
    content => template('quagga/quagga_status.sh.erb'),
  }
  file { '/etc/quagga/vtysh.conf':
    ensure => file,
    mode   => $mode,
    source => 'puppet:///modules/quagga/vtysh.conf',
  }
  file { '/etc/profile.d/vtysh.sh':
    ensure => file,
    source => 'puppet:///modules/quagga/vtysh.sh',
  }
  service { $service:
    ensure => running,
    enable => true,
  }
  ini_setting { 'zebra':
    ensure  => present,
    path    => '/etc/quagga/daemons',
    section => '',
    setting => 'zebra',
    value   => $enable.bool2str('yes','no'),
    require => Package[$package],
    notify  => Service[$service],
  }
}
