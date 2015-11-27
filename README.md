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
Please, follow the following setup to run the scripts.
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

<i>Extract mode</i>
<img src="https://cloud.githubusercontent.com/assets/5488566/11448489/8688d3ce-9540-11e5-8628-2c239d8c4ce4.png" alt="Extract-mode" />
