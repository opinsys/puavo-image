class bootserver_ddns {
  include ::apparmor

  if $ltsp_iface_ip == undef {
    fail("ltsp_iface_ip fact is missing")
  }

  exec {
    'ensure ubnt.conf exists':
      command => '/bin/echo \#option ubnt.unifi-address xxx.xxx.xxx.xxx; >/etc/dhcp/ubnt.conf',
      onlyif  => '/usr/bin/test ! -e /etc/dhcp/ubnt.conf',
      require => Package['isc-dhcp-server'];
  }

  file {
    '/etc/apparmor.d/local/usr.sbin.dhcpd':
      content => template('bootserver_ddns/dhcpd.apparmor'),
      mode    => 0644,
      notify  => Service['apparmor'],
      require => Package['apparmor'];
    
    '/etc/dhcp/dhcpd.conf':
      notify  => Service['isc-dhcp-server'],
      content => template('bootserver_ddns/dhcpd.conf'),
      require => [ Package['isc-dhcp-server']
                 , Exec['ensure ubnt.conf exists'] ];
    '/etc/dnsmasq.conf':
      notify  => Service['dnsmasq'],
      content => template('bootserver_ddns/dnsmasq.conf'),
      require => Package['dnsmasq'];
  }
  
  package {
    [ 'bind9'
    , 'dnsmasq'
    , 'isc-dhcp-server' ]:
      ensure => present;
  }

  service {
    'bind9':
      enable => true,
      ensure => 'running';

    'dnsmasq':
      enable => true,
      ensure => 'running';

    'isc-dhcp-server':
      enable => true,
      ensure => 'running';
  }

}
