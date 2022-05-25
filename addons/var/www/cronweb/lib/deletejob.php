<?php

	require_once('crontab.php');

	$cron = new Crontab();
	$cron->deleteJob($_POST['jobid']);
	system("/etc/init.d/S93crond restart");

?>
