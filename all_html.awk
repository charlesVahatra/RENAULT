BEGIN {	
	i=1	
	title[i]="TELEPHONE";		i++;
	title[i]="KM";		i++;
	title[i]="PUISSANCE";		i++;
	title[i]="CP";		i++;
	title[i]="CYLINDRE";		i++;
	title[i]="PORTE";		i++;
	title[i]="CAROSSERIE";		i++;
	title[i]="CARBURANT";		i++;
	title[i]="ANNEE";		i++;
	title[i]="TRANSMISSION";		i++;
	title[i]="BOITE";		i++;
	max_i=i
}
/<h2 class="spec-block-pdp">/{
	getline
	getline
	getline
	getline
	gsub("[^0-9]", "", $0)
	val["KM"]=$0

}
/"mpn": "/{
	split($0, ar, /"mpn": "/)
	split(ar[2], ar1, /"/)
	val["ID_CLIENT"]=ar1[1]
}
/<a href="tel:/{
	split($0, ar, /<a href="tel:/)
	split(ar[2], ar1, /"/)
	gsub("[^0-9]", "", ar1[1])
	val["TELEPHONE"]=ar1[1]
}

/<ul class="list-block-pdp">/{
		getline
		getline
		getline
		getline
		getline
		getline
		getline
		getline
		gsub("[^0-9]", "", $0)
		val["PUISSANCE"]=$0
		getline
		getline
		getline
		getline
		gsub("[^0-9]", "", $0)
		val["CYLINDRE"]=$0
		getline
		getline
		getline
		getline
		val["CARBURANT"]=$0
}
/<p class="address-contact-pdp">/{
	getline
	getline
	getline
	gsub("[^0-9]", "", $0)
	val["CP"]=$0
}
/class="txt-block-caract">Boîte de vitesses : <\/p>/{
	getline
	getline
	getline
	split($0, ar, /<p class="txt-block-caract">/)
	split(ar[2], ar1, /<\/p>/)
	val["BOITE"]=ar1[1]
}
END {	
	for (i=1; i<max_i; i++) {		
		gsub(/"|\t|\r|\n|\\/, "", val[title[i]])			
		if (trim(val[title[i]])!="")
			upd=upd" "sprintf("%s=\"%s\",", title[i], trim(val[title[i]]))	
	}
	if (upd!="")
		printf ("update %s set %s id_client=\"%s\" where site=\"renault\" and ID_CLIENT=\"%s\";\n", table, upd, val["ID_CLIENT"], val["ID_CLIENT"])
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
