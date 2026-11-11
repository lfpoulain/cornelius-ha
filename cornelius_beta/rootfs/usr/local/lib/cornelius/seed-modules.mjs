// Premier démarrage avec le catalogue de modules : l'état des modules installés n'existe pas.
// La copie du dépôt officiel livrée dans l'image (commit de source.env) devient la copie de
// départ du catalogue, et les modules qui ont déjà au moins une source dans la base sont
// préinstallés : les miroirs d'avant le catalogue, qui chargeaient tous les modules depuis
// l'image, gardent ceux qu'ils utilisent. Rien n'est téléchargé.
//   node seed-modules.mjs <copie du dépôt> <commit> <dossier des modules> <base SQLite>
import { cpSync, existsSync, mkdirSync, readdirSync, renameSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';

const [source, commit, directory, database] = process.argv.slice(2);
if (!source || !/^[0-9a-f]{40}$/u.test(commit ?? '') || !directory || !database) {
  console.error('usage : seed-modules.mjs <copie> <commit> <dossier> <base>');
  process.exit(2);
}

const stateFile = join(directory, 'state.json');
if (existsSync(stateFile)) process.exit(0);

// Mêmes valeurs que server/module-store/store.ts (officialRepositoryUrl, repositoryId).
const url = 'https://github.com/lfpoulain/cornelius-modules';
const id = 'github-com-lfpoulain-cornelius-modules';

const snapshot = join(directory, 'repositories', id, commit);
if (!existsSync(snapshot)) {
  const staging = `${snapshot}.seed.partial`;
  mkdirSync(join(directory, 'repositories', id), { recursive: true });
  cpSync(source, staging, { recursive: true });
  renameSync(staging, snapshot);
}

const available = new Set(
  readdirSync(snapshot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && existsSync(join(snapshot, entry.name, 'index.ts')))
    .map((entry) => entry.name),
);

// Modules qui ont au moins une source. Une base absente (nouvelle installation) ou d'avant
// les sources n'en a aucun.
let used = [];
if (existsSync(database)) {
  const db = new DatabaseSync(database, { readOnly: true });
  try {
    const table = db
      .prepare("SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'addon_instances'")
      .get();
    if (table)
      used = db
        .prepare('SELECT DISTINCT addon_id AS id FROM addon_instances ORDER BY addon_id')
        .all()
        .map((row) => row.id)
        .filter((module) => available.has(module));
  } finally {
    db.close();
  }
}

const now = Date.now();
const state = {
  version: 1,
  repositories: [
    { id, url, branch: null, commit, available: null, checkedAt: null, error: null },
  ],
  installed: used.map((module) => ({ id: module, repository: id, installedAt: now })),
};
const temporary = `${stateFile}.seed.tmp`;
writeFileSync(temporary, JSON.stringify(state, null, 2) + '\n', 'utf8');
renameSync(temporary, stateFile);
console.log(
  used.length > 0
    ? `Modules repris de l'image : ${used.join(', ')}`
    : 'Catalogue de modules prêt ; aucun module à reprendre.',
);
