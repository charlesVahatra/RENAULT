BEGIN { j=1 }
/<div class="brand-list-selection">/ {
getline
getline
getline
getline
	split($0, ar, /modello-/)
	split(ar[2], ar1, />/)
	gsub(/["[:space:]]/, "", ar1[1])
	printf("model_name[%d]=\"%s\";\n", j, ar1[1])
j++
	nb=2
	for(i=1;i<=nb;i++) {
	getline
	getline
	getline
	getline
	getline
	split($0, ar, /modello-/)
	split(ar[2], ar1, />/)
	gsub(/["[:space:]]/, "", ar1[1])
	printf("model_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	}
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	split($0, ar, /modello-/)
	split(ar[2], ar1, />/)
	gsub(/["[:space:]]/, "", ar1[1])
	printf("model_name[%d]=\"%s\";\n", j, ar1[1])
	j++
	nb=34
	for(i=1;i<=nb;i++) {
	getline
	getline
	getline
	getline
	getline
	split($0, ar, /modello-/)
	split(ar[2], ar1, />/)
	gsub(/["[:space:]]/, "", ar1[1])
	printf("model_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	}
        exit
}
END {
        print "max_model="j""
}