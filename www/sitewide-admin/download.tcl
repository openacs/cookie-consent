ad_page_contract {
    @author Gustaf Neumann

    @creation-date Dec 13, 2017
} {
    {version:word,notnull ""}
}

if {$version eq ""} {
    set version $::cookieconsent::version
}
::util::resources::download \
    -version_dir $version \
    -resource_info [::cookieconsent::resource_info]

ad_returnredirect .
