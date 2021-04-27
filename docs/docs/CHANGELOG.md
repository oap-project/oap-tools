# Change log
Generated on 2021-04-27

## Release 1.1.0

### Native-SQL-Engine

#### Features

|||
|:---|:---|
|[#239](https://github.com/oap-project/native-sql-engine/issues/239)|Adopt ARROW-7011|
|[#62](https://github.com/oap-project/native-sql-engine/issues/62)|Support Arrow's Build from Source and Package dependency library in the jar|
|[#145](https://github.com/oap-project/native-sql-engine/issues/145)|Support decimal in columnar window|
|[#31](https://github.com/oap-project/native-sql-engine/issues/31)|Decimal data type support|
|[#128](https://github.com/oap-project/native-sql-engine/issues/128)|Support Decimal in Aggregate|
|[#130](https://github.com/oap-project/native-sql-engine/issues/130)|Support decimal in project|
|[#134](https://github.com/oap-project/native-sql-engine/issues/134)|Update input metrics during reading|
|[#120](https://github.com/oap-project/native-sql-engine/issues/120)|Columnar window: Reduce peak memory usage and fix performance issues|
|[#108](https://github.com/oap-project/native-sql-engine/issues/108)|Add end-to-end test suite against TPC-DS|
|[#68](https://github.com/oap-project/native-sql-engine/issues/68)|Adaptive compression select in Shuffle.|
|[#97](https://github.com/oap-project/native-sql-engine/issues/97)|optimize null check in codegen sort|
|[#29](https://github.com/oap-project/native-sql-engine/issues/29)|Support mutiple-key sort without codegen|
|[#75](https://github.com/oap-project/native-sql-engine/issues/75)|Support HashAggregate in ColumnarWSCG|
|[#73](https://github.com/oap-project/native-sql-engine/issues/73)|improve columnar SMJ|
|[#51](https://github.com/oap-project/native-sql-engine/issues/51)|Decimal fallback|
|[#38](https://github.com/oap-project/native-sql-engine/issues/38)|Supporting expression as join keys in columnar SMJ|
|[#27](https://github.com/oap-project/native-sql-engine/issues/27)|Support REUSE exchange when DPP enabled|
|[#17](https://github.com/oap-project/native-sql-engine/issues/17)|ColumnarWSCG further optimization|

#### Performance
|||
|:---|:---|
|[#194](https://github.com/oap-project/native-sql-engine/issues/194)|Arrow Parameters Update when compiling Arrow|
|[#136](https://github.com/oap-project/native-sql-engine/issues/136)|upgrade to arrow 3.0|
|[#103](https://github.com/oap-project/native-sql-engine/issues/103)|reduce codegen in multiple-key sort|
|[#90](https://github.com/oap-project/native-sql-engine/issues/90)|Refine HashAggregate to do everything in CPP|

#### Bugs Fixed
|||
|:---|:---|
|[#278](https://github.com/oap-project/native-sql-engine/issues/278)|fix arrow dep in 1.1 branch|
|[#265](https://github.com/oap-project/native-sql-engine/issues/265)|TPC-DS Q67 failed with memmove exception in native split code.|
|[#280](https://github.com/oap-project/native-sql-engine/issues/280)|CMake version check|
|[#241](https://github.com/oap-project/native-sql-engine/issues/241)|TPC-DS q67 failed for XXH3_hashLong_64b_withSecret.constprop.0+0x180|
|[#262](https://github.com/oap-project/native-sql-engine/issues/262)|q18 has different digits compared with vanilla spark|
|[#196](https://github.com/oap-project/native-sql-engine/issues/196)|clean up options for native sql engine|
|[#224](https://github.com/oap-project/native-sql-engine/issues/224)|update 3rd party libs|
|[#227](https://github.com/oap-project/native-sql-engine/issues/227)|fix vulnerabilities from klockwork|
|[#229](https://github.com/oap-project/native-sql-engine/issues/229)|Fix the deprecated code warning in shuffle_split_test|
|[#217](https://github.com/oap-project/native-sql-engine/issues/217)|TPC-H query20 result not correct when use decimal dataset|
|[#211](https://github.com/oap-project/native-sql-engine/issues/211)|IndexOutOfBoundsException during running TPC-DS Q2|
|[#167](https://github.com/oap-project/native-sql-engine/issues/167)|Cannot successfully run q.14a.sql and q14b.sql when using double format for TPC-DS workload.|
|[#191](https://github.com/oap-project/native-sql-engine/issues/191)|libarrow.so and libgandiva.so not copy into the tmp directory|
|[#179](https://github.com/oap-project/native-sql-engine/issues/179)|Unable to find Arrow headers during build|
|[#153](https://github.com/oap-project/native-sql-engine/issues/153)|Fix incorrect queries after enabled Decimal|
|[#173](https://github.com/oap-project/native-sql-engine/issues/173)|fix the incorrect result of q69|
|[#48](https://github.com/oap-project/native-sql-engine/issues/48)|unit tests for c++ are broken|
|[#101](https://github.com/oap-project/native-sql-engine/issues/101)|ColumnarWindow: Remove obsolete debug code|
|[#100](https://github.com/oap-project/native-sql-engine/issues/100)|Incorrect result in Q45 w/ v2 bhj threshold is 10MB sf500|
|[#81](https://github.com/oap-project/native-sql-engine/issues/81)|Some ArrowVectorWriter implementations doesn't implement setNulls method|
|[#82](https://github.com/oap-project/native-sql-engine/issues/82)|Incorrect result in TPCDS Q72 SF1536|
|[#70](https://github.com/oap-project/native-sql-engine/issues/70)|Duplicate IsNull check in codegen sort|
|[#64](https://github.com/oap-project/native-sql-engine/issues/64)|Memleak in sort when SMJ is disabled|
|[#58](https://github.com/oap-project/native-sql-engine/issues/58)|Issues when running tpcds with DPP enabled and AQE disabled |
|[#52](https://github.com/oap-project/native-sql-engine/issues/52)|memory leakage in columnar SMJ|
|[#53](https://github.com/oap-project/native-sql-engine/issues/53)|Q24a/Q24b SHJ tail task took about 50 secs in SF1500|
|[#42](https://github.com/oap-project/native-sql-engine/issues/42)|reduce columnar sort memory footprint|
|[#40](https://github.com/oap-project/native-sql-engine/issues/40)|columnar sort codegen fallback to executor side|
|[#1](https://github.com/oap-project/native-sql-engine/issues/1)|columnar whole stage codegen failed due to empty results|
|[#23](https://github.com/oap-project/native-sql-engine/issues/23)|TPC-DS Q8 failed due to unsupported operation in columnar sortmergejoin|
|[#22](https://github.com/oap-project/native-sql-engine/issues/22)|TPC-DS Q95 failed due in columnar wscg|
|[#4](https://github.com/oap-project/native-sql-engine/issues/4)|columnar BHJ failed on new memory pool|
|[#5](https://github.com/oap-project/native-sql-engine/issues/5)|columnar BHJ failed on partitioned table with prefercolumnar=false|

#### PRs
|||
|:---|:---|
|[#282](https://github.com/oap-project/native-sql-engine/pull/282)|[NSE-280]fix cmake version check|
|[#281](https://github.com/oap-project/native-sql-engine/pull/281)|[NSE-280] bump cmake to 3.16|
|[#279](https://github.com/oap-project/native-sql-engine/pull/279)|[NSE-278]fix arrow dep in 1.1 branch|
|[#268](https://github.com/oap-project/native-sql-engine/pull/268)|[NSE-186] backport to 1.1 branch|
|[#266](https://github.com/oap-project/native-sql-engine/pull/266)|[NSE-265] Reserve enough memory before UnsafeAppend in builder|
|[#263](https://github.com/oap-project/native-sql-engine/pull/263)|[NSE-262] fix remainer loss in decimal divide|
|[#215](https://github.com/oap-project/native-sql-engine/pull/215)|[NSE-196] clean up native sql options|
|[#231](https://github.com/oap-project/native-sql-engine/pull/231)|[NSE-176]Arrow install order issue|
|[#242](https://github.com/oap-project/native-sql-engine/pull/242)|[NSE-224] update third party code|
|[#240](https://github.com/oap-project/native-sql-engine/pull/240)|[NSE-239] Adopt ARROW-7011|
|[#230](https://github.com/oap-project/native-sql-engine/pull/230)|[NSE-229] Fix the deprecated code warning in shuffle_split_test|
|[#225](https://github.com/oap-project/native-sql-engine/pull/225)|[NSE-227]fix issues from codescan|
|[#219](https://github.com/oap-project/native-sql-engine/pull/219)|[NSE-217] fix missing decimal check|
|[#212](https://github.com/oap-project/native-sql-engine/pull/212)|[NSE-211] IndexOutOfBoundsException during running TPC-DS Q2|
|[#187](https://github.com/oap-project/native-sql-engine/pull/187)|[NSE-185] Avoid unnecessary copying when simply projecting on fields|
|[#195](https://github.com/oap-project/native-sql-engine/pull/195)|[NSE-194]Turn on several Arrow parameters|
|[#189](https://github.com/oap-project/native-sql-engine/pull/189)|[NSE-153] Following NSE-153, optimize fallback conditions for columnar window|
|[#192](https://github.com/oap-project/native-sql-engine/pull/192)|[NSE-191]Fix issue0191 for .so file copy to tmp.|
|[#181](https://github.com/oap-project/native-sql-engine/pull/181)|[NSE-179]Fix arrow include directory not include when using ARROW_ROOT|
|[#175](https://github.com/oap-project/native-sql-engine/pull/175)|[NSE-153] Fix window results|
|[#174](https://github.com/oap-project/native-sql-engine/pull/174)|[NSE-173] fix incorrect result of q69|
|[#172](https://github.com/oap-project/native-sql-engine/pull/172)|[NSE-62]Fixing issue0062 for package arrow dependencies in jar with refresh2|
|[#171](https://github.com/oap-project/native-sql-engine/pull/171)|[NSE-170]improve sort shuffle code|
|[#165](https://github.com/oap-project/native-sql-engine/pull/165)|[NSE-161] adding format check|
|[#166](https://github.com/oap-project/native-sql-engine/pull/166)|[NSE-130] support decimal round and abs|
|[#164](https://github.com/oap-project/native-sql-engine/pull/164)|[NSE-130] fix precision loss in divide w/ decimal type|
|[#159](https://github.com/oap-project/native-sql-engine/pull/159)|[NSE-31] fix SMJ divide with decimal|
|[#156](https://github.com/oap-project/native-sql-engine/pull/156)|[NSE-130] fix overflow and precision loss|
|[#152](https://github.com/oap-project/native-sql-engine/pull/152)|[NSE-86] Merge Arrow Data Source|
|[#154](https://github.com/oap-project/native-sql-engine/pull/154)|[NSE-153] Fix incorrect quries after enabled Decimal|
|[#151](https://github.com/oap-project/native-sql-engine/pull/151)|[NSE-145] Support decimal in columnar window|
|[#129](https://github.com/oap-project/native-sql-engine/pull/129)|[NSE-128]Support Decimal in Aggregate/HashJoin|
|[#131](https://github.com/oap-project/native-sql-engine/pull/131)|[NSE-130] support decimal in project|
|[#107](https://github.com/oap-project/native-sql-engine/pull/107)|[NSE-136]upgrade to arrow 3.0.0|
|[#135](https://github.com/oap-project/native-sql-engine/pull/135)|[NSE-134] Update input metrics during reading|
|[#121](https://github.com/oap-project/native-sql-engine/pull/121)|[NSE-120] Columnar window: Reduce peak memory usage and fix performance issues|
|[#112](https://github.com/oap-project/native-sql-engine/pull/112)|[NSE-97] optimize null check and refactor sort kernels|
|[#109](https://github.com/oap-project/native-sql-engine/pull/109)|[NSE-108] Add end-to-end test suite against TPC-DS|
|[#69](https://github.com/oap-project/native-sql-engine/pull/69)|[NSE-68][Shuffle] Adaptive compression select in Shuffle.|
|[#98](https://github.com/oap-project/native-sql-engine/pull/98)|[NSE-97] remove isnull when null count is zero|
|[#102](https://github.com/oap-project/native-sql-engine/pull/102)|[NSE-101] ColumnarWindow: Remove obsolete debug code|
|[#105](https://github.com/oap-project/native-sql-engine/pull/105)|[NSE-100]Fix an incorrect result error when using SHJ in Q45|
|[#91](https://github.com/oap-project/native-sql-engine/pull/91)|[NSE-90]Refactor HashAggregateExec and CPP kernels|
|[#79](https://github.com/oap-project/native-sql-engine/pull/79)|[NSE-81] add missing setNulls methods in ArrowWritableColumnVector|
|[#44](https://github.com/oap-project/native-sql-engine/pull/44)|[NSE-29]adding non-codegen framework for multiple-key sort|
|[#76](https://github.com/oap-project/native-sql-engine/pull/76)|[NSE-75]Support ColumnarHashAggregate in ColumnarWSCG|
|[#83](https://github.com/oap-project/native-sql-engine/pull/83)|[NSE-82] Fix Q72 SF1536 incorrect result|
|[#72](https://github.com/oap-project/native-sql-engine/pull/72)|[NSE-51] add more datatype fallback logic in columnar operators|
|[#60](https://github.com/oap-project/native-sql-engine/pull/60)|[NSE-48] fix c++ unit tests|
|[#50](https://github.com/oap-project/native-sql-engine/pull/50)|[NSE-45] BHJ memory leak|
|[#74](https://github.com/oap-project/native-sql-engine/pull/74)|[NSE-73]using data ref in multiple keys based SMJ|
|[#71](https://github.com/oap-project/native-sql-engine/pull/71)|[NSE-70] remove duplicate IsNull check in sort|
|[#65](https://github.com/oap-project/native-sql-engine/pull/65)|[NSE-64] fix memleak in sort when SMJ is disabled|
|[#59](https://github.com/oap-project/native-sql-engine/pull/59)|[NSE-58]Fix empty input issue when DPP enabled|
|[#7](https://github.com/oap-project/native-sql-engine/pull/7)|[OAP-1846][oap-native-sql] add more fallback logic |
|[#57](https://github.com/oap-project/native-sql-engine/pull/57)|[NSE-56]ColumnarSMJ: fallback on full outer join|
|[#55](https://github.com/oap-project/native-sql-engine/pull/55)|[NSE-52]Columnar SMJ: fix memory leak by closing stream batches properly|
|[#54](https://github.com/oap-project/native-sql-engine/pull/54)|[NSE-53]Partial fix Q24a/Q24b tail SHJ task materialization performance issue|
|[#47](https://github.com/oap-project/native-sql-engine/pull/47)|[NSE-17]TPCDS Q72 optimization|
|[#39](https://github.com/oap-project/native-sql-engine/pull/39)|[NSE-38]ColumnarSMJ: support expression as join keys|
|[#43](https://github.com/oap-project/native-sql-engine/pull/43)|[NSE-42] early release sort input|
|[#33](https://github.com/oap-project/native-sql-engine/pull/33)|[NSE-32] Use Spark managed spill in columnar shuffle|
|[#41](https://github.com/oap-project/native-sql-engine/pull/41)|[NSE-40] fixes driver failing to do sort codege|
|[#28](https://github.com/oap-project/native-sql-engine/pull/28)|[NSE-27]Reuse exchage to optimize DPP performance|
|[#36](https://github.com/oap-project/native-sql-engine/pull/36)|[NSE-1]fix columnar wscg on empty recordbatch|
|[#24](https://github.com/oap-project/native-sql-engine/pull/24)|[NSE-23]fix columnar SMJ fallback|
|[#26](https://github.com/oap-project/native-sql-engine/pull/26)|[NSE-22]Fix w/DPP issue when inside wscg smj both sides are smj|
|[#18](https://github.com/oap-project/native-sql-engine/pull/18)|[NSE-17] smjwscg optimization:|
|[#3](https://github.com/oap-project/native-sql-engine/pull/3)|[NSE-4]fix columnar BHJ on new memory pool|
|[#6](https://github.com/oap-project/native-sql-engine/pull/6)|[NSE-5][SCALA] Fix ColumnarBroadcastExchange didn't fallback issue w/ DPP|


### OAP-MLlib

#### Features
|||
|:---|:---|
|[#35](https://github.com/oap-project/oap-mllib/issues/35)|Restrict printNumericTable to first 10 eigenvalues with first 20 dimensions|
|[#33](https://github.com/oap-project/oap-mllib/issues/33)|Optimize oneCCL port detecting|
|[#28](https://github.com/oap-project/oap-mllib/issues/28)|Use getifaddrs to get host ips for oneCCL kvs|
|[#12](https://github.com/oap-project/oap-mllib/issues/12)|Improve CI and add pseudo cluster testing|
|[#31](https://github.com/oap-project/oap-mllib/issues/31)|Print time duration for each PCA step|
|[#13](https://github.com/oap-project/oap-mllib/issues/13)|Add ALS with new oneCCL APIs|
|[#18](https://github.com/oap-project/oap-mllib/issues/18)|Auto detect KVS port for oneCCL to avoid port conflict|
|[#10](https://github.com/oap-project/oap-mllib/issues/10)|Porting Kmeans and PCA to new oneCCL API|

#### Bugs Fixed
|||
|:---|:---|
|[#43](https://github.com/oap-project/oap-mllib/issues/43)|[Release] Error when installing intel-oneapi-dal-devel-2021.1.1 intel-oneapi-tbb-devel-2021.1.1|
|[#46](https://github.com/oap-project/oap-mllib/issues/46)|[Release] Meet hang issue when running PCA algorithm.|
|[#48](https://github.com/oap-project/oap-mllib/issues/48)|[Release] No performance benefit when using Intel-MLlib to run ALS algorithm.|
|[#25](https://github.com/oap-project/oap-mllib/issues/25)|Fix oneCCL KVS port auto detect and improve logging|

#### PRs
|||
|:---|:---|
|[#51](https://github.com/oap-project/oap-mllib/pull/51)|[ML-50] Merge #47 and prepare for OAP 1.1|
|[#49](https://github.com/oap-project/oap-mllib/pull/49)|Revert "[ML-41] Revert to old oneCCL and Prepare for OAP 1.1"|
|[#47](https://github.com/oap-project/oap-mllib/pull/47)|[ML-44] [PIP] Update to oneAPI 2021.2 and Rework examples for validation|
|[#40](https://github.com/oap-project/oap-mllib/pull/40)|[ML-41] Revert to old oneCCL and Prepare for OAP 1.1|
|[#36](https://github.com/oap-project/oap-mllib/pull/36)|[ML-35] Restrict printNumericTable to first 10 eigenvalues with first 20 dimensions|
|[#34](https://github.com/oap-project/oap-mllib/pull/34)|[ML-33] Optimize oneCCL port detecting|
|[#20](https://github.com/oap-project/oap-mllib/pull/20)|[ML-12] Improve CI and add pseudo cluster testing|
|[#32](https://github.com/oap-project/oap-mllib/pull/32)|[ML-31] Print time duration for each PCA step|
|[#14](https://github.com/oap-project/oap-mllib/pull/14)|[ML-13] Add ALS with new oneCCL APIs|
|[#24](https://github.com/oap-project/oap-mllib/pull/24)|[ML-25] Fix oneCCL KVS port auto detect and improve logging|
|[#19](https://github.com/oap-project/oap-mllib/pull/19)|[ML-18]  Auto detect KVS port for oneCCL to avoid port conflict|

### SQL-DS-Cache

#### Features
|||
|:---|:---|
|[#36](https://github.com/oap-project/sql-ds-cache/issues/36)|HCFS doc for Spark|
|[#38](https://github.com/oap-project/sql-ds-cache/issues/38)|update Plasma dependency for Plasma-based-cache module|
|[#14](https://github.com/oap-project/sql-ds-cache/issues/14)|Add HCFS module|
|[#17](https://github.com/oap-project/sql-ds-cache/issues/17)|replace arrow-plasma dependency for hcfs module|

#### Bugs Fixed
|||
|:---|:---|
|[#62](https://github.com/oap-project/sql-ds-cache/issues/62)|Upgrade hadoop dependencies in HCFS|

#### PRs
|||
|:---|:---|
|[#83](https://github.com/oap-project/sql-ds-cache/pull/83)|[SQL-DS-CACHE-82][SDLe]Upgrade Jetty version|
|[#77](https://github.com/oap-project/sql-ds-cache/pull/77)|[SQL-DS-CACHE-62][POAE7-984] upgrade hadoop version to 3.3.0|
|[#56](https://github.com/oap-project/sql-ds-cache/pull/56)|[SQL-DS-CACHE-47]Add plasma native get timeout|
|[#37](https://github.com/oap-project/sql-ds-cache/pull/37)|[SQL-DS-CACHE-36][POAE7-898]HCFS docs for OAP 1.1|
|[#39](https://github.com/oap-project/sql-ds-cache/pull/39)|[SQL-DS-CACHE-38][POAE7-892]update Plasma dependency|
|[#18](https://github.com/oap-project/sql-ds-cache/pull/18)|[SQL-DS-CACHE-17][POAE7-905]replace intel-arrow with apache-arrow v3.0.0|
|[#13](https://github.com/oap-project/sql-ds-cache/pull/13)|[SQL-DS-CACHE-14][POAE7-847] Port HCFS to OAP|
|[#16](https://github.com/oap-project/sql-ds-cache/pull/16)|[SQL-DS-CACHE-15][POAE7-869]Refactor original code to make it a sub-module|


### PMEM-Spill

#### Bugs Fixed
|||
|:---|:---|
|[#22](https://github.com/oap-project/pmem-spill/issues/22)|[SDLe][Snyk]Upgrade Jetty version to fix vulnerability scanned by Snyk|
|[#13](https://github.com/oap-project/pmem-spill/issues/13)|The compiled code failed because the variable name was not changed|

#### PRs
|||
|:---|:---|
|[#27](https://github.com/oap-project/pmem-spill/pull/27)|[PMEM-SPILL-22][SDLe]Upgrade Jetty version|
|[#21](https://github.com/oap-project/pmem-spill/pull/21)|[POAE7-961] fix null pointer issue when offheap enabled.|
|[#18](https://github.com/oap-project/pmem-spill/pull/18)|[POAE7-858] disable RDD cache related PMem intialization as default and add PMem related logic in SparkEnv|
|[#19](https://github.com/oap-project/pmem-spill/pull/19)|[PMEM-SPILL-20][POAE7-912]add vanilla SparkEnv.scala for future update|
|[#15](https://github.com/oap-project/pmem-spill/pull/15)|[POAE7-858] port memory extension options to OAP 1.1|
|[#12](https://github.com/oap-project/pmem-spill/pull/12)|Change the variable name so that the passed parameters are correct|
|[#10](https://github.com/oap-project/pmem-spill/pull/10)|Fixing one pmem path on AppDirect mode may cause the pmem initialization path to be empty Path|


### PMEM-Shuffle

#### Features
|||
|:---|:---|
|[#7](https://github.com/oap-project/pmem-shuffle/issues/7)|Enable running in  fsdax mode|

#### Bugs Fixed
|||
|:---|:---|
|[#10](https://github.com/oap-project/pmem-shuffle/issues/10)|[pmem-shuffle] There are potential issues reported by Klockwork. |

#### PRs
|||
|:---|:---|
|[#13](https://github.com/oap-project/pmem-shuffle/pull/13)|[PMEM-SHUFFLE-10] Fix potential issues reported by klockwork for branch 1.1. |
|[#6](https://github.com/oap-project/pmem-shuffle/pull/6)|[PMEM-SHUFFLE-7] enable fsdax mode in pmem-shuffle|


### Remote-Shuffle

### Features
|||
|:---|:---|
|[#6](https://github.com/oap-project/remote-shuffle/issues/6)|refactor shuffle-daos by abstracting shuffle IO for supporting both synchronous and asynchronous DAOS Object API|
|[#4](https://github.com/oap-project/remote-shuffle/issues/4)|check-in remote shuffle based on DAOS Object API|

### Bugs Fixed
|||
|:---|:---|
|[#12](https://github.com/oap-project/remote-shuffle/issues/12)|[SDLe][Snyk]Upgrade org.mock-server:mockserver-netty to fix vulnerability scanned by Snyk|

### PRs
|||
|:---|:---|
|[#13](https://github.com/oap-project/remote-shuffle/pull/13)|[REMOTE-SHUFFLE-12][SDle][Snyk]Upgrade org.mock-server:mockserver-net…|
|[#5](https://github.com/oap-project/remote-shuffle/pull/5)|check-in remote shuffle based on DAOS Object API|
