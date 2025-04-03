# 1. Ensure nginx package is installed
package { 'nginx':
  ensure => installed,
}

# 2. Modify ULIMIT in nginx defaults (using more robust regex)
exec { 'increase-nginx-ulimit':
  command => "/bin/sed -i 's/^ULIMIT=.*/ULIMIT=\"-n 4096\"/' /etc/default/nginx",
  unless  => "grep -q '^ULIMIT=\"-n 4096\"' /etc/default/nginx",
  require => Package['nginx'],
  notify  => Exec['set-system-limits'],
}

# 3. Set system-wide limits (idempotent)
exec { 'set-system-limits':
  command     => "/bin/echo -e 'nginx soft nofile 4096\nnginx hard nofile 4096\n' >> /etc/security/limits.conf",
  unless      => "grep -q 'nginx.*nofile 4096' /etc/security/limits.conf",
  refreshonly => true,
  notify      => Service['nginx'],
}

# 4. Configure nginx worker connections
file_line { 'increase-worker-connections':
  path    => '/etc/nginx/nginx.conf',
  line    => 'worker_connections 4096;',
  match   => '^worker_connections',
  notify  => Service['nginx'],
}

# 5. Ensure nginx service
service { 'nginx':
  ensure     => running,
  enable     => true,
  hasrestart => true,
  require    => Package['nginx'],
}
