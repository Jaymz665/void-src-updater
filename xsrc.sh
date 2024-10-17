#!/bin/bash
cd ~/void-packages
echo -e "\e[32mобновляю vur...\e[0m"
git pull &>/dev/null
./xbps-src bootstrap-update &>/dev/null
		# Подготовка
CHECKV=$(./xbps-src update-check $1 | awk '/->/ {print $NF}' | sed 's/ //g' | tail -n1) #проверка обновлений из сорцов
CHECKS=$(./xbps-src update-check $1 | awk '/->/ {print $NF}' | sed 's/'$1'-//g' | tail -n1) #проверка обновлений из сорцов - версия
REPOV=$(xbps-query -RS "$1*" | grep -Eo $1-'[0-9.]+'  | sed 's/ //g'  | tail -n1) #версия в репозитории
LOCALV=$(xbps-query -s "$1*" | grep -Eo $1-'[0-9.]+'  | sed 's/ //g' | tail -n1) #установленная версия
XBPSV=$(find ~/void-packages/hostdir/binpkgs/ -name "$1*" -printf "%f\n"  | grep -Eo $1-'[0-9.]+'  | sed 's/ //g' | head -n1) #собранная версия
TEMPLV=$(cat ~/void-packages/srcpkgs/$1/template | grep -v '^$' | grep -v '^\s*$' | grep -oP 'version=\K[0-9.]+' | tail -n1 | sed 's/^/'$1-'/') #версия шаблона
ZERO=$(echo " ") #пустой вывод -z -n ебут голову, так надёжнее.

		# Визуальная сверка версий
echo -e "\e[36m Версии $1:
исходники --->$CHECKV
шаблон ------>$TEMPLV
репозиторий ->$REPOV
установлен -->$LOCALV
собран ------>$XBPSV\e[0m"
		# Логика на проверку версий
	
	if [[ "$CHECKV" > "$ZERO" && "$CHECKV" > "$TEMPLV" && "$CHECKV" > "$REPOV"  && "$CHECKV" > "$LOCALV" && "$CHECKV" > "$XBPSV"  ]]; then  # проверка пустого вывода в случае когда вресии совпадают
		
			echo -e "\e[33mОбновляю шаблон $1 до версии $CHECKS\e[0m"
			sed -i 's/version=.*/version='$CHECKS'/g' 'srcpkgs/'$1'/template'
			sed -i 's/revision=.*/revision=1/g' 'srcpkgs/'$1'/template'
			echo -e "\e[33mсравниваю суммы...\e[0m"
			xgensum -i $1 &>/dev/null
			else
				echo -e "\e[33mшаблон $1 обновлён, версия: $TEMPLV\e[0m"
				fi
		# Логика на установку
TEMPLV=$(cat ~/void-packages/srcpkgs/$1/template | grep -v '^$' | grep -v '^\s*$' | grep -oP 'version=\K[0-9.]+' | tail -n1 | sed 's/^/'$1-'/') #версия уже обновлённого шаблона

		if [[ "$LOCALV" < "$TEMPLV" && "$XBPSV" < "$TEMPLV" ]]; then
			echo -e "\e[33mтребуется сборка\e[0m"
			echo -e "\e[33mсравниваю суммы...\e[0m"
			xgensum -i $1 &>/dev/null
			echo -e "\e[33Сборка. Пожалуйста подождите...\e[0m"
			./xbps-src pkg $1
			else 
			echo -e "\e[32mобновлений не требуется\e[0m"
			fi
			
cd - &>/dev/null
