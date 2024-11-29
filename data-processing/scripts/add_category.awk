function categorize(amount){
    if(amount>=100){
        return "High"
    }else{
        return "Low"
    }
}
BEGIN{
    FS = ","
    OFS = ","
}
{
    
    if(NR ==1 ){
        $6 = "CATEGORY"
    }else{
        $6 = categorize($4)
    }
    print $0
}