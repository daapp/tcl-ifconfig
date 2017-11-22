tcl::tm::path add ../lib

package require ifconfig

foreach {k v} [dict get [ifconfig lo] lo] {
    puts "lo: $k = $v"
}
puts ""


set conf [ifconfig -a]
foreach iface [dict keys $conf] {
    puts "--- $iface ---"
    foreach {k v} [dict get $conf $iface] {
        puts "$k = $v"
    }
    puts ""
}
