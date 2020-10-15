# Running a production iReceptor Turnkey

There are a number of issues to consider when running a production iReceptor Turnkey repository. This
document contains information about the process the iReceptor team uses to run its cluster of
iReceptor Turnkey repositories. This is the process that we recommend you use, but it is
focussed on high performance and minimal user impact, at the cost of computational and storage
resources. As such, some or all of the approach described below may not be appropriate for all research groups.

## Scalability

iReceptor recommends [horizontal scalability](https://en.wikipedia.org/wiki/Scalability) as you add more data. When you add data to an iReceptor Turnkey, searches
over the data are slower. We carefully optimize indexes for common searches, with particular attention to the searches
performed by the [iReceptor Gateway](http://gateway.ireceptor.org) but eventually a single server with a single disk
reaches its limits. We solve this problem by simply adding another repository/server/virtual machine (horizontal scalability). As a result,
we run a cluster of repositories each with a fixed amount of data. Our repositories are federated at the client layer,
with the iReceptor Gateway presenting the cluster of repositories as a single large repository to the end user.

We find that as a single repository approaches 500 million rearrangements, performance starts to degrade to a point where
optimized sequence level searches (e.g. search for a specific CDR3) are no longer "interactive". By interactive, we mean the
repository is no longer able to complete an optimized query in under 180 seconds. Because our repositories are targeted at
working with the iReceptor Gateway, we optimize our scaling at the 180 seconds per optimized query sweet spot. 

There are a number of hardware resources that impact performance.

- CPUs: Mongo typically runs single threaded queries, so adding more CPUs means you can run more parallel queries, but it doesn't
help a single query run faster. So 2 - 8 cores/CPUs is typically sufficient unless you expect lots of concurrent queries. 
- Disk: Disk storage is critical for storing both the collections and the indexes for MongoDB. Out optimized query indexes require
almost as much disk space as the data itself. We find that 1TB of disk for a repository with 500M rearrangements is typically sufficient.
- Memory: Memory is the most critical resource. MongoDB is very fast if your searchers utilize your indexes AND your indexes fit in memory.
Having enough memory is critical and we typically run with 8 cores and 10GB of memory per core on our repository VMs.

The bottom line. If you have the resources, add a new repository as a repository approaches 500M rearrangements. 

## Optimizing data loading

The data loading process has a significant impact on the production level of a repository. Unless you are able to load
all of the data into a repository and then bring it on line, the data loading process can have a dramatic impact on your 
production repository.

