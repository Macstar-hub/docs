1- first for extend follow as below :
1-1: lsblk :
1-1-1: 
sdj                    8:144  0  250G  0 disk 
└─sdj1                 8:145  0  250G  0 part 
  └─vg9-data         252:7    0  200G  0 lvm  
sr0                   11:0    1 1024M  0 rom  

1-2: for making new partition and new whole size: 
1-2-1: fdisk /dev/sdj
1-2-2: act as below : 

before any change make print all patition: 
--------
Command (m for help): p

Disk /dev/sdj: 250 GiB, 268435456000 bytes, 524288000 sectors
Disk model: Virtual disk    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xad05955a

Device     Boot Start       End   Sectors  Size Id Type



/dev/sdj1        2048 419430399 419428352  200G 8e Linux LVM    ------> Importnant note: make sure remember first segment in this case we should remember: 2048.

delete old partition with command: "d"
-----------------

Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): p
Disk /dev/sdj: 250 GiB, 268435456000 bytes, 524288000 sectors
Disk model: Virtual disk    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xad05955a

Make new partition with "n" command: 
-----------------

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-524287999, default 2048):    ---------> Important note: make sure select write first segment, in this case select 2048. 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-524287999, default 524287999): 

Created a new partition 1 of type 'Linux' and of size 250 GiB.
Partition #1 contains a LVM2_member signature.

Do you want to remove the signature? [Y]es/[N]o: No    -------> Importnant note: must be select "No"

Make list all partition before write command  with "p" command: 
-----------------

Command (m for help): p

Disk /dev/sdj: 250 GiB, 268435456000 bytes, 524288000 sectors
Disk model: Virtual disk    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xad05955a

Device     Boot Start       End   Sectors  Size Id Type
/dev/sdj1        2048 524287999 524285952  250G 83 Linux

-----------------
And then make write with "w" command.

1-3: After we can check new partition with 

sdj                    8:144  0  250G  0 disk 
└─sdj1                 8:145  0  250G  0 part 
  └─vg9-data         252:7    0  200G  0 lvm  
sr0                   11:0    1 1024M  0 rom  


1-4: theh resize pv with below stpes: 
1-4-1: pvs: 
root@fbvmkpw10:/home/mofid.dc/me.moradi# pvs
  PV         VG  Fmt  Attr PSize    PFree 
  /dev/sda3  vg0 lvm2 a--   <18.00g     0 
  /dev/sdb   vg1 lvm2 a--    <2.00g     0 
  /dev/sdc1  vg3 lvm2 a--  <100.00g     0 
  /dev/sdd   vg3 lvm2 a--    <7.00g     0 
  /dev/sde   vg4 lvm2 a--    <6.00g     0 
  /dev/sdf   vg5 lvm2 a--    <5.00g     0 
  /dev/sdg   vg6 lvm2 a--    <3.00g     0 
  /dev/sdh   vg7 lvm2 a--    <4.00g     0 
  /dev/sdi   vg8 lvm2 a--    <8.00g     0 
  /dev/sdj1  vg9 lvm2 a--  <250.00g 50.00g       -----> Not yet resize pv

1-4-2: pvresize /dev/sdj1 
1-4-3: root@fbvmkpw10:/home/mofid.dc/me.moradi# pvs
  PV         VG  Fmt  Attr PSize    PFree 
  /dev/sda3  vg0 lvm2 a--   <18.00g     0 
  /dev/sdb   vg1 lvm2 a--    <2.00g     0 
  /dev/sdc1  vg3 lvm2 a--  <100.00g     0 
  /dev/sdd   vg3 lvm2 a--    <7.00g     0 
  /dev/sde   vg4 lvm2 a--    <6.00g     0 
  /dev/sdf   vg5 lvm2 a--    <5.00g     0 
  /dev/sdg   vg6 lvm2 a--    <3.00g     0 
  /dev/sdh   vg7 lvm2 a--    <4.00g     0 
  /dev/sdi   vg8 lvm2 a--    <8.00g     0 
  /dev/sdj1  vg9 lvm2 a--  <250.00g 100.00g  -----> new pv resize extended. 

1-5: To extended lv: 
1-5-1: lvextend /dev/vg9/data -l +100%FREE

1-6: to extend and resize zpool: 
1-6-1: zpool list
NAME             SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zfspv-unityssd   199G  41.5G   158G        -         -    43%    20%  1.00x    ONLINE  -
1-6-2: zpool online -e zfspv-unityssd /dev/vg9/data

1-6-2: 
