Simple class that sorts Google Reader feeds in folders for the days of the week.

The code assumes there are folders named “[daily]”, “[twice weekly]”, and “every other day”. The feeds in these folders are then added to the weekday folders.

The first feed in the “[twice weekly]” folder is added to folders “1 Monday” and “4 Thursday”. The second feed is added to “2 Tuesday” and “5 Friday”. And so on.

The script does not check whether a feed already is in a particular folder, so it would be added multiple times. This is no big deal, though, as Google Reader doesn’t add feeds multiple times.