 #!/bin/bash
 #Script setup debian 11 pour init ansible et JtR

 #install minimum
sudo apt-get install build-essential libssl-dev -y
sudo apt-get install yasm libgmp-dev libpcap-dev libnss3-dev libkrb5-dev pkg-config libbz2-dev zlib1g-dev -y

#install git to import project
sudo apt install git ansible -y
#import JtR project
sudo git clone git://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john
#go into src
cd john/src/
#build project
sudo ./configure && make -s clean && make -s
sudo make
#Now you are able to use is with ../run/john
cd ~
sudo mv john /opt/
#now use john with /opt/john/run/john
sudo useradd -m -s /bin/bash rayman
sudo -u rayman ssh-keygen
sudo cat /home/rayman/.ssh/id_rsa.pub
#add in google compute keys
