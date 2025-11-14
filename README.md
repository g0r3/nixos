# nixos
My nixos host configs

For machines first run the `prepare-disk.sh` script in the according machines subfolder.

Then install Nixos using the command `(sudo) nixos-install --flake .#name-of-machine`
If used with encryption, use this command to enroll the key:
`sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sdX2`
