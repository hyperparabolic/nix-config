# Scripts

Bootstrap, installation and debug scripts.

[hyperbparabolic-bootstrap](./hyperparabolic-bootstrap.sh) performs repo bootstrapping for new hosts. This includes key generation / rotation, and updating sops secrets.

[hyperparabolic-install](./hyperparabolic-install.sh) performs disk, zpool, zfs dataset, and LUKS/LVM management to enable [luksOnZfs](https://blog.decent.id/post/lower-compromises-zfs-encryption/), an encryption / filesystem scheme enabling both native ZFS encryption and LUKS key management and unlock options.

[hyperparabolic-import](./hyperparabolic-import.sh) is a utility to import and mount luksOnZfs filesystems for debugging outside a booting system.

[hyperparabolic-export](./hyperparabolic-export.sh) is a utility to unmount and export luksOnZfs filesystems during the installation process and in debugging outside a booting system.
