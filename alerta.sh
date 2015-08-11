#!/bin/bash

alarma="/home/user/aaa.wav"

function hacer_foto
{
	hazfoto=1

	while [[ $hazfoto -eq 1 ]] ; do
		fswebcam -r 640x480 --jpeg 85 -D 1 "foto.jpg"
		if [[ $(ls "foto.jpg" -l | cut -d " " -f5) -gt 1000 ]] ; then
			hazfoto=0
		fi
	done
	
	#mandar foto
	mkfifo pipeline_in
	mkfifo pipeline_out
	telegram-cli < pipeline_in > pipeline_out &
	PID=$!
	echo "contact_list" > pipeline_in
	while read x ; do
		contactos=$( echo $x | grep "Jose")
		if [[ $contactos != "" ]] ; then break ; fi
	done < pipeline_out
	echo "Enviando foto..."
	echo "send_photo Jose foto.jpg" > pipeline_in
	dd if=pipeline_out iflag=nonblock of=/dev/null >/dev/null 2>/dev/null
	while read x ; do
		enviada=$( echo $x | grep "[photo]")
		if [[ $enviada != "" ]] ; then break ; fi
	done < pipeline_out
	echo "Enviada foto."
	kill $PID
	rm pipeline_in
	rm pipeline_out
}

function reproducir_alarma
{
	#subir volumen
	#amixer sset Master unmute 
	#amixer sset Master 100%+ 
	#aplay $alarma &
	echo aaaa
}

function bloquear_todo
{
	xinput list | cut -d "[" -f 1 | grep -i 'TouchPad' | cut -d "=" -f2  | egrep '[0-9]+' -o > temp_dispositivos
	xinput list | cut -d "[" -f 1 | grep -i 'keyboard' | cut -d "=" -f2 | egrep '[0-9]+' -o >> temp_dispositivos
	xinput list | cut -d "[" -f 1 | grep -i 'button' | cut -d "=" -f2 | egrep '[0-9]+' -o >> temp_dispositivos
	xinput list | cut -d "[" -f 1 | grep -i 'hotkeys' | cut -d "=" -f2 | egrep '[0-9]+' -o >> temp_dispositivos
	xinput list | cut -d "[" -f 1 | grep -i 'mouse' | cut -d "=" -f2 | egrep '[0-9]+' -o >> temp_dispositivos

	for ID in $(cat temp_dispositivos) ; do
		xinput set-prop $ID "Device Enabled" 0 2> /dev/null
	done

}

function desbloquear_todo
{
for ID in $(cat temp_dispositivos) ; do
	xinput set-prop $ID "Device Enabled" 1 2> /dev/null
done
rm temp_dispositivos

}

function averiguar_ip
{

	echo $ip
}

upower --monitor 2> log_upower > log_upower &

while [[ 1 -eq 1 ]] ; do
	#conectado=$(grep 'line_power_AC0' log_upower -o)
	read -p "desconecta" conectado
	if [[ $conectado != "" ]] ; then
		#bloquear_todo
		reproducir_alarma &
		hacer_foto
		#sleep 120
		sleep 5
		echo "" > log_upower
		#desbloquear_todo
	fi	
	sleep 0.5	
done


