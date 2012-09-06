echo "-- build-start ------------------------"
echo "delete bin/"
rm -rf bin/
mkdir bin/
echo "build and run"
haxe build.hxml
