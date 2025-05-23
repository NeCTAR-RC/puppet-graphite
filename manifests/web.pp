# == Class: graphite::web
#
# This class is able to install or remove graphite web on a node.
# It manages the status of the related service.
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# The default values for the parameters are set in graphite::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class graphite::web(
  $ensure                = $graphite::params::ensure,
  Boolean $autoupgrade   = $graphite::params::autoupgrade,
  $status                = $graphite::params::status,
  $version               = false,
  Boolean $enable        = false,
  $dashboard_config_file = "puppet:///modules/${module_name}/etc/graphite-web/dashboard.conf",

  $secret_key,

  $database_name         = '/var/lib/graphite/graphite.db',
  $database_username     = '',
  $database_password     = '',
  $database_host         = '',
  $database_port         = '',
  $database_backend      = 'django.db.backends.sqlite3',

  $memcache_servers      = undef,
  $cache_duration        = '60',

  $cluster_servers       = undef,
  $carbonlink_hosts      = undef,

) inherits graphite::params {

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  #### Manage actions

  if $enable {
    # package(s)
    class { 'graphite::web::package': }

    case $database_backend {
      'django.db.backends.mysql': {
        include ::mariadb::python
      }
      'django.db.backends.sqlite3': {
        exec { 'graphite-syncdb':
          command => '/usr/lib/python3/dist-packages/django/bin/django-admin.py migrate --settings=graphite.settings',
          creates => $database_name,
          user    => '_graphite',
          path    => ['/usr/bin', '/usr/sbin']
        }
      }
    }


    # configuration
    class { 'graphite::web::config':
      secret_key        => $secret_key,

      database_name     => $database_name,
      database_username => $database_username,
      database_password => $database_password,
      database_host     => $database_host,
      database_port     => $database_port,
      database_backend  => $database_backend,

      carbonlink_hosts  => $carbonlink_hosts,
      cluster_servers   => $cluster_servers,
      memcache_servers  => $memcache_servers,
      cache_duration    => $cache_duration,
    }

    #### Manage relationships

    if $ensure == 'present' {
      # we need the software before configuring it
      Class['graphite::web::package'] -> Class['graphite::web::config']

    }

  }
}
