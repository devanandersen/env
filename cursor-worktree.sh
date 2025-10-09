#!/bin/bash
# Open Cursor with colors based on worktree path

set -e

readonly CMD="${CMD:-cursor}"
readonly WORKSPACE_DIR="${WORKSPACES:-$HOME/.${CMD}-workspaces}"

# Colors for random assignment - bright but faded
readonly RANDOM_COLORS=(
    "#d1567a"  # Pink
    "#5ac78f"  # Green
    "#4a9fd9"  # Blue
    "#d9b84d"  # Yellow
    "#d9633d"  # Orange
    "#42b8c9"  # Cyan
    "#c94d45"  # Red
    "#7a9b6b"  # Olive
    "#8b8b7a"  # Gray-brown
)

get_color() {
    local worktree="$1"
    local worktree_path="/Users/devanandersen/world/trees/$worktree"

    # Use predefined colors for specific worktree types
    case "$worktree" in
        secondary)  echo "#3d1a3d" ;;
        reference)     echo "#1a3d1a" ;;
        review)  echo "#1a2847" ;;
        hotfix)     echo "#3d1a1a" ;;
        *)
            # Generate random color and save it for this worktree
            local color_file="$worktree_path/.worktree-color"
            if [[ ! -f "$color_file" && -d "$worktree_path" ]]; then
                echo "${RANDOM_COLORS[$((RANDOM % ${#RANDOM_COLORS[@]}))]}" > "$color_file" 2>/dev/null || true
            fi
            if [[ -f "$color_file" ]]; then
                cat "$color_file"
            else
                # Fallback if file creation failed
                echo "${RANDOM_COLORS[$((RANDOM % ${#RANDOM_COLORS[@]}))]}"
            fi
            ;;
    esac
}

extract_worktree() {
    # Extract worktree name from path like .../trees/{worktree}/...
    local path="$1"
    [[ "$path" =~ /trees/([^/]+) ]] && echo "${BASH_REMATCH[1]}"
    return 0
}

extract_area() {
    # Extract area/library name from paths
    local path="$1"
    if [[ "$path" =~ /src/(areas|libraries)/[^/]+/([^/]+) ]]; then
        echo "${BASH_REMATCH[2]}"
    fi
    return 0
}

open_editor() {
    if command -v "$CMD" &>/dev/null; then
        "$CMD" "$@"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open -a "Cursor" "$@"
    else
        echo "Error: ${CMD} command not found" >&2
        exit 1
    fi
}

create_workspace() {
    local dir="$1" color="$2" file="$3"
    local name="${dir##*/}"

    cat > "$file" << EOF
{
  "folders": [{"path": "$dir", "name": "$name"}],
  "settings": {
    "workbench.colorCustomizations": {
      "activityBar.activeBackground": "$color",
      "activityBar.background": "$color",
      "activityBar.foreground": "#ffffff",
      "activityBar.inactiveForeground": "#ffffff99",
      "activityBarBadge.background": "#ffffff",
      "activityBarBadge.foreground": "#000000",
      "statusBar.background": "$color",
      "statusBar.foreground": "#ffffff",
      "statusBarItem.hoverBackground": "#ffffff22",
      "titleBar.activeBackground": "$color",
      "titleBar.activeForeground": "#ffffff",
      "titleBar.inactiveBackground": "$color",
      "titleBar.inactiveForeground": "#ffffff99"
    }
  }
}
EOF
}

# Main logic
if [[ $# -eq 0 ]]; then
    target_dir="$(pwd)"
else
    target_dir="$1"
    shift  # Shift off the directory argument, keep remaining args
fi
target_dir=$(cd "$target_dir" 2>/dev/null && pwd) || {
    echo "Error: Invalid directory" >&2
    exit 1
}

worktree=$(extract_worktree "$target_dir")

# Open directly if no worktree or root worktree
if [[ -z "$worktree" || "$worktree" == "root" ]]; then
    open_editor "$target_dir" "$@"
    exit 0
fi

# Generate workspace file with color
mkdir -p "$WORKSPACE_DIR"

area=$(extract_area "$target_dir")
workspace_name="${area:-${target_dir##*/}}_${worktree}"
workspace_file="$WORKSPACE_DIR/${workspace_name}.code-workspace"

# Regenerate workspace if script is newer
if [[ ! -f "$workspace_file" || "$0" -nt "$workspace_file" ]]; then
    create_workspace "$target_dir" "$(get_color "$worktree")" "$workspace_file"
fi

open_editor "$workspace_file" "$@"
