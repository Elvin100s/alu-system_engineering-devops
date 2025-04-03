# This Puppet script increases the ULIMIT of nginx default file to handle more concurrent connections
# It modifies both the soft and hard limits for the nginx process

# Increase ULIMIT in nginx default configuration
exec { 'increase-ulimit':
  command => '/bin/sed -i \'s/ULIMIT="-n 15"/ULIMIT="-n 4096"/\' /etc/default/nginx',
  notify  => Exec['set-hard-limit'],
}

# Increase hard limit for nginx processes
exec { 'set-hard-limit':
  command     => '/bin/sed -i \'1s/^/nginx\tsoft\tnofile\t4096\nnginx\thard\tnofile\t4096\n/\' /etc/security/limits.conf',
  refreshonly => true,
  notify      => Exec['restart-nginx'],
}

# Restart nginx to apply changes
exec { 'restart-nginx':
  command     => '/usr/sbin/service nginx restart',
  refreshonly => true,
}
