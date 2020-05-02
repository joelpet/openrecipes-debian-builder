#
# Regular cron jobs for the openrecipes package
#
0 4	* * *	root	[ -x /usr/bin/openrecipes_maintenance ] && /usr/bin/openrecipes_maintenance
