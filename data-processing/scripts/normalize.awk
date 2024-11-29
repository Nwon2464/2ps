BEGIN {
    FS = ","
    OFS = ","
}
{
    if(NR ==1 ){
        print; 
        next
    }else{
        if(length($5) == 10){
            gsub(/[^a-zA-Z0-9]/,"-",$5)
        }else{
            $5 = "0000-00-00"           
        }
    }    
    print $0
}