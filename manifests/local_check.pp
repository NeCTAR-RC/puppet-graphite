# Local nagios checks for graphite services

define graphite::local_check (
  $interface,
  $port
) {

    if $interface == "0.0.0.0" or $interface == undef {
      $interface = 'localhost'
    } else {
      $interface = $interface
    }

    # There is a case where there is no defined port.  in that case we
    # can't exactly guess what it would be so just don't enable the
    # check.
    if $port != undef {
      nagios::nrpe::service { "${name}_check":
        check_command => "/usr/lib/nagios/plugins/check_tcp -H ${interface} -p ${port}";
      }
    }
}
