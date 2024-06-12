# Databricks notebook source
display(dbutils.fs.ls('/databricks-datasets'))

# COMMAND ----------

display(dbutils.fs.ls('/databricks-datasets/learning-spark-v2/'))

# COMMAND ----------

display(dbutils.fs.ls('/databricks-datasets/learning-spark-v2/iot-devices'))

# COMMAND ----------

display(dbutils.fs.ls('/databricks-datasets/flowers/delta'))

# COMMAND ----------

#spark.read.format("delta").load('dbfs:/databricks-datasets/flowers/delta/').display()

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS trilha_panda 

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS trilha_panda.people10m OPTIONS (PATH 'dbfs:/databricks-datasets/learning-spark-v2/people/people-10m.delta')

# COMMAND ----------

# MAGIC %sql select * from trilha_panda.people10m

# COMMAND ----------

#noqa
