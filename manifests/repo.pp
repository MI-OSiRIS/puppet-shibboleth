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
        case $::operatingsystem {
          'centos', 'scientific': {
            $reponame = $::operatingsystemmajrelease ? {
              '6'     => 'CentOS_CentOS-6',  # i don't know why this one is strange
              default => "CentOS_$::operatingsystemmajrelease",
            }
          }

          'redhat': {
            $reponame = $::operatingsystemmajrelease ? {
              /(5|6)/ =>  "RHEL_$::operatingsystemmajrelease",
              default     => "CentOS_$::operatingsystemmajrelease",
            }
          }
            default: { fail('Your plattform is not supported to manage a repository.') }
        }

        yumrepo { 'security_shibboleth': 
          descr     => "Shibboleth (${reponame})",
          name      => 'security_shibboleth',
          baseurl   => "http://download.opensuse.org/repositories/security:/shibboleth/${reponame}/",
          gpgcheck  => 1,
          gpgkey    => "http://download.opensuse.org/repositories/security:/shibboleth/${reponame}/repodata/repomd.xml.key",
          enabled   => 1
        }
      }

      'suse': {
        $reponame = $::operatingsystem ? {  
          'SLES' => "SLE_${::operatingsystemmajrelease}",
          'OpenSuSE' => "openSUSE_${::operatingsystemmajrelease}" 
        }
            
      # requires darin/zypprepo
        zypprepo { 'security_shibboleth':
          descr     => "Shibboleth (SLE_${::operatingsystemmajrelease})",
          name      => 'security_shibboleth',
          baseurl   => "http://download.opensuse.org/repositories/security:/shibboleth/SLE_${::operatingsystemmajrelease}/",
          gpgkey    => 'http://download.opensuse.org/repositories/security:/shibboleth/SLE_${::operatingsystemmajrelease}//repodata/repomd.xml.key',
          enabled   => 1,
          gpgcheck  => 1,
        }
      }
      default: {  fail('Your plattform is not supported to manage a repository.')  }
    }      
  }

}
     
    
