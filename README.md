# 🐑 Simple Ecosystem Simulator


Une simulation rétro-épurée d’écosystème avec reproduction, alimentation, sommeil, et cycle jour/nuit.

Développé avec [LÖVE2D](https://love2d.org/), ce projet propose une base pour expérimenter des comportements d'entités dans un environnement évolutif et autonome.

![Miniature](./miniature.png){width=75%}

---

## 🎮 Objectif du projet

Simuler la vie de créatures (moutons) dans un environnement basé sur des tuiles (`Tile`), avec des comportements naturels :

- déplacement vers les ressources,
- sommeil selon le rythme circadien,
- reproduction conditionnelle (âge, énergie, saison…),
- liens sociaux (suivi de la mère, partenaire),
- vieillissement, gestation et naissance.

---

## 🧠 Mécaniques implémentées

- **Rythme jour/nuit** avec horloge mondiale (`WorldClock`)
- **Saisons** influençant la reproduction
- **Tuiles de terrain** avec herbe qui pousse et se fait manger
- **Moutons (`Sheep`)** avec :
  - besoins (faim, énergie)
  - genre, âge, gestation
  - comportement de troupeau (suivi de la mère ou du partenaire)
  - sommeil (diurne/nocturne)
- **Visualisation HUD** du temps et des statistiques de population
- **Liaisons sociales visibles** entre individus (traits colorés)
- **Modularité comportementale** via répertoires :
  - `Behavior/` : graze, move, sleep, reproduce, social
  - `Entity/` : entités du monde (Tile, Sheep)

---

## 🚀 Lancer le projet

### Prérequis

- [LÖVE2D](https://love2d.org/) (version 11.x recommandée)

### Lancement

<code> love .</code>

## 📌 TODO / Améliorations prévues

- Gestion de la longévité et de la mort
- Introduction de nouveaux animaux (prédateurs, proies…)
- Génétique simple (héritage de traits)
- Météo (influence sur la pousse de l’herbe)
- Menu interactif + interface clicable
- Export des données (statistiques, logs de population)

## 🧑‍💻 Auteur

Projet initié par Jojopov, pour s’entraîner à la simulation, la logique d’IA naturelle, et la structuration propre en Lua.

## 🧾 Licence

GNU GPL3
# SimpleEcosystem
