#
#
#
# $repos - Hash of plugin repos to clone.  Key is "friendly name", value is git repo url.
#

class sensu_client_plugins (
  $repos = {},
){

  case $::osfamily {
    'windows': {
      $checkout_loc = 'C:/ProgramData/sensu_plugins'
      $sensu_plugins_loc = 'c:/etc/sensu/plugins'
    }
    default: {
      $checkout_loc = '/usr/local/src/sensu_plugins'
      $sensu_plugins_loc = '/etc/sensu/plugins'
    }
  }

  file {$checkout_loc:
    ensure => directory,
  }
  file {$sensu_plugins_loc:
    ensure => directory,
  }

  vcsrepo {keys($repos):
    ensure      => 'latest',
    revision    => 'origin/HEAD',
    path        => "${checkout_loc}/${title}",
    source      => $repos[$title],
    provider    => 'git',
  }
  
  file {keys($repos):
    path    => "${sensu_plugins_loc}/${title}",
    ensure  => link,
    target  => "${checkout_loc}/${title}",
    require => [File[$checkout_loc, $sensu_plugins_loc],Vcsrepo[${title}]],
  }

}
