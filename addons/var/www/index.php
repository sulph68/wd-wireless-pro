<?php
   header('X-UA-Compatible: IE=edge,chrome=1');
    //build cached file if it doesn't exist
    $cacheFile = 'cache/fullpage.html';
    define ('DEBUG_MODE', false);
    define ('SITE_BASE_URL', 'UI');
    
   include_once('UI/lib/language.php');
             $language = new Language();
           $languageStr = $language->getLanguage();
           
          define('LANGUAGE_STR', $languageStr);
            ob_start();
            setlocale(LC_ALL, $languageStr.".UTF-8");
            bindtextdomain("default", "UI/locale");
            textdomain("default");
            
            include_once('UI/views/common/languages.php');
            if(isset($langMap[$languageStr])){
                $Language3Letter = $langMap[$languageStr];
            }
            else{
                $Language3Letter = 'eng';
            }
            define('LANGUAGE_3CHAR', $Language3Letter);

            include_once('UI/lib/pageLoader.php');/**/
?>

<?php
// lazy coding
function my_exec($cmd, $input='') {
	$proc=proc_open($cmd, array(0=>array('pipe', 'r'), 1=>array('pipe', 'w'), 2=>array('pipe', 'w')), $pipes);
	fwrite($pipes[0], $input);fclose($pipes[0]);
	$stdout=stream_get_contents($pipes[1]);fclose($pipes[1]);
	$stderr=stream_get_contents($pipes[2]);fclose($pipes[2]);
	$rtn=proc_close($proc);
	return array('stdout'=>$stdout, 'stderr'=>$stderr, 'return'=>$rtn);
}

?>

<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="apple-itunes-app" content="app-id=450655672">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<meta name="apple-itunes-app" content="app-id=450655672">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />

	<script type="text/javascript">
		window.onload = function(){
			 // window.location = "/UI";
		}
	</script>
	<link href="/css/bootstrap.css" rel="stylesheet">
	<link href="/css/bootstrap-responsive.css" rel="stylesheet">
	<title>MyPassport</title>

</head>
<body>
	<!--<div id="containner">
		<p id="check" style="display:block;"></p>
		<div id="logo" ><img src="/detect-source/images/loading_logo.png"/>
		<div id="wording"><?php echo _('NEWKORRA_CAPTIVE_LOADING'); ?>...</div>
		<div id="wording2" style="display:none;"><a id=""></a><div>
	</div>
	<!--<div id="bottom_area"></div>change22--
	</div><!--containner-->

	<div class="container">
		<div class="row">
			<div class="col">
			<h4>MOTD <button type="button" class="btn-primary pull-right" onclick="window.location.reload()">Refresh</button></h4>	
			<br>
			</div>
		</div>
		<div class="row">
			<div class="col">
			<?php
			$output = my_exec("/usr/bin/motd");
			print "<pre>".$output['stdout']."</pre>\n";
			?>
			</div>
		</div>

		<div class="row">
			<div class="col">
			<h4>Quick Links</h4>	
			</div>
		</div>
		<div class="row">
			<div class="col">
			<li><a href="/UI">WD NAS Admin Page</a>
			<li><a href="/files">File Browser</a>
			<li><a href="javascript:window.location='http://'+window.location.hostname+':8080';">File Browser - Insecure Direct Access</a>
			<li><a href="/cronweb">Cronjob Manager</a>
			</div>
		</div>
		<div class="row">
			<div class="col">
			<h4>Last rclone status</h4>	
			</div>
		</div>
		<div class="row">
			<div class="col" style="height: 300px; overflow-y: scroll;">
			<?php
			$output = my_exec("/home/root/local/bin/rclone_status");
			print "<pre>".$output['stdout']."</pre>\n";
			?>
			</div>
		</div>
		<div class="row">
			<div class="col">
			<h4>Temperature Throttle</h4>	
			</div>
		</div>
		<div class="row">
			<div class="col" style="height: 250px; overflow-y: scroll; display:flex; flex-direction: column-reverse;">
			<?php
			$output = my_exec("/usr/bin/tail -n25 /CacheVolume/throttle.log");
			print "<pre>".$output['stdout']."</pre>\n";
			?>
			</div>
		</div>
	</div>
	<div class="container">
		<div class="row">
			<div class="col">
			<br><br>
			</div>
		</div>
	</div>
        
</body>
