LD_LIBRARY_PATH="$(hab pkg path core/gcc-libs)/lib"
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(hab pkg path core/zlib)/lib
export LD_LIBRARY_PATH

export SANDY_DATA="/hab/svc/sandy/data"
export GEM_HOME="${SANDY_DATA}/dist/vendor/bundle/ruby/2.4.0"
export GEM_PATH="$(hab pkg path core/ruby)/lib/ruby/gems/2.4.0:$(hab pkg path core/bundler):$GEM_HOME"
export PATH="$PATH:${SANDY_DATA}/dist/bin:${SANDY_DATA}/dist/vendor/bundle/ruby/2.4.0/bin:$(hab pkg path core/ruby)/bin"
export RAILS_ENV="production"
export SANDY_SERVICE="${SANDY_SERVICE:-web}"

cd $SANDY_DATA/dist

exec 2>&1
rails console
