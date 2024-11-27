# TODO
- Add support for patch files

# NOTES
- Pokud hledáme moduly v /boot/config-..., tak už se nám ale nepodaří najít moduly, které jsem
  doinstalovali potom pomocí DKMS. Takže při druhém spuštění playbooku, tak to nenajde třeba amd_energy,
  který jsme už jednou pomocí DKMS instalovali, ale on není v config souboru. 
  Takže se to znovu pokusí zbuildit a nainstalovat. -> wasted time
  
  Takže si zase myslím, že dobrou alternativou by proto bylo modinfo. :D
  
  Trochu jsem to zkoumal a on taky dokáže zjistit, jestli je module builtin nebo jestli je pluggable.
  Takže efektivně získáme skoro stejné info jako z toho config souboru. 
  
  Potom by ta role na základě toho mohla udělat nic, pokud je to builtin tak neudělá nic a nechá ho být
  a pokud je to pluggable, tak ho načte pomocí modprobu. 
  
  A pokud tam ten modul vůbec není, tak by modinfo hodí error (který bychom chytli) a ta role by mohla 
  zbuildit ten modul z repa.