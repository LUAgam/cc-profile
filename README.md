# cc-profile

Profile-based environment switching for Claude Code and other LLM CLIs.

`cc-profile` keeps API URLs, keys, model names, and related environment
variables in named profile files. It can then inject a selected profile into any
command, without tying the workflow to one Claude Code installation method.

## Commands

- `ccprofile`: manage profiles
- `ccrun`: load a profile and run a command
- `ccenv`: print profile exports for `eval`
- `claude-docker`: optional Docker adapter for Claude Code

## Install

```bash
git clone https://github.com/LUAgam/cc-profile.git
cd cc-profile
sudo ./install.sh
```

Install somewhere else:

```bash
PREFIX="$HOME/.local" ./install.sh
```

Make sure `PREFIX/bin` is on `PATH`.

## Profiles

Profiles are `.env` files stored in:

```text
~/.config/cc-profiles/profiles/
```

Example:

```bash
mkdir -p ~/.config/cc-profiles/profiles
chmod 700 ~/.config/cc-profiles ~/.config/cc-profiles/profiles

cat > ~/.config/cc-profiles/profiles/runapi.env <<'EOF'
ANTHROPIC_BASE_URL=https://example.com
ANTHROPIC_API_KEY=sk-your-key
ANTHROPIC_MODEL=claude-sonnet-4-6
EOF
chmod 600 ~/.config/cc-profiles/profiles/runapi.env
```

Set the default profile:

```bash
ccprofile use runapi
```

List profiles:

```bash
ccprofile list
```

Show a profile with secrets masked:

```bash
ccprofile show runapi
```

## Run Commands

Run Claude Code with a named profile:

```bash
ccrun runapi claude
ccrun runapi claude -p 'hello'
```

Use the default profile:

```bash
ccrun claude
```

Run any command with a profile:

```bash
ccrun runapi node script.js
ccrun runapi python app.py
```

Run without a profile:

```bash
ccrun --no-profile env
```

Export a profile into the current shell:

```bash
eval "$(ccenv runapi)"
claude
```

Do not paste `ccenv` output into logs; it contains full secret values.

## Docker Claude Code Adapter

`claude-docker` runs Claude Code from a Docker image and injects the selected
profile as an env file. By default it expects an image named:

```text
claude-code:node20
```

Usage:

```bash
claude-docker
CC_PROFILE=runapi claude-docker -p 'hello'
```

It mounts:

- current directory as `/workspace`
- `~/.claude`
- `~/.claude.json`
- `~/.gitconfig` if present
- `~/.ssh` read-only if present

Override the image:

```bash
CLAUDE_CODE_DOCKER_IMAGE=my-claude-code:latest claude-docker
```

## Configuration

Environment variables:

- `CC_CONFIG_DIR`: profile config root, default `~/.config/cc-profiles`
- `CC_PROFILE_DIR`: profile directory, default `$CC_CONFIG_DIR/profiles`
- `CC_PROFILE`: profile override for one command
- `CLAUDE_CODE_PROFILE`: compatibility alias for `CC_PROFILE`
- `CLAUDE_CODE_CONFIG_DIR`: legacy compatibility config root
- `CLAUDE_CODE_PROFILE_DIR`: legacy compatibility profile directory

If `~/.config/cc-profiles` does not exist, the tools fall back to the legacy
Claude Code-oriented path:

```text
~/.config/claude-code
```

## Security

- Keep profile directories mode `700`.
- Keep profile files mode `600`.
- Commit only `.example.env` files.
- Never commit real API keys.
- `ccprofile show` masks common key/token/secret variables.
- `ccenv` intentionally prints full values for shell evaluation.

## Development

Run smoke tests:

```bash
./test/smoke.sh
```

The tests use a temporary config directory and do not touch your real profiles.
