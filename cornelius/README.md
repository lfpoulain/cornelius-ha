# Cornelius

Le miroir intelligent de la famille : il reconnaît qui se présente, écoute « Cornelius » et répond à la voix, en français. Cette application fait tourner le serveur et la perception sur la box ; le miroir s'affiche sur un autre appareil du réseau local.

## Avant d'installer

- Une box 64 bits : PC x86-64, Raspberry Pi 4 ou 5, Home Assistant Green ou Yellow.
- Un autre appareil pour le miroir : navigateur récent, écran, micro, haut-parleur et caméra.
- Une clé OpenAI (ou Mistral) pour la conversation.
- L'image se construit sur la box à l'installation : comptez plusieurs minutes.

## Droits demandés

- **Réseau de l'hôte** : satellites audio par mDNS, miroir en HTTPS sur le réseau local, Home Assistant sur `127.0.0.1:8123`.
- **Vidéo** : pour une caméra USB branchée sur la box, facultative.

Voir l'onglet **Documentation** pour la mise en route.
