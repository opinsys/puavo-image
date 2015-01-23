class image::wirelessaccesspoint {
  include image::bundle::basic,
	  packages

  Apt::Key        <| title == "opinsys-repo.gpgkey" |>
  Apt::Repository <| title == archive
                  or title == kernels
                  or title == repo |>

  # wirelessaccesspoint should be able to function as a wireless accesspoint
  # (puavo-wlanap*) and as a digital signage system (iivari-client)
  Package <| tag == admin
          or tag == basic
          or title == iivari-client
          or title == puavo-wlanap
          or title == puavo-wlanap-dnsproxy |>
}
