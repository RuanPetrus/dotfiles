# Extract archives without scattering files or creating redundant directories.
extract() {
  if [ "$#" -eq 0 ]; then
    printf 'Usage: extract ARCHIVE...\n' >&2
    return 2
  fi

  local archive target temp entry_count single_name result=0
  for archive in "$@"; do
    if [ ! -f "$archive" ]; then
      printf 'extract: not a file: %s\n' "$archive" >&2
      result=1
      continue
    fi

    target=${archive##*/}
    case "$target" in
      *.tar.gz) target=${target%.tar.gz} ;;
      *.tar.bz2) target=${target%.tar.bz2} ;;
      *.tar.xz) target=${target%.tar.xz} ;;
      *.tar.zst) target=${target%.tar.zst} ;;
      *.tbz2) target=${target%.tbz2} ;;
      *.tgz) target=${target%.tgz} ;;
      *.tbz) target=${target%.tbz} ;;
      *.txz) target=${target%.txz} ;;
      *.tzst) target=${target%.tzst} ;;
      *.tar) target=${target%.tar} ;;
      *.zip) target=${target%.zip} ;;
      *.7z) target=${target%.7z} ;;
      *.rar) target=${target%.rar} ;;
    esac
    [ -n "$target" ] || target=extracted

    temp=
    case "$archive" in
      *.tar | *.tar.gz | *.tgz | *.tar.bz2 | *.tbz | *.tbz2 | *.tar.xz | *.txz | *.tar.zst | *.tzst)
        temp=$(mktemp -d ./.extract.XXXXXX) || return 1
        if ! tar -xf "$archive" -C "$temp"; then
          rm -rf -- "$temp"
          result=1
          continue
        fi
        ;;
      *.zip)
        temp=$(mktemp -d ./.extract.XXXXXX) || return 1
        if ! unzip -q "$archive" -d "$temp"; then
          rm -rf -- "$temp"
          result=1
          continue
        fi
        ;;
      *.7z | *.rar)
        temp=$(mktemp -d ./.extract.XXXXXX) || return 1
        if ! 7z x "-o$temp" -- "$archive"; then
          rm -rf -- "$temp"
          result=1
          continue
        fi
        ;;
      *.gz | *.Z)
        gzip --decompress --keep -- "$archive" || result=1
        ;;
      *.bz2)
        bzip2 --decompress --keep -- "$archive" || result=1
        ;;
      *.xz)
        xz --decompress --keep -- "$archive" || result=1
        ;;
      *.zst)
        zstd --decompress --keep -- "$archive" || result=1
        ;;
      *.lz4)
        lz4 --decompress --keep -- "$archive" || result=1
        ;;
      *)
        printf 'extract: unsupported archive: %s\n' "$archive" >&2
        result=1
        ;;
    esac

    [ -n "$temp" ] || continue

    entry_count=$(find "$temp" -mindepth 1 -maxdepth 1 -printf x | wc -c)
    if [ "$entry_count" -eq 1 ]; then
      single_name=$(find "$temp" -mindepth 1 -maxdepth 1 -printf '%f' -quit)
      if [ -d "$temp/$single_name" ]; then
        if [ -e "$single_name" ] || [ -L "$single_name" ]; then
          printf 'extract: destination already exists: %s\n' "$single_name" >&2
          rm -rf -- "$temp"
          result=1
          continue
        fi
        if mv -- "$temp/$single_name" "$single_name"; then
          rmdir "$temp"
        else
          rm -rf -- "$temp"
          result=1
        fi
        continue
      fi
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
      printf 'extract: destination already exists: %s\n' "$target" >&2
      rm -rf -- "$temp"
      result=1
      continue
    fi
    if ! mv -- "$temp" "$target"; then
      rm -rf -- "$temp"
      result=1
    fi
  done

  return "$result"
}
