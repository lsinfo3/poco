% 	 Implementation of Haversine formula adopted from http://stackoverflow.com/questions/837872/calculate-distance-in-meters-when-you-know-longitude-and-latitude-in-java
% 	 * @param lat1
% 	 * @param lng1
% 	 * @param lat2
% 	 * @param lng2
% 	 * @return
% 	 */
function dist = distFrom(node1,node2)
lat1 = node1(1);
lng1 = node1(2);
lat2 = node2(1);
lng2 = node2(2);
earthRadius = 3958.75;
dLat = toRadians(lat2 - lat1);
dLng = toRadians(lng2 - lng1);
a = sin(dLat / 2) * sin(dLat / 2) + cos(toRadians(lat1)) * cos(toRadians(lat2))	* sin(dLng / 2) * sin(dLng / 2);
c = 2 * atan2(sqrt(a), sqrt(1 - a));
dist = earthRadius * c;
meterConversion = 1/0.000621371192;
dist=dist * meterConversion;

function r=toRadians(d)
    r=d/180*pi;
end

end