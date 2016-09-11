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
  }

  plugin {
    [ 'puavo-wlan-elements'
    , 'puavo-wlan-traffic' ]:
      require => Package['puavo-wlancontroller-munin-plugin'];

    'users':
      ;
  }

  bootserver_nginx::enable { 'munin': ; }

  package {
    [ 'munin'
    , 'munin-node'
    , 'puavo-wlancontroller-munin-plugin' ]:
      ensure => present;
  }

  service {
    'munin-node':
      ensure  => running,
      require => Package['munin-node'];
  }

  tidy {
    '/etc/munin/plugins':
      matches => [ 'if_err_tap*', 'if_tap*', 'nfsd', 'nfs_client' ],
      notify  => Service['munin-node'],
      recurse => true;
  }
}
