#!/usr/bin/env bash

dbname="interndb"
user="myah1"

for i in $(psql -tA -U $user --dbname=$dbname -c "SELECT id FROM urls WHERE urls.status = 'not_dld';")
do
    date=$(date +"%d-%b-%Y")
    url=$(psql -tA -U $user --dbname=$dbname -c "SELECT url FROM urls WHERE urls.id = $i;")
    mkdir -p $date
    filename="${date}_${i}"
    echo $filename
    curl $url -q --output ./$date/$filename 
    res=$?
    if [[ $res -eq 0 ]]
    then 
        echo "URL $url downloaded to ~/$date"
        psql -U $user --dbname=$dbname -q -c "UPDATE urls SET status = 'dld', date = CURRENT_TIMESTAMP WHERE urls.id = $i;" 
    else
        echo "curl encountered an error while downloading the file, skipping to the next url"
    fi    
done
