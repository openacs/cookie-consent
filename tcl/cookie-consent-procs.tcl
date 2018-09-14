ad_library {

    Integration of the Cookie Consent Library into OpenACS

    The Cookie Consent Library is and Cookie Consent to be free and
    open sourced library for alerting users about the use of
    cookies on a website.  It is designed to help you comply with the
    hideous EU Cookie Law and not make you want to kill yourself in
    the process. So we made it fast, free, and relatively painless.

    Details:
    https://cookieconsent.insites.com/
    https://github.com/insites/cookieconsent/

    This package integrates the Consent Plugin with OpenACS,
    in particular with OpenACS subsites.

    @author Gustaf Neumann
    @creation-date 13 Dec 2017
    @cvs-id $Id$
}

namespace eval ::cookieconsent {

    set package_id [apm_package_id_from_key "cookieconsent"]

    #
    # It is possible to configure the version of the cookie consent
    # widget also via NaviServer config file:
    #
    #   ns_section ns/server/${server}/acs/cookie-consent
    #      ns_param version cookieconsent2/3.0.3
    #

    set version [parameter::get \
                     -package_id $package_id \
                     -parameter Version \
                     -default cookieconsent2/3.0.3]

    ad_proc -private get_relevant_subsite {} {
    } {
        set dict [security::get_register_subsite]
        if {![dict exists $dict subsite_id]} {
            set host_node_id [dict get $dict host_node_id]
            if {$host_node_id == 0} {
                #
                # Provide compatibility with older versions of
                # get_register_subsite, not returning the
                # host_node_id. In such cases, we get the host_node_id
                # via the URL
                #
                set node_info [site_node::get_from_url -url [dict get $dict url]]
                set host_node_id [dict get $node_info node_id]
            }
            set subsite_id [site_node::get_object_id -node_id $host_node_id]
        } else {
            set subsite_id [dict get $dict subsite_id]
        }
        return $subsite_id
    }

    ad_proc reset_cookie {
        {-subsite_id ""}
    } {

        Reset the consent cookie.

    } {
        if {$subsite_id eq ""} {
            set subsite_id [get_relevant_subsite]
        }
        ad_unset_cookie "cookieconsent_status-$subsite_id"
    }

    #
    # Create the Class for configuring the cookie consent widget.
    # This class requires nx from the next-scripting framework.
    #
    #     https://next-scripting.org/xowiki/
    #
    # which is automatically installed for XOTcl2 via
    # https://openacs.org/xowiki/naviserver-openacs
    #
    nx::Class create CookieConsent {
        :property {position             pushdown};# bottom|top|pushdown|left|right
        :property {layout               block}   ;# block|classic|edgeless|wire
        :property {palette              default} ;# default|oacs|honeybee|mono|neon|corporate
        :property {learn-more-link      https://cookiesandyou.com/}
        :property {default-palette      {popup {text #fff background #004570} button {text #000 background #f1d600}}}

        :property {compliance-type      inform}  ;# inform|opt-out|opt-in
        :property {message-text        "#cookie-consent.message#"}
        :property {dismiss-button-text "#cookie-consent.dismiss-button-text#"}
        :property {policy-link-text    "#cookie-consent.policy-link-text#"}

        :property {subsite_id:required}

        :public method render_js {} {
            #
            # Perform the actual rendering of the cookie consent widget.
            #

            set static false
            if {${:position} eq "pushdown"} {
                set position top
                set static true
            } elseif  {${:position} in {"left" "right"}} {
                set position bottom-${:position}
            } else {
                set position ${:position}
            }

            #
            # Set up a dictionary for the palette with common
            # settings:
            #
            set d {popup {text #fff} button {text #000}}

            #
            # Update the default palette based on the value of the
            # passed-in palette.
            #
            switch ${:palette} {
                oacs {
                    dict set d popup background \#004570
                    dict set d button background \#f1d600
                }
                honeybee {
                    dict set d popup background \#000
                    dict set d button background \#f1d600
                }
                mono {
                    dict set d popup background \#237afc
                    dict set d button background transparent
                    dict set d button text \#fff
                    dict set d button border \#fff
                }
                neon {
                    dict set d popup background \#1d8a8a
                    dict set d button background \#62ffaa
                }
                corporate {
                    dict set d popup background \#edeff5
                    dict set d popup text \#838391
                    dict set d button background \#4b81e8
                }
                default {
                    set d ${:default-palette}
                }
            }

            #
            # We have to juggle the colors depending on the layout
            #
            set buttonBackground [dict get $d button background]
            set buttonTextColor  [dict get $d button text]
            if {[dict exists $d button border]} {
                set buttonBorder [dict get $d button border]
            } else {
                set buttonBorder $buttonBackground
            }
            switch ${:layout} {
                block    -
                classic  -
                edgeless {set theme ${:layout}}
                wire     {
                    set theme block
                    set buttonBackground transparent
                    set buttonTextColor  [dict get $d button background]
                }
            }

            #
            # Use different cookies dependent on the subsite
            #
            set cookie_name "cookieconsent_status-${:subsite_id}"

            set js [subst {
                window.addEventListener("load", function(){
                    window.cookieconsent.initialise({
                        "palette": {
                            "popup": {
                                "background": "[dict get $d popup background]",
                                "text":       "[dict get $d popup text]",
                            },
                            "button": {
                                "background": "$buttonBackground",
                                "border":     "$buttonBorder",
                                "text":       "$buttonTextColor"
                            }
                        },
                        "cookie": {
                            "name":       "$cookie_name",
                            "path":       "/",
                            "domain":     "",
                            "expiryDays": "365"
                        },
                        "theme":    "$theme",
                        "position": "$position",
                        "static":   $static,
                        "content": {
                            "message": "[lang::util::localize ${:message-text}]",
                            "dismiss": "[lang::util::localize ${:dismiss-button-text}]",
                            "link":    "[lang::util::localize ${:policy-link-text}]",
                            "href":    "${:learn-more-link}",
                            "header":  "Cookies used on the website!",
                            "deny":    "Decline",
                            "allow":   "Allow cookies"
                        }
                    })});
            }]
            return $js
        }
    }

    ad_proc initialize_widget {
        {-subsite_id ""}
    } {

        Initialize an cookie-consent widget.

    } {
        if {[catch {ns_conn content}]} {
            #
            # If the connection is already closed, do nothing.
            #
            # "ns_conn content" will raise an exception, when the
            # connection is already closed. This is not obivous
            # without deeper knowledge. Therefore, NaviServer needs
            # probably a "ns_conn closed" flag the check for such
            # situations in a more self-expanatory way.
            #
            return
        }

        if {$subsite_id eq ""} {
            set subsite_id [get_relevant_subsite]
        }

        set enabled_p [parameter::get \
                           -package_id $subsite_id \
                           -parameter CookieConsentEnabled \
                           -default 0]
        #
        # Just do real initialization, when the cookie is NOT set.
        # When more complex interactions are defined, this has to be
        # reconsidered.
        #
        set cookie_set [ad_get_cookie "cookieconsent_status-$subsite_id" ""]

        if {$enabled_p && $cookie_set eq ""} {
            #
            # Create an instance of the consent widget class from all configuration options
            #
            foreach {param default} {
                Layout         block
                Palette        oacs
                Position       bottom
                LearnMoreLink  https://cookiesandyou.com/
                DefaultPalette "popup {text #fff background #004570} button {text #000 background #f1d600}"
            } {
                set p($param) [parameter::get \
                                  -package_id $subsite_id \
                                  -parameter CookieConsent$param \
                                  -default $default]
            }

            set c [CookieConsent new \
                       -subsite_id      $subsite_id \
                       -position        $p(Position) \
                       -palette         $p(Palette) \
                       -layout          $p(Layout) \
                       -learn-more-link $p(LearnMoreLink) \
                       -default-palette $p(DefaultPalette) \
                      ]
            #
            # ... and add it to the page
            #
            add_to_page -version "" $c
            $c destroy
        }
    }


    ad_proc resource_info {
        {-version ""}
    } {

        Get information about available version(s) of the
        cookieconsent packages, either from the local file system, or
        from CDN.

	@return dict containing resourceDir, resourceName, cdn,
	        cdnHost, prefix, cssFiles, jsFiles and extraFiles.
    } {
        #
        # If no version of the cookie consent library was specified,
        # use the name-spaced variable as default.
        #
        if {$version eq ""} {
            set version $::cookieconsent::version
        }

        #
        # Provide paths for loading either via resources or CDN
        #
        set resourceDir [acs_package_root_dir cookie-consent/www/resources]
        set cdn         "//cdnjs.cloudflare.com/ajax/libs"

        #
        # If the resources are not available locally, these will be
        # loaded via CDN and the CDN host is set (necessary for CSP).
        # The returned "prefix" indicates the place, from where the
        # resource will be loaded.
        #
        if {[file exists $resourceDir/$version]} {
            set prefix /resources/cookie-consent/$version/
            set cdnHost ""
        } else {
            set prefix $cdn/$version/
            set cdnHost cdnjs.cloudflare.com
        }
        lappend result \
            resourceName "Cookie Consent Widget" \
            resourceDir $resourceDir \
            cdn $cdn \
            cdnHost $cdnHost \
            prefix $prefix \
            cssFiles {cookieconsent.min.css} \
            jsFiles  {cookieconsent.min.js} \
            extraFiles {}

        return $result
    }


    ad_proc add_to_page {
        {-version ""}
        object
    } {
        Add the necessary CSS, JavaScript and CSP to the current
        page.
    } {
        set resource_info [resource_info -version $version]

        if {[dict exists $resource_info cdnHost] && [dict get $resource_info cdnHost] ne ""} {
            security::csp::require script-src [dict get $resource_info cdnHost]
            security::csp::require style-src [dict get $resource_info cdnHost]
        }
        set prefix [dict get $resource_info prefix]

        foreach cssFile [dict get $resource_info cssFiles] {
            template::head::add_css -href $prefix/$cssFile
        }
        foreach jsFile [dict get $resource_info jsFiles] {
            template::head::add_javascript -src $prefix/$jsFile
        }

        ::template::add_body_script -script [$object render_js]
    }

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
