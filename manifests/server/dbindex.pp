# See README.md for details.
define openldap::server::dbindex(
  $ensure    = undef,
  $suffix    = undef,
  $attribute = undef,
  $indices   = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Dbindex[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Dbindex[$title] ->
    Class['openldap::server']
  }

  openldap_dbindex { $title:
    ensure    => $ensure,
    suffix    => $suffix,
    attribute => $attribute,
    indices   => $indices,
    confdir   => $::openldap::server::confdir,
  }
}
