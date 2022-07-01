# Components

OAP Project aims to optimize Spark, and it contains 3 components including **Gazelle Plugin**, **OAP MLlib** and **CloudTik** since release 1.4.0.

* [Gazelle Plugin](https://github.com/oap-project/gazelle_plugin.git)

* [OAP MLlib](https://github.com/oap-project/oap-mllib.git)

* [CloudTik](https://github.com/oap-project/cloudtik.git)


## Gazelle Plugin

[Documents Website](https://oap-project.github.io/gazelle_plugin/)

Spark SQL works very well with structured row-based data. It used WholeStageCodeGen to improve the performance by Java JIT code. However, Java JIT is usually not working very well on utilizing latest SIMD instructions, especially under complicated queries.
Apache Arrow provided CPU-cache friendly columnar in-memory layout, its SIMD-optimized kernels and LLVM-based SQL engine Gandiva are also very efficient.

Gazelle Plugin reimplements Spark SQL execution layer with SIMD-friendly columnar data processing based on Apache Arrow,
and leverages Arrow's CPU-cache friendly columnar in-memory layout, SIMD-optimized kernels and LLVM-based expression engine to bring better performance to Spark SQL.

## OAP MLlib

[Documents Website](https://oap-project.github.io/oap-mllib/)

OAP MLlib is an optimized package to accelerate machine learning algorithms in Spark MLlib.
It is compatible with Spark MLlib and leverages open source Intel® oneAPI Data Analytics Library (oneDAL) to provide highly optimized algorithms and get most out of CPU and GPU capabilities.
It also takes advantage of open source Intel® oneAPI Collective Communications Library (oneCCL) to provide efficient communication patterns in multi-node multi-GPU clusters.

## CloudTik

[Documents Website](https://cloudtik.readthedocs.io/)

CloudTik is a cloud scaling platform to scale your distributed analytics and AI cluster on public cloud providers including AWS, Azure, GCP, and so on.

- Built upon Cloud compute engines and Cloud storages

- Support major public Cloud providers (AWS, Azure, GCP, and more to come)

- Powerful and Optimized: Out of box and optimized runtimes for Analytics and AI

- Simplified and Unified: Easy to use and unified operating experience on all Cloud providers

- Open and Flexible: Open architecture and users with full control, fully open-source and user transparent.
