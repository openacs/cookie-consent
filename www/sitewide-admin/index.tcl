ad_page_contract {
    @author Gustaf Neumann

    @creation-date Dec 22, 2017
} {
}

set title "Cookie Consent Sitewide Admin"
set context [list $title]

set what "Cookie Consent Widget"
set version $::cookieconsent::version

#
# Get version info about the resource files of this package. If not
# locally installed, offer a link for download.
#
set resource_info [::cookieconsent::resource_info]
set resource_dir  [dict get $resource_info resourceDir]
set cdn           [dict get $resource_info cdn]

#
# Check, if the resources are already installed.
#
set is_installed [::util::resources::is_installed_locally \
		      -resource_info $resource_info \
		      -version_dir $version ]
if {$is_installed} {
    #
    # Tell the users, where the resources are installed.
    #
    set resources $resource_dir/$version

} else {
    #
    # Check, if we can install the resources locally.
    #
    set writable [util::resources::can_install_locally \
		      -resource_info $resource_info \
		      -version_dir $version]
    if {!$writable} {
	#
	# If we cannot install locally, tell the user were we want to
	# install.
	#
	set path $resource_dir/$version
    }
}
