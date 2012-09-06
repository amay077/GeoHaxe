import net.geohex.GeoHexTest;

class GeoHexTestRunner {
	static function main() {

		var r = new haxe.unit.TestRunner();
		r.add(new GeoHexTest());

		r.run();
	}	
}