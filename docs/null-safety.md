# Null Safety

Flat infers nullability of database columns directly from entity fields, as mentioned in the [Entities](entities.md) section.
When not explicitly making a field nullable by applying `?` to its type, a column cannot hold `NULL`.
For more information regarding `null`s as query results, see the [Queries](daos.md#queries) and [Streams](daos.md#streams) section. 
