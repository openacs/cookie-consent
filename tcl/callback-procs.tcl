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

            "ExpiryDays"
            "Lifetime of the cookie"
            "365" "number"
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
            ExpiryDays
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

    ad_proc -private after-upgrade {
        -from_version_name
        -to_version_name
    } {
        After-upgrade callback.
    } {
        apm_upgrade_logic \
            -from_version_name $from_version_name \
            -to_version_name $to_version_name \
            -spec {
                0.7 0.8 {
                    foreach package_id [apm_package_ids_from_key -package_key cookie-consent] {
                        set old_value [parameter::get -package_id $package_id -parameter Version]
                        ns_log notice \
                            "cookie-conset: after upgrade: check parameter 'Version'" \
                            "of package_id $package_id has value '$old_value'"

                        set new_value $old_value
                        regsub {cookieconsent2/} $old_value "" new_value

                        if {$old_value ne $new_value} {
                            parameter::set_value \
                                -package_id $package_id \
                                -parameter Version \
                                -value $new_value

                            ns_log notice \
                                "cookie-conset: after upgrade: parameter 'Version'" \
                                "of package_id $package_id" \
                                "changed from '$old_value' to '$new_value'"

                        }
                    }
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

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
