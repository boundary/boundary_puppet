# See README.md for details.
define boundary::meter (
  $meter,
  $ensure,
  $token,
  $tags = []

) {
  boundary_meter { $meter:
    ensure  => $ensure,
    token   => $token,
    tags    => $tags,
    require => Package['boundary-meter'],
    notify  => Service['boundary-meter'],
  }

}