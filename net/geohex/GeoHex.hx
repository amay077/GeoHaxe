package net.geohex;

private class Consts
{
	// version: 2.03
	static public inline var version : String = "2.03";

	// *** Share with all instances ***
	static public inline var h_key : String = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	static public inline var h_base : Float = 20037508.34;
	static public inline var h_deg : Float = Math.PI * (30 / 180);
	static public inline var h_k = Math.tan(h_deg);
}

private class Zone 
{
	private var _lat : Float;
	private var _lon : Float;
	private var _x : Float;
	private var _y : Float;
	private var _code : String;

	// *** Share with all instances ***
	// private static
	static public function calcHexSize(level : Int) 
	{
		return Consts.h_base / Math.pow(2, level) / 3;
	}

	// private static
	static public function loc2xy(lon : Float, lat : Float) 
	{
		var x = lon * Consts.h_base / 180;
		var y = Math.log(Math.tan((90 + lat) * Math.PI / 360)) / (Math.PI / 180);
		y *= Consts.h_base / 180;
		return { x: x, y: y };
	}

	// private static
	static public function xy2loc(x : Float, y : Float) 
	{
		var lon = (x / Consts.h_base) * 180;
		var lat = (y / Consts.h_base) * 180;
		lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180)) - Math.PI / 2);
		return { lon: lon, lat: lat };
	}

	public function new(lat : Float, lon : Float, x : Float, y : Float, code : String)
	{
		_lat = lat;
		_lon = lon;
		_x = x;
		_y = y;
		_code = code;	
	}

	public function getLevel() 
	{
		return Consts.h_key.indexOf(_code.charAt(0));
	}

	public function getHexSize() 
	{
		return Zone.calcHexSize(this.getLevel());
	}

	public function getHexCoords() 
	{
		var h_lat = _lat;
		var h_lon = _lon;
		var h_xy = loc2xy(h_lon, h_lat);
		var h_x = h_xy.x;
		var h_y = h_xy.y;
		var h_deg = Math.tan(Math.PI * (60 / 180));
		var h_size = this.getHexSize();
		var h_top = xy2loc(h_x, h_y + h_deg *  h_size).lat;
		var h_btm = xy2loc(h_x, h_y - h_deg *  h_size).lat;

		var h_l = xy2loc(h_x - 2 * h_size, h_y).lon;
		var h_r = xy2loc(h_x + 2 * h_size, h_y).lon;
		var h_cl = xy2loc(h_x - 1 * h_size, h_y).lon;
		var h_cr = xy2loc(h_x + 1 * h_size, h_y).lon;
		return [
			{lat: h_lat, lon: h_l},
			{lat: h_top, lon: h_cl},
			{lat: h_top, lon: h_cr},
			{lat: h_lat, lon: h_r},
			{lat: h_btm, lon: h_cr},
			{lat: h_btm, lon: h_cl}
		];
	}
}

class GeoHex 
{
	static private var _zoneCache : Hash<Dynamic> = new Hash<Dynamic>();

	static public function getVersion() : String 
	{
		return Consts.version;
	}

	public function new() {

	}

	static public function getZoneByLocation(lat : Float, lon : Float, level : Int) 
	{
		var h_size = Zone.calcHexSize(level);

		var z_xy = Zone.loc2xy(lon, lat);
		var lon_grid = z_xy.x;
		var lat_grid = z_xy.y;
		var unit_x = 6 * h_size;
		var unit_y = 6 * h_size * Consts.h_k;
		var h_pos_x = (lon_grid + lat_grid / Consts.h_k) / unit_x;
		var h_pos_y = (lat_grid - Consts.h_k * lon_grid) / unit_y;
		var h_x_0 = Math.floor(h_pos_x);
		var h_y_0 = Math.floor(h_pos_y);
		var h_x_q = h_pos_x - h_x_0; //桁丸め修正
		var h_y_q = h_pos_y - h_y_0;
		var h_x = Math.round(h_pos_x);
		var h_y = Math.round(h_pos_y);

		var h_max = Math.round(Consts.h_base / unit_x + Consts.h_base / unit_y);

		if (h_y_q > -h_x_q + 1) 
		{
			if((h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q)){
				h_x = h_x_0 + 1;
				h_y = h_y_0 + 1;
			}
		} 
		else if (h_y_q < -h_x_q + 1) 
		{
			if ((h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5))
			{
				h_x = h_x_0;
				h_y = h_y_0;
			}
		}

		var h_lat = (Consts.h_k * h_x * unit_x + h_y * unit_y) / 2;
		var h_lon = (h_lat - h_y * unit_y) / Consts.h_k;

		var z_loc = Zone.xy2loc(h_lon, h_lat);
		var z_loc_x = z_loc.lon;
		var z_loc_y = z_loc.lat;

		if (Consts.h_base - h_lon < h_size)
		{
			z_loc_x = 180;
			var h_xy = h_x;
			h_x = h_y;
			h_y = h_xy;
		}

		var h_x_p =0;
		var h_y_p =0;
		if (h_x < 0) h_x_p = 1;
		if (h_y < 0) h_y_p = 1;
		var h_x_abs = Math.abs(h_x) * 2 + h_x_p;
		var h_y_abs = Math.abs(h_y) * 2 + h_y_p;
	//	var h_x_100000 = Math.floor(h_x_abs/777600000);
		var h_x_10000 = Math.floor((h_x_abs%777600000)/12960000);
		var h_x_1000 = Math.floor((h_x_abs%12960000)/216000);
		var h_x_100 = Math.floor((h_x_abs%216000)/3600);
		var h_x_10 = Math.floor((h_x_abs%3600)/60);
		var h_x_1 = Math.floor((h_x_abs%3600)%60);
	//	var h_y_100000 = Math.floor(h_y_abs/777600000);
		var h_y_10000 = Math.floor((h_y_abs%777600000)/12960000);
		var h_y_1000 = Math.floor((h_y_abs%12960000)/216000);
		var h_y_100 = Math.floor((h_y_abs%216000)/3600);
		var h_y_10 = Math.floor((h_y_abs%3600)/60);
		var h_y_1 = Math.floor((h_y_abs%3600)%60);

		var h_code = Consts.h_key.charAt(level % 60);

	//	if(h_max >=77600000/2) h_code += h_key.charAt(h_x_100000) + h_key.charAt(h_y_100000);
		if(h_max >=12960000/2) h_code += Consts.h_key.charAt(h_x_10000) + Consts.h_key.charAt(h_y_10000);
		if(h_max >=216000/2) h_code += Consts.h_key.charAt(h_x_1000) + Consts.h_key.charAt(h_y_1000);
		if(h_max >=3600/2) h_code += Consts.h_key.charAt(h_x_100) + Consts.h_key.charAt(h_y_100);
		if(h_max >=60/2) h_code += Consts.h_key.charAt(h_x_10) + Consts.h_key.charAt(h_y_10);
		h_code += Consts.h_key.charAt(h_x_1) + Consts.h_key.charAt(h_y_1);

		if (_zoneCache.exists(h_code)) 
		{ 
			return _zoneCache.get(h_code); 
		}

		_zoneCache.set(h_code, new Zone(z_loc_y, z_loc_x, h_x, h_y, h_code));
		return _zoneCache.get(h_code);
	}

	static public function getZoneByCode(code : String) 
	{
		if (_zoneCache.exists(code)) { return _zoneCache.get(code); }
		var c_length = code.length;
		var level = Consts.h_key.indexOf(code.charAt(0));
		var scl = level;
		var h_size =  Zone.calcHexSize(level);
		var unit_x = 6 * h_size;
		var unit_y = 6 * h_size * Consts.h_k;
		var h_max = Math.round(Consts.h_base / unit_x + Consts.h_base / unit_y);
		var h_x = 0;
		var h_y = 0;

	/*	if (h_max >= 777600000 / 2) {
		h_x = h_key.indexOf(code.charAt(1)) * 777600000 + 
			  h_key.indexOf(code.charAt(3)) * 12960000 + 
			  h_key.indexOf(code.charAt(5)) * 216000 + 
			  h_key.indexOf(code.charAt(7)) * 3600 + 
			  h_key.indexOf(code.charAt(9)) * 60 + 
			  h_key.indexOf(code.charAt(11));
		h_y = h_key.indexOf(code.charAt(2)) * 777600000 + 
			  h_key.indexOf(code.charAt(4)) * 12960000 + 
			  h_key.indexOf(code.charAt(6)) * 216000 + 
			  h_key.indexOf(code.charAt(8)) * 3600 + 
			  h_key.indexOf(code.charAt(10)) * 60 + 
			  h_key.indexOf(code.charAt(12));
		} else
	*/
		if (h_max >= 12960000 / 2) 
		{
			h_x = Consts.h_key.indexOf(code.charAt(1)) * 12960000 + 
				  Consts.h_key.indexOf(code.charAt(3)) * 216000 + 
				  Consts.h_key.indexOf(code.charAt(5)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(7)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(9));
			h_y = Consts.h_key.indexOf(code.charAt(2)) * 12960000 + 
				  Consts.h_key.indexOf(code.charAt(4)) * 216000 + 
				  Consts.h_key.indexOf(code.charAt(6)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(8)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(10));
		}
		else if (h_max >= 216000 / 2) 
		{
			h_x = Consts.h_key.indexOf(code.charAt(1)) * 216000 + 
				  Consts.h_key.indexOf(code.charAt(3)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(5)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(7));
			h_y = Consts.h_key.indexOf(code.charAt(2)) * 216000 + 
				  Consts.h_key.indexOf(code.charAt(4)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(6)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(8));
		}
		else if (h_max >= 3600 / 2) 
		{
			h_x = Consts.h_key.indexOf(code.charAt(1)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(3)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(5));
			h_y = Consts.h_key.indexOf(code.charAt(2)) * 3600 + 
				  Consts.h_key.indexOf(code.charAt(4)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(6));
		}
		else if (h_max >= 60 / 2) 
		{
			h_x = Consts.h_key.indexOf(code.charAt(1)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(3));
			h_y = Consts.h_key.indexOf(code.charAt(2)) * 60 + 
				  Consts.h_key.indexOf(code.charAt(4));
		}
		else
		{
			h_x = Consts.h_key.indexOf(code.charAt(1));
			h_y = Consts.h_key.indexOf(code.charAt(2));
		}

		h_x = (h_x % 2) ? -(h_x - 1) / 2 : h_x / 2;
		h_y = (h_y % 2) ? -(h_y - 1) / 2 : h_y / 2;
		var h_lat_y = (Consts.h_k * h_x * unit_x + h_y * unit_y) / 2;
		var h_lon_x = (h_lat_y - h_y * unit_y) / Consts.h_k;

		var h_loc = Zone.xy2loc(h_lon_x, h_lat_y);
		return (_zoneCache[code] = new Zone(h_loc.lat, h_loc.lon, h_x, h_y, code));
	}

	static public function getZoneByXY(x, y, level) 
	{
		var scl = level;
		var h_size =  Zone.calcHexSize(level);
		var unit_x = 6 * h_size;
		var unit_y = 6 * h_size * Consts.h_k;
		var h_max = Math.round(Consts.h_base / unit_x + Consts.h_base / unit_y);
		var h_lat_y = (Consts.h_k * x * unit_x + y * unit_y) / 2;
		var h_lon_x = (h_lat_y - y * unit_y) / Consts.h_k;

		var h_loc = Zone.xy2loc(h_lon_x, h_lat_y);
		var x_p =0;
		var y_p =0;
		if (x < 0) x_p = 1;
		if (y < 0) y_p = 1;
		var x_abs = Math.abs(x) * 2 + x_p;
		var y_abs = Math.abs(y) * 2 + y_p;
	//	var x_100000 = Math.floor(x_abs/777600000);
		var x_10000 = Math.floor((x_abs%777600000)/12960000);
		var x_1000 = Math.floor((x_abs%12960000)/216000);
		var x_100 = Math.floor((x_abs%216000)/3600);
		var x_10 = Math.floor((x_abs%3600)/60);
		var x_1 = Math.floor((x_abs%3600)%60);
	//	var y_100000 = Math.floor(y_abs/777600000);
		var y_10000 = Math.floor((y_abs%777600000)/12960000);
		var y_1000 = Math.floor((y_abs%12960000)/216000);
		var y_100 = Math.floor((y_abs%216000)/3600);
		var y_10 = Math.floor((y_abs%3600)/60);
		var y_1 = Math.floor((y_abs%3600)%60);

		var h_code = Consts.h_key.charAt(level % 60);

	//	if(h_max >=77600000/2) h_code += h_key.charAt(x_100000) + h_key.charAt(y_100000);
		if(h_max >=12960000/2) h_code += Consts.h_key.charAt(x_10000) + Consts.h_key.charAt(y_10000);
		if(h_max >=216000/2) h_code += Consts.h_key.charAt(x_1000) + Consts.h_key.charAt(y_1000);
		if(h_max >=3600/2) h_code += Consts.h_key.charAt(x_100) + Consts.h_key.charAt(y_100);
		if(h_max >=60/2) h_code += Consts.h_key.charAt(x_10) + Consts.h_key.charAt(y_10);
		h_code += Consts.h_key.charAt(x_1) + Consts.h_key.charAt(y_1);

		_zoneCache.set(h_code, new Zone(h_loc.lat, h_loc.lon, x, y, h_code));
		return _zoneCache.get(h_code);
	}

	static public function getXYListBySteps(zone, radius) 
	{
		var list = new Array();

		for (i in 0..radius) 
		{
			list[i] = new Array();
		}

		list[0].push((zone.x) + "_" + (zone.y));
		for (i in 0..radius) 
		{
	        for (j in 0..radius) 
	        {
	            if (i || j)
	            {
		      		if (i >= j) 
		      		{
		      			list[i].push((zone.x + i) + "_" + (zone.y + j)); 
	      			}
	      			else 
	      			{
	      				list[j].push((zone.x + i) + "_" + (zone.y + j));
	      			}
		      		
		      		if (i >= j) 
		      		{
		      			list[i].push((zone.x - i) + "_" + (zone.y - j)); 
	      			}
	      			else 
	      			{
	      				list[j].push((zone.x - i) + "_" + (zone.y - j)) ;
	      			}

	              	if (i>0 && j>0 && (i+j<=radius-1))
	              	{
		        		list[i+j].push((zone.x - i) + "_" + (zone.y + j));
		        		list[i+j].push((zone.x + i) + "_" + (zone.y - j));
		      		}
	            }
	        }
	    }
		return list;
	}

	static public function getXYListByCoordPath(start, end, level) 
	{
		var zone0 = GeoHex.getZoneByLocation(start.lat, start.lon, level);
		var zone1 = GeoHex.getZoneByLocation(end.lat, end.lon, level);
        var startx = parseFloat(zone0.x);
        var starty = parseFloat(zone0.y);
        var endx = parseFloat(zone1.x);
        var endy = parseFloat(zone1.y);
        var x = endx - startx;
        var y = endy - starty;
		var list = new Array();
		var xabs = Math.abs(x);
		var yabs = Math.abs(y);
		/*if(xabs)*/ var xqad = x/xabs;
		/*if(yabs)*/ var yqad = y/yabs;
		var m = 0;
		if (xqad == yqad)
		{
		    if(yabs > xabs) m = x; else m = y;
		}
		var mabs = Math.abs(m);
		var steps = xabs + yabs - mabs + 1;
		var start_xy = Zone.loc2xy(start.lon, start.lat);
		var start_x = start_xy.x;
		var start_y = start_xy.y;
		var end_xy = Zone.loc2xy(end.lon, end.lat);
		var end_x = end_xy.x;
		var end_y = end_xy.y;
		var h_size = Zone.calcHexSize(level);
		var unit_x = 6 * h_size;
		var unit_y = 6 * h_size * Consts.h_k;
		var pre_x=0;
		var pre_y=0;
		var cnt=0;

		for (i in 0..steps*2)
		{
		    var lon_grid = start_x + (end_x - start_x)*i/(steps*2);
		    var lat_grid = start_y + (end_y - start_y)*i/(steps*2);
		    var h_pos_x = (lon_grid + lat_grid / h_k) / unit_x;
		    var h_pos_y = (lat_grid - Consts.h_k * lon_grid) / unit_y;
		    var h_x_0 = Math.floor(h_pos_x);
		    var h_y_0 = Math.floor(h_pos_y);
		    var h_x_q = h_pos_x - h_x_0;
		    var h_y_q = h_pos_y - h_y_0;
		    var h_x = Math.round(h_pos_x);
		    var h_y = Math.round(h_pos_y);

		    var h_max = Math.round(Consts.h_base / unit_x + Consts.h_base / unit_y);

			if (h_y_q > -h_x_q + 1) 
			{
				if ((h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q))
				{
					h_x = h_x_0 + 1;
					h_y = h_y_0 + 1;
				}
			} 
			else if (h_y_q < -h_x_q + 1) 
			{
				if ((h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5))
				{
					h_x = h_x_0;
					h_y = h_y_0;
				}
			}

			if (pre_x!=h_x||pre_y!=h_y)
			{
				cnt++;
				list[cnt] = new Array();
				list[cnt].push(h_x + "_" + h_y) ;
			}

		    pre_x = h_x;
		    pre_y = h_y;    
		}

		return (list);
	}

	static public function getXYListByZonePath(start, end) 
	{
	    var x = end.x - start.x;
	    var y = end.y - start.y;
		var list = new Array();
		var xabs = Math.abs(x);
		var yabs = Math.abs(y);
		/*if(xabs)*/ var xqad = x/xabs;
		/*if(yabs)*/ var yqad = y/yabs;
		var m = 0;
		if (xqad == yqad)
		{
		    if(yabs > xabs) m = x; else m = y;
		}

		var mabs = Math.abs(m);
		var steps = xabs + yabs - mabs + 1;

		for(i in 0..steps)
		{
			list[i] = new Array();
		}

		var j = 0;
		if(m)
		{
		  	var mqad = m/mabs;
		  	var pase = Math.abs(steps/m);
		  	if (x)
		  	{
		    	for (i in 0..steps)
	    		{
		       		if (i > j * pase)
		       		{
		          		j++;
		          		list[i].push((start.x + i*mqad) + "_" + (start.y + j*mqad));
		       		}
		       		else
		       		{
		          		list[i].push((start.x + i*mqad) + "_" + (start.y + j*mqad));
		       		}
        		}
		  	}
		  	else
		  	{
	    		for(i in 0..steps)
		    	{
		       		if (i > j * pase)
		       		{
		          		j++;
		          		list[i].push((start.x + j*mqad) + "_" + (start.y + i*mqad));
		       		}
		       		else
		       		{
		          		list[i].push((start.x + j*mqad) + "_" + (start.y + i*mqad));
		       		}
		    	}
		  	}
		}
		else
		{
			if (xabs && yqad)
			{
		    	var pase = Math.abs(steps/xabs);
		    	for(i in 0..steps)
		    	{
		       		if (i > j * pase) j++;
		          	list[i].push((start.x + j*xqad) + "_" + (start.y + (i-j)*yqad));
	            }
		  	}
		  	else if (xabs)
		  	{
		    	for (i in 0..steps)
		    	{
					list[i].push((start.x + i*xqad) + "_" + (start.y));
	            }
		  	}
		  	else
		  	{
		    	for(i in 0..steps)
		    	{
		        	list[i].push((start.x) + "_" + (start.y + i*yqad));
	            }
		  	}
		}
		return list;
	}

	public function getSteps(start, end)
	{
        var x = 1.0; //end.x - start.x;
        var y = 1.0; //end.y - start.y;
		var list = new Array();
		var xabs = Math.abs(x);
		var yabs = Math.abs(y);
		/*if (xabs) */ var xqad = x/xabs;
		/*if (yabs) */ var yqad = y/yabs;
		var m = 0.0;
		if (xqad == yqad) 
		{
			m = (yabs > xabs) ? x : y; 
		    // if (yabs > xabs) m = x; else m = y;
		}
		var mabs = Math.abs(m);
		var steps = xabs + yabs - mabs + 1;
		return steps;
	}
}
