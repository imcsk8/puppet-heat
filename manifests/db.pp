# Configures the heat database
# This class will install the required libraries depending on the driver
# specified in the connection_string parameter
#
# == Parameters
#  [*database_connection*]
#    the connection string. format: [driver]://[user]:[password]@[host]/[database]
#
class heat::db (
  $sql_connection = 'mysql://heat:heat@localhost/heat'
) {

  include heat::params

  Package<| title == 'heat-common' |> -> Class['heat::db']

  validate_re($sql_connection,
    '(sqlite|mysql|posgres):\/\/(\S+:\S+@\S+\/\S+)?')

  case $sql_connection {
    /^mysql:\/\//: {
      $backend_package = false
      include mysql::python
    }
    /^postgres:\/\//: {
      $backend_package = 'python-psycopg2'
    }
    /^sqlite:\/\//: {
      $backend_package = 'python-pysqlite2'
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'heat-backend-package':
      ensure => present,
      name   => $backend_package,
    }
  }

  heat_config {
    'DEFAULT/sql_connection': value => $sql_connection;
  }

  Heat_config['DEFAULT/sql_connection'] ~> Exec['heat-dbsync']

  exec { 'heat-dbsync':
    command     => $::heat::params::dbsync_command,
    path        => '/usr/bin',
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => Heat_config['DEFAULT/sql_connection']
  }

}
