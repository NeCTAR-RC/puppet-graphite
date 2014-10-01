define graphite::carbon::cache::process(
  $line_receiver_port=undef,
  $pickle_receiver_port=undef,
  $cache_query_port=undef,
  $local_data_dir=undef)
{

  Ini_setting {
      path    => '/etc/carbon/carbon.conf'
  }

  if ($line_receiver_port != undef) {
    ini_setting {"carbon_cache_${name}_line_receiver_port":
      ensure  => present,
      section => "cache:${name}",
      setting => 'LINE_RECEIVER_PORT',
      value   => $line_receiver_port,
    }

    nagios::nrpe::service { "carbon_cache_${name}_line_receiver_port":
      check_command => "/usr/lib/nagios/plugins/check_tcp -H localhost -p ${line_receiver_port}";
    }

  } else {
    ini_setting {"carbon_cache_${name}_line_receiver_port":
      ensure  => absent,
      section => "cache:${name}",
    }
  }

  if ($pickle_receiver_port != undef) {
    ini_setting {"carbon_cache_${name}_pickle_receiver_port":
      ensure  => present,
      section => "cache:${name}",
      setting => 'PICKLE_RECEIVER_PORT',
      value   => $pickle_receiver_port,
    }

    nagios::nrpe::service { "carbon_cache_${name}_pickle_receiver_port":
      check_command => "/usr/lib/nagios/plugins/check_tcp -H localhost -p ${pickle_receiver_port}";
    }

  } else {
    ini_setting {"carbon_cache_${name}_pickle_receiver_port":
      ensure  => absent,
      section => "cache:${name}",
    }
  }

  if ($cache_query_port != undef) {
    ini_setting {"carbon_cache_${name}_cache_query_port":
      ensure  => present,
      section => "cache:${name}",
      setting => 'CACHE_QUERY_PORT',
      value   => $cache_query_port,
    }

    nagios::nrpe::service { "carbon_cache_${name}_cache_query_port":
      check_command => "/usr/lib/nagios/plugins/check_tcp -H localhost -p ${cache_query_port}";
    }

  } else {
    ini_setting {"carbon_cache_${name}_cache_query_port":
      ensure  => absent,
      section => "cache:${name}",
    }
  }

  if ($local_data_dir != undef) {
    ini_setting {"carbon_cache_${name}_local_data_dir":
      ensure  => present,
      section => "cache:${name}",
      setting => 'LOCAL_DATA_DIR',
      value   => $local_data_dir,
    }
  } else {
    ini_setting {"carbon_cache_${name}_local_data_dir":
      ensure  => absent,
      section => "cache:${name}",
    }
  }


}
