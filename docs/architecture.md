# Architecture

The components for storing and accessing data are **Entity**, **Data Access Object (DAO)** and **Database**.

The first, Entity, represents a persistent class and thus a database table.
DAOs manage the access to Entities and take care of the mapping between in-memory objects and table rows.
Lastly, Database, is the central access point to the underlying SQLite database.
It holds the DAOs and, beyond that, takes care of initializing the database and its schema.
[Room](https://developer.android.com/topic/libraries/architecture/room) serves as the source of inspiration for this composition, because it allows creating a clean separation of the component's responsibilities.

The figure shows the relationship between Entity, DAO and Database.

![Flat Architecture](https://raw.githubusercontent.com/Amir-P/flat/develop/img/architecture.png)
