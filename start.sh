#!/bin/bash
# Minecraft Bedrock server startup script using screen

# Set path variable
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "Unable to set path variable.  You likely need to download an updated version of SetupMinecraft.sh from GitHub!"
fi

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
    echo "This script is not meant to be run as root. Please run ./start.sh as a non-root user, without sudo;  Exiting..."
    exit 1
fi

# Randomizer for user agent
RandNum=$(echo $((1 + $RANDOM % 5000)))

# Check if server is already started
ScreenWipe=$(screen -wipe 2>&1)
if screen -list | grep -q '\.servername\s'; then
    echo "Server is already started!  Press screen -r servername to open it"
    exit 1
fi

# Change directory to server directory
cd dirname/minecraft/servername

# Create logs/backups/downloads folder if it doesn't exist
if [ ! -d "logs" ]; then
    mkdir logs
fi
if [ ! -d "downloads" ]; then
    mkdir downloads
fi
if [ ! -d "backups" ]; then
    mkdir backups
fi

# Check if network interfaces are up
NetworkChecks=0
if [ -e '/sbin/route' ]; then
    DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
else
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
fi
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second"
    sleep 1
    if [ -e '/sbin/route' ]; then
        DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
    else
        DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    fi
    NetworkChecks=$((NetworkChecks + 1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Take ownership of server files and set correct permissions
Permissions=$(sudo bash dirname/minecraft/servername/fixpermissions.sh -a)

# Create backup
if [ -d "worlds" ]; then
    echo "Backing up server (to minecraft/servername/backups folder)"
    if [ -n "$(which pigz)" ]; then
        echo "Backing up server (multiple cores) to minecraft/servername/backups folder"
        tar -I pigz -pvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz worlds
    else
        echo "Backing up server (single cored) to minecraft/servername/backups folder"
        tar -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz worlds
    fi
fi

# Rotate backups -- keep most recent 10
Rotate=$(
    pushd dirname/minecraft/servername/backups
    ls -1tr | head -n -10 | xargs -d '\n' rm -f --
    popd
)

# Retrieve latest version of Minecraft Bedrock dedicated server
echo "Checking for the latest version of Minecraft Bedrock server ..."

# Test internet connectivity first
curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -s google.com -o /dev/null
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    # Download server index.html to check latest version

    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o downloads/version.html https://www.minecraft.net/en-us/download/server/bedrock
    LatestURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)

    LatestFile=$(echo "$LatestURL" | sed 's#.*/##')

    echo "Latest version online is $LatestFile"
    if [ -e version_pin.txt ]; then
        echo "version_pin.txt found with override version, using version specified: $(cat version_pin.txt)"
        PinFile=$(cat version_pin.txt)
    fi

    if [ -e version_installed.txt ]; then
        InstalledFile=$(cat version_installed.txt)
        echo "Current install is: $InstalledFile"
    fi

    if [[ "$PinFile" == *"zip" ]] && [[ "$InstalledFile" == "$PinFile" ]]; then
        echo "Requested version $PinFile is already installed"
    elif [ ! -z "$PinFile" ]; then
        echo "Installing $PinFile"
        DownloadFile=$PinFile
        DownloadURL="https://minecraft.azureedge.net/bin-linux/$PinFile"

        # Download version of Minecraft Bedrock dedicated server if it's not already local
        if [ ! -f "downloads/$DownloadFile" ]; then
            curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o "downloads/$DownloadFile" "$DownloadURL"
        fi

        # Install version of Minecraft requested
        if [ ! -z "$DownloadFile" ]; then
            if [ ! -e dirname/minecraft/servername/server.properties ]; then
                unzip -o "downloads/$DownloadFile" -x "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            else
                unzip -o "downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            fi
            Permissions=$(chmod u+x dirname/minecraft/servername/bedrock_server >/dev/null)
            echo "$DownloadFile" >version_installed.txt
        fi
    elif [[ "$InstalledFile" == "$LatestFile" ]]; then
        echo "Latest version $LatestFile is already installed"
    else
        echo "Installing $LatestFile"
        DownloadFile=$LatestFile
        DownloadURL=$LatestURL

        # Download version of Minecraft Bedrock dedicated server if it's not already local
        if [ ! -f "downloads/$DownloadFile" ]; then
            curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o "downloads/$DownloadFile" "$DownloadURL"
        fi

        # Install version of Minecraft requested
        if [ ! -z "$DownloadFile" ]; then
            if [ ! -e dirname/minecraft/servername/server.properties ]; then
                unzip -o "downloads/$DownloadFile" -x "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            else
                unzip -o "downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            fi
            Permissions=$(chmod u+x dirname/minecraft/servername/bedrock_server >/dev/null)
            echo "$DownloadFile" >version_installed.txt
        fi
    fi
fi

if [ ! -e dirname/minecraft/servername/allowlist.json ]; then
    echo "Creating default allowlist.json..."
    echo '[]' > dirname/minecraft/servername/allowlist.json
fi
if [ ! -e dirname/minecraft/servername/permissions.json ]; then
    echo "Creating default permissions.json..."
    echo '[]' > dirname/minecraft/servername/permissions.json
fi

echo "Starting Minecraft server.  To view window type screen -r servername"
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"

BASH_CMD="LD_LIBRARY_PATH=dirname/minecraft/servername dirname/minecraft/servername/bedrock_server"
if command -v gawk &>/dev/null; then
    BASH_CMD+=$' | gawk \'{ print strftime(\"[%Y-%m-%d %H:%M:%S]\"), $0 }\''
else
    echo "gawk application was not found -- timestamps will not be available in the logs.  Please delete SetupMinecraft.sh and run the script the new recommended way!"
fi
screen -L -Logfile logs/servername.$(date +%Y.%m.%d.%H.%M.%S).log -dmS servername /bin/bash -c "${BASH_CMD}"
