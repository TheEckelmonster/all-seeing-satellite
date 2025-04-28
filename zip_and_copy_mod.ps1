$mod = "all-seeing-satellite"
$version = "0.5.1"

$mod_directory = $mod + "_"
$full = $mod_directory + $version

# Path to your mod
$dev_path = "G:\Factorio\Mods\dev\" + $mod
# Default path to Factorio mods
$destination = $env:APPDATA + "\Factorio\mods\"

$zip = ".zip"
$dev_full = $dev_path + "\" + $full

# Delete the old .zip file from the dev directory
Write-Output ("Deleteing " + ($dev_full + $zip))
del ($dev_full + $zip)

# Zip the contents of the mod folder
Write-Output ("Zipping " + ($dev_full + "\") + " to " + ($dev_full + $zip))
Compress-Archive ($dev_full + "\") ($dev_full + $zip)

# Delete the old .zip file from the Factorio\mods folder
Write-Output ("Deleteing " + ($destination + $full + $zip))
del ($destination + $full + $zip)

# Copy the .zip from the dev folder to the Factorio\mods folder
Write-Output ("Copying " + ($dev_full + $zip) + " to " + $destination)
Copy-Item ($dev_full + $zip) -Destination $destination