package net.geohex;

import net.geohex.GeoHex;

class HelloTest extends haxe.unit.TestCase {

	public function testBasic() {
		var geohex = new GeoHex();

		assertEquals("A", "A");
	}

	public function testGetVersion() 
	{
		assertEquals("2.03", GeoHex.getVersion());
	}

	// public function testLoc2xy_basic() 
	// {
	// 	var xy = Zone.loc2xy(0.0, 0.0);
	// 	assertEquals(0.0, xy.x);
	// 	assertEquals(0.0, xy.y);
	// }

	// public function testXy2loc_basic() 
	// {
	// 	var loc = Zone.xy2loc(210.0, 0.0);
	// 	// assertEquals( {lon:0.0, lat:0.0}, loc);
	// 	assertEquals(0.0, loc.lat);
	// 	assertEquals(0.0, loc.lon);
	// }

}