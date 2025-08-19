import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:pub_semver/src/version.dart';

class FakeClassElement implements ClassElement2 {
  @override
  T? accept2<T>(ElementVisitor2<T> visitor) {
    throw UnimplementedError();
  }

  @override
  List<InterfaceType> get allSupertypes => throw UnimplementedError();

  @override
  Element2 get baseElement => throw UnimplementedError();

  @override
  List<Element2> get children2 => throw UnimplementedError();

  @override
  List<ConstructorElement2> get constructors2 => throw UnimplementedError();

  @override
  String get displayName => throw UnimplementedError();

  @override
  String displayString2({bool multiline = false, bool preferTypeAlias = false}) {
    throw UnimplementedError();
  }

  @override
  String? get documentationComment => throw UnimplementedError();

  @override
  LibraryElement2 get enclosingElement2 => throw UnimplementedError();

  @override
  List<FieldElement2> get fields2 => throw UnimplementedError();

  @override
  ClassFragment get firstFragment => throw UnimplementedError();

  @override
  List<ClassFragment> get fragments => throw UnimplementedError();

  @override
  String getExtendedDisplayName2({String? shortName}) {
    throw UnimplementedError();
  }

  @override
  FieldElement2? getField2(String name) {
    throw UnimplementedError();
  }

  @override
  GetterElement? getGetter2(String name) {
    throw UnimplementedError();
  }

  @override
  ExecutableElement2? getInheritedConcreteMember(Name name) {
    throw UnimplementedError();
  }

  @override
  ExecutableElement2? getInheritedMember(Name name) {
    throw UnimplementedError();
  }

  @override
  ExecutableElement2? getInterfaceMember(Name name) {
    throw UnimplementedError();
  }

  @override
  MethodElement2? getMethod2(String name) {
    throw UnimplementedError();
  }

  @override
  ConstructorElement2? getNamedConstructor2(String name) {
    throw UnimplementedError();
  }

  @override
  List<ExecutableElement2>? getOverridden(Name name) {
    throw UnimplementedError();
  }

  @override
  SetterElement? getSetter2(String name) {
    throw UnimplementedError();
  }

  @override
  List<GetterElement> get getters2 => throw UnimplementedError();

  @override
  bool get hasNonFinalField => throw UnimplementedError();

  @override
  int get id => throw UnimplementedError();

  @override
  Map<Name, ExecutableElement2> get inheritedConcreteMembers => throw UnimplementedError();

  @override
  Map<Name, ExecutableElement2> get inheritedMembers => throw UnimplementedError();

  @override
  InterfaceType instantiate({required List<DartType> typeArguments, required NullabilitySuffix nullabilitySuffix}) {
    throw UnimplementedError();
  }

  @override
  Map<Name, ExecutableElement2> get interfaceMembers => throw UnimplementedError();

  @override
  List<InterfaceType> get interfaces => throw UnimplementedError();

  @override
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn2(LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  bool get isBase => throw UnimplementedError();

  @override
  bool get isConstructable => throw UnimplementedError();

  @override
  bool get isDartCoreEnum => throw UnimplementedError();

  @override
  bool get isDartCoreObject => throw UnimplementedError();

  @override
  bool get isExhaustive => throw UnimplementedError();

  @override
  bool isExtendableIn2(LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  bool get isFinal => throw UnimplementedError();

  @override
  bool isImplementableIn2(LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  bool get isInterface => throw UnimplementedError();

  @override
  bool isMixableIn2(LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  bool get isMixinApplication => throw UnimplementedError();

  @override
  bool get isMixinClass => throw UnimplementedError();

  @override
  bool get isPrivate => throw UnimplementedError();

  @override
  bool get isPublic => throw UnimplementedError();

  @override
  bool get isSealed => throw UnimplementedError();

  @override
  bool get isSimplyBounded => throw UnimplementedError();

  @override
  bool get isSynthetic => throw UnimplementedError();

  @override
  bool get isValidMixin => throw UnimplementedError();

  @override
  ElementKind get kind => throw UnimplementedError();

  @override
  LibraryElement2 get library2 => throw UnimplementedError();

  @override
  MethodElement2? lookUpConcreteMethod(String methodName, LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  GetterElement? lookUpGetter2({required String name, required LibraryElement2 library}) {
    throw UnimplementedError();
  }

  @override
  MethodElement2? lookUpInheritedMethod2({required String methodName, required LibraryElement2 library}) {
    throw UnimplementedError();
  }

  @override
  MethodElement2? lookUpMethod2({required String name, required LibraryElement2 library}) {
    throw UnimplementedError();
  }

  @override
  SetterElement? lookUpSetter2({required String name, required LibraryElement2 library}) {
    throw UnimplementedError();
  }

  @override
  String? get lookupName => throw UnimplementedError();

  @override
  Metadata get metadata2 => throw UnimplementedError();

  @override
  List<MethodElement2> get methods2 => throw UnimplementedError();

  @override
  List<InterfaceType> get mixins => throw UnimplementedError();

  @override
  String? get name3 => throw UnimplementedError();

  @override
  Element2 get nonSynthetic2 => throw UnimplementedError();

  @override
  AnalysisSession? get session => throw UnimplementedError();

  @override
  List<SetterElement> get setters2 => throw UnimplementedError();

  @override
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  InterfaceType? get supertype => throw UnimplementedError();

  @override
  Element2? thisOrAncestorMatching2(bool Function(Element2 p1) predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType2<E extends Element2>() {
    throw UnimplementedError();
  }

  @override
  InterfaceType get thisType => throw UnimplementedError();

  @override
  List<TypeParameterElement2> get typeParameters2 => throw UnimplementedError();

  @override
  ConstructorElement2? get unnamedConstructor2 => throw UnimplementedError();

  @override
  void visitChildren2<T>(ElementVisitor2<T> visitor) {}
}

class FakeFieldElement implements FieldElement2 {
  @override
  T? accept2<T>(ElementVisitor2<T> visitor) {
    throw UnimplementedError();
  }

  @override
  FieldElement2 get baseElement => throw UnimplementedError();

  @override
  List<Element2> get children2 => throw UnimplementedError();

  @override
  DartObject? computeConstantValue() {
    throw UnimplementedError();
  }

  @override
  Expression? get constantInitializer => throw UnimplementedError();

  @override
  // ignore: deprecated_member_use
  ConstantInitializer? get constantInitializer2 => throw UnimplementedError();

  @override
  String get displayName => throw UnimplementedError();

  @override
  String displayString2({bool multiline = false, bool preferTypeAlias = false}) {
    throw UnimplementedError();
  }

  @override
  String? get documentationComment => throw UnimplementedError();

  @override
  InstanceElement2 get enclosingElement2 => throw UnimplementedError();

  @override
  FieldFragment get firstFragment => throw UnimplementedError();

  @override
  List<FieldFragment> get fragments => throw UnimplementedError();

  @override
  String getExtendedDisplayName2({String? shortName}) {
    throw UnimplementedError();
  }

  @override
  GetterElement? get getter2 => throw UnimplementedError();

  @override
  bool get hasImplicitType => throw UnimplementedError();

  @override
  bool get hasInitializer => throw UnimplementedError();

  @override
  int get id => throw UnimplementedError();

  @override
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn2(LibraryElement2 library) {
    throw UnimplementedError();
  }

  @override
  bool get isConst => throw UnimplementedError();

  @override
  bool get isCovariant => throw UnimplementedError();

  @override
  bool get isEnumConstant => throw UnimplementedError();

  @override
  bool get isExternal => throw UnimplementedError();

  @override
  bool get isFinal => throw UnimplementedError();

  @override
  bool get isLate => throw UnimplementedError();

  @override
  bool get isPrivate => throw UnimplementedError();

  @override
  bool get isPromotable => throw UnimplementedError();

  @override
  bool get isPublic => throw UnimplementedError();

  @override
  bool get isStatic => throw UnimplementedError();

  @override
  bool get isSynthetic => throw UnimplementedError();

  @override
  ElementKind get kind => throw UnimplementedError();

  @override
  LibraryElement2 get library2 => throw UnimplementedError();

  @override
  String? get lookupName => throw UnimplementedError();

  @override
  Metadata get metadata2 => throw UnimplementedError();

  @override
  String? get name3 => throw UnimplementedError();

  @override
  Element2 get nonSynthetic2 => throw UnimplementedError();

  @override
  AnalysisSession? get session => throw UnimplementedError();

  @override
  SetterElement? get setter2 => throw UnimplementedError();

  @override
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  Element2? thisOrAncestorMatching2(bool Function(Element2 p1) predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType2<E extends Element2>() {
    throw UnimplementedError();
  }

  @override
  DartType get type => throw UnimplementedError();

  @override
  void visitChildren2<T>(ElementVisitor2<T> visitor) {}
}

class FakeDartObject implements DartObject {
  @override
  DartObject? getField(String name) {
    throw UnimplementedError();
  }

  @override
  bool get hasKnownValue => throw UnimplementedError();

  @override
  bool get isNull => throw UnimplementedError();

  @override
  bool? toBoolValue() {
    throw UnimplementedError();
  }

  @override
  double? toDoubleValue() {
    throw UnimplementedError();
  }

  @override
  // ignore: deprecated_member_use
  ExecutableElement? toFunctionValue() {
    throw UnimplementedError();
  }

  @override
  ExecutableElement2? toFunctionValue2() {
    throw UnimplementedError();
  }

  @override
  int? toIntValue() {
    throw UnimplementedError();
  }

  @override
  List<DartObject>? toListValue() {
    throw UnimplementedError();
  }

  @override
  Map<DartObject?, DartObject?>? toMapValue() {
    throw UnimplementedError();
  }

  @override
  ({Map<String, DartObject> named, List<DartObject> positional})? toRecordValue() {
    throw UnimplementedError();
  }

  @override
  Set<DartObject>? toSetValue() {
    throw UnimplementedError();
  }

  @override
  String? toStringValue() {
    throw UnimplementedError();
  }

  @override
  String? toSymbolValue() {
    throw UnimplementedError();
  }

  @override
  DartType? toTypeValue() {
    throw UnimplementedError();
  }

  @override
  DartType? get type => throw UnimplementedError();

  @override
  // ignore: deprecated_member_use
  VariableElement? get variable => throw UnimplementedError();

  @override
  VariableElement2? get variable2 => throw UnimplementedError();
}
