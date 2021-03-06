# == Class puppetmaster::puppetdb::client
# Configures a puppetmaster to work as a puppetdb client
class puppetmaster::puppetdb::client(
    Integer $port = 443
) {

    $host = hiera('puppetdb_host', 'puppet1.miraheze.org')

    file { '/etc/puppet/puppetdb.conf':
        ensure  => present,
        content => template('puppetmaster/puppetdb.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    file { '/etc/puppet/routes.yaml':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///modules/puppetmaster/routes.yaml',
    }

    if defined(Service['apache2']) {
        File['/etc/puppet/routes.yaml'] -> Service['apache2']
    }

    # Absence of this directory causes the puppetmaster to spit out
    # 'Removing mount "facts": /var/lib/puppet/facts does not exist or is not a directory'
    # and catalog compilation to fail with https://tickets.puppetlabs.com/browse/PDB-949
    file { '/var/lib/puppet/facts':
        ensure => directory,
    }

    class { 'puppetdb': }

    if hiera('puppetmaster::puppetdb::use_local_db', false) {
      class { 'puppetdb::database':
          require => Class['puppetdb'],
      }
    }
}
