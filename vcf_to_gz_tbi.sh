#!/bin/bash

# Default values
OUTPUT_PATH=`pwd`

# Help message --- {{{
usage () {
	echo -e \\n"Compresses and indexes a given vcf file."\\n
	echo -e "Usage: $0 [-f FILE] [-p PATH]"\\n
	echo "Options:"
	echo "-f FILE         VCF file"
	echo "-p PATH         Path to save output files"
	echo -e "-h              Prints help message"\\n
	exit 1
}
# }}} ---

# getopts --- {{{
while getopts f:p:h flags
do
	case "${flags}" in
		f) VCF_FILE=${OPTARG};;
		p) OUTPUT_PATH=${OPTARG};;
		h) usage;;
		?) echo -e \\n"Use -h to see the help documentation."\\n; exit 2;;
	esac
done

if [ -z ${VCF_FILE} ]; then echo -e \\n"[ERRR] Required argument -f missing."; usage; exit 1; fi
# }}}  ---

# Compression and Indexing --- {{{
if [ -e ${VCF_FILE} ]
then
    bgzip -c ${VCF_FILE} > "${OUTPUT_PATH}/${VCF_FILE}.gz"
    tabix -p vcf "${OUTPUT_PATH}/${VCF_FILE}.gz" 

    echo -e \\n"VCF file:              ${VCF_FILE}"
    echo "Compressed VCF file:   ${OUTPUT_PATH}/${VCF_FILE}.gz"
    echo -e "Indexed VCF file:      ${OUTPUT_PATH}/${VCF_FILE}.gz.tbi"\\n
else
    echo -e \\n"[ERRR] No such file exist. Please check your file name."
    usage
    exit 1
fi
# }}}  ---