
class heat::keystone::auth(
  $password,
  $heat_auth_name        = 'heat',
  $heat_public_address   = '127.0.0.1',
  $heat_admin_address    = '127.0.0.1',
  $heat_internal_address = '127.0.0.1',
  $heat_port             = '8004',
  $heat_version          = 'v1',
  $stack_user_role       = 'heat_stack_user',
  $cfn_auth_name         = 'heat-cfn',
  $cfn_public_address    = '127.0.0.1',
  $cfn_admin_address     = '127.0.0.1',
  $cfn_internal_address  = '127.0.0.1',
  $cfn_port              = '8000',
  $cfn_version           = 'v1',
  $region                = 'RegionOne',
  $tenant                = 'services',
  $email                 = 'heat@localhost'
) {

  keystone_user { $heat_auth_name:
    ensure   => present,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }
  keystone_role { "${stack_user_role}":
    ensure  => present,
  }
  keystone_user_role { "${heat_auth_name}@${tenant}":
    ensure  => present,
    roles   => 'admin',
  }
  keystone_service { $heat_auth_name:
    ensure      => present,
    type        => 'orchestration',
    description => 'Heat API',
  }
  keystone_endpoint { "${region}/${heat_auth_name}":
    ensure       => present,
    public_url   => "http://${heat_public_address}:${heat_port}/${heat_version}/%(tenant_id)s",
    admin_url    => "http://${heat_admin_address}:${heat_port}/${heat_version}/%(tenant_id)s",
    internal_url => "http://${heat_internal_address}:${heat_port}/${heat_version}/%(tenant_id)s",
  }

  if "${cfn_auth_name}" != "" {
    keystone_service { $cfn_auth_name:
      ensure      => present,
      type        => 'cloudformation',
      description => 'Heat CloudFormation API',
    }

    keystone_endpoint { "${region}/${cfn_auth_name}":
      ensure       => present,
      public_url   => "http://${cfn_public_address}:${cfn_port}/${cfn_version}",
      admin_url    => "http://${cfn_admin_address}:${cfn_port}/${cfn_version}",
      internal_url => "http://${cfn_internal_address}:${cfn_port}/${cfn_version}",
    }
  }

}
