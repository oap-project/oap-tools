val call_center = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/call_center")
val catalog_page = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/catalog_page")
val catalog_returns = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/catalog_returns")
val catalog_sales = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/catalog_sales")
val customer = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/customer")
val customer_address = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/customer_address")
val customer_demographics = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/customer_demographics")
val date_dim = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/date_dim")
val household_demographics = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/household_demographics")
val income_band = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/income_band")
val inventory = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/inventory")
val item = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/item")
val promotion = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/promotion")
val reason = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/reason")
val ship_mode = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/ship_mode")
val store = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/store")
val store_returns = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/store_returns")
val store_sales = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/store_sales")
val time_dim = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/time_dim")
val warehouse = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/warehouse")
val web_page = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/web_page")
val web_returns = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/web_returns")
val web_sales = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/web_sales")
val web_site = spark.read.format("parquet").load("s3a://<my-bucket>/s3a_tpcds_sf20_parquet/web_site")

call_center.createOrReplaceTempView("call_center")
catalog_page.createOrReplaceTempView("catalog_page")
catalog_returns.createOrReplaceTempView("catalog_returns")
catalog_sales.createOrReplaceTempView("catalog_sales")
customer.createOrReplaceTempView("customer")
customer_address.createOrReplaceTempView("customer_address")
customer_demographics.createOrReplaceTempView("customer_demographics")
date_dim.createOrReplaceTempView("date_dim")
household_demographics.createOrReplaceTempView("household_demographics")
income_band.createOrReplaceTempView("income_band")
inventory.createOrReplaceTempView("inventory")
item.createOrReplaceTempView("item")
promotion.createOrReplaceTempView("promotion")
reason.createOrReplaceTempView("reason")
ship_mode.createOrReplaceTempView("ship_mode")
store.createOrReplaceTempView("store")
store_returns.createOrReplaceTempView("store_returns")
store_sales.createOrReplaceTempView("store_sales")
time_dim.createOrReplaceTempView("time_dim")
warehouse.createOrReplaceTempView("warehouse")
web_page.createOrReplaceTempView("web_page")
web_returns.createOrReplaceTempView("web_returns")
web_sales.createOrReplaceTempView("web_sales")
web_site.createOrReplaceTempView("web_site")

df = spark.sql(""" with customer_total_return as
(select sr_customer_sk as ctr_customer_sk
,sr_store_sk as ctr_store_sk
,sum(SR_RETURN_AMT) as ctr_total_return
from store_returns
,date_dim
where sr_returned_date_sk = d_date_sk
and d_year =2000
group by sr_customer_sk
,sr_store_sk)
 select  c_customer_id
from customer_total_return ctr1
,store
,customer
where ctr1.ctr_total_return > (select avg(ctr_total_return)*1.2
from customer_total_return ctr2
where ctr1.ctr_store_sk = ctr2.ctr_store_sk)
and s_store_sk = ctr1.ctr_store_sk
and s_state = 'TN'
and ctr1.ctr_customer_sk = c_customer_sk
order by c_customer_id
 limit 100""")
 
df.count()
val dfx=spark.read.json(Seq(df.queryExecution.executedPlan.toJSON).toDS)
dfx.write.mode("overwrite").format("json").save("/home/ubuntu/executedPlanQ1")