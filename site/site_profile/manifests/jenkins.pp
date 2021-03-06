class site_profile::jenkins {

  $config_hash = hiera_hash('site_profile::jenkins::config_hash', {})
  $configure_firewall = hiera('site_profile::jenkins::configure_firewall', false)
  class { "::jenkins":
    configure_firewall => $configure_firewall,
    config_hash => $config_hash,
  }

  $firewall_rules = hiera_hash('site_profile::jenkins::firewall_rules', {})
  create_resources('firewall', $firewall_rules)


  file { "/var/lib/jenkins/.ssh":
    ensure => directory,
    mode => 0700,
    owner => 'jenkins',
    group => 'jenkins',
    require => Class['::jenkins'],
  }

  # SSH configuration.
  file { "/var/lib/jenkins/.ssh/config":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/config",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/config",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # SSH private key - real file is in private repo,
  # default is just a placeholder for hosts outside the main infrastructure.
  file { "/var/lib/jenkins/.ssh/id_rsa":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/id_rsa",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/id_rsa",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # ssh pub key -- doesn't really need to be in the private repo, but it's nice
  # to keep them together.
  file { "/var/lib/jenkins/.ssh/id_rsa.pub":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/id_rsa.pub",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/id_rsa.pub",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # Deploy ssh keys.
  file { "/var/lib/jenkins/.ssh/jenkins_deploy_key":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/jenkins_deploy_key",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/jenkins_deploy_key",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }
  file { "/var/lib/jenkins/.ssh/jenkins_deploy_key.pub":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/jenkins_deploy_key.pub",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/jenkins_deploy_key.pub",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # Create directories that are be used by jenkins scripts.
  $jenkins_work_dirs = hiera_hash('site_profile::jenkins::work_directories', {})
  if ($jenkins_work_dirs != {}) {
    create_resources('file', $jenkins_work_dirs, {'ensure' => directory,})
  }

  # MySQL backup script.
  file { "/usr/local/bin/mysql-backup.sh":
    owner => root,
    group => root,
    mode => 755,
    source => "puppet:///modules/site_profile/usr/local/bin/mysql-backup.sh",
  }

}
