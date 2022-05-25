<?php

	require_once('crontab.php');

	$cron = new Crontab();
	$cron->deleteAllJobs();
	system("/etc/init.d/S93crond restart");

?>
