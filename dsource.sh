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

	condition=$(basename "$2")
	file=($( dwarfdump "$1" | grep -E "DW_AT_decl_file.*$condition.*\.m|\.c" | head -1 | cut -d \" -f2 ))

	if [ ! -f $file ] 
	then
		echo "$file" "not exist."
		echo "please make sure source path is correct."
		exit 0
	fi

	echo "link successfully!"
	echo "view linked source at path:" $2
}

function link() {

	dir=($( dwarfdump "$1" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 ))

	if [ ! -d $dir ] 
	then
		echo "$dir" 
		echo "directory does not exist, create one? [y/n]"
		read input
		if [ $input == 'y' ]
		then
			sudo mkdir -p $dir
		else
			exit 0
		fi
	fi

	if [ ! -d $2 ]
	then
		echo "source directory is not exist, please input the right path."
		echo "or manually copy source directory to the path above."
		exit 0
	fi

	BASENAME=$(basename "$1")
	NAME=${BASENAME%.*}
	sudo ln -s "$2" $dir"/""$NAME"

	check $1 $dir
	
}

function delete() {

	dir=($( dwarfdump "$1" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 ))

	if [ ! -d $dir ]
	then
		echo "directory not exist."
		exit 0
	fi

	echo $dir
	echo "to delete [y/n]?"
	read input
	if [ $input == 'y' ]
	then
		sudo rm -rf $dir
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


