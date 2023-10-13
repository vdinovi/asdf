# -*- sh -*-

# shellcheck source=lib/functions/versions.bash
. "$(dirname "$(dirname "$0")")/lib/functions/versions.bash"

upgrade_command() {
  local plugin_name=$1
  local query=$2

  if [ "$plugin_name" = "--all" ]; then
    # TODO: upgrade all
    echo "NYI: upgrade all"
  fi

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local versions

  if [ -f "${plugin_path}/bin/latest-stable" ]; then
    versions=$("${plugin_path}"/bin/latest-stable "$query")
    if [ -z "${versions}" ]; then
      # this branch requires this print to mimic the error from the list-all branch
      printf "No compatible versions available (%s %s)\n" "$plugin_name" "$query" >&2
      exit 1
    fi
  else
    # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
    versions=$(list_all_command "$plugin_name" "$query" |
      grep -ivE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-milestone|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
      sed 's/^[[:space:]]\+//' |
      tail -1)
    if [ -z "${versions}" ]; then
      exit 1
    fi
  fi

  printf "%s\n" "$versions"
}

upgrade_command "$@"