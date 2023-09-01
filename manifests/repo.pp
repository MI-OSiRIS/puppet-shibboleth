# == Class: shibboleth::repo
#
# This class manages the Shibboleth RPM repository based on the operating system. 
# https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxRPMInstall
##
# === Parameters
#
# This class does not provide any parameters.
# To control the behaviour of this class, have a look at the parameters:
# * shibboleth::manage_repo
#
# NOTE:  It is likely that the Suse related parts of this class do not work right.   
#
class shibboleth::repo {
  if $::shibboleth::manage_repo {
    case $::osfamily {
      'redhat': {
        if ( versioncmp($facts['os']['release']['major'], '7') == 0 ) {
          yumrepo { 'shibboleth': 
            descr      => "Shibboleth (CentOS_7)",
            name       => 'shibboleth',
            type       => "rpm-md",
            mirrorlist => "https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_7",
            gpgcheck   => 1,
            gpgkey     => [ "https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key","https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key" ] ,
            enabled    => 1,
            skip_if_unavailable => 1
          }
        } elsif ( versioncmp($facts['os']['release']['major'], '8') == 0 ) {
          yumrepo { 'shibboleth': 
            descr      => "Shibboleth (CentOS_8)",
            name       => 'shibboleth',
            type       => "rpm-md",
            mirrorlist => "https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_8",
            gpgcheck   => 1,
            gpgkey     => [ "https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key","https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key" ] ,
            enabled    => 1,
            skip_if_unavailable => 1
          }
        } elsif ( versioncmp($facts['os']['release']['major'], '9') == 0 ) {
          yumrepo { 'shibboleth': 
            descr      => "Shibboleth (rockylinux9)",
            name       => 'shibboleth',
            type       => "rpm-md",
            mirrorlist => "https://shibboleth.net/cgi-bin/mirrorlist.cgi/rockylinux9",
            gpgcheck   => 1,
            gpgkey     => [ "https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key","https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key" ] ,
            enabled    => 1,
            skip_if_unavailable => 1
          }
        }
      }
      default: {  fail('Your plattform is not supported to manage a repository.')  }
    }      
  }
}
