EXTENSION = pgjwt
DATA = pgjwt--0.0.1.sql
REGRESS = jwt_test     # our test script file (without extension)

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
