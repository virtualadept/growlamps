#!/usr/bin/perl
#

use DateTime;
use DateTime::Event::Sunrise;

$lightstatus = 0;
$|=1;

# By default pin 11 is IN, swap it.
print "Setting Pin 11 state to OUT\n\n";
`/usr/bin/gpio -1 mode 11 out`;

# Every min, get the current sunup/down time (to compensate for date shift) and turn lamps on/off
#
# Todo -> cache sunup and sundown time, and readjust when day rolls over.
# if todaydate > cached date -> new date sub
while (1) {
	# Set this to your Lat/Long and TZ.
	$nowtime = DateTime->now(time_zone => 'America/Los_Angeles');
	$sun_morada = DateTime::Event::Sunrise->new(longitude => -121.2458,latitude  => +38.0385);
	$suntime = DateTime->new(year      => $nowtime->year,
                         	month     => $nowtime->month,
                         	day       => $nowtime->day,
                         	time_zone => 'America/Los_Angeles');

	if (($nowtime->hms gt $sun_morada->sunrise_datetime($suntime)->hms) && ($nowtime->hms lt $sun_morada->sunset_datetime($suntime)->hms)) {
		if ($lightstatus == 0) {
			print "TURNING ON LIGHTS!!\n";
			`/usr/bin/gpio -1 write 11 1`;
			sleep 5;
		#	print "Smile for camera!!\n\n";
		#	$snaptime = time;
		#	`/usr/bin/raspistill -o /home/pi/timelapse/$snaptime.jpg`;
			$lightstatus = 1;
		}
		print "ON: Its: " . $nowtime->hms . "   Sundown is: " . $sun_morada->sunset_datetime($suntime)->hms .  "\n";
		sleep 60;

	} else { 
		if ($lightstatus == 1) {
		#	print "Smile for camera!!\n\n";
		#	$snaptime = time;
		#	`/usr/bin/raspistill -o /home/pi/timelapse/$snaptime.jpg`;
			sleep 5;
			print "TURNING OFF LIGHTS!!!\n";
			`/usr/bin/gpio -1 write 11 0`;
			$lightstatus = 0;
		}
		print "OFF: Its: " . $nowtime->hms . "   Sunup is: " . $sun_morada->sunrise_datetime($suntime)->hms . "\n";
       		sleep 60;
	}
}
