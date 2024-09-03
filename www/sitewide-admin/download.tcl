ad_page_contract {
    @author Gustaf Neumann

    @creation-date Dec 13, 2017
} {
    {version:token,notnull ""}
}

::util::resources::download \
    -resource_info [::cookieconsent::resource_info -version $version]

ad_returnredirect .

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
