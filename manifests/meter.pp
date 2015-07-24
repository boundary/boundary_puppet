# See README.md for details.
define boundary::meter (
  $ensure,
  $token,
  $tags = []

) {

  boundary_meter { $name:
    ensure => $ensure,
    token => $token,
    tags => $tags
}

}