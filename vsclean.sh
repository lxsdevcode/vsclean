
#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.vscode-server/bin"
DRY_RUN=0

case "${1:-}" in
    --dry-run)
        DRY_RUN=1
        ;;
    --help|-h)
        echo "Utilizare: $0 [--dry-run]"
        echo "  --dry-run  Simuleaza stergerea, fara sa stearga nimic"
        echo "  fara parametri: sterge versiunile inactive"
        exit 0
        ;;
    "")
        ;;
    *)
        echo "Parametru necunoscut: $1" >&2
        echo "Utilizare: $0 [--dry-run]" >&2
        exit 2
        ;;
esac

if [[ ! -d "$BASE" ]]; then
    echo "Directorul nu exista: $BASE"
    exit 1
fi

# Identifica directoarele folosite de procesele active.
ACTIVE=$(
    ps -u "$(id -u)" -o args= |
    grep -oF "$BASE/" |
    cut -d/ -f1-0 2>/dev/null || true
)

# Extrage identificatorii versiunilor din comenzile proceselor.
ACTIVE=$(
    ps -u "$(id -u)" -o args= |
    grep -oE "$BASE/[a-f0-9]{40}" |
    sort -u || true
)

for DIR in "$BASE"/*; do
    [[ -d "$DIR" ]] || continue
    VERSION="${DIR##*/}"

    if printf '%s\n' "$ACTIVE" | grep -Fqx -- "$DIR"; then
        echo "Pastrata (activa): $VERSION"
        continue
    fi

    if [[ ! "$VERSION" =~ ^[a-f0-9]{40}$ ]]; then
        echo "Ignorata (nume necunoscut): $VERSION"
        continue
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[SIMULARE] Ar sterge: $VERSION"
    else
        echo "Stergere: $VERSION"
        rm -rf -- "$DIR"
    fi
done

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Simulare terminata. Nu s-a sters nimic."
else
    echo "Curatare terminata."
fi
