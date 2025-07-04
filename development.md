# OpenVSCode Server - Local Development

## Prerequisites

- Node.js 20+
- npm

## Quick Start

### 1. Install Dependencies

```bash
npm ci
```

### 2. Initialize Server

```bash
npm run server:init
```

### 3. Set Environment Variables

```bash
export NODE_ENV=development
export VSCODE_DEV=1
```

### 4. Start Development Server

```bash
npm run watch
```

### 5. Run Server (in new terminal)

```bash
./scripts/code-server.sh --without-connection-token
```

## Access

Open your browser to the URL shown in the terminal (typically `http://localhost:3000`).

## Development Workflow

1. Make your changes to the source code
2. The `watch` process will automatically recompile
3. Refresh your browser to see the changes

## Stopping the Server

- Press `Ctrl+C` in the terminal running the server
- Press `Ctrl+C` in the terminal running the watch process

## Maintaining the Codebase

### Making Changes

Always push changes to the `main` branch first:

```bash
git checkout main
# Make your changes
git add .
git commit -m "Your commit message"
git push origin main
```

### Syncing Patches to Release Branches

After pushing changes to `main`, apply them to release branches:

```bash
./scripts/apply-patches.sh release/1.99
```

Replace `release/1.99` with your target release branch name.

**Note**: This script will automatically fetch the branch from upstream if it doesn't exist in your forked repository, then apply your custom patches to it.

### Updating Branches with Upstream Changes

To sync existing branches with upstream changes:

```bash
./sync-with-upstream.sh upstream/release/1.99 release/1.99
```

**Format**: `./sync-with-upstream.sh upstream/[upstream_branch_name] [local_branch_name]`

**Examples**:

- `./sync-with-upstream.sh upstream/main main`
- `./sync-with-upstream.sh upstream/release/1.85 release/1.85`

### Maintenance Workflow

1. **Update main branch** with upstream changes:

   ```bash
   ./sync-with-upstream.sh upstream/main main
   ```

2. **Make your changes** on main branch

3. **Apply changes to release branches**:

   ```bash
   ./scripts/apply-patches.sh release/1.99
   ```

4. **Update release branches** with new upstream releases:

   ```bash
   ./sync-with-upstream.sh upstream/release/1.99 release/1.99
   ```

# OpenVSCode Server - Local Development

## Prerequisites

- Node.js 20
- npm

## Quick Start

### 1. Install Dependencies

```bash
npm ci
```

### 2. Initialize Server

```bash
npm run server:init
```

### 3. Set Environment Variables

```bash
export NODE_ENV=development
export VSCODE_DEV=1
```

### 4. Start Development Server

```bash
npm run watch
```

### 5. Run Server (in new terminal)

```bash
./scripts/code-server.sh --without-connection-token
```

## Access

Open your browser to the URL shown in the terminal (typically `http://localhost:3000`).

## Development Workflow

1. Make your changes to the source code
2. The `watch` process will automatically recompile
3. Refresh your browser to see the changes

## Maintaining the Codebase

### Making Changes

Always push changes to the `main` branch first:

```bash
git checkout main
# Make your changes
git add .
git commit -m "Your commit message"
git push origin main
```

### Syncing Patches to Release Branches

After pushing changes to `main`, apply them to release branches:

```bash
./scripts/apply-patches.sh release/1.99
```

Replace `release/1.99` with your target release branch name.

### Updating Branches with Upstream Changes

To sync existing branches with upstream changes:

```bash
./sync-with-upstream.sh upstream/release/1.99 release/1.99
```

**Format**: `./sync-with-upstream.sh upstream/[upstream_branch_name] [local_branch_name]`

**Examples**:

- `./sync-with-upstream.sh upstream/main main`
- `./sync-with-upstream.sh upstream/release/1.85 release/1.85`

### Maintenance Workflow

1. **Update main branch** with upstream changes:

   ```bash
   ./sync-with-upstream.sh upstream/main main
   ```

2. **Make your changes** on main branch

3. **Apply changes to release branches**:

   ```bash
   ./scripts/apply-patches.sh release/1.99
   ```

4. **Update release branches** with new upstream releases:

   ```bash
   ./sync-with-upstream.sh upstream/release/1.99 release/1.99
   ```
