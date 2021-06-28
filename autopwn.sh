#!/bin/bash

#
#Colores
#
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#
#Dice Saliendo...
#
function goodbye() {
    # say goodbye
    echo -e "\n\n${purpleColour}[+]${endColour} Saliendo...\n"
}

#
#Cuando das control+C sale del programa
#
trap "goodbye" EXIT

#
#Instalar Squid Proxy
#
echo -e "${greenColour}[+]${endColour} Actualizando e instalando Squid Proxy"
apt update
apt install squid -y

#
#Iniciando el servicio Squid
#
echo -e "${greenColour}[+]{end Colour} Iniciando el Servicio Squid"
systemctl start squid
systemctl enable squid

#
#Pregunta al usuario si quiere que la conexion sea transparente
#

#
#Cambiar puerto de Squid Proxy
#
read -p "[*] El puerto por defecto es 3128, ponga aqui el puerto deseado, si quiere que la conexion sea transparente ponga despues del puerto transparent Ej: 3128 transparent, si no solo ponga el puerto: " port
if [ "$port" != "" ]
		then
			echo -e "Cambiando al puerto ${redColour}$port${endColour}..."
			sleep 1

echo -e "${greenColour}[+]${endColour} Aplicando cambios..."
systemctl restart squid

#
#Pregunta al usuario si quiere permitir todo el trafico
#
clear
echo -e "Desea permitir, todo el trafico entrante? Seleccione ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
	case $yn in

#
#Modo Si permitir trafico
#
Si )
clear
echo -e "${greenColour}[+]${endColour} Configurando Squid para permitir todo el trafico..."
sed 's/http_acacess deny/http_access allow all/' /etc/squid/squid.conf
systemctl restart squid

#
#Pregunta si quiere configuracion adiccional
#
clear
echo -e "Quiere configuracion adiccional? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
	case $yn in

#
#Cierra la pregunta de configuracion adiccional
#
No )
exit 1;;
       esac
done

#
#Pregunta al usuario si quiere que solo se puedan conectar las direcciones IP que el desea
#
Si )
echo -e "Quiere configurar que solo se pueda conectar con una IP especifica? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
    case $yn in

#
#Cierra la pregunta de no configurar una IP
#
No )
echo -e "${turquoiseColour}[*]${endColour} Continuando con el script..."
sleep 1

#
#Configuramos una IP
#
Si )
echo -e "${greenColour}[+]${endColour} Vamos a configurar una IP..."
sleep 1
read -p "[*] Dime una IPv4 para añadirla puedes poner tambien 10.10.10.0/24 para añadir un rango, o poner solo una 10.10.10.2: " IP
if [ "$IP" != "" ]
        then
			echo "acl localnet src $IP" >> /etc/squid/squid.conf

#
#Pregunta al usuario si quiere abrir algun puerto en especifico
#
echo -e "Quiere abrir algun puerto en especifico? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Cierra la pregunta de abrir un puerto en espeficico
#
No )
echo -e "${turquoiseColour}[*]${endColour} Continuando con el script..."
sleep 1

#
#Abriremos un puerto en especifico
#
Si )
echo -e "${greenColour}[+]${endColour} Vamos a abrir un puerto..."
sleep 1
read -p "[*] Dime un puerto para abrir: " puerto
if [ "$puerto" != "" ]
        then
        	echo "acl Safe_ports port $puerto" >> /etc/squid/squid.conf

#
#Pregunta al usuario si quiere poner autenticacion
#
echo -e "Quiere poner autenticacion? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Cierra la pregunta de poner autenticacion
#
No )
echo -e "${turquoiseColour}[*]${endColour} Continuando con el script..."
sleep 1

#
#Ponemos autenticacion
#
Si )
echo -e "${greenColour}[+]${endColour} Configurando autenticacion..."
apt install apache2-utils
touch /etc/squid/passwd
chown proxy: etc/squid/passwd
htpasswd /etc/squid/passwd newuser
echo "auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd" >> /etc/squid/squid.conf
echo "auth_param basic children 5" >> /etc/squid/squid.conf
echo "auth_param basic realm Squid Basic Authentication" >> /etc/squid/squid.conf
echo "auth_param basic credentialsttl 2 hours" >> /etc/squid/squid.conf
echo "acl auth_users proxy_auth REQUIRED" >> /etc/squid/squid.conf
echo "http_access allow auth_users" >> /etc/squid/squid.conf
systemctl restart squid

#
#Pregunta al usuario si quiere bloquear sitios web o palabras clave
#
echo -e "Quiere bloquear algun sitio web o alguna palabra clave? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Añadimos las palabras claves o paginas web
#
Si )
touch /etc/squid/blocked.acl
read -p "[*] Dime una pagina o palabra a bloquear: " block
if [ "$block" != "" ]
        then
			echo "$block" >> /etc/squid/blocked.acl
			echo 'acl blocked_websites dstdomain "/etc/squid/blocked.acl"' >> /etc/squid/squid.conf
			echo "http_access deny blocked_websites" >> /etc/squid/squid.conf
		systemctl restart squid
exit 1;;

#
#Cierra de bloquear sitios web o palabras clave
#
No )
exit 1;;
        esac
done

#
#Cierra la pregunta de configuracion adiccional
#
No )
exit 1;;
		esac
done

#
#Cierra el Si de la pregunta de todo el trafico
#
exit 1
;;

#
#Modo No permitir trafico
#
No )


exit 1;;
       esac
   done
