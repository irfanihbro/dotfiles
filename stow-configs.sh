#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package="Configs"
target="${HOME}/.config"
backup_conflicts=false
backup_dir="${HOME}/.config-stow-backup-$(date +%Y%m%d-%H%M%S)"
adopt=false
dry_run=false

usage() {
  cat <<'EOF'
Usage: ./stow-configs.sh [options]

Options:
  --backup-conflicts    Move conflicting targets to a backup dir, then stow
  --backup-dir DIR      Backup directory to use with --backup-conflicts
  --adopt               Run stow with --adopt (destructive; use with care)
  --dry-run             Show what would happen without changing anything
  -h, --help            Show this help
EOF
}

run_stow_check() {
  local out status
  set +e
  out="$(cd "$repo_root" && stow -n "${stow_args[@]}" "$package" 2>&1)"
  status=$?
  set -e
  printf '%s\n' "$out"
  STOW_CHECK_OUTPUT="$out"
  return "$status"
}

extract_conflicts() {
  local line path
  while IFS= read -r line; do
    if [[ $line =~ over[[:space:]]existing[[:space:]]target[[:space:]](.+)[[:space:]]since[[:space:]]neither[[:space:]]a[[:space:]]link[[:space:]]nor[[:space:]]a[[:space:]]directory ]]; then
      path="${BASH_REMATCH[1]}"
      path="${path%\'}"
      printf '%s\n' "$path"
    fi
  done <<< "$1"
}

backup_path_for() {
  local path="$1"
  local rel="${path#"$target"/}"
  if [[ "$path" != "$target"* ]]; then
    rel="${path#/}"
  fi
  printf '%s/%s\n' "$backup_dir" "$rel"
}

target_path_for() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$target" "$path"
  fi
}

move_conflicts() {
  local conflict target_path dest
  mkdir -p "$backup_dir"
  while IFS= read -r conflict; do
    [[ -n "$conflict" ]] || continue
    target_path="$(target_path_for "$conflict")"
    if [[ -L "$target_path" ]]; then
      echo "[!] Skipping symlink conflict: $target_path"
      continue
    fi
    if [[ ! -e "$target_path" ]]; then
      echo "[=] Conflict no longer exists: $target_path"
      continue
    fi
    dest="$(backup_path_for "$target_path")"
    mkdir -p "$(dirname "$dest")"
    echo "[+] Backing up $target_path -> $dest"
    mv "$target_path" "$dest"
  done
}

while (($#)); do
  case "$1" in
    --backup-conflicts) backup_conflicts=true ;;
    --backup-dir)
      shift
      [[ $# -gt 0 ]] || { echo "Missing value for --backup-dir" >&2; exit 2; }
      backup_dir="$1"
      backup_conflicts=true
      ;;
    --adopt) adopt=true ;;
    --dry-run) dry_run=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

stow_args=(-v -t "$target")
if $adopt; then
  echo "[!] --adopt can overwrite existing files; proceeding non-interactively."
  stow_args+=(--adopt)
fi

mkdir -p "$target"

echo "[+] Checking stow status..."
if run_stow_check; then
  if $dry_run; then
    exit 0
  fi
  echo "[+] Applying stow configs..."
  cd "$repo_root"
  stow "${stow_args[@]}" "$package"
  exit 0
fi

conflicts="$(extract_conflicts "$STOW_CHECK_OUTPUT" || true)"
if [[ -z "$conflicts" ]]; then
  echo "[!] stow check failed for a non-conflict reason; fix the issue and retry." >&2
  exit 1
fi

echo "[!] Conflicts detected:" >&2
printf '%s\n' "$conflicts" >&2

if $dry_run; then
  exit 0
fi

if $backup_conflicts; then
  echo "[+] Backing up conflicting targets to: $backup_dir"
  move_conflicts <<< "$conflicts"
  echo "[+] Applying stow configs..."
  cd "$repo_root"
  stow "${stow_args[@]}" "$package"
  exit 0
fi

echo "[!] Resolve conflicts manually, or rerun with --backup-conflicts / --adopt." >&2
exit 1
