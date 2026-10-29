/**
 * Superpowers plugin for OpenCode.ai
 *
 * Injects superpowers bootstrap context into the first user message.
 * Registers the bundled skills directory (no symlinks needed).
 *
 * The default export serves both plugin APIs: V2 calls `setup(ctx)`,
 * V1 (1.18.29+) calls `server()`.
 */

import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const superpowersSkillsDir = path.resolve(__dirname, '../../skills');
const BOOTSTRAP_MARKER = 'EXTREMELY_IMPORTANT';

// Simple frontmatter extraction (avoid dependency on skills-core for bootstrap)
const extractAndStripFrontmatter = (content) => {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { frontmatter: {}, content };

  const frontmatterStr = match[1];
  const body = match[2];
  const frontmatter = {};

  for (const line of frontmatterStr.split('\n')) {
    const colonIdx = line.indexOf(':');
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const value = line.slice(colonIdx + 1).trim().replace(/^["']|["']$/g, '');
      frontmatter[key] = value;
    }
  }

  return { frontmatter, content: body };
};

const getBootstrapContent = () => {
  const skillPath = path.join(superpowersSkillsDir, 'using-superpowers', 'SKILL.md');
  if (!fs.existsSync(skillPath)) return null;

  const { content } = extractAndStripFrontmatter(fs.readFileSync(skillPath, 'utf8'));

  const toolMapping = `**Tool Mapping for OpenCode:**
When skills reference tools you don't have, substitute OpenCode equivalents:
- \`TodoWrite\` → \`todowrite\`
- \`Task\` tool with subagents → Use OpenCode's subagent system (@mention)
- \`Skill\` tool → OpenCode's native \`skill\` tool
- \`Read\`, \`Write\`, \`Edit\`, \`Bash\` → Your native tools

Use OpenCode's native \`skill\` tool to list and load skills.`;

  return `<${BOOTSTRAP_MARKER}>
You have superpowers.

**IMPORTANT: The using-superpowers skill content is included below. It is ALREADY LOADED - you are currently following it. Do NOT use the skill tool to load "using-superpowers" again - that would be redundant.**

${content}

${toolMapping}
</${BOOTSTRAP_MARKER}>`;
};

const loadSkills = () => {
  if (!fs.existsSync(superpowersSkillsDir)) return [];
  const skills = [];
  for (const entry of fs.readdirSync(superpowersSkillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const skillPath = path.join(superpowersSkillsDir, entry.name, 'SKILL.md');
    if (!fs.existsSync(skillPath)) continue;
    const { frontmatter, content } = extractAndStripFrontmatter(fs.readFileSync(skillPath, 'utf8'));
    const id = frontmatter.name || entry.name;
    skills.push({ id, name: id, description: frontmatter.description, path: skillPath, content });
  }
  return skills;
};

export default {
  id: 'superpowers',

  async setup(ctx) {
    // Transform callbacks must be synchronous and replayable, so skills are read once up front.
    const skills = loadSkills();
    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        if (!editor.get(skill.id)) editor.add(skill);
      }
    });

    // Context-hook edits apply to the outgoing request only, so the bootstrap is
    // re-injected on every agent-loop call; keeping it in the first user message
    // (not the system prompt) keeps the prefix cacheable and avoids multiple
    // system messages, which break some models.
    await ctx.session.hook('context', (event) => {
      const bootstrap = getBootstrapContent();
      if (!bootstrap) return;
      const idx = event.messages.findIndex((m) => m.role === 'user');
      if (idx === -1) return;
      const first = event.messages[idx];
      if (first.content.some((p) => p.type === 'text' && p.text.includes(BOOTSTRAP_MARKER))) return;
      const content = [{ type: 'text', text: bootstrap }, ...first.content];
      event.messages[idx] = new first.constructor({ ...first, content });
    });
  },

  async server() {
    return {
      config: async (config) => {
        config.skills = config.skills || {};
        config.skills.paths = config.skills.paths || [];
        if (!config.skills.paths.includes(superpowersSkillsDir)) {
          config.skills.paths.push(superpowersSkillsDir);
        }
      },

      'experimental.chat.messages.transform': async (_input, output) => {
        const bootstrap = getBootstrapContent();
        if (!bootstrap || !output.messages.length) return;
        const firstUser = output.messages.find((m) => m.info.role === 'user');
        if (!firstUser || !firstUser.parts.length) return;
        if (firstUser.parts.some((p) => p.type === 'text' && p.text.includes(BOOTSTRAP_MARKER))) return;
        const ref = firstUser.parts[0];
        firstUser.parts.unshift({ ...ref, type: 'text', text: bootstrap });
      },
    };
  },
};
