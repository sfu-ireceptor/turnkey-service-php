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

The data loading process has a significant impact on the production level of a repository.
In order to minimize this impact, the iReceptor team runs a "staging" repository for each "production" repository
that is able to take on more data. These are tpyically running on separate VMs with the "staging" repository a mirror of the "production" repository.
By mirror, we mean that the MongoDB collections are identical. 

The "production" repository is almost always in production. When a study is being loaded, it is loaded into the "staging" repository. 
This loading of course has no impact on the "production" repository. For
large studies, in particular when loading large studies into a repository that already has a large amount of data, this can take a long time.
Once the "staging" repository is finished loading the new study, the "staging" Turnkey is shutdown and the MongoDB database folder is copied to the
"production" repository VM in a self contained directory. At this point, the "production" repository has two MongoDB folders, one that is being used
by the "production" service and one that contains the data from the "staging" repository. When you are ready to move the new data into production, you
simply bring down the "production" repository, change the location of the "production" repository to point to the new folder from the "staging"
repository, and the bring the "production" Turnkey repository back on line. This should take a matter of seconds.

Becasue the "staging" and "production" repositories now have the same data, this process can be repeated. That is, a new study can be loaded
into the "staging" repository, copied to the "production" repository, and the directories switched once again. Once a "production" repository
becomes "full" (approaches 500M rearrangements), no data is added, and when it is necessary to add a new study, a new, empty "production" repository
provisioned, the empty "production" repository is mirrored on the "staging" repository, data is loaded into the empty "staging" repopsitory, and once
done, the new "production" repository is updated as above. To find out more information about the iReceptor Public archive and the cluster of repositories
from which it is built, please refer to the [iReceptor Repsository web page](http://www.ireceptor.org/repositories).

### Details

- Use the Turnkey [stop_turnkey.sh and start_turnkey.sh](start_stop_turnkey.md) commands to stop and start the "staging" and "production" Turnkey repositories.
- Follow the directions in [Moving the database to another folder](moving_the_database_folder.md) to change the active folder being used by MongoDB
- This approach uses the Mongo [Backing up copying underlying data files](https://docs.mongodb.com/manual/core/backups/#back-up-by-copying-underlying-data-files) approach. Note that this is safest to do when Mongo is not running, hence the need to stop the Turnkey during copy and switching directories.
- It is ALWAYS good practice to back up your repository by performing such operations. You can use the Turnkey [Backing up and restoring the database](database_backup.md) process for this, but because you are not destroying the old Mongo DB directory, you by defintion have a backup of the "production" repository.

