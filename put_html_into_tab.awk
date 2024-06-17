BEGIN { c=1}
/<p class="city-item-vehicle"><i class="fa fa-map-marker" aria-hidden="true"><\/i>/{
	getline
	val["GARAGE_NAME", c]=$0
}

/<li class="item-vehicle"/{
	getline
	split($0, ar, /href="/)
	split(ar[2], ar1, /"/)
	val["ANNONCE_LINK", c]="https://www.used-renault-trucks.fr"ar1[1]
	gsub(".*-", "", ar1[1])
	val["ID_CLIENT", c]=ar1[1]
	
	c++
}
/<p class="year-item-vehicle">/{
	split($0, ar, /datetime="/)
	split(ar[2], ar1, /-/)
	val["ANNEE", c]=ar1[1]
	val["MOIS", c]=ar1[2]
}
/<p class="km-item-vehicle"><i class="fa fa-tachometer" aria-hidden="true"><\/i>/{
	split($0, ar, /<p class="km-item-vehicle"><i class="fa fa-tachometer" aria-hidden="true"><\/i>/)
	split(ar[2], ar1, /</)
	gsub("[^0-9]", "", ar1[1])
	val["KM", c]=ar1[1]
}

END {
	max_c=c
	for(c=1;c<max_c; c++) {	
		for(i=1; i<max_i; i++) {
		
			gsub("\r|\t", "", val[title[i], c])
			gsub("\"", "", val[title[i], c])
			printf("%s\t", trim(val[title[i], c])) 					
		}
		printf("\n")
	}
}

function ltrim(s) {
	gsub("^[ \t]+", "", s);
	return s
}

function rtrim(s) {
	gsub("[ \t]+$", "", s);
	return s
}

function trim(s) {
	return rtrim(ltrim(s));
}
