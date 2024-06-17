#!/bin/bash

ExitProcess () {
        status=$1
        if [ ${status} -ne 0 ]
        then
                echo -e $usage
                echo -e $error
        fi
        find ${dir}/ -type f -name "*.$$" -exec rm -f {} \;
        exit ${status}
}

function download_pages () {
	# url
	# output 
	curl "${url}" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'Cache-Control: max-age=0' \
  -H 'Connection: keep-alive' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: none' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"'> ${output} 
}

function download_list_multy_process (){

	awk 'BEGIN{FS="\t"}{print "if [ ! -s "$1" ]; then url=\""$2"\"; output=\""$1"\";  download_pages ; fi"}' ${list_file} > ${dir}/${d}/LISTING/${category}/wget_file.txt
    nb=`wc -l ${dir}/${d}/LISTING/${category}/wget_file.txt | awk '{print $1}' `
    let "split = (nb / nb_processus) + 1"
    split -l${split} -d ${dir}/${d}/LISTING/${category}/wget_file.txt  ${dir}/${d}/LISTING/${category}/wget_file.txt.
    i=0
    for wget_file in `ls ${dir}/${d}/LISTING/${category}/wget_file.txt.*`
    do
        echo -e "set -x\n">>${wget_file}
        . ${wget_file} >  ${dir}/${d}/LISTING/${category}/LOG/log_${i} 2>&1 &
        let "i=i+1"
    done
	wait
}

function download_detail_multy_process (){
		
		awk -vdir="${dir}/${d}/ALL/" 'BEGIN{FS="\t"}{print "if [ ! -s "dir"annonce_"$2".html ]; then url=\""$1"\"; output="dir"annonce_"$2".html;  download_pages ; fi"}' ${dir}/${d}/extract.tab > ${dir}/${d}/wgets/wget_file.txt
		nb=`wc -l-f  ${dir}/${d}/wgets/wget_file.txt | awk '{print $1}' `
        let "split = (nb / nb_processus) + 1"
        split -l${split} -d ${dir}/${d}/wgets/wget_file.txt  ${dir}/${d}/wgets/wget_file.txt.
        i=0
        for wget_file in `ls ${dir}/${d}/wgets/wget_file.txt.*`
        do
			echo -e "set -x\n">>${wget_file}
			. ${wget_file} >  ${dir}/${d}/log_${i} 2>&1 &
			let "i=i+1"
        done
        wait
}

#
# MAIN
#
usage="download_site.sh \n\
\t-a no download - just process what's in the directory\n\
\t-d [date] (default today)\n\
\t-h help\n\
\t-i id start de la region default : 1\n\
\t-I id end de la region default : max_region\n\
\t-M [region]\n\
\t-m [modele]\n\
\t-r retrieve only, do not download the detailed adds\n\
\t-R reset : delete files to redownload\n\
\t-t table name \n\
\t-T valeurs : new used certified ex: -T\"used new\"\n\
\t-x debug mode\n\
"

date
typeset -i lynx_ind=1
typeset -i get_detail_mod=1
typeset -i get_all_ind=1
typeset -i get_list_ind=1
typeset -i nb_retrieve_per_page=12
typeset -i max_retrieve=30000
typeset -i nb_processus=5
typeset -i max_loop_1=5
typeset -i max_loop=3
Y=`date "+%Y"  --date="-366 days ago"`

while getopts :-ad:rht:xz: name
do
  case $name in

    a)  lynx_ind=0
        let "shift=shift+1"
        ;;

    d)  d=$OPTARG
        let "shift=shift+1"
        ;;

        i)      MIN_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    I)  MAX_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    M)  my_region=`echo ${OPTARG} | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

        m)      my_modele=`echo $OPTARG | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

    h)  echo -e ${usage}
        ExitProcess 0
        ;;

    r)  get_all_ind=0
        let "shift=shift+1"
        ;;

    t)  table=$OPTARG
        let "shift=shift+1"
        ;;

    x)  set -x
        let "shift=shift+1"
        ;;

    z)  let "shift=shift+1"
        ;;

    --) break
        ;;

        esac
done
shift ${shift}

if [ $# -ne 0 ]
        then
    error="Bad arguments, $@"
    ExitProcess 1
fi

if [ "${d}X" = "X" ]
        then
        d=`date +"%Y%m%d"`
fi
if [ "${table}X" = "X" ]
        then
        mois=$(date --date "today + `date +%d`days" +%Y_%m)
        table="renault"`date +"%Y_%m"`
fi
if [ "${grand_table}X" = "X" ]
        then
        grand_table="VO_UK_"`date +"%Y_%m"`
fi

debut=`date +"%Y-%m-%d %H:%M:%S"`
dir=`pwd`
mkdir -p ${dir}/${d} ${dir}/${d}/LISTING  ${dir}/${d}/ALL 
touch ${dir}/${d}/status 

if [ ${get_list_ind} -eq 1 ]; then
	
	echo  -e "list" > ${dir}/${d}/status 
	# https://www.used-renault-trucks.fr/l/tracteur
	# https://www.used-renault-trucks.fr/l/porteur
	for category in "tracteur" "porteur" "porteur_remorqueur" "utilitaire" "semi-remorque"
	do	
			directory=${dir}/${d}/LISTING/${category}/
		    mkdir -p ${directory}/LOG
		mkdir -p ${dir}/${d}/LISTING/${category}/
		output=${dir}/${d}/LISTING/${category}/page_0.html
		url=https://www.used-renault-trucks.fr/l/${category}
		download_pages
		
		nb_site=$(awk -f ${dir}/nb_annonce.awk ${output})
		let "max_page=$nb_site/$nb_retrieve_per_page"
		
		for(( page =2; page<=${max_page};page++ ))
		do
			output=${dir}/${d}/LISTING/${category}/page_${page}.html
			# https://www.used-renault-trucks.fr/l/porteur?page=2
			url="https://www.used-renault-trucks.fr/l/${category}?page=${page}"
			echo -e "${output}\t${url}" >> ${dir}/${d}/LISTING/${category}/$$.wget_file
		done	
			
			list_file=${dir}/${d}/LISTING/${category}/$$.wget_file
			download_list_multy_process	
			
			echo -e "parsing list" >> ${dir}/${d}/status		
			
			find ${directory}/ -type f -name '*.html' -exec awk -f ${dir}/liste_tab.awk -f ${dir}/put_html_into_tab.awk {} \; >> ${directory}/${category}.$$
		
			
		# Log Par Marque
		cat  ${directory}/${category}.$$  | sort -u -k1,1 >> ${directory}/${category}.tab
		nb_observe=`wc -l ${directory}/${category}.tab | awk '{print $1}'`
		cat  ${directory}/${category}.tab >> ${dir}/${d}/extract.$$
		echo -e "${category}\t${nb_site}\t${nb_observe}\tCATEGORY"
	
	done
	cat ${dir}/${d}/extract.$$ | sort -u -k1,1 >  ${dir}/${d}/extract.tab
	wait 
	awk -vtable=${table} -f ${dir}/liste_tab.awk -f ${dir}/put_into_db.awk  ${dir}/${d}/extract.tab >> ${dir}/${d}/VO_ANNONCE_insert.sql 
fi 
if [ ${get_all_ind} -eq 1 ]; then
		
		mkdir -p ${dir}/${d}/wgets  
		rm -f  ${dir}/${d}/wgets/wget_file.* 
		download_detail_multy_process			
		# parsing fiches
		find ${dir}/${d}/ALL -type f -name "*html" -exec awk -vtable=${table} -f ${dir}/all_html.awk  {} \; >> ${dir}/${d}/VO_ANNONCE_update.sql
		
fi

echo -e "FIN DU TELECHARGEMENT!"
ExitProcess 0