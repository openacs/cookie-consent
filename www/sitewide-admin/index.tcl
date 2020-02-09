ad_page_contract {
    @author Gustaf Neumann

    @creation-date Dec 22, 2017
} {
}

set version $::cookieconsent::version
set resource_info [::cookieconsent::resource_info]

set title "[dict get $resource_info resourceName] - Sitewide Admin"
set context [list $title]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
