BEGIN{
    FS=" "
    # OFS=","
}
{
    # if (match($0, /#+ <a name="([^"]*)"><\/a>(.*)/, arr)) {
    #     print "["arr[2]"]""(#"arr[1]")"
    # }
    
    # a = $0
    # b =gensub(/#+ <a name="([^"]*)"><\/a>(.*)/,"[\\2](#\\2)","g",a)
    # print b

    # if (tolower($0) ~ /to|he/ && /World|No/){
    #     print $0
    # } 

    print gensub(/\<(imp|ant|(\w*))\>/,"(\\2)","g")
}

# when you have a txt file like this '_;3%,.,=-=,:'
# what would be the answer when run gensub(/\W*[^,]/,"42",2)
END{

}

# # awk 'gsub(/\([^()]*)/, "")' patterns.txt
#  awk 'gsub(/#+ <a name="([^"]/,"[&]")' anchors.txt

# when your command is like below, how to print grouping
#  awk '/#+ <a name="([^"]*)"><\/a>(.*)/' anchors.txt
