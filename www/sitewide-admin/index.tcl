set title "Cookie Consent Sitewide Admin"
set context [list $title]

set resource_prefix [acs_package_root_dir cookie-consent/www/resources]
set what "Cookie Consent Widget"
set version $::cookieconsent::version


if {$::tcl_version eq "8.5"} {
    #
    # In Tcl 8.5, "::try" was not yet a built-in of Tcl
    #
    package require try 
}


#
# Get version info about the resource files of this package. If not
# locally installed, offer a link for download.
#
set version_info [::cookieconsent::version_info]
set first_css [lindex [dict get $version_info cssFiles] 0]
set cdn [dict get $version_info cdn]

set writable 1
if {![file isdirectory $resource_prefix]} {
    try {
	file mkdir $resource_prefix
    } on error {errorMsg} {
	set writable 0
    }
}

if {$writable} {
    if {[file exists $resource_prefix/$version/$first_css]} {
	set resources $resource_prefix/$version
    }
    set path $resource_prefix/$version
    if {![file exists $path]} {
	catch {file mkdir $path}
    }
    set writable [file writable $path]
} else {
    set path $resource_prefix
}

