# Isolates

As floor is based on sqflite, Android and iOS apps access the SQLite database on a native background thread.
On Linux, macOS, and Windows, a separate isolate is used.
You can do some further reading on sqflite's background work mechanisms [here](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/usage_recommendations.md).
