# See README.md for details.
define openldap::server::access(
  $access,
  $ensure   = present,
  $position = undef,
  $what     = undef,
  $suffix   = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Access[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Access[$title] ->
    Class['openldap::server']
  }

  openldap_access { $title:
    ensure   => $ensure,
    position => $position,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::conffile,
    what     => $what,
    suffix   => $suffix,
    access   => is_array($access) ? {
      true  => $access,
      false => [ $access ]
    },
  }
}
