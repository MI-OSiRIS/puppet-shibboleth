# Class: shibboleth
#
# This module manages shibboleth
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

# [Remember: No empty lines between comments and class definition]
class shibboleth (
  $admin              = $::shibboleth::params::admin,
  $hostname           = $::shibboleth::params::hostname,
  $manage_user        = $::shibboleth::params::manage_user,
  $user               = $::shibboleth::params::user,
  $group              = $::shibboleth::params::group,
  $conf_dir           = $::shibboleth::params::conf_dir,
  $conf_file          = $::shibboleth::params::conf_file,
  $sp_cert            = $::shibboleth::params::sp_cert,
  $bin_dir            = $::shibboleth::params::bin_dir,
  $handlerSSL         = $::shibboleth::params::handlerSSL,
  $consistent_address = $::shibboleth::params::consistent_address,
  $manage_repo        = $::shibboleth::params::manage_repo,
  $configure_apache   = $::shibboleth::params::configure_apache,
  $logo_path          = $::shibboleth::params::logo_path,
  $logo_filename      = $::shibboleth::params::logo_filename,
  $style_sheet        = $::shibboleth::params::style_sheet,
  $logo_source        = undef
) inherits shibboleth::params {

  include shibboleth::repo

  $config_file = "${conf_dir}/${conf_file}"

  if $manage_user {
    user{$user:
      ensure  => 'present',
      home    => '/var/log/shibboleth',
      shell   => '/bin/false',
      require => Class['apache::mod::shib'],
      before => Service['shibd']
    }
  }

  # by requiring the apache::mod::shib, these should wait for the package
  # to create the directory.
  file{'shibboleth_conf_dir':
    ensure  => 'directory',
    path    => $conf_dir,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['apache::mod::shib'],
  }

  file{'shibboleth_config_file':
    ensure  => 'file',
    path    => $config_file,
    replace => false,
    require => [Class['apache::mod::shib'],File['shibboleth_conf_dir']],
  }

  File['shibboleth_config_file'] -> Augeas <| incl == $config_file |>

# Using augeas is a performance hit, but it works. Fix later.
  augeas{'sp_config_resources':
    lens    => 'Xml.lns',
    incl    => $config_file,
    context => "/files${config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set Errors/#attribute/supportContact ${admin}",
      "set Errors/#attribute/logoLocation /shibboleth-sp/${logo_filename}",
      "set Errors/#attribute/styleSheet /shibboleth-sp/main.css",
    ],
    notify  => Service['httpd','shibd'],
  }

  augeas{'sp_config_consistent_address':
    lens    => 'Xml.lns',
    incl    => $config_file,
    context => "/files${config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set Sessions/#attribute/consistentAddress ${consistent_address}",
    ],
    notify  => Service['httpd','shibd'],
  }

  augeas{'sp_config_hostname':
    lens    => 'Xml.lns',
    incl    => $config_file,
    context => "/files${config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set #attribute/entityID https://${hostname}/shibboleth",
      "set Sessions/#attribute/handlerURL https://${hostname}/Shibboleth.sso",
    ],
    notify  => Service['httpd','shibd'],
  }

  augeas{'sp_config_handlerSSL':
    lens    => 'Xml.lns',
    incl    => $config_file,
    context => "/files${config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set Sessions/#attribute/handlerSSL ${handlerSSL}",
    ],
    notify  => Service['httpd','shibd'],
  }

  if $logo_source {
    file { "${logo_path}/${logo_filename}":
      ensure => present,
      source => $logo_source
    }
  }

  if $configure_apache {
    apache::custom_config { 'shibsso':
        content => file('shibboleth/shibsso.conf'),
        priority => 99
    }

     apache::custom_config { 'shibsp_alias':
        content => template('shibboleth/shibsp.conf.erb'),
        priority => 99
    }


  }

  service{'shibd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Class['apache::mod::shib'],
  }

}
