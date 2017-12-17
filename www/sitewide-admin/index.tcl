set title "Cookie Consent Sitewide Admin"
set context [list $title]

set resource_prefix [acs_package_root_dir cookie-consent/www/resources]
set what "Cookie Consent Widget"
set version $::cookieconsent::version

#
# Get version info about the resource files of this package. If not
# locally installed, offer a link for download.
#
set version_info [::cookieconsent::version_info]
set first_css [lindex [dict get $version_info cssFiles] 0]

if {[file exists $resource_prefix/$version/$first_css]} {
    set resources $resource_prefix/$version
}
set cdn [dict get $version_info cdn]

set path $resource_prefix/$version
if {![file exists $path]} {
    catch {file mkdir $path}
}
set writable [file writable $path]
