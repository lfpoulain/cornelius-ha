# Cornelius

Cornelius est le miroir intelligent de la famille : il reconnaît qui se présente, écoute « Cornelius » et répond à la voix, en français. Cette application fait tourner son serveur et sa perception sur la box Home Assistant. Le miroir s'affiche sur un autre appareil : un Raspberry Pi en kiosque, une tablette ou un ordinateur.

Le guide complet est dans la documentation de Cornelius : [Installer dans Home Assistant](https://github.com/lfpoulain/Cornelius/blob/home-assistant/docs/installation/home-assistant.md).

## Démarrer

1. Dans **Configuration**, choisissez le mot de passe de l'administration : 8 caractères au moins, autre que `cornelius`. Collez la clé OpenAI ici ou plus tard dans l'administration.
2. **Démarrer**, puis activez **Chien de garde** : il relance Cornelius s'il s'arrête.
3. **Ouvrir l'interface web**. Le navigateur prévient que le certificat n'est pas reconnu : Cornelius crée le sien. Comparez son empreinte avec la ligne « Empreinte du certificat » du **Journal**, puis continuez.

## Ouvrir le miroir

1. Sur l'appareil du miroir, ouvrez `https://homeassistant.local:3443/` (ou l'adresse IP de la box, avec le port choisi dans **Réseau**).
2. Autorisez l'appareil avec le mot de passe de l'administration.
3. Dans l'administration, **Caméra et reconnaissance → Emplacement de la caméra**, choisissez **Sur l'appareil qui affiche le miroir**, sauf si une caméra USB est branchée sur la box.
4. Touchez **Activer la voix** sur le miroir.

## Relier Home Assistant

Dans **Modules → Home Assistant**, l'adresse est `http://127.0.0.1:8123`, avec un jeton longue durée créé de préférence par un compte réservé à Cornelius, sans droits d'administrateur. Si Home Assistant sert lui-même du HTTPS (`ssl_certificate` dans sa configuration), utilisez son adresse `https://` avec le nom de son certificat.

## Options

- **Mot de passe de l'administration** : un mot de passe choisi ensuite dans l'administration le remplace, et cette option n'a alors plus d'effet. Pour le changer, passez par l'administration.
- **Clé OpenAI** : facultative, celle collée dans l'administration passe avant.
- **Petite machine** : `oui` retire la vision locale et cherche les visages sur une image réduite. `auto` vaut `oui` sur Raspberry Pi, Home Assistant Green et Yellow, ODROID et Khadas, `non` ailleurs.
- **Port interne** : port HTTP sur la boucle locale de la box, utilisé par la perception (`3000`, 1024 ou plus).
- **Numéro de la caméra USB** : pour une caméra branchée sur la box.
- **Noms d'hôte acceptés** : noms supplémentaires pour ouvrir Cornelius, séparés par des virgules. Le nom de la box et les adresses IP locales sont toujours acceptés.

Le port HTTPS (`3443`) se change dans la rubrique **Réseau** : 1024 ou plus, différent du port interne.

## Les droits demandés

- **Réseau de l'hôte** : les satellites audio trouvent Cornelius par mDNS, le miroir l'ouvre en HTTPS sur le réseau local, et Cornelius rejoint Home Assistant sur `127.0.0.1:8123`. Cela fait passer la note de sécurité de l'application de 5 à 4 (sur 8).
- **Vidéo** : seulement pour une caméra USB branchée sur la box.

Sur le réseau de l'hôte, `127.0.0.1` est partagé avec Home Assistant et ses autres applications : Cornelius ne leur fait pas confiance pour autant (`CORNELIUS_TRUST_LOOPBACK=0`) : elles ont les mêmes droits qu'un appareil du réseau local et n'ouvrent ni le miroir ni l'administration sans le mot de passe.

## Données et sauvegardes

Tout ce qui doit durer est dans le dossier de l'application : base, certificat, journal, images de l'écran de veille, images générées et modèles. Pendant une sauvegarde, l'application s'arrête le temps de copier son dossier (base, images, journal), puis repart.

Les sauvegardes de Home Assistant contiennent la base (jeton Home Assistant, signatures des visages, souvenirs) et les options (mot de passe, clé OpenAI) : gardez-les à l'abri. Les modèles n'y sont pas : ceux de l'image sont remis au démarrage, et le modèle de vision se retélécharge depuis l'administration.

## Limites

- Pas de panneau dans la barre latérale (Ingress) : l'administration s'ouvre dans son propre onglet, en HTTPS, ce que le micro du miroir exige.
- Pas de génération d'images locale : choisissez OpenAI dans **Modules → Génération d'image**. Un modèle local installé depuis l'administration serait perdu à chaque redémarrage de l'application.

## Aide

- Le **Journal** de l'application montre le serveur et la perception ; le journal détaillé est dans l'administration, rubrique **Journal**.
- Questions et problèmes : [dépôt Cornelius](https://github.com/lfpoulain/Cornelius) et [dépannage](https://github.com/lfpoulain/Cornelius/blob/main/docs/utilisation/depannage.md).

## Licence

Cornelius est sous licence [PolyForm Noncommercial 1.0.0](https://github.com/lfpoulain/Cornelius/blob/main/LICENSE) : usage non commercial seulement. Ses notices sont dans l'image, dans `/app`. Les fichiers de l'application elle-même sont sous licence MIT.
