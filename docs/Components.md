# Components

OAP Project aims to optimize Spark, and it contains 2 components including **Gazelle Plugin** and **OAP MLlib** from release 1.3.0.

* [Gazelle Plugin](https://oap-project.github.io/gazelle_plugin/)

* [OAP MLlib](https://oap-project.github.io/oap-mllib/)


## Gazelle Plugin

[Document Website](https://oap-project.github.io/gazelle_plugin/)

Spark SQL works very well with structured row-based data. It used WholeStageCodeGen to improve the performance by Java JIT code. However, Java JIT is usually not working very well on utilizing latest SIMD instructions, especially under complicated queries.
Apache Arrow provided CPU-cache friendly columnar in-memory layout, its SIMD-optimized kernels and LLVM-based SQL engine Gandiva are also very efficient.

Gazelle Plugin reimplements Spark SQL execution layer with SIMD-friendly columnar data processing based on Apache Arrow,
and leverages Arrow's CPU-cache friendly columnar in-memory layout, SIMD-optimized kernels and LLVM-based expression engine to bring better performance to Spark SQL.

## OAP MLlib

[Document Website](https://oap-project.github.io/oap-mllib/)

OAP MLlib is an optimized package to accelerate machine learning algorithms in Spark MLlib.
It is compatible with Spark MLlib and leverages open source Intel® oneAPI Data Analytics Library (oneDAL) to provide highly optimized algorithms and get most out of CPU and GPU capabilities.
It also takes advantage of open source Intel® oneAPI Collective Communications Library (oneCCL) to provide efficient communication patterns in multi-node multi-GPU clusters.