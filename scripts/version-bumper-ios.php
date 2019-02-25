<?php
echo "\r\n";

echo "---- BUMPING VERSION ----";
echo "\r\n";
echo "\r\n";

echo "Parsing SmartReceipts/SmartReceipts-Info.plist....";
echo "\r\n";

// Parse SmartReceipts/SmartReceipts-Info.plist
if (file_exists('../SmartReceipts/SmartReceipts-Info.plist')) {
    $plistXML = simplexml_load_file('../SmartReceipts/SmartReceipts-Info.plist');
} else {
    exit('Failed to open ../SmartReceipts/SmartReceipts-Info.plist');
}

// Get the full version from the XML Object
$fullVersion = $plistXML->dict->string[7];
echo "Full version from XML: " . $fullVersion;
echo "\r\n";

// Get major from full version
preg_match("/([0-9]+)\.[0-9]+\.[0-9]+/", $fullVersion, $matches);
$major = $matches[1];

// Get minor from full version
preg_match("/[0-9]+\.([0-9]+)\.[0-9]+/", $fullVersion, $matches);
$minor =  $matches[1];

// Get versionCode from the XML object
$versionCode = $plistXML->dict->string[9];
echo "versionCode from XML: " . $versionCode;
echo "\r\n";

// Bump Version Code
$versionCode += 20;
echo "versionCode after bumping by 20: " . $versionCode;
echo "\r\n";

echo "Minor from XML: " . $minor;
echo "\r\n";

// Bump minor
$minor++;

echo "Minor after bumping by 1: " . $minor;
echo "\r\n";

// Build new full version with bumped stuff
$fullVersion = $major . "." . $minor . "." . $versionCode;

echo "New full version after bumping: " . $fullVersion;
echo "\r\n";

echo "Editing XML Object...";
echo "\r\n";

// Edit version code in the xml object
$plistXML->dict->string[9] = $versionCode;

// Edit full version in the xml object
$plistXML->dict->string[7] = $fullVersion;

echo "Writing to SmartReceipts/SmartReceipts-Info.plist....";
echo "\r\n";

// Save to file
$new = fopen("SmartReceipts/SmartReceipts-Info.plist", "w");
fwrite($new, $plistXML->asXML()); //write XML to new file using asXML method
fclose($new);

// Check version was bumped properly
echo "Checking to see we wrote correctly to SmartReceipts/SmartReceipts-Info.plist....";
echo "\r\n";

// Parse SmartReceipts/SmartReceipts-Info.plist (after editing)
if (file_exists('SmartReceipts/SmartReceipts-Info.plist')) {
    $plistXML = simplexml_load_file('SmartReceipts/SmartReceipts-Info.plist');
} else {
    exit('Failed to open SmartReceipts/SmartReceipts-Info.plist');
}

// Check version code bump
if ($plistXML->dict->string[9] == $versionCode){
	echo "versionCode updated successfully!";
	echo "\r\n";

} else {
	echo "Failed to bump versionCode, exiting...";
	echo "\r\n";
	die();
}

// Check fullVersio bump
if ($plistXML->dict->string[7] == $fullVersion){
	echo "fullVersion updated successfully!";
	echo "\r\n";

} else {
	echo "Failed to bump fullVersion, exiting...";
	echo "\r\n";
	die();
}


echo "Done!";
echo "\r\n";
echo "\r\n";
echo "---- FINISHED BUMPING VERSION ----";
echo "\r\n";
echo "\r\n";
?>