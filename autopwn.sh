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
clear
echo -e "${greenColour}[+]${endColour} Actualizando e instalando Squid Proxy..."
sleep 1
#apt update
#apt install squid -y
sleep 1
clear

#
#Iniciando el servicio Squid
#
clear
echo -e "${greenColour}[+]${end Colour} Iniciando el Servicio Squid..."
sleep 1
#systemctl start squid
#systemctl enable squid

#
#Pregunta al usuario si quiere que la conexion sea transparente
#

#
#Cambiar puerto de Squid Proxy
#
clear
read -p "[*] El puerto por defecto es 3128, ponga aqui el puerto deseado, si quiere que la conexion sea transparente ponga despues del puerto transparent Ej: 3128 transparent, si no solo ponga el puerto: " port
if [ "$port" != "" ]
		then
			echo -e "\nCambiando al puerto ${redColour}$port${endColour}..."
			sleep 1

echo -e "\n${greenColour}[+]${endColour} Aplicando cambios..."
cat /etc/squid/squid.conf | sed "s/http_port */http_port $port/g" > /etc/squid/squid.conff
rm -r /etc/squid/squid.conf
mv /etc/squid/squid.conff /etc/squid/squid.conf
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
sleep 1
cat /etc/squid/squid.conf | sed 's/http_acacess deny/http_access allow all/' >> /etc/squid/squid.conff
rm -r /etc/squid/squid.conf
mv /etc/squid/squid.conff /etc/squid/squid.conf
systemctl restart squid

#
#Pregunta si quiere configuracion adiccional
#
clear
echo -e "Quiere configuracion adiccional? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
	case $yn in

#
#Pregunta al usuario si quiere que solo se puedan conectar las direcciones IP que el desea
#
Si )
clear
echo -e "Quiere configurar que solo se pueda conectar con una IP especifica? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
    case $yn in

#
#Configuramos una IP
#
Si )
clear
echo -e "${greenColour}[+]${endColour} Vamos a configurar una IP...\n"
sleep 1
read -p "[*] Dime una IPv4 para añadirla puedes poner tambien 10.10.10.0/24 para añadir un rango, o poner solo una 10.10.10.2: " ip
if [ "$ip" != "" ]
        then
			echo "acl localnet src $ip" >> /etc/squid/squid.conf
			sleep 1

#
#Pregunta al usuario si quiere abrir algun puerto en especifico
#
clear
echo -e "Quiere abrir algun puerto en especifico? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Abriremos un puerto en especifico
#
Si )
echo -e "${greenColour}[+]${endColour} Vamos a abrir un puerto...\n"
sleep 1
clear
read -p "[*] Dime un puerto para abrir: " puerto
if [ "$puerto" != "" ]
        then
        	echo "acl Safe_ports port $puerto" >> /etc/squid/squid.conf

#
#Pregunta al usuario si quiere poner autenticacion
#
clear
echo -e "Quiere poner autenticacion? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Ponemos autenticacion
#
Si )
clear
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
clear
echo -e "Quiere bloquear algun sitio web o alguna palabra clave? ${greenColour}Si${endColour} o ${redColour}No${endColour}"
select yn in "Si" "No"; do
     case $yn in

#
#Añadimos las palabras claves o paginas web
#
Si )
clear
touch /etc/squid/blocked.acl
read -p "[*] Dime una pagina o palabra a bloquear: " block
if [ "$block" != "" ]
        then
			echo "$block" >> /etc/squid/blocked.acl
			echo 'acl blocked_websites dstdomain "/etc/squid/blocked.acl"' >> /etc/squid/squid.conf
			echo "http_access deny blocked_websites" >> /etc/squid/squid.conf
		systemctl restart squid
exit 1
break

#
#Cierra la pregunta de añadir palabras claves o paginas web
#
else
       echo -e "\n${redColour}[+]${endColour} Cerrando Script..."
      exit 1
   fi
   break
;;

#
#Cierra la pregunta que le hace al usuario de si quiere bloquear sitios web
#
	   No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done
;;

#
#Cierra la pregunta de poner autenticacion
#
           No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done

#
#Cierra la pregunta de poner el puerto
#
else
       echo -e "\n${redColour}[+]${endColour} Cerrando Script..."
      exit 1
   fi
   break
;;

#
#Cierra la pregunta de abrir un puerto
#
           No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done

#
#Cierra la pregunta de poner una IP
#
else
       echo -e "\n${redColour}[+]${endColour} Cerrando Script..."
      exit 1
   fi
   break
;;

#
#Cierra la pregunta de poner las IP's que el desee
#
           No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done
;;

#
#Cierra la pregunta de añadir configuracion adicional
#
           No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done
;;

#
#Cierra la pregunta de pasar todo el trafico
#
           No )
               echo -e "\n${redColour}[-]${endColour} Cerrando Script..."
           exit 1;;
       esac
   done

#
#Cierra la pregunta de cambiar el puerto de Squid Proxy
#
else
       echo -e "\n${redColour}[+]${endColour} Cerrando Script..."
      exit 1
   fi
   break
;;

