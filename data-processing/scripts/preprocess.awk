BEGIN {
    FS = ","
    OFS = ","
    header = ""
}
{
    if (NR == 1) {
        header = $0
        print
        next
    }
    if ($0 == header) {
        next
    }
    print
}