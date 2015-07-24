# See README.md for details.
define boundary::meter (
  $ensure,
  $token,
  $meter = $::fqdn,
  $tags = []

) {

  boundary_meter ( $meter, $ensure, $token, $tags )

}