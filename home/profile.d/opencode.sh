# opencode configuration
# Loaded by ~/.profile via profile.d mechanism

if [ -d "$HOME/.opencode/bin" ]; then
  # Avoid duplicate PATH entries
  case ":${PATH}:" in
    *:"$HOME/.opencode/bin":*) ;;
    *) export PATH="$HOME/.opencode/bin:$PATH" ;;
  esac
fi
