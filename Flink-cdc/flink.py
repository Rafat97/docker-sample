from pyflink.table import DataTypes, TableEnvironment, EnvironmentSettings
from pyflink.table.descriptors import Schema
from pyflink.table.expressions import lit
import os
from faker import Faker

env_settings = EnvironmentSettings.in_streaming_mode()
CURRENT_DIR = os.getcwd()

table_env = TableEnvironment.create(env_settings)
# Get the current working directory



jar_files = [
    "flink-sql-connector-postgres-cdc-3.0.1.jar",
    "flink-sql-connector-mongodb-cdc-3.0.1.jar",
    "flink-sql-connector-mysql-cdc-3.0.1.jar",
]

# Build the list of JAR URLs by prepending 'file:///' to each file name
jar_urls = [f"file:///{CURRENT_DIR}/{jar_file}" for jar_file in jar_files]

table_env.get_config().get_configuration().set_string(
    "pipeline.jars",
    ";".join(jar_urls)
)
table_env.get_config().get_configuration().set_string(
    "execution.checkpointing.interval",
    "5000"
)

postgres_sink = f"""
CREATE TABLE test_pg_src (
   id STRING,
   PRIMARY KEY (id) NOT ENFORCED
 ) WITH (
    'connector' = 'postgres-cdc',
    'hostname' = '192.168.0.100',
    'port' = '5432',
    'username' = 'postgres',
    'password' = 'postgres',
    'database-name' = 'financial_db',
    'schema-name' = 'public',
    'slot.name' = 'flinktransaction',
    'decoding.plugin.name' = 'pgoutput',
    'table-name' = 'transactions'
 );
"""
table_env.execute_sql(postgres_sink)

postgres_sink = f"""
CREATE TABLE test_pg_dest (
   id STRING,
   PRIMARY KEY (id) NOT ENFORCED
 ) WITH (
    'connector' = 'print'
 );
"""
table_env.execute_sql(postgres_sink)

table_env.execute_sql("SHOW TABLES").print()


table_env.execute_sql("""
         SELECT COUNT(*) FROM test_pg_src
""").print()
