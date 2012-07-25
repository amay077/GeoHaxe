package net.geohex;

import net.geohex.GeoHex;
import net.geohex.GeoHex.Zone;

class HelloTest extends haxe.unit.TestCase {

	public function testBasic() {
		var geohex = new GeoHex();

		assertEquals("A", "A");
	}

	public function testGetVersion() 
	{
		assertEquals("2.03", GeoHex.getVersion());
	}

	public function testGetHexSize_basic() 
	{
    	assertEquals(247376.6461728395, 
    			GeoHex.getZoneByLocation(0, 0, 1).getHexSize()); // Lv1
    	assertEquals(27486.29401920439, 
    			GeoHex.getZoneByLocation(0, 0, 3).getHexSize()); // Lv3
    	assertEquals(3054.0326688004875, 
    			GeoHex.getZoneByLocation(0, 0, 5).getHexSize()); // Lv5
    	assertEquals(339.3369632000542, 
    			GeoHex.getZoneByLocation(0, 0, 7).getHexSize()); // Lv7
    	assertEquals(37.70410702222824, 
    			GeoHex.getZoneByLocation(0, 0, 9).getHexSize()); // Lv9
    	assertEquals(4.189345224692027, 
    			GeoHex.getZoneByLocation(0, 0, 11).getHexSize()); // Lv11
    	assertEquals(0.4654828027435586, 
    			GeoHex.getZoneByLocation(0, 0, 13).getHexSize()); // Lv13
    	assertEquals(0.05172031141595095, 
    			GeoHex.getZoneByLocation(0, 0, 15).getHexSize()); // Lv15
	}

    public function testGetZoneByLocation_basic() 
    {
		var zone : Zone = GeoHex.getZoneByLocation(0, 0, 1);
    	var locs = zone.getHexCoords();
    	
    	assertEquals(6, locs.length);
		assertEquals( 0.0               , locs[0].lat);
		assertEquals(-4.444444444444445 , locs[0].lon);
		assertEquals( 3.8461100614416903, locs[1].lat);
		assertEquals(-2.2222222222222223, locs[1].lon);
		assertEquals( 3.8461100614416903, locs[2].lat);
		assertEquals( 2.2222222222222223, locs[2].lon);
		assertEquals( 0.0               , locs[3].lat);
		assertEquals( 4.444444444444445 , locs[3].lon);
		assertEquals(-3.846110061441703 , locs[4].lat);
		assertEquals( 2.2222222222222223, locs[4].lon);
		assertEquals(-3.846110061441703 , locs[5].lat);
		assertEquals(-2.2222222222222223, locs[5].lon);
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