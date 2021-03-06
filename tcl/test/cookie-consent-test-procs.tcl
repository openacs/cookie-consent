ad_library {

    Tests for cookie consent widget

    @author Gustaf Neumann
    @creation-date 2021-03-06
}

aa_register_case \
    -cats {api} \
    -procs {
        ad_conn
        ad_get_cookie
        ad_set_cookie
        cookieconsent::CookieConsent instproc render_js
        cookieconsent::add_to_page
        cookieconsent::initialize_widget
        cookieconsent::reset_cookie
        cookieconsent::resource_info
        parameter::get
    } \
    cookie_consent__setup {

        Test setup of cookie consent widget. This test checks only for
        hard errors and does not try evaluate the user experience (for
        that we could develop a web test).

    } {

    set info [cookieconsent::resource_info]
    set keys [dict keys $info]
    foreach att {resourceName resourceDir cdn cdnHost prefix cssFiles jsFiles extraFiles} {
        aa_true "resource info contains $att" [dict exists $info $att]
    }
    set subsite_id [ad_conn subsite_id]
    set cookie_name "cookieconsent_status-$subsite_id"

    set enabled_p [parameter::get \
                       -package_id $subsite_id \
                       -parameter CookieConsentEnabled \
                       -default 0]
    aa_log "CookieConsentEnabled $enabled_p"
    set cookie [ad_get_cookie $cookie_name ""]
    aa_log "cookie $cookie_name -> '$cookie'"

    #
    # Clear the cookie to trigger calls to "add_to_page".
    #
    cookieconsent::reset_cookie -subsite_id $subsite_id
    cookieconsent::initialize_widget -subsite_id $subsite_id

    #
    # Restore the previous cookie.
    #
    ad_set_cookie $cookie_name $cookie
}


#
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
