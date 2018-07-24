if [ "$#" -ne 1 ]; then
    echo "Syntax ./shellgen <asm file>"
	exit
fi

echo -e "\e[36m--Compiling assembly--"
nasm -f elf32 $1 -o $1.o

echo -e "\e[36m--Linking--"
ld $1.o -o nasmfile

echo -e "\e[33m--Generating Objdump output--"

objdump -d ./nasmfile -M intel

echo -e "\e[36m--Generating Shellcode--"
aar=$(objdump -d ./nasmfile |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g')


echo  $aar
echo ----


echo  \#include \<stdio.h\> > shell.c

var= $(echo unsigned char  shellcode\[\]\=$aar \; >> shell.c)



echo int main\(\) >>shell.c
echo { >>shell.c
echo printf\(\"Shellcode Length:  %d\\n\", sizeof\(shellcode\) - 1\)\; >>shell.c
echo int \(*ret\)\(\) = \(int\(*\)\(\)\)shellcode\; >>shell.c
echo ret\(\)\; >>shell.c
echo } >>shell.c

echo -e "\e[31m--Output--"
echo -e "\e[31m------------------------------------------------"
gcc --no-stack-protector shell.c -o temp
chmod 700 ./temp
./temp