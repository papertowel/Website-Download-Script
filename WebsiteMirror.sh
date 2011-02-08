#!/bin/bash
function func_help
{
   clear
   echo "Usage for this script: ./WebsiteMirror.sh LOCALMIRROR REMOTESERVER SPEED USERNAME PASSWORD SAVE"
   echo ""
   echo "LOCALMIRROR is location for where to save your local copy of the morror ex: ~/mirror/"
   echo "SPEED is for limiting your download speed. Enter 0 for unlimited"
   echo "REMOTESERVER is remote mirror example: http://remotemirror.com/"
   echo "Not Required: USERNAME is if your remote server requires username"
   echo "Not Required: PASSWORD is if your remote server requires password"
   echo "SAVE is if you want to save these settings and not be bothered with this again"
   echo "**if you put in save command then next time you can run ./WebsiteMirror.sh and it will mirror with previous settings"
   echo ""
   echo ""
   exit 0
}
function func_type
{
 # For those of you wondering the ${..,,} is for making the variable lowercase
  if [[ ${REMOTESERVER,,} == *http://* ]]; then
  TYPE="http"
 elif [[ ${REMOTESERVER,,} == *https://* ]]; then
  TYPE="https"
 elif [[ ${REMOTESERVER,,} == *ftp://* ]]; then
  TYPE="ftp"
 else
  # Unrecognized REMOTESERVER
  clear
  echo "Only https http and ftp are currently supported"
  exit 0
 fi
}
function func_save
{
  #Make mirror directory if it doesn't exist
 if ! [ -e ~/.mirror/ ]; then
  mkdir ~/.mirror/
 fi
 echo "LOCALMIRROR=$LOCALMIRROR" > ~/.mirror/settings
 echo "REMOTESERVER=$REMOTESERVER" >> ~/.mirror/settings
 echo "TYPE=$TYPE" >> ~/.mirror/settings
 echo "SPEED=$SPEED" >> ~/.mirror/settings
 echo "USERNAME=$USERNAME" >> ~/.mirror/settings
 echo "PASSWORD=$PASSWORD" >> ~/.mirror/settings
}
function func_speed
{
 # Check to see if speed is an integer
 if ! [[ "$SPEED" =~ ^[0-9]+$ ]] ; then
  #SPEED is not an integer
  echo "Enter only integers for speed. Please try again."
  exit 0
 fi
}



if [ ${#*} == 0 ]; then
 #no input from user check to see if we have saved settings.
   #Check to see if settings have been saved before
  if [ -f ~/.mirror/settings ]; then
   #File exists we will load settings and run automatically
   while read line; do
    if [[ "$line" == *LOCALMIRROR* ]]; then
        #Used to replace the line LOCALMIRROR= with nothing
     LOCALMIRROR=${line/"LOCALMIRROR="/""}
    elif [[ "$line" == *REMOTESERVER* ]]; then
     REMOTESERVER=${line/"REMOTESERVER="/""}
    elif [[ "$line" == *TYPE* ]]; then
     TYPE=${line/"TYPE="/""}
    elif [[ "$line" == *SPEED* ]]; then
     SPEED=${line/"SPEED="/""}
    elif [[ "$line" == *USERNAME* ]]; then
     USERNAME=${line/"USERNAME="/""}
    elif [[  "$line" == *PASSWORD* ]]; then
     PASSWORD=${line/"PASSWORD="/""}
    fi
   done <~/.mirror/settings
  else
   #File doesn't exist let them know how to use this script"
   func_help
  fi

elif [ ${#*} == 2 ]; then
 #Hopefully the user has entered LOCALMIRROR and REMOTESERVER
 LOCALMIRROR=$1
 REMOTESERVER=$2
 #Check to see if it is http or https or ftp
 func_type
elif [ ${#*} == 3 ]; then
 #Hopefully the user has entered LOCALMIRROR REMOTESERVER and SAVE
 LOCALMIRROR=$1
 REMOTESERVER=$2
 SAVE=$3
  if [[ ${SAVE,,} == "save" ]]; then
   #User wants to save the settings

   #Check to see if it is http or https or ftp
   func_type
   #Save the settings
   func_save
  else
  echo "Unrecognized input. Please try again"
  exit 0
  fi
elif [ ${#*} == 4 ]; then
 #Either they have entered LOCALMIRROR REMOTESERVER SPEED SAVE
 #OR they have entered LOCALMIRROR REMOTESERVER USERNAME AND PASSWORD
 LOCALMIRROR=$1
 REMOTESERVER=$2
 SAVE=$4
 if [[ ${SAVE,,} == "save" ]]; then
  #User has inputted LOCALMIRROR REMOTESERVER SPEED AND SAVE
  SPEED=$3
  # Check to see if speed is an integer
  func_speed
  #Save the settings
  func_type
  func_save
 else
  # We will assume that the user has inputted LOCALMIRROR REMOTESERVER USERNAME AND PASSWORD
  SAVE=""
  USERNAME=$3
  PASSWORD=$4
  func_type
 fi
elif [ ${#*} == 5 ]; then
 #Hopefully the user has entered LOCALMIRROR REMOTESERVER SPEED USERNAME And PASSWORD
 LOCALMIRROR=$1
 REMOTESERVER=$2
 SPEED=$3
 USERNAME=$4
 PASSWORD=$5
 #Check to see if speed is an integer
 func_speed 
 func_type
elif [ ${#*} == 6 ]; then
 #Hopefully the user has entered LOCALMIRROR REMOTESERVER SPEED USERNAME PASSWORD AND SAVE
 LOCALMIRROR=$1
 REMOTESERVER=$2
 SPEED=$3
 USERNAME=$4
 PASSWORD=$5
 SAVE=$6
 if [[ ${SAVE,,} == "save" ]]; then
 func_type
 func_speed
 func_save
 else
  echo "Unrecognized input, Please check input and try again."
  exit 0
 fi
else
 #Not quite sure what they entered so show them help
 func_help
fi

####################################################################################
#          JUST A RECAP. VARIABLES USED AT THIS POINT ARE  (CAN BE NULL THOUGH)    #
#                                                                                  #
# $LOCALMIRROR   $REMOTESERVER   $TYPE   $SPEED   $USERNAME   $PASSWORD            #
####################################################################################

  #Make LOCALMIRROR Directory if it doesn't exist
 if ! [ -e $LOCALMIRROR ]; then
  #File Mirror Directory doesnt exists so make it
  mkdir $LOCALMIRROR -p
 fi
 #echo "LOCALMIRROR = $LOCALMIRROR"
 #echo "REMOTESERVER = $REMOTESERVER"
 #echo "TYPE = $TYPE"
 #echo "SPEED = $SPEED"
 #echo "USERNAME = $USERNAME"
 #echo "PASSWORD = $PASSWORD"

clear
echo " "
echo " "
echo " 			       - -	"
echo "			     { 0 0 }	"
echo "+------------------------oOOo--(_)--oOOo------------------------+"
echo "|								|"
echo "|		---The Web Site Download Script---		|"
echo "|								|"
echo "|			 * Written by: *			|"
echo "|								|"
echo "|		====  Laptopfreek0 & Chris Lanham	====	|"
echo "|								|"
echo "+---------------------------------------------------------------+"
echo " "
echo " "
echo "-Warning-!!! this script may take hours or even days to complete!!!"
echo " "
echo " --- Part 1: --- "
read -p "To start this script press any key, to abort hold Control + C"

echo " "
echo " "

# These next two find commands are to clean up any existing index or html files that might cause the mirror to not update correctly (important when updating an existing mirror)
# It will search the current working directory for any html files as well as any downloads.* directories.
# These types of files are generated in each update of a previously mirrored website.
# If you want to keep all of the html files of your mirror it is important that you comment these find commands out !!!
echo "Do you want to delete any pre-existing mirror html and download files ( y / n ) ?"

read a
if [[ $a == "N" || $a == "n" ]]; then
        echo "Skipping Clean Process..."
else
        echo "Cleaning files..."

find $LOCALMIRROR -name '*html*' -print0 | xargs -0 rm -v
find $LOCALMIRROR -name '*downloads.*' -print0 | xargs -0 rm -v

fi
echo " "
echo " --- Part 2 ---"
read -p "To continue this script and start mirror process press any key... to abort hold Control + C"

#Note you might need to add k to the end of speed

cd $LOCALMIRROR
if [[ $TYPE == "https" ]]; then
 #TYPE is https so we want no check certificate etc
  if [[ -n $USERNAME && $USERNAME != "" ]]; then
   if [[ -n $SPEED  && $SPEED != "" && $SPEED != "0" ]]; then
     #TYPE IS HTTPS WE HAVE USERNAME PASS AND SPEED
     wget -c -e --limit-rate=$SPEED robots=off -x --user=$USERNAME --password=$PASSWORD -m --no-check-certificate $REMOTESERVER
   else
     #TYPE IS HTTPS WE HAVE USERNAME AND PASS BUT NOT SPEED
     wget -c -e robots=off -x --user=$USERNAME --password=$PASSWORD -m --no-check-certificate $REMOTESERVER
   fi
  else
    if [[ -n $SPEED && $SPEED != "" && $SPEED != "0" ]]; then
     #TYPE IS HTTPS WE DO NOT HAVE USERNAME PASS BUT WE DO HAVE SPEED
     wget -c -e --limit-rate=$SPEED robots=off -x -m --no-check-certificate $REMOTESERVER
   else
     #TYPE IS HTTPS WE NO USERNAME PASSWORD OR SPEED
     wget -c -e robots=off -x -m --no-check-certificate $REMOTESERVER
   fi
  fi
else
 #TYPE is http or ftp
  if [[ -n $USERNAME && $USERNAME != "" ]]; then
   if [[ -n $SPEED && $SPEED != "" && $SPEED != "0" ]]; then
     #TYPE IS HTTP WE HAVE USERNAME PASS AND SPEED
     wget -c -e --limit-rate=$SPEED robots=off -x --user=$USERNAME --password=$PASSWORD -m $REMOTESERVER
   else
     #TYPE IS HTTP WE HAVE USERNAME AND PASS BUT NOT SPEED
     wget -c -e robots=off -x --user=$USERNAME --password=$PASSWORD -m $REMOTESERVER
   fi
  else
    if [[ -n $SPEED && $SPEED != "" && $SPEED != "0" ]]; then
     #TYPE IS HTTP WE DO NOT HAVE USERNAME PASS BUT WE DO HAVE SPEED
     wget -c -e --limit-rate=$SPEED robots=off -x -m $REMOTESERVER
   else
     #TYPE IS HTTP WE NO USERNAME PASSWORD OR SPEED
     wget -c -e robots=off -x -m $REMOTESERVER
   fi
  fi
fi
#wget -c -e --limit-rate=1200k robots=off -x --user=foo --password=bar -m --no-check-certificate https://example.com/exampleDirectory

echo ""
echo ""
echo "#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#"
echo ""
echo ""

# This section of the script is to clean any un-wanted html files generated by the mirroring process.
# If you would like to keep the generated html and html.download.* files choose "n" and hit enter at this prompt.
# After choosing "y" or "n" you must hit enter for the script to read your choice

echo "Do you want to delete the extra html files ( y / n ) ?"

read a
if [[ $a == "N" || $a == "n" ]]; then
        echo "Ending script..."
else
        echo "Cleaning files..."

find $LOCALMIRROR -name '*html*' -print0 | xargs -0 rm -v
find $LOCALMIRROR -name '*downloads.*' -print0 | xargs -0 rm -v

fi

echo "end of script"
echo "#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#-#=\+/=#"
echo " "
read -p "Press any key to continue."
