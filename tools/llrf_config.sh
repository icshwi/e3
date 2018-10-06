#Check for curl-devel
[ "$UID" -eq 0 ] || { echo "This script must be run with root priviledges."; exit 1; }
echo "Checking for requiring dependencies:"
echo "boost-devel, libcurl-devel, udev-devel"
yum install -y boost-devel
yum install -y libcurl-devel
yum install -y libudev-devel
