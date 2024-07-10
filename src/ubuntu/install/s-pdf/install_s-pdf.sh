#!/usr/bin/env bash
set -ex

ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

if [[ "${DISTRO}" == @(debian|opensuse|ubuntu) ]] && [ ${ARCH} = 'amd64' ] && [ ! -z ${SKIP_CLEAN+x} ]; then
  echo "not installing chromium on x86_64 desktop build"
  exit 0
fi

if [[ "${DISTRO}" == @(centos|oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8|fedora37|fedora38|fedora39|fedora40) ]]; then
  if [[ "${DISTRO}" == @(oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8|fedora37|fedora38|fedora39|fedora40) ]]; then
    dnf install -y chromium
    if [ -z ${SKIP_CLEAN+x} ]; then
      dnf clean all
    fi
  else
    yum install -y chromium
    if [ -z ${SKIP_CLEAN+x} ]; then
      yum clean all
    fi
  fi
elif [ "${DISTRO}" == "opensuse" ]; then
  zypper install -yn chromium
  if [ -z ${SKIP_CLEAN+x} ]; then
    zypper clean --all
  fi
elif grep -q "ID=debian" /etc/os-release || grep -q "ID=kali" /etc/os-release || grep -q "ID=parrot" /etc/os-release; then
  apt-get update
  apt-get install -y chromium
  if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
  fi
else
  apt-get update
  apt-get install -y git  automake  autoconf  libtool  libleptonica-dev  pkg-config zlib1g-dev make g++ openjdk-21-jdk python3 python3-pip
# jbig2enc:
mkdir ~/.git
cd ~/.git &&\
git clone https://github.com/agl/jbig2enc.git &&\
cd jbig2enc &&\
./autogen.sh &&\
./configure &&\
make &&\
make install

cd ~/.git &&\
git clone https://github.com/Stirling-Tools/Stirling-PDF.git &&\
cd Stirling-PDF &&\
chmod +x ./gradlew &&\
./gradlew build &&\
mkdir /opt/Stirling-PDF &&\
mv ./build/libs/Stirling-PDF-*.jar /opt/Stirling-PDF/ &&\
mv scripts /opt/Stirling-PDF/ &&\
cp ./docs/stirling-transparent.svg /opt/Stirling-PDF/ &&\
echo "Scripts installed."

apt install -y 'tesseract-ocr-*'

cat > /usr/share/applications/Stirling-PDF.desktop <<EOF
[Desktop Entry]
Name=Stirling PDF;
GenericName=Launch StirlingPDF and open its WebGUI;
Category=Office;
Exec=xdg-open http://localhost:8080 && nohup java -jar /opt/Stirling-PDF/Stirling-PDF-*.jar &;
Icon=/opt/Stirling-PDF/stirling-transparent.svg;
Keywords=pdf;
Type=Application;
NoDisplay=false;
Terminal=true;
EOF

fi

apt-get install -y libreoffice-writer libreoffice-calc libreoffice-impress unpaper ocrmypdf
pip3 install uno opencv-python-headless unoconv pngquant WeasyPrint --break-system-packages

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
