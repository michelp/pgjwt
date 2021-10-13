EXTENSION = pgjwt
DATA = pgjwt--0.1.1.sql pgjwt--0.1.0--0.1.1.sql

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
