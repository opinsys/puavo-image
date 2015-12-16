class opinsys_apt_repositories {
  include apt

  $subdir = $lsbdistcodename ? {
              'jessie' => 'git-jessie',
              default  => "git-master",
            }

  # define some apt keys and repositories for use

  apt::key {
    'opinsys-repo.gpgkey':
      key_id => 'C0F0F8B7',
      key_source
        => 'puppet:///modules/opinsys_apt_repositories/keys/opinsys-repo.gpgkey';
  }

  Apt::Repository { require => Apt::Key['opinsys-repo.gpgkey'], }
# XXX disable until we have some of these archives for Debian or just remove
# @apt::repository {
#     'archive':
#       aptline => "http://archive.opinsys.fi/$subdir $lsbdistcodename main contrib non-free";
#
#     'kernels':
#       aptline => "http://archive.opinsys.fi/kernels $lsbdistcodename main contrib non-free";
#
#     'libreoffice-5-0':
#       aptline => "http://archive.opinsys.fi/libreoffice-5-0 $lsbdistcodename main contrib non-free";
#
#     'repo':
#       aptline => "http://archive.opinsys.fi/blobs $lsbdistcodename main contrib non-free";
#
#     'x2go':
#       aptline => "http://archive.opinsys.fi/x2go $lsbdistcodename main contrib non-free";
#
#     'xorg-updates':
#       aptline => "http://archive.opinsys.fi/git-xorg-updates $lsbdistcodename main contrib non-free";
# }

  file {
    '/etc/apt/preferences.d/opinsys.pref':
      content => template('opinsys_apt_repositories/opinsys.pref');
  }
}
