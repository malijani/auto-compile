#!/bin/bash
sourceCode=$1
output=$2
compiler=gcc
tmpFile="/tmp/$sourceCode-back"
greenColor=$(tput setaf 2)
normalColor=$(tput sgr0)
if [ ! $(which $compiler) ] ; then
	echo "You didn't install $compiler on your system! please install it and try again"
	exit 1
fi
#I didn't write this function, i found it usefull in : https://stackoverflow.com/questions/4857310/how-to-get-diff-working-like-git-diff
function gdiff()
{
    local REG=`tput op`
    local GRP=`tput setaf 6`
    local ADD=`tput setaf 2`
    local REM=`tput setaf 1`

    local NL=$'\n'
    local GRP_LABEL="${GRP}@@ %df,%dn +%dF,%dN @@${REG}"

    local UNCH_GRP_FMT=''

    [[ "${1}" == '@full' ]] && {

        UNCH_GRP_FMT="${GRP_LABEL}${NL}%="
        shift
    }

    diff \
        --new-line-format="${ADD}+%L${REG}" \
        --old-line-format="${REM}-%L${REG}" \
        --unchanged-line-format=" %L${REG}" \
        --new-group-format="${GRP_LABEL}${NL}%>" \
        --old-group-format="${GRP_LABEL}${NL}%<" \
        --changed-group-format="${GRP_LABEL}${NL}%<%>" \
        --unchanged-group-format="${UNCH_GRP_FMT}" \
            "${@}" | less -FXR
}

while true ; do
	firstHash=$(md5sum "$sourceCode")
	cp "$sourceCode" "$tmpFile"
	sleep 5
	secondHash=$(md5sum "$sourceCode")
	if [ "$firstHash" != "$secondHash" ] ; then
		clear
		usedLibraries=$(head -n 30 $sourceCode | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' | grep '^#include' | awk '{ print $2 }')
		echo -en "You're using this libraries in your code:\n${greenColor}$usedLibraries${normalColor}\n=============================\n"
		differences=$(gdiff "$sourceCode" "$tmpFile") 
		echo -en "This is your editions:\n$differences=============================\nTest code:\n\n"
		$compiler "$sourceCode" -o "$output"
		if [ -e "$output" ]; then
		./"$output"
		mv "$output" "/tmp/$output-last"
		fi
		firstHash="$secondHash"
		cp "$sourceCode" "$tmpFile"
	fi
done
