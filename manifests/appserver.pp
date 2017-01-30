define nodejs_app::appserver (
  $app_name,
  $app_version,
  $app_repo,
  $vcsroot = undef
){

  case $::kernel {
    'windows': {
      $_vcsroot  = 'C:\\nodejsapps'
    }
    default: {
      $_vcsroot  = '/opt/nodejsapps'
    }
  }

  if $vcsroot == undef {
    $_vcsroot_resolved = $_vcsroot
  }

  case $::kernel {
    'windows': {
      $_checkcmd = "pm2 show ${app_name} | findstr online"
      $_apprepo  = "${_vcsroot_resolved}\\${app_name}"
    }
    default: {
      $_checkcmd = "pm2 show ${app_name} | grep online"
      $_apprepo  = "${_vcsroot_resolved}/${app_name}"
    }
  }

  file { $_vcsroot_resolved:
    ensure => directory,
  }

  vcsrepo { $_apprepo:
    ensure   => present,
    provider => git,
    source   => $app_repo,
    revision => $app_version,
    require  => File[$_vcsroot_resolved],
  }

  class {'::nodejs': }

  package { 'pm2':
    ensure   => 'present',
    provider => 'npm',
    require  => Class['nodejs'],
  }


  $_startcmd = "pm2 start ${app_name}.config.js"
  exec {"pm2_start_${app_name}":
    cwd     => $_apprepo,
    path    => $::path,
    command => $_startcmd,
    unless  => $_checkcmd,
  }

}
Nodejs_app::Appserver produces Http {
  name => $name,
  host => $::hostname,
  ip   => $::ipaddress,
  port => '8000',
}
