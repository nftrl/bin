#!/bin/bash
# Marcus Larsen

# flushes the line above the cursor
_overwrite () {
    printf "\r\033[1A\033[0K"
}

# print jelb
_printhelp () {
    printf "usage:\tpop-test.sh [-d <mappe med .fsx filer>] [-t <tmp mappe>] [-z <zip mappe>] [-q|--quiet] [-e <exe mappe>]\n"
    printf "\n"
    printf "\t-d\n"
    printf "\tdefault: ./\n"
    printf "\t\tMappen med .fsx filer.\n"
    printf "\n"
    printf "\t-t\n"
    printf "\tdefault: /tmp/pop/\n"
    printf "\t\tMappen hvori logfiler og .exe (by default) ligger.\n"
    printf "\n"
    printf "\t-z\n"
    printf "\tdefault: off\n"
    printf "\t\tZipper .fsx filerne i <zip mappe>.\n"
    printf "\n"
    printf "\t-q --quiet\n"
    printf "\tdefault: off\n"
    printf "\t\tGør sådan, at programmet ikke skriver noget til STDOUT.\n"
    printf "\t\tSkriver stadig til log filer.\n"
    printf "\n"
    printf "\t-e\n"
    printf "\tdefault: <tmp mappe>/exe/\n"
    printf "\t\tMappen hvori .exe filerne bliver skrevet til.\n"
}

# Read arguments
while [ $# -gt 0 ]
do
    case $1 in
        --help)
            _printhelp
            exit
            ;;
        -d)
            shift
            working_dir=$1
            ;;
        -z)
            shift
            zip_dir=$1
            ;;
        -t)
            shift
            tmp_dir=$1
            ;;
        -q|--quiet)
            quiet=true
            ;;
        -e)
            shift
            exe_dir=$1
    esac
    shift
done

# Create tmp_dir
[ -z $tmp_dir ] && tmp_dir=/tmp/pop # hvis $tmp_dir er tom
mkdir -p $tmp_dir

# Create logfiles
log_output=$tmp_dir/stdout.txt
log_error=$tmp_dir/stderr.txt
printf "" >$log_output
printf "" >$log_error

# Create exe_dir
[ -z $exe_dir ] && exe_dir=$tmp_dir/exe
mkdir -p $exe_dir

# FIXME : stemmer ikke overens med -d argument.
if [ -f files.txt ]
then
    files=$(cat files.txt)
else
    files=$(ls $working_dir | grep ".fsx")
fi

# Start med at teste filerne
for f_fsx in $files
do
    f_exe="${f_fsx%.fsx}.exe"

    # Print til terminal
    [ -z "$quiet" ] && printf "\r%-10s\tCompiling\n" $f_fsx
    # Compile .fsx
    if fsharpc --nologo -o "$exe_dir/$f_exe" "$working_dir/$f_fsx" 1>/dev/null 2>>$log_error
    then # Compiles
        # Print header to $log_output
        [ -s "$log_output" ] && printf "\n\n" >>$log_output
        printf "........................... $f_fsx\n" >>$log_output

        # Print til terminal
        [ -z "$quiet" ] && _overwrite
        [ -z "$quiet" ] && printf "\r%-10s\tRunning\n" $f_fsx

        # Kør .exe
        if mono "$exe_dir/$f_exe" 1>>$log_output 2>>$log_error
        then # Runs
            # Print til terminal
            [ -z "$quiet" ] && _overwrite
            [ -z "$quiet" ] && printf "\r%-10s\tDone\n" $f_fsx
        else # ERROR: Doesn't run
            # Print til terminal
            [ -z "$quiet" ] && _overwrite
            [ -z "$quiet" ] && printf "\r%-10s\tERROR: Can't run file\n" $f_exe
            continue
        fi
    else # ERROR: Doesn't compile
        # Print til terminal
        [ -z "$quiet" ] && _overwrite
        [ -z "$quiet" ] && printf "\r%-10s\tERROR: Can't compile file\n" $f_fsx
        continue
    fi
done

if [ ! -z $zip_dir ]
then
    # Print til terminal
    [ -z "$quiet" ] && printf "\n"
    [ -z "$quiet" ] && printf "Zipping files to ${zip_dir}\n"

    if [ -z $quiet ]
    then
        for f in $files
        do
            zip -r $zip_dir "$working_dir/$f"
        done
    else
        for f in $files
        do
            zip -r $zip_dir "$working_dir/$f" 1>/dev/null
        done
    fi
fi
