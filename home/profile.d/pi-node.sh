# Pi Coding Agent - Node.js runtime PATH
if [ -d "$HOME/.local/share/pi-node" ]; then
  for _pi_node_dir in "$HOME/.local/share/pi-node"/node-*/bin; do
    if [ -d "$_pi_node_dir" ]; then
      export PATH="$_pi_node_dir:$PATH"
      break
    fi
  done
  unset -v _pi_node_dir
fi
