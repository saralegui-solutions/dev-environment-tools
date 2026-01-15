
# ========================================
# Dev Environment Tools - tmux-switch
# ========================================
# Interactive tmux session management with fzf
# Repository: https://github.com/saralegui-solutions/dev-environment-tools
# ========================================

tmux-switch() {
    # If argument provided, use direct session switching
    if [ -n "$1" ]; then
        local session_name="$1"
        if [ -n "$TMUX" ]; then
            # Inside tmux - switch to session
            tmux switch-client -t "$session_name" 2>/dev/null || {
                tmux new-session -d -s "$session_name"
                tmux switch-client -t "$session_name"
            }
        else
            # Outside tmux - attach or create
            tmux new-session -A -s "$session_name"
        fi
        return
    fi

    # Interactive mode - check if fzf is available
    if ! command -v fzf &> /dev/null; then
        echo "📋 Available tmux sessions:"
        tmux list-sessions 2>/dev/null || echo "No active sessions"
        echo ""
        echo "Usage: tmux-switch <session_name>"
        echo "       tmux-switch claude-work"
        echo ""
        echo "💡 Tip: Install fzf for interactive menu (sudo apt install fzf)"
        return 1
    fi

    # Get list of existing sessions
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

    # Build options list
    local options="[CREATE NEW SESSION]"
    if [ -n "$sessions" ]; then
        options="$sessions"$'\n'"[CREATE NEW SESSION]"
    fi

    # Show interactive menu (< /dev/tty ensures fzf can read from terminal)
    local selection=$(echo "$options" | fzf \
        --prompt="🖥️  Select tmux session: " \
        --height=40% \
        --border=rounded \
        --reverse \
        --header="↑↓ navigate | Enter select | Esc cancel" < /dev/tty)

    if [ -z "$selection" ]; then
        echo "No selection made"
        return 1
    fi

    # Handle create new session
    if [ "$selection" = "[CREATE NEW SESSION]" ]; then
        read -p "Enter new session name: " session_name
        if [ -z "$session_name" ]; then
            echo "❌ Session name cannot be empty"
            return 1
        fi
    else
        session_name="$selection"
    fi

    # Switch or attach to session
    if [ -n "$TMUX" ]; then
        # Inside tmux - switch to session
        tmux switch-client -t "$session_name" 2>/dev/null || {
            echo "Creating new session '$session_name'..."
            tmux new-session -d -s "$session_name"
            tmux switch-client -t "$session_name"
        }
    else
        # Outside tmux - attach or create
        tmux new-session -A -s "$session_name"
    fi
}

# ========================================
# Aliases - Tmux and Claude
# ========================================

# Tmux session management
alias tms='tmux-switch'                   # Switch between tmux sessions
alias tmls='tmux list-sessions 2>/dev/null || echo "No active tmux sessions"'

# Claude Code integration
alias cy='claude --dangerously-skip-permissions'

# End Dev Environment Tools
