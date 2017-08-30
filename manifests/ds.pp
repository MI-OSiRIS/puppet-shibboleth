# configures basic shib discovery service on /ds/index.html
# configure_apache requires that you are using puppetlabs-apache to manage
# default paths installed from package are used (/etc/shibboleth-ds)
# Location /ds will be configured

class shibboleth::ds (
    $logo_path = '/etc/shibboleth-ds',
    $logo_source = undef,   # if defined as puppet file uri will copy into logo_path
    $logo_filename = 'blank.gif',
    $ds_title = 'Shibboleth Discovery Service',
    $user_stylesheet = undef,
    $configure_apache = $shibboleth::configure_apache
) {

    package { 'shibboleth-embedded-ds': ensure => present }

    file { '/etc/shibboleth-ds/idpselect_config.js':
        ensure => present,
        content => template('shibboleth/idpselect_config.js.erb')
    }

    file { '/etc/shibboleth-ds/index.html':
        ensure => present,
        content => template('shibboleth/index.html.erb')
    }

    if $logo_source {
        file { "${logo_path}/$logo_filename":
            ensure => present,
            source => $logo_source
        }
    }

    if $configure_apache {
        apache::custom_config { 'shibds':
            content => template('shibboleth/shibds.conf.erb'),
            priority => 99,
            require => Package['shibboleth-embedded-ds']
        }
    }

}
