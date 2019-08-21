 #!/bin/bash

function showHelp() {
	echo "SYNOPSIS"
	echo "\t ./dsource [-ldc] /path/to/{*.a|xx.framework/xx} [/path/to/source]"
	echo "DESCRIPTION"
	echo "\t -l\tlink a binary path to source code path"
	echo "\t -f\t using dwarfdump to find a binary file's compile dir"
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

	EXTENSION="${1##*.}"
	if [ $EXTENSION == "a" ]
	then
		sudo rm $dir
		sudo ln -s "$2" $dir
	else 
		BASENAME=$(basename "$1")
		NAME=${BASENAME%.*}
		sudo ln -s "$2" $dir"/""$NAME"
	fi

	check $1 $dir
	
}

function findCompileDir() {

	dir=($( dwarfdump "$1" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 ))

	if [ ! -d $dir ]
	then
		echo "directory not exist."
		exit 0
	fi

	echo "compile dir is:" $dir
	echo "you may copy source code to this directory, and use dsourc -c to check it"
	
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

link=0
check=0
find=0

while getopts "h?clf" opt; do
    case "$opt" in
    c)  check=1
    	;;
    l)  link=1
        ;;
    f)  find=1
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

if [ $find == 1 ]
then
	if [ -z "$1" ]
	then
		echo "error: please input pod path"
		exit 0
	fi
	findCompileDir $1
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


