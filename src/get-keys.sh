#/bin/sh
apt-get install -f -y dirmngr
for i in $*; do
cat $1 | apt-key add -
done
