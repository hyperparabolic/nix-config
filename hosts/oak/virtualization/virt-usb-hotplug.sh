#!/usr/bin/env bash

connection="qemu:///system"

if [ $# -lt 3 ]; then
    echo "Usage: <domain> [ a | d ] [ [ # | <vendor_id>:<product_id> ] ... ]"
    exit 1
fi

domain="$1"
shift 1

case $1 in
    "attach" | "a")
        action="attach-device"
        ;;
    "detach" | "d")
        action="detach-device"
        ;;
    *)
        echo "Usage: <domain> [ a | d ] [ [ # | <vendor_id>:<product_id> ] ... ]"
        exit 1
esac
shift 1

for o in "$@"; do
    case $o in
        "1")
            # xbox controller
            vendor_id="045e"
            product_id="028e"
            ;;
        "2")
            vendor_id="057e"
            product_id="2009"
            ;;
        "3")
            vendor_id="054c"
            product_id="09cc"
            ;;
        *)
            IFS=":" read -r vendor_id product_id <<< "$o"
            ;;
    esac

    tmpfile=$(mktemp --suffix=.xml)
    echo "<hostdev mode=\"subsystem\" type=\"usb\" managed=\"yes\"><source><vendor id=\"0x$vendor_id\"/><product id=\"0x$product_id\"/></source></hostdev>" > "$tmpfile"
    echo "$tmpfile"
    echo "vendor_id=\"0x$vendor_id\""
    echo "product_id=\"0x$product_id\""

    virsh -c "$connection" "$action" "$domain" --file "$tmpfile" --live
done
