# Historique

Les versions les plus récentes en premier. Chaque version indique le commit de Cornelius qu'elle contient.

## 0.1.0 · 2026-11-01

### Ajouté

- Première version : serveur et perception de Cornelius sur Home Assistant OS (amd64 et aarch64), miroir sur un autre appareil en HTTPS (port 3443), satellites audio par mDNS.
- Cornelius au commit `26d03a3` (branche `home-assistant`) et cornelius-modules au commit `365ab49` ; Node 24.22.2, uv 0.13.6, Python 3.12.16 et image de base `base-debian:trixie-2026.10.3` épinglés par version et empreinte.
- La boucle locale de la box n'est pas une source de confiance (`CORNELIUS_TRUST_LOOPBACK=0`) ; le nom de la box est accepté ; le mode petite machine suit le type de machine de Home Assistant.
- Chien de garde sur `/api/health`, sauvegarde à froid sans les modèles.
