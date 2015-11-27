Archive-Server-Project
======================
Project done during the Spring 2014 for the system administration course [ LO14 ] at the University of Technology of Troyes.
We created a linux-based archive server with shell scripts, using Bash and AWK. The main options were listing available archives, browsing each file content, and extracting an archive onto the client-side.
<img src="https://mdn.mozillademos.org/files/4291/client-server.png" alt="Logo Server" width="400px"/>
======================
* Listing mode to know available archives on the server
* Extraction mode to download an archive and automatically extract the files from it
* Browsing mode to run through the archives, explore and alter directories/files
  * ls
  * cd
  * pwd
  * rm
  * cat
  * clear
  * exit

======================
Please, follow the required setup below to run the scripts. These programs are intended to run on a recent distribution of Linux (compatible with Ubuntu 12 and Debian 7). They are not intended to run an other distributions or platform, even if some of them might run the server without much issues.

The server-side should be running vshserver.sh in the first place.
Make this file executable and run it. The server can be runned locally for testing purposes.

Only then, the client-side can connect to the server. It must provide an available client port to receive the messages on its side (8080 or 8888 should do it).


* server_directory
	* Archives
		* PokmeonArchive.txt
		* OneArchive.txt
	* vshserver.sh
	* vshbrowse.sh
	* vshlist.sh

* client_directory
	* vshclient.sh

======================
Screenshots from the running server below

<i>List mode</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448488/8687a27e-9540-11e5-83e2-da485698caa7.png" alt="List-mode" width="400px"/></p>

<i>Extract mode</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448489/8688d3ce-9540-11e5-8628-2c239d8c4ce4.png" alt="Extract-mode" width="400px"/></p>

<i>Browse mode</i>
* <i>ls</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448485/868249aa-9540-11e5-9a4d-70f5faeb5fa2.png" alt="Browse-mode-ls" width="400px"/></p>

* <i>cat</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448486/8683cea6-9540-11e5-8be3-d38bef87241b.png" alt="Browse-mode-ls" width="400px"/></p>

* <i>cd, pwd</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448487/86851a54-9540-11e5-9327-2d7327dd95ef.png" alt="Browse-mode-ls" width="400px"/></p>

* <i>rm</i>
<p><img src="https://cloud.githubusercontent.com/assets/5488566/11448484/866959b8-9540-11e5-95bc-9c11ce3c9685.png" alt="Browse-mode-ls" width="400px"/></p>
