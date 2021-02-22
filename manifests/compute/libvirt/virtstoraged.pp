# == Class: nova::compute::libvirt::virtstoraged
#
# virtstoraged configuration
#
# === Parameters:
#
# [*log_level*]
#   Defines a log level to filter log outputs.
#   Defaults to undef
#
# [*log_filters*]
#   Defines a log filter to select a different logging level for
#   for a given category log outputs.
#   Defaults to undef
#
# [*log_outputs*]
#   (optional) Defines log outputs, as specified in
#   https://libvirt.org/logging.html
#   Defaults to undef
#
# [*ovs_timeout*]
#   (optional) A timeout for openvswitch calls made by libvirt
#   Defaults to undef
#
class nova::compute::libvirt::virtstoraged (
  $log_level         = undef,
  $log_filters       = undef,
  $log_outputs       = undef,
  $ovs_timeout       = undef,
) {

  include nova::deps
  require nova::compute::libvirt

  if $log_level {
    virtstoraged_config {
      'log_level': value => $log_level;
    }
  }
  else {
    virtstoraged_config {
      'log_level': ensure => 'absent';
    }
  }

  if $log_filters {
    virtstoraged_config {
      'log_filters': value => "\"${log_filters}\"";
    }
  }
  else {
    virtstoraged_config {
      'log_filters': ensure => 'absent';
    }
  }

  if $log_outputs {
    virtstoraged_config {
      'log_outputs': value => "\"${log_outputs}\"";
    }
  }
  else {
    virtstoraged_config {
      'log_outputs': ensure => 'absent';
    }
  }

  if $ovs_timeout {
    virtstoraged_config {
      'ovs_timeout': value => $ovs_timeout;
    }
  } else {
    virtstoraged_config {
      'ovs_timeout': ensure => 'absent';
    }
  }

  Anchor['nova::config::begin']
  -> Virtstoraged_config<||>
  -> Anchor['nova::config::end']
}

