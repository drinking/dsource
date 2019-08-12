

if [ -z "$1" ] || [ -z "$2" ]
then
	echo "please input Pods framework path and source path"
	echo "example: sh ./dsource.sh ~/path/to/Pods/yourpodname/ ~/path/to/yoursource"
	exit
fi

export DSOURCE=$2
function dump() {

	BASENAME=$(basename "$1")
	NAME=${BASENAME%.*}
	DIR=$(dirname "$1")
	dwarfdump "$1"/"$NAME" | grep "AT_comp_dir" | head -1 | cut -d \" -f2 | while  read -r line; do
		echo "ln" "$DSOURCE" to "$line"/"$NAME"
		sudo mkdir -p "$line"/"$NAME"
		sudo ln -s $DSOURCE "$line"/"$NAME"
	done
	
}

export -f dump
find $1 -name "*.framework" -exec bash -c 'dump "$1"' _ {} \;