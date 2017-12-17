ad_library {

    Callback procs for Cookie Consent Library into OpenACS


    @author Gustaf Neumann
    @creation-date 13 Dec 2017
    @cvs-id $Id$
}

namespace eval ::cookieconsent {

    #
    # Provide hooks for installing/uninstalling the package
    #
    ad_proc -private after-install {} {
	#
	# Add additional parameters to acs-subsite
	#
	foreach {name description default datatype} {
	    "Enabled"
	    "Enable/Disable Cookie Consent for this Subsite"
	    "0" "number"

	    "Layout"
	    "Layout of the Cookie Consent Widget; possible values: block|classic|edgeless|wire"
	    "block" "string"

	    "LearnMoreLink"
	    "Link for learning more about Cookies"
	    "https://cookiesandyou.com/" "string"

	    "Palette"
	    "Color palette for the Cookie Consent Widget; possible values: default|oacs|honeybee|mono|neon|corporate"
	    "default" "string"

	    "Position"
	    "Position of the Cookie Consent Widget; possible values: bottom|top|pushdown|left|right"
	    "pushdown" "string"

	    "DefaultPalette"
	    "Default style: use the following settings, when CookieConsentPalette is set to 'default'"
	    "popup {text #fff background #004570} button {text #000 background #f1d600}" "string"

	} {
	    apm_parameter_register "CookieConsent$name" \
		$description "acs-subsite" $default $datatype "Cookie Consent"
	}
    }

    ad_proc -private before-uninstall {} {
	#
	# Remove the package specific parameters from acs-subsite
	#
	foreach parameter {
	    Enabled
	    Layout
	    LearnMoreLink
	    Palette
	    Position
	    DefaultPalette
	} {
	    ns_log notice [list apm_parameter_unregister \
			       -parameter "CookieConsent$parameter" \
			       -package_key "acs-subsite" \
			       "" ]
	    ::try {
		apm_parameter_unregister \
		    -parameter "CookieConsent$parameter" \
		    -package_key "acs-subsite" \
		    ""
	    } on error {errMsg} {
		ns_log notice "apm_parameter_unregister of parameter CookieConsent$parameter lead to: $errMsg"
	    }
	}
    }


    #
    # Register a "page_plugin" callback for the subsite. In case, this
    # is used with an OpenACS version earlier than 5.10.0d2, this is
    # essentially no-op operation; the site admin has to add the
    # "::cookieconsent::initialize_widget" manually to the templates.
    #
    ad_proc -public -callback subsite::page_plugin -impl cookie-consent {
    } {
	Implementation of subsite::page_plugin for cookie-consent
    } {
	::cookieconsent::initialize_widget
    }

}
