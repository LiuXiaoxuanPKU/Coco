FROM docker.io/nixos/nix

RUN mkdir -p ~/.config/nix
RUN echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
