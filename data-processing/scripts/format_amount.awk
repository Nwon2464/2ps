function format_amount(amount) {
    return sprintf("%.4f", amount)
}
function is_valid_amount(amount) {
    if (amount == "" || amount == "NULL" || amount == "null" || amount =="NaN" || amount == "NAN" || amount < 0) {
        return 0
    }
    if (amount !~ /^[0-9]*\.?[0-9]+$/) {
        return 0 
    }  
    if (amount ~ /,/) {
        return 0 
    }
    if (amount > 1000000000) {
        return 0 
    }
    if (amount == "-0" || amount == "-0.0000") {
        return 0
    }
    return 1 
}

BEGIN {
    FS = ","
    OFS = ","
}

{
    if(NR ==1 ){
        print; 
        next
    }else{
        if(is_valid_amount($4)){
            $4 = format_amount($4)
        }else{
            $4 = "Invalid"
        }
    }
    print $0
}
