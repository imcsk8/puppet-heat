# Class heat
#
#  heat base package & configuration
#
# == parameters
#  [*package_ensure*]
#    ensure state for package. Optional. Defaults to 'present'
#  [*verbose*]
#    should the daemons log verbose messages. Optional. Defaults to 'False'
#  [*debug*]
#    should the daemons log debug messages. Optional. Defaults to 'False'
#  [*rabbit_host*]
#    ip or hostname of the rabbit server. Optional. Defaults to '127.0.0.1'
#  [*rabbit_port*]
#    port of the rabbit server. Optional. Defaults to 5672.
#  [*rabbit_hosts*]
#    array of host:port (used with HA queues). Optional. Defaults to undef.
#    If defined, will remove rabbit_host & rabbit_port parameters from config
#  [*rabbit_userid*]
#    user to connect to the rabbit server. Optional. Defaults to 'guest'
#  [*rabbit_password*]
#    password to connect to the rabbit_server. Optional. Defaults to empty.
#  [*rabbit_virtualhost*]
#    virtualhost to use. Optional. Defaults to '/'
#  [*qpid_hostname*]
#  [*qpid_port*]
#  [*qpid_username*]
#  [*qpid_password*]
#  [*qpid_heartbeat*]
#  [*qpid_protocol*]
#  [*qpid_tcp_nodelay*]
#  [*qpid_reconnect*]
#  [*qpid_reconnect_timeout*]
#  [*qpid_reconnect_limit*]
#  [*qpid_reconnect_interval*]
#  [*qpid_reconnect_interval_min*]
#  [*qpid_reconnect_interval_max*]
#  (optional) various QPID options
#

class heat(
  $package_ensure     = 'present',
  $verbose            = false,
  $debug              = false,
  $rpc_backend        = 'heat.openstack.common.rpc.impl_kombu',
  $rabbit_host        = '127.0.0.1',
  $rabbit_port        = 5672,
  $rabbit_hosts       = undef,
  $rabbit_userid      = 'guest',
  $rabbit_password    = '',
  $rabbit_virtualhost = '/',
  $qpid_hostname = 'localhost',
  $qpid_port = 5672,
  $qpid_username = 'guest',
  $qpid_password = 'guest',
  $qpid_heartbeat = 60,
  $qpid_protocol = 'tcp',
  $qpid_tcp_nodelay = true,
  $qpid_reconnect = true,
  $qpid_reconnect_timeout = 0,
  $qpid_reconnect_limit = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval = 0,
) {

  include heat::params

  File {
    require => Package['heat-common'],
  }

  group { 'heat':
    name    => 'heat',
    require => Package['heat-common'],
  }

  user { 'heat':
    name    => 'heat',
    gid     => 'heat',
    groups  => ['heat'],
    system  => true,
    require => Package['heat-common'],
  }

  file { '/etc/heat/':
    ensure  => directory,
    owner   => 'heat',
    group   => 'heat',
    mode    => '0750',
  }

  file { '/etc/heat/heat.conf':
    owner   => 'heat',
    group   => 'heat',
    mode    => '0640',
  }

  package { 'heat-common':
    ensure => $package_ensure,
    name   => $::heat::params::common_package_name,
  }

  Package['heat-common'] -> Heat_config<||>

  if $rpc_backend == 'heat.openstack.common.rpc.impl_kombu' {

    if $rabbit_hosts {
      heat_config { 'DEFAULT/rabbit_host': ensure => absent }
      heat_config { 'DEFAULT/rabbit_port': ensure => absent }
      heat_config { 'DEFAULT/rabbit_hosts':
        value => join($rabbit_hosts, ',')
      }
      } else {
      heat_config { 'DEFAULT/rabbit_host': value => $rabbit_host }
      heat_config { 'DEFAULT/rabbit_port': value => $rabbit_port }
      heat_config { 'DEFAULT/rabbit_hosts':
        value => "${rabbit_host}:${rabbit_port}"
      }
    }

      if size($rabbit_hosts) > 1 {
        heat_config { 'DEFAULT/rabbit_ha_queues': value => true }
      } else {
        heat_config { 'DEFAULT/rabbit_ha_queues': value => false }
      }

      heat_config {
        'DEFAULT/rabbit_userid'          : value => $rabbit_userid;
        'DEFAULT/rabbit_password'        : value => $rabbit_password;
        'DEFAULT/rabbit_virtualhost'     : value => $rabbit_virtualhost;
      }
  }

  if $rpc_backend == 'heat.openstack.common.rpc.impl_qpid' {

    heat_config {
      'DEFAULT/qpid_hostname': value => $qpid_hostname;
      'DEFAULT/qpid_port': value => $qpid_port;
      'DEFAULT/qpid_username': value => $qpid_username;
      'DEFAULT/qpid_password': value => $qpid_password;
      'DEFAULT/qpid_heartbeat': value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol': value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay': value => $qpid_tcp_nodelay;
      'DEFAULT/qpid_reconnect': value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout': value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit': value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval': value => $qpid_reconnect_interval;
    }

  }

  heat_config {
    'DEFAULT/rpc_backend'            : value => $rpc_backend;
    'DEFAULT/debug'                  : value => $debug;
    'DEFAULT/verbose'                : value => $verbose;
  }

}
