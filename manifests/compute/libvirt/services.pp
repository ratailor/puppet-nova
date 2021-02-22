# == Class: nova::compute::libvirt::services
#
# Install and manage libvirt services.
#
# === Parameters:
#
# [*libvirt_service_name*]
#   (optional) libvirt service name.
#   Defaults to $::nova::params::libvirt_service_name
#
# [*virtlock_service_name*]
#   (optional) virtlock service name.
#   Defaults to $::nova::params::virtlock_service_name
#
# [*virtlog_service_name*]
#   (optional) virtlog service name.
#   Defaults to $::nova::params::virtlog_service_name
#
# [*libvirt_virt_type*]
#   (optional) Libvirt domain type. Options are: kvm, lxc, qemu, parallels
#   Defaults to 'kvm'
#
# [*enable_modular_libvirt_daemons*]
#   (optional) Whether to enable modular libvirt daemons or use monolithic
#   libvirt daemon.
#   Defaults to $::nova::params::enable_modular_libvirt_daemons
#
# [*virtsecret_service_name*]
#   (optional) virtsecret service name.
#   Defaults to $::nova::params::virtsecret_service_name
#
# [*virtnodedevd_service_name*]
#   (optional) virtnodedevd service name.
#   Defaults to $::nova::params::virtnodedevd_service_name
#
# [*virtqemu_service_name*]
#   (optional) virtqemu service name.
#   Defaults to $::nova::params::virtqemu_service_name
#
# [*virtproxy_service_name*]
#   (optional) virtproxy service name.
#   Defaults to $::nova::params::virtproxy_service_name
#
# [*virtstorage_service_name*]
#   (optional) virtstorage service name.
#   Defaults to $::nova::params::virtstorage_service_name
#
class nova::compute::libvirt::services (
  $libvirt_service_name           = $::nova::params::libvirt_service_name,
  $virtlock_service_name          = $::nova::params::virtlock_service_name,
  $virtlog_service_name           = $::nova::params::virtlog_service_name,
  $libvirt_virt_type              = 'kvm',
  $enable_modular_libvirt_daemons = $::nova::params::enable_modular_libvirt_daemons,
  $virtsecret_service_name        = $::nova::params::virtsecret_service_name,
  $virtnodedev_service_name       = $::nova::params::virtnodedev_service_name,
  $virtqemu_service_name          = $::nova::params::virtqemu_service_name,
  $virtproxy_service_name         = $::nova::params::virtproxy_service_name,
  $virtstorage_service_name       = $::nova::params::virtstorage_service_name
) inherits nova::params {

  include nova::deps
  include nova::params

  if $libvirt_service_name {
    # libvirt-nwfilter
    if $::osfamily == 'RedHat' {
      package { 'libvirt-nwfilter':
        ensure => present,
        name   => $::nova::params::libvirt_nwfilter_package_name,
        before => Service['libvirt'],
        tag    => ['openstack', 'nova-support-package'],
      }
      case $libvirt_virt_type {
        'qemu': {
          $libvirt_package_name_real = "${::nova::params::libvirt_daemon_package_prefix}kvm"
        }
        'parallels': {
          $libvirt_package_name_real = $::nova::params::libvirt_package_name
        }
        default: {
          $libvirt_package_name_real = "${::nova::params::libvirt_daemon_package_prefix}${libvirt_virt_type}"
        }
      }
    } else {
      $libvirt_package_name_real = $::nova::params::libvirt_package_name
    }

    # libvirt
    package { 'libvirt':
      ensure => present,
      name   => $libvirt_package_name_real,
      tag    => ['openstack', 'nova-support-package'],
    }
    service { 'libvirt' :
      ensure  => running,
      enable  => true,
      name    => $libvirt_service_name,
      require => Anchor['nova::install::end'],
    }

    # messagebus
    if($::osfamily == 'RedHat' and $::operatingsystem != 'Fedora') {
      service { 'messagebus':
        ensure => running,
        enable => true,
        name   => $::nova::params::messagebus_service_name,
      }
      Package['libvirt'] -> Service['messagebus'] -> Service['libvirt']
    }

    # when nova-compute & libvirt run together
    Service['libvirt'] -> Service<| title == 'nova-compute'|>
  }


  if $virtlock_service_name {
    service { 'virtlockd':
      ensure => running,
      enable => true,
      name   => $virtlock_service_name,
    }
    Package<| name == 'libvirt' |> -> Service['virtlockd']
  }

  if $virtlog_service_name {
    service { 'virtlogd':
      ensure => running,
      enable => true,
      name   => $virtlog_service_name,
    }
    Package<| name == 'libvirt' |> -> Service['virtlogd']
  }
  if $libvirt_service_name and $virtlog_service_name {
    Service['virtlogd'] -> Service['libvirt']
  }

  if $enable_modular_libvirt_daemons {
    if $virtlog_service_name {
      Package<| name == 'libvirt' |> -> Service['virtlogd']
    }

    if $virtsecret_service_name {
      service { 'virtsecretd':
        ensure => running,
        enable => true,
        name   => $virtsecret_service_name,
      }
      Package<| name == 'libvirt' |> -> Service['virtsecretd']
      Service['virtlogd'] -> Service['virtsecretd']
    }

    if $virtnodedev_service_name {
      service { 'virtnodedevd':
        ensure => running,
        enable => true,
        name   => $virtnodedev_service_name,
      }
      Package<| name == 'libvirt' |> -> Service['virtnodedevd']
      Service['virtlogd'] -> Service['virtnodedevd']
    }

    if $virtqemu_service_name {
      service { 'virtsecretd':
        ensure => running,
        enable => true,
        name   => $virtqemu_service_name,
      }
      Package<| name == 'libvirt' |> -> Service['virtqemud']
      Service['virtlogd'] -> Service['virtqemud']
    }

    if $virtproxy_service_name {
      service { 'virtproxyd':
        ensure => running,
        enable => true,
        name   => $virtproxy_service_name,
      }
      Package<| name == 'libvirt' |> -> Service['virtproxyd']
      Service['virtlogd'] -> Service['virtproxyd']
    }

    if $virtstorage_service_name {
      service { 'virtstoraged':
        ensure => running,
        enable => true,
        name   => $virtstorage_service_name,
      }
      Package<| name == 'libvirt' |> -> Service['virtstoraged']
      Service['virtlogd'] -> Service['virtstoraged']
    }
  }
}
