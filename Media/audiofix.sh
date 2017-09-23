#!/bin/bash
#
#Info:
# Script que ajusta el volumen de los vídeos a nivel 0.
# También se puede modificar la codificación y el Bitrate del audio.
#
# Script that adjusts the volume of videos to level 0.
# You can also modify the audio encoding and Bitrate.
#
# Version: 1.2
# Author: Javier Pastor
# Email: script@cerebelum.net


tPathOut="$(readlink -f "new")"
tFormatAudioOut="mp3"
tBitRate="192k"
tSelFile="*.avi"
tForzarConversion="1"
tUnicaPistaAudio="true"

pffmpeg="/usr/bin/ffmpeg"
pffmpegvmin="1.2.6"


AUDIOFIX_NAME="AudioFix"
AUDIOFIX_VER="1.2"
AUDIOFIX_MAIL="script@cerebelum.net"



DEBUGCOLORTXT="ON"
if [ ${DEBUGCOLORTXT} = "ON" ]; then
	CTXT_S1="\e[00;37m"
	CTXT_T1="\e[01;36m"
	CTXT_TX="\e[01;37m"
	CTXT_PU="\e[01;32m"
	CTXT_OK="\e[01;33m"
	CTXT_ER="\e[01;31m"
	CTXT_AV="\e[01;34m"
	CTXT_CL="\e[00m"
fi

function ColorTxtClean()
{
	echo -en "${CTXT_CL}"
}

function OK () {
	local VARCODIGOERROR=$1
	if [ ${VARCODIGOERROR} -eq 0 ]; then
		echo -e "${CTXT_S1}[${CTXT_OK}OK${CTXT_S1}]"
	else
		echo -e "${CTXT_S1}[${CTXT_ER}ERROR${VARCODIGOERROR}${CTXT_S1}]"
	fi
	echo -en "${CTXT_CL}"
	return ${VARCODIGOERROR}
}

function msgTitulo ()
{
	echo -e "${CTXT_TX}${AUDIOFIX_NAME} Ver(${AUDIOFIX_VER}) By Javier Pastor (${AUDIOFIX_MAIL})"
	echo -e "${CTXT_CL}"
}

function msgInfoUso ()
{
	msgTitulo
	echo -e "${CTXT_TX}"
	echo -e "Uso/Use: ` basename $0`"
	echo -e ""
	echo -e "  -h --help					ES: Ayuda"
	echo -e "  								EN: Help"
	echo -e ""
	echo -e "  -v --version					ES: Muestra la versión del programa"
	echo -e "  								EN: Show the program version)"
	echo -e ""
	echo -e "  -aco --acodecout <codec>		ES: Códec del formato de salida"
	echo -e "    							EN: Output format codec"
	echo -e "    							Default: mp3"
	echo -e ""
	echo -e "  -br --bitrate <k>			ES: Bitrate del audio de salida"
	echo -e "								EN: Output audio bitrate"
	echo -e "								Default: 192k"
	echo -e ""
	echo -e "  -f --file <archivo>			ES: Archivos a recodificar"
	echo -e "								EN: Files to recode"
	echo -e '								Default: "*.avi"'
	echo -e ""
	echo -e "  -po --pathout <path>			ES: Path salida de archivos recodificados"
	echo -e "  								EN: Path output of recoded files"
	echo -e "								Default: /[path actual]/new"
	echo -e ""
	echo -e "  -fz --forzar					ES: Fuerza la recodificación de todos los archivos"
	echo -e "  								EN: Forces recoding of all files"
	echo -e "								Default: False"
	echo -e ""
	echo -e "  -aex --audioextra			ES: Mantiene pista de audio extra"
	echo -e "  								EN Keeps track of extra audio"
	echo -e ""
	echo -e "Ejemplo/Example:"
	echo -e ""
	echo -e '# '` basename $0`' --acodecout "aac" --bitrate "96k" --file "24 - s01e*.avi" --pathout "/tmp/outnew"'
	echo -e "${CTXT_CL}"
}


while [ $# -gt 0 ]; do
	case $1 in
		--help | -h )
			msgInfoUso
			exit
		;;
		--version | -v )
			msgTitulo
			exit
		;;
		--acodecout | -aco )
			tFormatAudioOut="$2"
			shift
		;;
		--bitrate | -br )
			tBitRate="$2"
			shift
		;;
		--file | -f )
			tSelFile="$2"
			shift
		;;
		--forzar | -fz )
			tForzarConversion="0"
			shift
		;;
		--pathout | -po )
			tPathOut="$2"
			shift
		;;
		
		--audioextra | -aex )
			tUnicaPistaAudio="false"
			shift
		;;
		
		* )
			msgTitulo
			echo -e "${CTXT_PU} * ${CTXT_ER}ERROR: ${CTXT_TX}PARÁMETRO DESCONOCIDO ($1)"
			echo -e "${CTXT_CL}"
			exit 1
	esac
	shift
done





msgTitulo

if [ ! -e "${pffmpeg}" ]
then
	echo -e "${CTXT_PU} * ${CTXT_ER}ERROR: ${CTXT_TX}PROGRAMA FFMPEG NO LOCALIZADO!"
	echo -e "${CTXT_CL}"
	exit 1
fi

pffmpegvact=$("${pffmpeg}" -version | grep "ffmpeg version" | cut -d " " -f 3)
if [ "${pffmpegvmin}" != "${pffmpegvact}" ]; then
	tmin=$(echo -e ${pffmpegvmin}"\n"${pffmpegvact}|sort -V|head -n 1)
	if [ "${tmin}" = "${pffmpegvact}" ];then
		echo -e "${CTXT_PU} * ${CTXT_ER}ERROR: ${CTXT_TX}TU VERSIÓN DE FFMPEG (${pffmpegvact}) NO ES VÁLIDA MÍNIMA (${pffmpegvmin})!"
		echo -e "${CTXT_CL}"
		exit 1
	fi
	unset tmin
fi



if [ ! -e "${tPathOut}" ]; 
then
	echo -en "${CTXT_PU} * ${CTXT_TX}CREANDO DIRECTORIO DE SALIDA DE ARCHIVOS..."
	mkdir -p "${tPathOut}"	
	OK $?
	if [ "$?" != "0" ]
	then
		echo -e "${CTXT_CL}"
		exit 1
	else
		echo -e "${CTXT_CL}"
	fi
fi



for f in ${tSelFile}; do
	sleep 1
	
	echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO (${f}):"
	if [ ! -e "${f}" ]
	then
		echo -e "${CTXT_PU}   ** ${CTXT_ER}ERROR: ${CTXT_TX}EL ARCHIVO (${f}) NO EXISTE!"
		echo -e ""
		echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) ABORTADO"
		echo -e "${CTXT_CL}"
		continue
		sleep 2
	fi
	
	if [ ! -z "${tPathOutFileNew}" ]; then unset tPathOutFileNew; fi	
	tPathOutFileNew="${tPathOut}/${f}"
	if [ -e "${tPathOutFileNew}" ]
	then
		echo -e "${CTXT_PU}   ** ${CTXT_AV}AVISO: ${CTXT_TX}EL ARCHIVO DE DESTINO YA EXISTE!"
		read -p "	     ¿DESEAS BORRARLO? (S/N)" RESP
		echo -e "${CTXT_CL}"
		if [ "$RESP" = "s" ] || [ "$RESP" = "S" ]
		then
			rm -f "${tPathOutFileNew}";
		else
			echo -e ""
			echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) ABORTADO"
			echo -e "${CTXT_CL}"
			continue
			sleep 2
		fi
	fi
	
	if [ ! -z "${tPathLogFileMaxVol}" ]; then unset tPathLogFileMaxVol; fi
	if [ ! -z "${tNumDBFix0}" ]; then unset tNumDBFix0; fi
	if [ ! -z "${tNumDBFix1}" ]; then unset tNumDBFix1; fi
	if [ ! -z "${tAddOptFixVol}" ]; then unset tAddOptFixVol; fi
	tPathLogFileMaxVol="$(readlink -f "${f}_log")"
	echo -en "${CTXT_PU}   ** ${CTXT_TX}DETECTANDO VOLUMEN MAXIMO..."
	"${pffmpeg}" -i "${f}" -vn -af volumedetect -map 0:1 -f null - 2> "${tPathLogFileMaxVol}"
	OK $?
	if [ "$?" = "1" ]
	then 
		echo -e ""
		echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) ABORTADO"
		echo -e "${CTXT_CL}"
		continue
		sleep 3
	fi
	tNumDBFix0=$(cat "${tPathLogFileMaxVol}" | grep max_volume | cut -d " " -f 5)
	tNumDBFix1=$(echo "${tNumDBFix0}" | sed 's/-//g')	
	if [ -e "${tPathLogFileMaxVol}" ]; then rm -f "${tPathLogFileMaxVol}"; fi
	echo -e "${CTXT_PU}   ** ${CTXT_TX}VOLUMEN MAX: ${CTXT_T1}${tNumDBFix0}${CTXT_CL}"
	if [ "${tNumDBFix0:0:1}" != "-" ] && [ "${tNumDBFix0}" != "0.0" ]
	then
		echo -e "${CTXT_PU}   ** ${CTXT_ER}ERROR: ${CTXT_TX}VALOR DE VOLUMEN MAXIMO ES POSITIVO!!!!!!!!!!"
		echo ""
		read -p "             PRESIONE CUALQUIER TECLA PARA CONTINUAR..." -n1 -s
		echo -e ""
		echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) ABORTADO"
		echo -e "${CTXT_CL}"
		continue
	fi
	if ! [[ "${tNumDBFix1}" =~ $(echo '^-?[0-9]+([.][0-9]+)?$') ]]
	then
		echo -e "${CTXT_PU}   ** ${CTXT_ER}ERROR: ${CTXT_TX}VALOR DE VOLUMEN MAXIMO NO ES NUMERICO (${tNumDBFix1})!"
		echo ""
		read -p "             PRESIONE CUALQUIER TECLA PARA CONTINUAR..." -n1 -s
		echo -e ""
		echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) ABORTADO"
		echo -e "${CTXT_CL}"
		continue
	fi
	if [ $( echo "${tNumDBFix1}>1" | bc ) -eq 0 ] 
	then
		if [ "${tForzarConversion}" == "0" ]
		then
			echo -e "${CTXT_PU}   ** ${CTXT_AV}AVISO: ${CTXT_TX}NO ES NECESARIO RECODIFICAR EL AUDIO!"
			echo -e ""
			echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) FINALIZADO"
			echo -e "${CTXT_CL}"
			continue
			sleep 3
		else
			tAddOptFixVol="0"
		fi
	else
		tAddOptFixVol="1"
	fi
	
	echo -en "${CTXT_PU}   ** ${CTXT_TX}RECODIFICANDO AUDIO ARCHIVO..."
	
	if [ ${tUnicaPistaAudio} == "true" ]
	then
		tOptMap=" -map 0:0 -map 0:1 "
	else
		tOptMap=" -map 0:0 -map 0:1 -map 0:2 "
	fi
	
	
	if [ ${tAddOptFixVol} == "1" ]
	then
		"${pffmpeg}" -i "${f}" -af "volume=${tNumDBFix1}dB" -c:v copy -c:a ${tFormatAudioOut} -strict experimental -b:a ${tBitRate} ${tOptMap} "${tPathOutFileNew}" 2> /dev/null
		OK $?
	else
		#"${pffmpeg}" -i "${f}" -c:v copy -c:a ${tFormatAudioOut} -strict experimental -b:a ${tBitRate} ${tOptMap} "${tPathOutFileNew}" 2> /dev/null
		"${pffmpeg}" -i "${f}" -c:v copy -c:a copy ${tOptMap} "${tPathOutFileNew}" 2> /dev/null
		OK $?
	fi
	echo -e ""
	echo -e "${CTXT_PU} * ${CTXT_TX}PROCESANDO DE (${f}) FINALIZADO"
	echo -e "${CTXT_CL}"
	sleep 3
done

echo ""
echo -e "${CTXT_PU} * ${CTXT_TX}TODOS LOS PROCESOS TERMINADOS"
echo -e "${CTXT_CL}"
