has_db() {
  local db=$1

  psql \
    --host "$DB_DIR" \
    --list \
    --quiet \
    --tuples-only \
    | cut -d \| -f 1 | grep -qw "$db"
}

wait_db_socket() {
  local wait_seconds=${1:-10}

  until test $((wait_seconds--)) -eq 0 -o -S "$DB_SOCKET" ; do sleep 1; done

  ((++wait_seconds))
}

_sed() {
  # darwin's sed in not GNU sed
  if command -v gsed >/dev/null; then
    gsed "$@"
  else
    sed "$@"
  fi
}

install_gems_maybe() {
  if ! bundle check >/dev/null 2>&1; then
    bundle install --jobs="${BUNDLE_JOBS:-4}"
    bundle config set no-prune 'true'
  fi
}

db_name_for_service() {
  local name=$(basename $1)
  local suffix="development"

  if [ $name == "core" ]; then
    echo "ros-core_${suffix}"
  else
    # voucher-service expects voucher_development, not voucher-service_development
    # but we have other services with hyphens such as instant-outcome
    echo $(echo $name | sed -e 's/-service//' -e 's/-/_/g')_${suffix}
  fi
}

migrate_and_seed_db_maybe() {
  local db="$1"
  local tasks=()
  local test_tasks=()

  wait_db_socket

  if has_db "$db"; then
    if [ -e tmp/reset ]; then
      rm tmp/reset
      tasks=(db:drop
             db:create db:migrate db:seed)
      test_tasks=(db:migrate)
    elif bundle exec rails db:migrate:status | awk '{ print $1 }' | grep -q ^down; then
      tasks=(db:migrate)
      test_tasks=(db:migrate)
    fi
  else
    tasks=(db:create db:migrate db:seed)
    test_tasks=(db:migrate)
  fi

  if [ ${#tasks[@]} -gt 0 ]; then
    bundle exec rails "${tasks[@]}"
  fi

  for e in test; do
    if [ ${#test_tasks[@]} -gt 0 ]; then
      bundle exec rails "${test_tasks[@]}" RAILS_ENV=$e
    fi
  done
}

source_service_env() {
  local file=$BASE_DIR/$ENV_PATH/${1}.env

  set -a
  if [ -e $file ]; then
    . $file
  fi
}
