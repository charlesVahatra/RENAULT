BEGIN {nb_annonce=0}
/<span class="color-red">/ {
	split($0, ar, /<span class="color-red">/)
	split(ar[2], ar1, /<\/span>/)
	    gsub("\r", "", ar1[1])
        gsub("[^0-9]", "", ar1[1])
        nb_annonce=ar1[1]
}
END{
        print ""nb_annonce""
}