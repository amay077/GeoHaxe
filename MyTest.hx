import net.geohex.HelloTest;

class MyTest {
	static function main() {
		var r = new haxe.unit.TestRunner();
		r.add(new HelloTest());

		r.run();
	}	
}