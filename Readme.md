##TP VHDL : Ethernet-10 Core

> ZENNARO Thomas <br>
> BOURLOT Xavier <br>

Le projet se décompose en 3 fichiers : 
 - receiver
 - transmitter
 - transceiver (non fonctionnel)

### Receiver

Fréquence maximale de fonctionnement : 327.547MHz <br>
Nombre de flip flop : 9 <br>
Le fichier `receiver_test` implémente des tests de réception de trames complètes et valides, de trames avec adresse incorrecte et interrompues par reset ou enable.

Il subsiste des warnings non résolus mais vus en cours avec vous : 
 - `WARNING:Xst:1710 - FF/Latch <RDONEP> (without init value) has a constant value of 0 in block <receiver>. This FF/Latch will be trimmed during the optimization process.` (RDONEP change bien de valeur en simulation.)
 - `WARNING:Xst:2404 -  FFs/Latches <RSMATIP<0:0>> (without init value) have a constant value of 0 in block <receiver>.`
 - `WARNING RDATAO (0 à 7) et RBYTEP (without initial value)`

Nous avons tenté d'éliminer ces warning en contraignant la taille des signaux par l'utilisation de subtypes. Tout l'intervalle de valeurs est bien utilisé (vérifié en simulation). Chaque signal de sortie ne conserve également pas de valeur constante pendant la réception.

####Choix d'implémentation des signaux
 - `RENABP` : on considère qu'un niveau bas de `RENABP` remet à zéro les signaux relatifs aux données et les différents compteurs de trame (par opposition à une simple pause dans la réception).
 - `current_frame_step` : on utilise ce signal pour découper les différentes parties de la trame (0 correspond au SFD, 1 correspond à l'adresse destinataire...)
 - `current_addr_byte` : compteur d'octets dans chaque étape de la trame.
 - `clk_counter` : divise la clock en 8 pour la réception par octets. Remise à zéro du compteur par débordement.
 
### Transmitter

Fréquence maximale de fonctionnement : 311.915MHz <br>
Nombre de flip flops : 14 <br>

Le fichier `transmitter_test` implémente des tests d'emission de trames complètes et valides, de trames interrompues par reset ou abort, ainsi qu'une tentative de transmission durant le padding suite à une erreur..

Il subsiste des warnings non résolus mais vus en cours avec vous : 

 - `WARNING:Xst:1293 - FF/Latch <current_frame_step_1> has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:1896 - Due to other FF/Latch trimming, FF/Latch <current_frame_step_2> has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:1710 - FF/Latch <TDONEP> (without init value) has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_0> of sequential type is unconnected in block <transmitter>.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_1> of sequential type is unconnected in block <transmitter>.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_2> of sequential type is unconnected in block <transmitter>.`
 - `WARNING:Xst:1293 - FF/Latch <current_frame_step_1> has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:1293 - FF/Latch <current_frame_step_2> has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:1895 - Due to other FF/Latch trimming, FF/Latch <TDONEP> (without init value) has a constant value of 0 in block <transmitter>. This FF/Latch will be trimmed during the optimization process.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_0> of sequential type is unconnected in block <transmitter>.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_1> of sequential type is unconnected in block <transmitter>.`
 - `WARNING:Xst:2677 - Node <current_addr_byte_2> of sequential type is unconnected in block <transmitter>.`

Nous avons tenté d'éliminer ces warning en contraignant la taille des signaux par l'utilisation de subtypes. Tout l'intervalle de valeurs est bien utilisé (vérifié en simulation). Chaque signal de sortie ne conserve également pas de valeur constante pendant l'émission.

####Choix d'implémentation des signaux

On utilise les mêmes signaux de comptage que pour le receiver (`current_frame_step`, `current_addr_byte`, `clk_counter`).
 - `TABORTB` : on considère qu'un niveau haut de `TABORTB` remet à zéro les signaux relatifs aux données et les différents compteurs de trame.
 - `TFINISHP` : doit se lever après la fin de la trame, c.a.d. dès que l'EFD a été envoyé. Une levée prématurée de ce signal provoque une erreur et reset la transmission.
 - `TLASTP` : signale le dernier octet de données. Il entraîne une émission de l'EFD.
 - `TDONEP` : une impulsion est produite pour chaque envoi de données utiles (données + adresse destinataire) 

### Transceiver

Non implémenté car problème d'inclusion des composants non résolu.
