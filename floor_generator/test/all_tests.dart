import 'misc/foreign_key_action_test.dart' as misc_foreign_key_action_test;
import 'misc/string_utils_test.dart' as misc_string_utils_test;
import 'misc/type_utils_test.dart' as misc_type_utils_test;
import 'processor/dao_processor_test.dart' as processor_dao_processor_test;
import 'processor/database_processor_test.dart'
    as processor_database_processor_test;
import 'processor/entity_processor_test.dart'
    as processor_entity_processor_test;
import 'processor/field_processor_test.dart' as processor_field_processor_test;
import 'processor/insertion_method_processor_test.dart'
    as processor_insertion_method_processor_test;
import 'processor/query_method_processor_test.dart'
    as processor_query_method_processor_test;
import 'processor/queryable_processor_test.dart'
    as processor_queryable_processor_test;
import 'processor/transaction_method_processor_test.dart'
    as processor_transaction_method_processor_test;
import 'processor/update_method_processor_test.dart'
    as processor_update_method_processor_test;
import 'processor/view_processor_test.dart' as processor_view_processor_test;
import 'value_object/entity_test.dart' as value_object_entity_test;
import 'value_object/field_test.dart' as value_object_field_test;
import 'value_object/foreign_key_test.dart' as value_object_foreign_key_test;
import 'value_object/index_test.dart' as value_object_index_test;
import 'value_object/view_test.dart' as value_object_view_test;
import 'writer/dao_writer_test.dart' as writer_dao_writer_test;
import 'writer/database_builder_writer_test.dart'
    as writer_database_builder_writer_test;
import 'writer/database_writer_test.dart' as writer_database_writer_test;
import 'writer/deletion_method_writer_test.dart'
    as writer_deletion_method_writer_test;
import 'writer/floor_writer_test.dart' as writer_floor_writer_test;
import 'writer/insert_method_writer_test.dart'
    as writer_insert_method_writer_test;
import 'writer/query_method_writer_test.dart'
    as writer_query_method_writer_test;
import 'writer/transaction_method_writer_test.dart'
    as writer_transaction_method_writer_test;
import 'writer/update_method_writer_test.dart'
    as writer_update_method_writer_test;

void main() {
  misc_type_utils_test.main();
  misc_foreign_key_action_test.main();
  misc_string_utils_test.main();
  processor_transaction_method_processor_test.main();
  processor_query_method_processor_test.main();
  processor_view_processor_test.main();
  processor_field_processor_test.main();
  processor_dao_processor_test.main();
  processor_queryable_processor_test.main();
  processor_entity_processor_test.main();
  processor_update_method_processor_test.main();
  processor_insertion_method_processor_test.main();
  processor_database_processor_test.main();
  writer_database_writer_test.main();
  writer_database_builder_writer_test.main();
  writer_update_method_writer_test.main();
  writer_deletion_method_writer_test.main();
  writer_transaction_method_writer_test.main();
  writer_dao_writer_test.main();
  writer_insert_method_writer_test.main();
  writer_floor_writer_test.main();
  writer_query_method_writer_test.main();
  value_object_view_test.main();
  value_object_foreign_key_test.main();
  value_object_entity_test.main();
  value_object_index_test.main();
  value_object_field_test.main();
}
