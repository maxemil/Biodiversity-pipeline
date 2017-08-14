# on singularity >= 2.3.1 dev (order of sections matter!)
Bootstrap: docker
From: finalduty/archlinux:daily


%setup
cp MEGAN6-install.exp $SINGULARITY_ROOTFS

%post

######## base system ########
echo "Server = http://mirror.de.leaseweb.net/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "[lambdait]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = https://lambda.informatik.uni-tuebingen.de/repo/mypkgs/" >> /etc/pacman.conf

pacman -Syu --noconfirm
pacman -S --noconfirm base-devel jdk git wget expect tk

######## MEGAN6 ########
cp MEGAN6-install.exp /usr/local/
cd /usr/local/

wget http://ab.inf.uni-tuebingen.de/data/software/megan6/download/MEGAN_Community_unix_6_8_12.sh

chmod +x MEGAN6-install.exp
./MEGAN6-install.exp


######## MALT ########
wget http://ab.inf.uni-tuebingen.de/data/software/malt/download/MALT_unix_0_3_9.sh
chmod +x MALT_unix_0_3_9.sh
./MALT_unix_0_3_9.sh -q


######## python ########
pacman -S --noconfirm python3 python-pip
pip install biopython pandas numpy


######## FUNGuild ########
cd /usr/local
git clone https://github.com/UMNFuN/FUNGuild.git
ln /usr/local/FUNGuild/Guilds_v1.1.py /usr/local/bin/


######## Vsearch ########
wget https://github.com/torognes/vsearch/archive/v2.4.3.tar.gz
tar xzf v2.4.3.tar.gz
cd vsearch-2.4.3
./autogen.sh
./configure
make
make install

%files
binaries/spaced /usr/local/bin/spaced


%test
/usr/local/malt/malt-build -h
/usr/local/malt/malt-run -h
/usr/local/megan/tools/rma2info -h
vsearch --version
python3 /usr/local/bin/Guilds_v1.1.py -h


%labels
Maintainer	max-emil.schon@icm.uu.se
