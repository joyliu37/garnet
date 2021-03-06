# add Genesis to the path
export GENESIS_HOME=/Genesis2/Genesis2Tools
export PATH=$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH
export PERL5LIB=$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

# force color
export PYTEST_ADDOPTS="--color=yes"

cd /garnet/

pytest --pycodestyle        \
    --cov global_controller \
    --cov io_core           \
    --cov memory_core       \
    --ignore=filecmp.py     \
    --ignore=Genesis2/      \
    --ignore=tests/test_interconnect \
    -v --cov-report term-missing tests

# coreir has memory leak. split them into two to get around
pytest --pycodestyle        \
    --cov global_controller \
    --cov io_core           \
    --cov memory_core       \
    --ignore=filecmp.py     \
    --ignore=Genesis2/      \
    --ignore=tests/test_memory_core \
    -v --cov-report term-missing tests/test_interconnect
