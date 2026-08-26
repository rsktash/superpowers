#!/usr/bin/env node
// lint-citations.mjs — verify a task body's factual citations against the tree.
//
// Usage: lint-citations.mjs <body-file.md> [--repo <root>]
//
// Verifies two surfaces:
//  1. The body's fenced ```citations block — one claim per line:
//       file: <path>                      path exists
//       symbol: <name> @ <path>          literal <name> occurs in <path>
//       string: <text> @ <path>          literal <text> occurs in <path>
//       key: <dot.path> @ <file.json>    key path resolves in the JSON file
//       commit-contains: <sha> <text>    `git show <sha>` contains <text>
//       new: <path>                      declared as created by this task (exempts free-scan)
//  2. Free scan — every backticked token that looks like a repo path must exist,
//     unless declared under a `Create:` line in Files or via `new:`.
//
// Exit 0 = every claim verified. Exit 1 = failures listed, one per line.
// A body that cites nothing passes vacuously — the linter proves cited facts,
// never coverage.

import { readFileSync, existsSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { resolve, join } from "node:path";

const args = process.argv.slice(2);
const bodyFile = args.find((a) => !a.startsWith("--"));
const repoFlag = args.indexOf("--repo");
const repo = repoFlag !== -1 ? resolve(args[repoFlag + 1]) : process.cwd();

if (!bodyFile) {
  console.error("usage: lint-citations.mjs <body-file.md> [--repo <root>]");
  process.exit(2);
}

const body = readFileSync(bodyFile, "utf8");
const failures = [];
const exempt = new Set();

const fileHas = (path, text) => {
  const abs = join(repo, path);
  if (!existsSync(abs)) return `no such file: ${path}`;
  return readFileSync(abs, "utf8").includes(text) ? null : `not found in ${path}: ${text}`;
};

// ---- 1. citations block ----------------------------------------------------
const block = body.match(/```citations\n([\s\S]*?)```/);
for (const raw of block ? block[1].split("\n") : []) {
  const line = raw.trim();
  if (!line || line.startsWith("#")) continue;
  const m = line.match(/^(file|symbol|string|key|commit-contains|new):\s*(.*)$/);
  if (!m) {
    failures.push(`unparseable citation line: ${line}`);
    continue;
  }
  const [, kind, rest] = m;
  const at = rest.match(/^(.*?)\s+@\s+(\S+)$/); // "<payload> @ <path>"
  const unq = (s) => s.replace(/^["'«]|["'»]$/g, "");
  let err = null;
  if (kind === "file") {
    if (!existsSync(join(repo, rest))) err = `no such path: ${rest}`;
  } else if (kind === "new") {
    exempt.add(rest);
  } else if (kind === "symbol" || kind === "string") {
    if (!at) err = `expected "<${kind}> @ <path>": ${line}`;
    else err = fileHas(at[2], unq(at[1]));
  } else if (kind === "key") {
    if (!at) err = `expected "<dot.path> @ <file.json>": ${line}`;
    else {
      const abs = join(repo, at[2]);
      if (!existsSync(abs)) err = `no such file: ${at[2]}`;
      else {
        let node;
        try { node = JSON.parse(readFileSync(abs, "utf8")); } catch { err = `unparseable JSON: ${at[2]}`; }
        if (!err) {
          for (const part of at[1].split(".")) {
            if (node == null || typeof node !== "object" || !(part in node)) {
              err = `key not found in ${at[2]}: ${at[1]}`;
              break;
            }
            node = node[part];
          }
        }
      }
    }
  } else if (kind === "commit-contains") {
    const cm = rest.match(/^(\S+)\s+(.+)$/);
    if (!cm) err = `expected "<sha> <text>": ${line}`;
    else {
      try {
        const patch = execFileSync("git", ["-C", repo, "show", cm[1]], {
          encoding: "utf8",
          maxBuffer: 64 * 1024 * 1024,
        });
        if (!patch.includes(unq(cm[2]))) err = `commit ${cm[1]} does not contain: ${cm[2]}`;
      } catch {
        err = `no such commit: ${cm[1]}`;
      }
    }
  }
  if (err) failures.push(`FAIL ${line}  —  ${err}`);
}

// ---- 2. free scan of backticked paths --------------------------------------
// Files declared as created by the task are legitimate future paths.
for (const m of body.matchAll(/^\s*-?\s*Create:\s*`?([^\s`]+)`?/gm)) exempt.add(m[1]);

const seen = new Set();
for (const m of body.matchAll(/`([^`\n]+)`/g)) {
  // strip a trailing :line or :start-end pin before checking existence
  const token = m[1].replace(/:\d+(-\d+)?$/, "");
  if (!/^[\w@][\w.\/@-]*\/[\w.\/@-]+\.\w{1,10}$/.test(token)) continue; // path-shaped: has a slash and an extension
  if (seen.has(token) || exempt.has(token)) continue;
  seen.add(token);
  const abs = join(repo, token);
  if (!existsSync(abs)) failures.push(`FAIL cited path does not exist: ${token}`);
  else if (m[1] !== token) {
    // a :line pin survived into the body — verify the range is inside the file
    const span = m[1].slice(token.length + 1).split("-").map(Number);
    const lines = readFileSync(abs, "utf8").split("\n").length;
    if (Math.max(...span) > lines)
      failures.push(`FAIL line pin past end of file (${lines} lines): ${m[1]}`);
  }
}

if (failures.length) {
  for (const f of failures) console.error(f);
  console.error(`\nlint-citations: ${failures.length} unverified claim(s) — fix or delete each; an unverifiable fact does not belong in a task body.`);
  process.exit(1);
}
console.log("lint-citations: OK");
