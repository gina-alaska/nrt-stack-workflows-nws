LD_LIBRARY_PATH="$(hab pkg path core/gcc-libs)/lib"
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(hab pkg path core/zlib)/lib
export LD_LIBRARY_PATH

export SANDY_DATA="/hab/pkgs/uafgina/sandy/1.4.3e/20180104040740/"
export GEM_HOME="${SANDY_DATA}/dist/vendor/bundle/ruby/2.4.0"
export GEM_PATH="$(hab pkg path core/ruby)/lib/ruby/gems/2.4.0:$(hab pkg path core/bundler):$GEM_HOME"
export PATH="$PATH:${SANDY_DATA}/dist/bin:${SANDY_DATA}/dist/vendor/bundle/ruby/2.4.0/bin"
export RAILS_ENV="production"
export SANDY_SERVICE="${SANDY_SERVICE:-web}"

cd $SANDY_DATA/dist

rake console

