#
#
#
# $repos - Hash of plugin repos to clone.
#

class sensu_client_plugins (
  $repos = hiera('sensu_client_plugins::repos',{}),
){

  case $::osfamily {
    'windows': {
      $locations = {
        "checkout_loc" => 'C:/ProgramData/sensu_plugins',
        "sensu_plugins_loc" => 'c:/etc/sensu/plugins',
      }
    }
    default: {
      $locations = {
        "checkout_loc" => '/usr/local/src/sensu_plugins',
        "sensu_plugins_loc" => '/etc/sensu/plugins',
      }
    }
  }

  if !defined(File [$locations["checkout_loc"]]) {
    file {$locations["checkout_loc"]:
      ensure => directory,
    }
  }
  if !defined(File [$locations["sensu_plugins_loc"]]) {
    file {$locations["sensu_plugins_loc"]:
      ensure => directory,
    }
  }

  create_resources("sensu_plugin_repo", $repos, $locations)
}

define sensu_plugin_repo (
  $repo_name = $title,
  $repo_source,
  $checkout_loc,
  $sensu_plugins_loc,
){
  vcsrepo {$repo_name:
    ensure      => 'latest',
    revision    => 'origin/master',
    path        => "${checkout_loc}/${repo_name}",
    source      => $repo_source,
    provider    => 'git',
    require => File[$checkout_loc, $sensu_plugins_loc],
#    before  => File[$sensu_plugins_loc],
  }

  file {$repo_name:
    path    => "${sensu_plugins_loc}/${repo_name}",
    ensure  => link,
    target  => "${checkout_loc}/${repo_name}",
#    require => File[$sensu_plugins_loc],
    require => Vcsrepo[$repo_name],
  }

}
