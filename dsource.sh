 #!/bin/bash

function showHelp() {
	echo "SYNOPSIS"
	echo "\t ./dsource [-ldc] /path/to/pod [/path/to/source]"
	echo "DESCRIPTION"
	echo "\t -l\tlink pod path to source code path"
	echo "\t -d\t delete linked files depends on pod path"
	echo "\t -c\t check linked files exist at the right path"
}

function check() {

	frameworks=($(find "$1" -name "*.framework"))
	dirs=()


	for i in ${frameworks[@]}
	do
		BASENAME=$(basename "$i")
		NAME=${BASENAME%.*}
		dirs+=($( dwarfdump "$i"/"$NAME" | grep "DW_AT_decl_file" | grep $NAME | head -1 | cut -d \" -f2 ))
	done

	for i in ${dirs[@]}
	do
		if [ ! -f $i ] 
		then
			echo "please make sure your source path is correct."
			exit 0
		fi

	done

	echo "link successfully"

}

function link() {

	frameworks=($(find "$1" -name "*.framework"))
	dirs=()


	for i in ${frameworks[@]}
	do
		BASENAME=$(basename "$i")
		NAME=${BASENAME%.*}
		dir=($( dwarfdump "$i"/"$NAME" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 ))
		if [ ! -z $dir ]
		then
			dirs+=("$dir"/"$NAME")
		fi
	done

	for i in ${dirs[@]}
	do
		echo "ln " $i "to" $2
	done
	echo "to link [y/n]?"

	read input
	if [ $input == 'y' ]
	then
		for i in ${dirs[@]}
		do
			sudo mkdir -p $i
			sudo ln -s $2 $i
		done

	fi

	check $1
	
}

function delete() {

	frameworks=($(find "$1" -name "*.framework"))
	dirs=()


	for i in ${frameworks[@]}
	do
		BASENAME=$(basename "$i")
		NAME=${BASENAME%.*}
		dirs+=($( dwarfdump "$i"/"$NAME" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 ))
	done
	
	echo $dirs
	echo "to delete [y/n]?"
	read input
	if [ $input == 'y' ]
	then
		for i in ${dirs[@]}
		do
			sudo rm -rf $i
		done

	fi
	
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

link=0
check=0
delete=0

while getopts "h?cld" opt; do
    case "$opt" in
    c)  check=1
    	;;
    l)  link=1
        ;;
    d)  delete=1
        ;;
    h|\?)
	    showHelp
	    exit 0
    ;;
    esac
done

shift $((OPTIND-1))

[ "${1-}" = "--" ] && shift


if [ $link == 1 ]
then
	if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "error: please input pod path and source path"
		exit 0
	fi

	link $1 $2
fi

if [ $delete == 1 ]
then
	if [ -z "$1" ]
	then
		echo "error: please input pod path"
		exit 0
	fi
	delete $1
fi

if [ $check == 1 ]
then
	if [ -z "$1" ]
	then
		echo "error: please input pod path"
		exit 0
	fi
	check $1
fi


