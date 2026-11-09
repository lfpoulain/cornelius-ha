# Historique

Les versions les plus récentes en premier. Chaque version indique le commit de Cornelius qu'elle contient.

## 0.3.0 · 2026-11-09

### Changé

- Cornelius [0.3.0](https://github.com/lfpoulain/Cornelius/releases/tag/v0.3.0) (commit `148a1eb`) : les nouveautés sont dans ses notes de version.
- cornelius-modules au commit [`e6e9e4e`](https://github.com/lfpoulain/cornelius-modules/commit/e6e9e4ea5f5e08aad1e08d852d593399e01295d5).

## 0.2.0 · 2026-11-02

### Changé

- Cornelius [0.2.0](https://github.com/lfpoulain/Cornelius/releases/tag/v0.2.0), sa première version publiée (commit `7d24988`, tag `v0.2.0`), au lieu d'un commit de travail. Désormais, l'application suit les versions publiées de Cornelius.

### Ajouté

- Mémoire extraite par un serveur compatible OpenAI de la maison (Ollama…), réglable dans **Mise en route → Clés et jetons → Mémoire personnalisée** de l'administration de Cornelius.

## 0.1.1 · 2026-11-02

### Corrigé

- Les satellites trouvent la box seuls : l'annonce mDNS répondait aux recherches sous Windows seulement (Cornelius au commit `7fd03bb`).

### Changé

- Le dépôt est public : l'application s'installe depuis la boutique de Home Assistant (bouton « Ajouter le dépôt » du README) et ses mises à jour y arrivent.

## 0.1.0 · 2026-11-01

### Ajouté

- Première version : serveur et perception de Cornelius sur Home Assistant OS (amd64 et aarch64), miroir sur un autre appareil en HTTPS (port 3443), satellites audio par mDNS.
- Cornelius au commit `26d03a3` et cornelius-modules au commit `365ab49` ; Node 24.22.2, uv 0.13.6, Python 3.12.16 et image de base `base-debian:trixie-2026.10.3` épinglés par version et empreinte.
- La boucle locale de la box n'est pas une source de confiance (`CORNELIUS_TRUST_LOOPBACK=0`) ; le nom de la box est accepté ; le mode petite machine suit le type de machine de Home Assistant.
- Chien de garde sur `/api/health`, sauvegarde à froid sans les modèles.
