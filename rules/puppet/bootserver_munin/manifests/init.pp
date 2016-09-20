class bootserver_munin {
  include bootserver_nginx

  define plugin($wildcard = false) {
    $plugin_name = $title
    $real_plugin_name = $wildcard ? {
      true  => regsubst($plugin_name, '([^_]+)_.+', '\1_'),
      false => $plugin_name,
    }

    file {
      "/etc/munin/plugins/$plugin_name":
        ensure  => link,
        notify  => Service['munin-node'],
        target  => "/usr/share/munin/plugins/$real_plugin_name",
    }
  }

  $statefile = '/var/lib/munin-node/plugin-state/nobody/puavo-wlan-127.0.0.1'
  
  exec {
    'reset puavo-wlan state':
      command => "/usr/bin/test -e '${statefile}' &&         \
      /bin/mv '${statefile}' '${statefile}.reset_by_puppet'; \
      /usr/bin/touch '${statefile}.reset_by_puppet'",
      creates => "${statefile}.reset_by_puppet";
  }

  file {
    '/etc/munin/munin-node.conf':
      content => template('bootserver_munin/munin-node.conf'),
      mode    => 0644,
      notify  => Service['munin-node'],
      require => Package['munin-node'];

    '/etc/nginx/sites-available/munin':
      content => template('bootserver_munin/nginx_conf'),
      mode    => 0644,
      notify  => Exec['reload nginx'],
      require => [ Package['munin'], Package['munin-node'] ];

    '/usr/share/munin/plugins/puavo-bootserver-clients':
      content => template('bootserver_munin/puavo-bootserver-clients'),
      mode    => 0755;

    '/usr/share/munin/plugins/puavo-wlan':
      content => template('bootserver_munin/puavo-wlan'),
      mode    => 0755;
  }

  bootserver_munin::plugin {
    [ 'if_altvpn1'
    , 'if_eth0'
    , 'if_eth1'
    , 'if_inet0'
    , 'if_ltsp0'
    , 'if_vpn1'
    , 'if_wlan0' ]:
      wildcard => true;

    [ 'puavo-bootserver-clients'
    , 'users' ]:
      ;

    'puavo-wlan':
      require => [ Package['python-numpy'], Package['python-redis'] ];
  }

  bootserver_nginx::enable { 'munin': ; }

  package {
    [ 'munin'
    , 'munin-node'
    , 'python-numpy'
    , 'python-redis' ]:
      ensure => present;
  }

  service {
    'munin-node':
      ensure  => running,
      require => Package['munin-node'];
  }

  tidy {
    '/etc/munin/plugins':
      matches => [ 'if_err_tap*'
                 , 'if_tap*'
                 , 'nfs4_client'
                 , 'nfs_client'
                 , 'nfsd' ],
      notify  => Service['munin-node'],
      recurse => true;
  }
}
