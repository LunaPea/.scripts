function rofimenu() {
  links=$(curl -s $1 | xmllint - --html --xpath $2 | while read line; do
    link=$(echo $line | grep -o 'href="[^"]*"' | sed 's/href=//;s/"//g')
    text=$(echo $line | sed -e 's/<[^>]*>//g')

    echo "$link $text"
  done)

  selection=$(echo -e "$links" | cut -d" " -f2- | rofi -matching fuzzy -i -dmenu)
  if [[ $? -eq 1 ]]; then
    exit 1
  fi
  link=$(echo "$links" | grep "$selection" | cut -d" " -f1)
  echo $link
}

anime=$(rofimenu https://wbijam.pl "(////div[@class='dropdown-content'])[3]/a")
if [ $? -eq 1 ]; then
  exit
fi

seria=$(rofimenu $anime "(////div[@class='dropdown-content'])[1]/a")
if [ $? -eq 1 ]; then
  exit
fi

odcinek=$(rofimenu $anime$seria "////table/tbody/tr/td/a")
if [ $? -eq 1 ]; then
  exit
fi

data=$(curl -s $anime$seria | xmllint - --html --xpath "////table/tbody/tr/td" | grep $odcinek --after-context 2 | tail -n 1 | xmllint - --html --xpath "string(/)")
if [ $(echo $data | awk -F '.' '{print $3$2$1}') -gt $(date +"%Y%m%d") ]; then
  echo "NIE MA JESZCZE, POCZEKAJ SE DO $data" | rofi -dmenu
  exit
fi

odcinek=$(echo "$anime"odtwarzacz-$(curl -s $anime$odcinek | xmllint - --html --xpath "///table/tbody//tr/td" | grep "cda" --after-context 2 | grep "odtwarzacz_link"| xmllint - --html --xpath "string(//td/span/@rel)").html)

echo Openning $odcinek
mpv $(curl -s $odcinek | xmllint - --html --xpath "string(///strong[1]/a/@href)")
