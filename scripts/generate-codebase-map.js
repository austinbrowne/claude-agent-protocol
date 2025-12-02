#!/usr/bin/env node

/**
 * Codebase Map Generator
 *
 * Analyzes a project directory and generates a comprehensive CODEBASE_MAP.md
 * file that documents the architecture, key files, patterns, and dependencies.
 *
 * Usage:
 *   node generate-codebase-map.js [project-path] [output-path]
 *
 * Examples:
 *   node generate-codebase-map.js                    # Current dir, outputs to .claude/CODEBASE_MAP.md
 *   node generate-codebase-map.js /path/to/project   # Specific project
 *   node generate-codebase-map.js . ./docs/MAP.md    # Custom output path
 */

const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
  // Directories to always ignore
  ignoreDirs: new Set([
    'node_modules', '.git', '.svn', '.hg', '__pycache__', '.pytest_cache',
    '.mypy_cache', '.tox', '.nox', 'venv', '.venv', 'env', '.env',
    'dist', 'build', 'out', '.next', '.nuxt', '.output', 'coverage',
    '.nyc_output', '.cache', '.parcel-cache', '.turbo', 'target',
    'vendor', 'Pods', '.gradle', '.idea', '.vscode', '.DS_Store'
  ]),

  // File extensions to analyze
  codeExtensions: new Set([
    '.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs',
    '.py', '.pyi',
    '.go',
    '.rs',
    '.java', '.kt', '.scala',
    '.rb',
    '.php',
    '.c', '.cpp', '.cc', '.h', '.hpp',
    '.cs',
    '.swift',
    '.vue', '.svelte',
    '.sql',
    '.sh', '.bash', '.zsh'
  ]),

  // Config files to detect
  configFiles: new Set([
    'package.json', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml',
    'tsconfig.json', 'jsconfig.json',
    'requirements.txt', 'Pipfile', 'pyproject.toml', 'setup.py', 'setup.cfg',
    'Cargo.toml', 'Cargo.lock',
    'go.mod', 'go.sum',
    'Gemfile', 'Gemfile.lock',
    'composer.json', 'composer.lock',
    'pom.xml', 'build.gradle', 'build.gradle.kts',
    'Makefile', 'CMakeLists.txt',
    'Dockerfile', 'docker-compose.yml', 'docker-compose.yaml',
    '.env.example', '.env.sample',
    'webpack.config.js', 'vite.config.js', 'vite.config.ts',
    'rollup.config.js', 'esbuild.config.js',
    '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'eslint.config.js',
    '.prettierrc', '.prettierrc.js', '.prettierrc.json',
    'jest.config.js', 'jest.config.ts', 'vitest.config.ts',
    '.github/workflows', 'Jenkinsfile', '.gitlab-ci.yml',
    'CLAUDE.md', '.claude'
  ]),

  // Max depth for directory tree
  maxDepth: 4,

  // Max files to list per directory
  maxFilesPerDir: 10,

  // Max total files to process (memory protection)
  maxTotalFiles: 50000,

  // Important file patterns (regex)
  importantPatterns: [
    /^index\.(js|ts|jsx|tsx)$/,
    /^main\.(js|ts|py|go|rs)$/,
    /^app\.(js|ts|jsx|tsx|py)$/,
    /^server\.(js|ts)$/,
    /^routes?\.(js|ts)$/,
    /^api\.(js|ts)$/,
    /schema\.(prisma|graphql|sql)$/,
    /^config\.(js|ts|py|json)$/,
    /^settings\.(py|json)$/,
    /middleware/i,
    /auth/i,
    /database|db/i
  ]
};

/**
 * Detect the tech stack from config files and extensions
 */
function detectTechStack(projectPath) {
  const stack = {
    languages: new Set(),
    frameworks: [],
    testing: [],
    build: [],
    database: [],
    deployment: [],
    other: []
  };

  const files = getAllFiles(projectPath, 1);
  const fileNames = files.map(f => path.basename(f));
  const extensions = new Set(files.map(f => path.extname(f)));

  // Detect languages
  if (extensions.has('.ts') || extensions.has('.tsx')) stack.languages.add('TypeScript');
  if (extensions.has('.js') || extensions.has('.jsx')) stack.languages.add('JavaScript');
  if (extensions.has('.py')) stack.languages.add('Python');
  if (extensions.has('.go')) stack.languages.add('Go');
  if (extensions.has('.rs')) stack.languages.add('Rust');
  if (extensions.has('.java')) stack.languages.add('Java');
  if (extensions.has('.rb')) stack.languages.add('Ruby');
  if (extensions.has('.php')) stack.languages.add('PHP');
  if (extensions.has('.cs')) stack.languages.add('C#');
  if (extensions.has('.swift')) stack.languages.add('Swift');

  // Detect frameworks from package.json
  const packageJsonPath = path.join(projectPath, 'package.json');
  if (fs.existsSync(packageJsonPath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      const deps = { ...pkg.dependencies, ...pkg.devDependencies };

      // Frontend frameworks
      if (deps.react) stack.frameworks.push('React');
      if (deps.vue) stack.frameworks.push('Vue');
      if (deps.svelte) stack.frameworks.push('Svelte');
      if (deps.angular || deps['@angular/core']) stack.frameworks.push('Angular');
      if (deps.next) stack.frameworks.push('Next.js');
      if (deps.nuxt) stack.frameworks.push('Nuxt');
      if (deps.gatsby) stack.frameworks.push('Gatsby');
      if (deps.remix || deps['@remix-run/react']) stack.frameworks.push('Remix');

      // Backend frameworks
      if (deps.express) stack.frameworks.push('Express');
      if (deps.fastify) stack.frameworks.push('Fastify');
      if (deps.koa) stack.frameworks.push('Koa');
      if (deps.hapi || deps['@hapi/hapi']) stack.frameworks.push('Hapi');
      if (deps.nestjs || deps['@nestjs/core']) stack.frameworks.push('NestJS');

      // Testing
      if (deps.jest) stack.testing.push('Jest');
      if (deps.vitest) stack.testing.push('Vitest');
      if (deps.mocha) stack.testing.push('Mocha');
      if (deps.playwright || deps['@playwright/test']) stack.testing.push('Playwright');
      if (deps.cypress) stack.testing.push('Cypress');
      if (deps['testing-library'] || deps['@testing-library/react']) stack.testing.push('Testing Library');

      // Build tools
      if (deps.webpack) stack.build.push('Webpack');
      if (deps.vite) stack.build.push('Vite');
      if (deps.esbuild) stack.build.push('esbuild');
      if (deps.rollup) stack.build.push('Rollup');
      if (deps.turbo) stack.build.push('Turborepo');

      // Database
      if (deps.prisma || deps['@prisma/client']) stack.database.push('Prisma');
      if (deps.mongoose) stack.database.push('MongoDB/Mongoose');
      if (deps.pg) stack.database.push('PostgreSQL');
      if (deps.mysql2 || deps.mysql) stack.database.push('MySQL');
      if (deps.redis || deps.ioredis) stack.database.push('Redis');
      if (deps.sequelize) stack.database.push('Sequelize');
      if (deps.typeorm) stack.database.push('TypeORM');
      if (deps.drizzle || deps['drizzle-orm']) stack.database.push('Drizzle');

      // Other
      if (deps.tailwindcss) stack.other.push('Tailwind CSS');
      if (deps['styled-components']) stack.other.push('Styled Components');
      if (deps.graphql) stack.other.push('GraphQL');
      if (deps.trpc || deps['@trpc/server']) stack.other.push('tRPC');
      if (deps.zod) stack.other.push('Zod');

    } catch (e) {
      // Ignore JSON parse errors
    }
  }

  // Python detection
  const requirementsPath = path.join(projectPath, 'requirements.txt');
  const pyprojectPath = path.join(projectPath, 'pyproject.toml');

  if (fs.existsSync(requirementsPath) || fs.existsSync(pyprojectPath)) {
    let content = '';
    if (fs.existsSync(requirementsPath)) {
      content = fs.readFileSync(requirementsPath, 'utf8');
    }
    if (fs.existsSync(pyprojectPath)) {
      content += fs.readFileSync(pyprojectPath, 'utf8');
    }

    if (/django/i.test(content)) stack.frameworks.push('Django');
    if (/flask/i.test(content)) stack.frameworks.push('Flask');
    if (/fastapi/i.test(content)) stack.frameworks.push('FastAPI');
    if (/pytest/i.test(content)) stack.testing.push('pytest');
    if (/sqlalchemy/i.test(content)) stack.database.push('SQLAlchemy');
  }

  // Deployment detection
  if (fs.existsSync(path.join(projectPath, 'Dockerfile'))) stack.deployment.push('Docker');
  if (fs.existsSync(path.join(projectPath, 'docker-compose.yml')) ||
      fs.existsSync(path.join(projectPath, 'docker-compose.yaml'))) {
    stack.deployment.push('Docker Compose');
  }
  if (fs.existsSync(path.join(projectPath, 'vercel.json')) ||
      fs.existsSync(path.join(projectPath, '.vercel'))) {
    stack.deployment.push('Vercel');
  }
  if (fs.existsSync(path.join(projectPath, 'netlify.toml'))) stack.deployment.push('Netlify');
  if (fs.existsSync(path.join(projectPath, '.github', 'workflows'))) stack.deployment.push('GitHub Actions');
  if (fs.existsSync(path.join(projectPath, 'serverless.yml'))) stack.deployment.push('Serverless');
  if (fs.existsSync(path.join(projectPath, 'fly.toml'))) stack.deployment.push('Fly.io');

  return stack;
}

/**
 * Get all files recursively up to maxDepth
 * Uses a shared counter to limit total files (memory protection)
 */
function getAllFiles(dirPath, maxDepth = CONFIG.maxDepth, currentDepth = 0, fileCount = null) {
  // Initialize counter on first call
  if (fileCount === null) {
    fileCount = { count: 0, warned: false };
  }

  if (currentDepth > maxDepth) return [];
  if (fileCount.count >= CONFIG.maxTotalFiles) {
    if (!fileCount.warned) {
      console.warn(`Warning: File limit (${CONFIG.maxTotalFiles}) reached. Results may be incomplete.`);
      fileCount.warned = true;
    }
    return [];
  }

  let files = [];

  try {
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });

    for (const entry of entries) {
      if (fileCount.count >= CONFIG.maxTotalFiles) break;

      const fullPath = path.join(dirPath, entry.name);

      if (entry.isDirectory()) {
        if (!CONFIG.ignoreDirs.has(entry.name) && !entry.name.startsWith('.')) {
          files = files.concat(getAllFiles(fullPath, maxDepth, currentDepth + 1, fileCount));
        }
      } else {
        files.push(fullPath);
        fileCount.count++;
      }
    }
  } catch (e) {
    // Ignore permission errors
  }

  return files;
}

/**
 * Build directory tree structure
 */
function buildDirectoryTree(projectPath, maxDepth = CONFIG.maxDepth) {
  function buildTree(dirPath, depth = 0, prefix = '') {
    if (depth > maxDepth) return '';

    let result = '';

    try {
      const entries = fs.readdirSync(dirPath, { withFileTypes: true })
        .filter(e => !CONFIG.ignoreDirs.has(e.name) && !e.name.startsWith('.'))
        .sort((a, b) => {
          // Directories first, then files
          if (a.isDirectory() && !b.isDirectory()) return -1;
          if (!a.isDirectory() && b.isDirectory()) return 1;
          return a.name.localeCompare(b.name);
        });

      const dirs = entries.filter(e => e.isDirectory());
      const files = entries.filter(e => !e.isDirectory());

      // Add directories
      for (let i = 0; i < dirs.length; i++) {
        const entry = dirs[i];
        const isLast = i === dirs.length - 1 && files.length === 0;
        const connector = isLast ? '└── ' : '├── ';
        const childPrefix = isLast ? '    ' : '│   ';

        result += `${prefix}${connector}${entry.name}/\n`;
        result += buildTree(
          path.join(dirPath, entry.name),
          depth + 1,
          prefix + childPrefix
        );
      }

      // Add files (limited)
      const filesToShow = files.slice(0, CONFIG.maxFilesPerDir);
      for (let i = 0; i < filesToShow.length; i++) {
        const entry = filesToShow[i];
        const isLast = i === filesToShow.length - 1;
        const connector = isLast ? '└── ' : '├── ';
        result += `${prefix}${connector}${entry.name}\n`;
      }

      if (files.length > CONFIG.maxFilesPerDir) {
        result += `${prefix}└── ... (${files.length - CONFIG.maxFilesPerDir} more files)\n`;
      }

    } catch (e) {
      // Ignore permission errors
    }

    return result;
  }

  const projectName = path.basename(projectPath);
  return `${projectName}/\n${buildTree(projectPath)}`;
}

/**
 * Identify key files in the project
 */
function identifyKeyFiles(projectPath) {
  const allFiles = getAllFiles(projectPath);
  const keyFiles = [];

  for (const filePath of allFiles) {
    const fileName = path.basename(filePath);
    const relativePath = path.relative(projectPath, filePath);

    // Check against important patterns
    for (const pattern of CONFIG.importantPatterns) {
      if (pattern.test(fileName) || pattern.test(relativePath)) {
        keyFiles.push({
          path: relativePath,
          reason: getFileReason(fileName, relativePath)
        });
        break;
      }
    }

    // Check config files
    if (CONFIG.configFiles.has(fileName)) {
      keyFiles.push({
        path: relativePath,
        reason: 'Configuration file'
      });
    }
  }

  // Deduplicate and limit
  const seen = new Set();
  return keyFiles.filter(f => {
    if (seen.has(f.path)) return false;
    seen.add(f.path);
    return true;
  }).slice(0, 25);
}

/**
 * Get reason why file is important
 */
function getFileReason(fileName, relativePath) {
  if (/^index\./i.test(fileName)) return 'Entry point';
  if (/^main\./i.test(fileName)) return 'Main entry';
  if (/^app\./i.test(fileName)) return 'Application entry';
  if (/^server\./i.test(fileName)) return 'Server entry';
  if (/routes?/i.test(fileName)) return 'Routing configuration';
  if (/api/i.test(fileName)) return 'API definitions';
  if (/schema/i.test(fileName)) return 'Data schema';
  if (/config/i.test(fileName)) return 'Configuration';
  if (/settings/i.test(fileName)) return 'Settings';
  if (/middleware/i.test(fileName)) return 'Middleware';
  if (/auth/i.test(relativePath)) return 'Authentication';
  if (/database|db/i.test(relativePath)) return 'Database';
  return 'Key file';
}

/**
 * Analyze code patterns in the project
 */
function analyzePatterns(projectPath) {
  const patterns = {
    architecture: [],
    conventions: [],
    testing: []
  };

  const allFiles = getAllFiles(projectPath);
  const dirs = new Set(allFiles.map(f => path.dirname(path.relative(projectPath, f)).split(path.sep)[0]));

  // Detect architecture patterns
  if (dirs.has('src') && dirs.has('tests')) {
    patterns.architecture.push('src/tests separation');
  }
  if (dirs.has('components') || allFiles.some(f => f.includes('/components/'))) {
    patterns.architecture.push('Component-based structure');
  }
  if (dirs.has('services') || allFiles.some(f => f.includes('/services/'))) {
    patterns.architecture.push('Service layer pattern');
  }
  if (dirs.has('controllers') || allFiles.some(f => f.includes('/controllers/'))) {
    patterns.architecture.push('MVC/Controller pattern');
  }
  if (dirs.has('hooks') || allFiles.some(f => f.includes('/hooks/'))) {
    patterns.architecture.push('Custom hooks pattern');
  }
  if (dirs.has('utils') || dirs.has('lib') || dirs.has('helpers')) {
    patterns.architecture.push('Utility modules');
  }
  if (dirs.has('types') || allFiles.some(f => f.endsWith('.d.ts'))) {
    patterns.architecture.push('TypeScript type definitions');
  }
  if (dirs.has('api') || allFiles.some(f => f.includes('/api/'))) {
    patterns.architecture.push('API layer');
  }
  if (allFiles.some(f => f.includes('/pages/') || f.includes('/app/'))) {
    patterns.architecture.push('File-based routing');
  }

  // Detect conventions
  const tsFiles = allFiles.filter(f => f.endsWith('.ts') || f.endsWith('.tsx'));
  const jsFiles = allFiles.filter(f => f.endsWith('.js') || f.endsWith('.jsx'));

  if (tsFiles.length > jsFiles.length * 2) {
    patterns.conventions.push('TypeScript-first');
  }

  if (allFiles.some(f => f.endsWith('.test.ts') || f.endsWith('.test.js'))) {
    patterns.conventions.push('*.test.* naming for tests');
  }
  if (allFiles.some(f => f.endsWith('.spec.ts') || f.endsWith('.spec.js'))) {
    patterns.conventions.push('*.spec.* naming for tests');
  }

  // Check for barrel exports
  const indexFiles = allFiles.filter(f => /index\.(ts|js)$/.test(f));
  if (indexFiles.length > 3) {
    patterns.conventions.push('Barrel exports (index files)');
  }

  // Testing patterns
  if (dirs.has('__tests__')) {
    patterns.testing.push('__tests__ directory');
  }
  if (dirs.has('tests') || dirs.has('test')) {
    patterns.testing.push('Separate test directory');
  }
  if (allFiles.some(f => f.includes('.test.') && f.includes('/src/'))) {
    patterns.testing.push('Co-located tests');
  }
  if (allFiles.some(f => f.includes('e2e') || f.includes('integration'))) {
    patterns.testing.push('E2E/Integration tests');
  }

  return patterns;
}

/**
 * Generate "Where to Find" quick reference
 */
function generateQuickReference(projectPath, techStack) {
  const references = [];
  const allFiles = getAllFiles(projectPath);

  // Common locations
  const locationPatterns = [
    { pattern: /components?/i, label: 'UI Components' },
    { pattern: /pages?|routes?/i, label: 'Pages/Routes' },
    { pattern: /api|endpoints?/i, label: 'API Endpoints' },
    { pattern: /services?/i, label: 'Business Logic' },
    { pattern: /hooks?/i, label: 'React Hooks' },
    { pattern: /utils?|helpers?|lib/i, label: 'Utilities' },
    { pattern: /types?/i, label: 'Type Definitions' },
    { pattern: /models?|entities?/i, label: 'Data Models' },
    { pattern: /auth/i, label: 'Authentication' },
    { pattern: /middleware/i, label: 'Middleware' },
    { pattern: /config/i, label: 'Configuration' },
    { pattern: /tests?|__tests__/i, label: 'Tests' },
    { pattern: /styles?|css/i, label: 'Styles' },
    { pattern: /assets?|public|static/i, label: 'Static Assets' },
    { pattern: /docs?/i, label: 'Documentation' }
  ];

  for (const { pattern, label } of locationPatterns) {
    const matches = allFiles.filter(f => pattern.test(f));
    if (matches.length > 0) {
      // Get the most common directory
      const dirs = matches.map(f => {
        const rel = path.relative(projectPath, f);
        const parts = rel.split(path.sep);
        for (let i = 0; i < parts.length; i++) {
          if (pattern.test(parts[i])) {
            return parts.slice(0, i + 1).join('/');
          }
        }
        return parts[0];
      });

      const dirCounts = {};
      for (const dir of dirs) {
        dirCounts[dir] = (dirCounts[dir] || 0) + 1;
      }

      const topDir = Object.entries(dirCounts)
        .sort((a, b) => b[1] - a[1])[0];

      if (topDir) {
        references.push({ label, location: topDir[0] });
      }
    }
  }

  return references;
}

/**
 * Generate the CODEBASE_MAP.md content
 */
function generateCodebaseMap(projectPath) {
  const projectName = path.basename(projectPath);
  const techStack = detectTechStack(projectPath);
  const directoryTree = buildDirectoryTree(projectPath);
  const keyFiles = identifyKeyFiles(projectPath);
  const patterns = analyzePatterns(projectPath);
  const quickRef = generateQuickReference(projectPath, techStack);

  let content = `# Codebase Map: ${projectName}

> Auto-generated by \`generate-codebase-map.js\`
> Last updated: ${new Date().toISOString().split('T')[0]}

---

## Tech Stack

`;

  // Languages
  if (techStack.languages.size > 0) {
    content += `**Languages:** ${Array.from(techStack.languages).join(', ')}\n`;
  }

  // Frameworks
  if (techStack.frameworks.length > 0) {
    content += `**Frameworks:** ${techStack.frameworks.join(', ')}\n`;
  }

  // Testing
  if (techStack.testing.length > 0) {
    content += `**Testing:** ${techStack.testing.join(', ')}\n`;
  }

  // Build
  if (techStack.build.length > 0) {
    content += `**Build Tools:** ${techStack.build.join(', ')}\n`;
  }

  // Database
  if (techStack.database.length > 0) {
    content += `**Database:** ${techStack.database.join(', ')}\n`;
  }

  // Deployment
  if (techStack.deployment.length > 0) {
    content += `**Deployment:** ${techStack.deployment.join(', ')}\n`;
  }

  // Other
  if (techStack.other.length > 0) {
    content += `**Other:** ${techStack.other.join(', ')}\n`;
  }

  content += `
---

## Directory Structure

\`\`\`
${directoryTree}\`\`\`

---

## Key Files

| File | Purpose |
|------|---------|
`;

  for (const file of keyFiles) {
    content += `| \`${file.path}\` | ${file.reason} |\n`;
  }

  content += `
---

## Architecture Patterns

`;

  if (patterns.architecture.length > 0) {
    content += `**Structure:**\n`;
    for (const p of patterns.architecture) {
      content += `- ${p}\n`;
    }
    content += '\n';
  }

  if (patterns.conventions.length > 0) {
    content += `**Conventions:**\n`;
    for (const p of patterns.conventions) {
      content += `- ${p}\n`;
    }
    content += '\n';
  }

  if (patterns.testing.length > 0) {
    content += `**Testing:**\n`;
    for (const p of patterns.testing) {
      content += `- ${p}\n`;
    }
    content += '\n';
  }

  content += `---

## Where to Find Things

| What | Location |
|------|----------|
`;

  for (const ref of quickRef) {
    content += `| ${ref.label} | \`${ref.location}/\` |\n`;
  }

  content += `
---

## Common Tasks

### Adding a New Feature

1. Identify the appropriate directory from the structure above
2. Follow existing patterns in similar files
3. Add tests in the corresponding test location
4. Update any relevant documentation

### Finding Code

- **By keyword:** Use \`grep -r "keyword" src/\`
- **By file type:** Use \`find . -name "*.ts" -type f\`
- **By pattern:** Check the "Where to Find Things" table above

---

## Notes

- This map was auto-generated and may need manual refinement
- Update this file when making significant architectural changes
- For detailed patterns, explore the key files listed above

---

*Generated with [generate-codebase-map.js](./scripts/generate-codebase-map.js)*
`;

  return content;
}

/**
 * Main execution
 */
function main() {
  const args = process.argv.slice(2);

  // Determine project path
  let projectPath = process.cwd();
  if (args[0] && !args[0].startsWith('-')) {
    projectPath = path.resolve(args[0]);
  }

  // Determine output path
  let outputPath = path.join(projectPath, '.claude', 'CODEBASE_MAP.md');
  if (args[1]) {
    outputPath = path.resolve(args[1]);
  }

  // Validate project path
  if (!fs.existsSync(projectPath)) {
    console.error(`Error: Project path does not exist: ${projectPath}`);
    process.exit(1);
  }

  if (!fs.statSync(projectPath).isDirectory()) {
    console.error(`Error: Project path is not a directory: ${projectPath}`);
    process.exit(1);
  }

  console.log(`Analyzing project: ${projectPath}`);
  console.log(`Output file: ${outputPath}`);

  // Generate the map
  const content = generateCodebaseMap(projectPath);

  // Ensure output directory exists
  const outputDir = path.dirname(outputPath);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Write the file
  try {
    fs.writeFileSync(outputPath, content);
  } catch (e) {
    console.error(`Error: Failed to write output file: ${e.message}`);
    process.exit(1);
  }

  console.log(`\nCodebase map generated successfully!`);
  console.log(`\nTo use this map:`);
  console.log(`  1. Review and refine the generated content`);
  console.log(`  2. Reference it in prompts: "See .claude/CODEBASE_MAP.md for architecture"`);
  console.log(`  3. Update when architecture changes`);
}

main();
