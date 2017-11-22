# name is "-a" or "-all" or "interface name"
proc ifconfig {{name ""}} {
    set ifaceRE {^[a-z]+\d*}
    set ifaceOnlyRE "$ifaceRE$"
    set key ""
    switch -regexp -- $name [list \
                                 {^$} {} \
                                 {^-all$} - {^-a$} {
                                     set key -a
                                 } \
                                 $ifaceRE {
                                     set key $name
                                 } \
                                 default {
                                     return -code error "invalid key \"$name\", should be -all or interface name"
                                 }
                            ]

    if {[catch {exec ifconfig {*}$key} result]} {
        return -code error $result
    } else {
        set state NAME
        set config [dict create]
        set ifName ""
        set params [list]
        foreach line [split $result \n] {
            switch -- $state {
                NAME {
                    if {[regexp "($ifaceRE): flags=.*" $line -> ifName]} {
                        set state INFO
                        dict set config $ifName [dict create]
                    }
                }
                INFO {
                    if {$line eq ""} {
                        set state NAME
                        dict set config $ifName $params
                        set ifName ""
                    } else {
                        switch -regexp -- $line {
                            {^\s+inet } {
                                lappend params {*}$line
                            }
                            {^\s+inet6 } {
                                lappend params {*}$line
                            }
                        }
                    }
                }
            }
        }
        return $config
    }
}
