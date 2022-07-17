# Minecraft Bedrock Server

Sets up a Minecraft Bedrock dedicated server on Ubuntu / Debian with options for automatic updates, backups and running automatically at startup.<br>
View installation instructions at: https://aesycos.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/<br>
<br>

<h2>Features</h2>
<ul>
  <li>Sets up the official Minecraft Bedrock Server (currently in alpha testing)</li>
  <li>Fully operational Minecraft Bedrock edition server in a couple of minutes</li>
  <li>Ubuntu / Debian distributions supported</li>
  <li>Sets up Minecraft as a system service with option to autostart at boot</li>
  <li>Automatic backups when server restarts</li>
  <li>Supports multiple instances -- you can run multiple Bedrock servers on the same system</li>
  <li>Updates automatically to the latest or user-defined version when server is started</li>
  <li>Easy control of server with start.sh, stop.sh and restart.sh scripts</li>
  <li>Adds logging with timestamps to "logs" directory</li>
  <li>Optional scheduled daily restart of server using cron</li>
</ul>

<h2>Quick Installation Instuctions</h2>
To run the installation type:<br>
<pre>curl https://raw.githubusercontent.com/Aesycos/MinecraftBedrockServer/master/SetupMinecraft.sh | bash</pre>

<h2>Installation Guide</h2>
<a href="https://aesycos.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/">Minecraft Bedrock Dedicated Server Script Installation / Configuration Guide</a>

<h2>Multiple Servers and Installation Paths</h2>
<p>The server supports multiple servers at once.  When you run SetupMinecraft.sh again, pick the identical root path as any previous servers.  The path structure of the scripts is $ROOTPATH/minecraftbe/yourservername, which is why the "root" path SetupMinecraft.sh asks you for should always be the same.</p>
<p>The individual server folder is determined by the "server name" you enter for your server.  If it's an existing server, the scripts will be safely updated.  If it's a new server, then a new folder will be created under $ROOTPATH/minecraft/newservername. The default server name is "bedrock"</p>
<p>Keep the installation path the same for all servers and the script will manage all this for you.</p>

<h2>Version Override</h2>
You can revert to a previous version with the revert.sh script included in your directory like this: <pre>./revert.sh
Set previous version in version_pin.txt: bedrock-server-1.19.10.20.zip</pre>
If you have a specific version you would like to run, you can also create version_pin.txt yourself like this: <pre>echo "bedrock-server-1.18.33.02.zip" > version_pin.txt</pre>
The version hold can be removed by deleting version_pin.txt.  This will allow it to update to the latest version again!
