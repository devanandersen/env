let
  # Read public keys from file (one per line)
  # Create keys.txt with your public key(s)
  keys = builtins.filter (k: k != "") (
    builtins.split "\n" (builtins.readFile ./keys.txt)
  );
in
{
  "private-config.age".publicKeys = keys;
}
