class image::bundle::desktop {
  include acroread,
          ::desktop,
          disable_accounts_service,
          disable_geoclue,
          # firefox,			# XXX iceweasel in Debian
          fontconfig,
          gnome_terminal,
          # graphics_drivers,		# XXX needs fixing for Debian
          image::bundle::basic,
          kaffeine,
          keyutils,
          ktouch,
          laptop_mode_tools,
          libreoffice,
          network_manager,
          puavo_wlan,
          # pycharm,	# XXX pycharm needs to be packaged for Debian
          # tuxpaint,	# XXX needs fixing for Debian
          wacom,
          workaround_firefox_local_swf_bug
          # xexit	# XXX requires puavo-ltsp-client
}
