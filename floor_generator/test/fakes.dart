import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:pub_semver/src/version.dart';

class FakeClassElement implements ClassElement {
  @override
  T? accept<T>(ElementVisitor<T> visitor) {
    throw UnimplementedError();
  }

  @override
  List<PropertyAccessorElement> get accessors => throw UnimplementedError();

  @override
  List<InterfaceType> get allSupertypes => throw UnimplementedError();

  @override
  List<ConstructorElement> get constructors => throw UnimplementedError();

  @override
  AnalysisContext get context => throw UnimplementedError();

  @override
  Element get declaration => throw UnimplementedError();

  @override
  String get displayName => throw UnimplementedError();

  @override
  String? get documentationComment => throw UnimplementedError();

  @override
  CompilationUnitElement get enclosingElement => throw UnimplementedError();

  @override
  List<FieldElement> get fields => throw UnimplementedError();

  @override
  String getExtendedDisplayName(String? shortName) {
    throw UnimplementedError();
  }

  @override
  FieldElement? getField(String name) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getGetter(String name) {
    throw UnimplementedError();
  }

  @override
  MethodElement? getMethod(String name) {
    throw UnimplementedError();
  }

  @override
  ConstructorElement? getNamedConstructor(String name) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getSetter(String name) {
    throw UnimplementedError();
  }

  @override
  bool get hasAlwaysThrows => throw UnimplementedError();

  @override
  bool get hasDeprecated => throw UnimplementedError();

  @override
  bool get hasDoNotStore => throw UnimplementedError();

  @override
  bool get hasFactory => throw UnimplementedError();

  @override
  bool get hasInternal => throw UnimplementedError();

  @override
  bool get hasIsTest => throw UnimplementedError();

  @override
  bool get hasIsTestGroup => throw UnimplementedError();

  @override
  bool get hasJS => throw UnimplementedError();

  @override
  bool get hasLiteral => throw UnimplementedError();

  @override
  bool get hasMustCallSuper => throw UnimplementedError();

  @override
  bool get hasNonFinalField => throw UnimplementedError();

  @override
  bool get hasNonVirtual => throw UnimplementedError();

  @override
  bool get hasOptionalTypeArgs => throw UnimplementedError();

  @override
  bool get hasOverride => throw UnimplementedError();

  @override
  bool get hasProtected => throw UnimplementedError();

  @override
  bool get hasRequired => throw UnimplementedError();

  @override
  bool get hasSealed => throw UnimplementedError();

  @override
  bool get hasVisibleForTemplate => throw UnimplementedError();

  @override
  bool get hasVisibleForTesting => throw UnimplementedError();

  @override
  int get id => throw UnimplementedError();

  @override
  InterfaceType instantiate(
      {required List<DartType> typeArguments,
      required NullabilitySuffix nullabilitySuffix}) {
    throw UnimplementedError();
  }

  @override
  List<InterfaceType> get interfaces => throw UnimplementedError();

  @override
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn(LibraryElement? library) {
    throw UnimplementedError();
  }

  @override
  bool get isDartCoreObject => throw UnimplementedError();

  @override
  bool get isMixinApplication => throw UnimplementedError();

  @override
  bool get isPrivate => throw UnimplementedError();

  @override
  bool get isPublic => throw UnimplementedError();

  @override
  bool get isSimplyBounded => throw UnimplementedError();

  @override
  bool get isSynthetic => throw UnimplementedError();

  @override
  bool get isValidMixin => throw UnimplementedError();

  @override
  ElementKind get kind => throw UnimplementedError();

  @override
  LibraryElement get library => throw UnimplementedError();

  @override
  ElementLocation? get location => throw UnimplementedError();

  @override
  MethodElement? lookUpConcreteMethod(
      String methodName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpGetter(
      String getterName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpInheritedConcreteGetter(
      String getterName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpInheritedConcreteMethod(
      String methodName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpInheritedConcreteSetter(
      String setterName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpInheritedMethod(
      String methodName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpMethod(String methodName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpSetter(
      String setterName, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  List<ElementAnnotation> get metadata => throw UnimplementedError();

  @override
  List<MethodElement> get methods => throw UnimplementedError();

  @override
  List<InterfaceType> get mixins => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  int get nameLength => throw UnimplementedError();

  @override
  int get nameOffset => throw UnimplementedError();

  @override
  AnalysisSession? get session => throw UnimplementedError();

  @override
  InterfaceType? get supertype => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching<E extends Element>(predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() {
    throw UnimplementedError();
  }

  @override
  InterfaceType get thisType => throw UnimplementedError();

  @override
  List<TypeParameterElement> get typeParameters => throw UnimplementedError();

  @override
  ConstructorElement? get unnamedConstructor => throw UnimplementedError();

  @override
  void visitChildren(ElementVisitor visitor) {}

  @override
  bool get hasUseResult => throw UnimplementedError();

  @override
  bool get hasVisibleForOverriding => throw UnimplementedError();

  @override
  Element get nonSynthetic => throw UnimplementedError();

  @override
  bool get isDartCoreEnum => throw UnimplementedError();

  @override
  AugmentedClassElement get augmented => throw UnimplementedError();

  @override
  bool get hasMustBeOverridden => throw UnimplementedError();

  @override
  List<Element> get children => throw UnimplementedError();

  @override
  bool get hasReopen => throw UnimplementedError();

  @override
  bool get isBase => throw UnimplementedError();

  @override
  bool get isConstructable => throw UnimplementedError();

  @override
  bool get isExhaustive => throw UnimplementedError();

  @override
  bool isExtendableIn(LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  bool get isFinal => throw UnimplementedError();

  @override
  bool isImplementableIn(LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  bool get isInterface => throw UnimplementedError();

  @override
  bool isMixableIn(LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  bool get isMixinClass => throw UnimplementedError();

  @override
  bool get isSealed => throw UnimplementedError();

  @override
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  ClassElement? get augmentationTarget => throw UnimplementedError();

  @override
  bool get hasImmutable => throw UnimplementedError();

  @override
  bool get hasRedeclare => throw UnimplementedError();

  @override
  bool get hasVisibleOutsideTemplate => throw UnimplementedError();

  @override
  bool get isAugmentation => throw UnimplementedError();

  @override
  bool get isInline => throw UnimplementedError();

  @override
  ClassElement? get augmentation => throw UnimplementedError();

  @override
  CompilationUnitElement get enclosingElement3 => throw UnimplementedError();

  @override
  String getDisplayString({bool withNullability = true, bool multiline = false}) {
    throw UnimplementedError();
  }

  @override
  bool get hasDoNotSubmit => throw UnimplementedError();

  @override
  bool get hasMustBeConst => throw UnimplementedError();

  @override
  Source get librarySource => throw UnimplementedError();

  @override
  Source get source => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching3<E extends Element>(bool Function(Element p1) predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType3<E extends Element>() {
    throw UnimplementedError();
  }
}

class FakeFieldElement implements FieldElement {
  @override
  T? accept<T>(ElementVisitor<T> visitor) {
    throw UnimplementedError();
  }

  @override
  DartObject? computeConstantValue() {
    throw UnimplementedError();
  }

  @override
  AnalysisContext get context => throw UnimplementedError();

  @override
  FieldElement get declaration => throw UnimplementedError();

  @override
  String get displayName => throw UnimplementedError();

  @override
  String? get documentationComment => throw UnimplementedError();

  @override
  Element get enclosingElement => throw UnimplementedError();

  @override
  String getExtendedDisplayName(String? shortName) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? get getter => throw UnimplementedError();

  @override
  bool get hasAlwaysThrows => throw UnimplementedError();

  @override
  bool get hasDeprecated => throw UnimplementedError();

  @override
  bool get hasDoNotStore => throw UnimplementedError();

  @override
  bool get hasFactory => throw UnimplementedError();

  @override
  bool get hasImplicitType => throw UnimplementedError();

  @override
  bool get hasInitializer => throw UnimplementedError();

  @override
  bool get hasInternal => throw UnimplementedError();

  @override
  bool get hasIsTest => throw UnimplementedError();

  @override
  bool get hasIsTestGroup => throw UnimplementedError();

  @override
  bool get hasJS => throw UnimplementedError();

  @override
  bool get hasLiteral => throw UnimplementedError();

  @override
  bool get hasMustCallSuper => throw UnimplementedError();

  @override
  bool get hasNonVirtual => throw UnimplementedError();

  @override
  bool get hasOptionalTypeArgs => throw UnimplementedError();

  @override
  bool get hasOverride => throw UnimplementedError();

  @override
  bool get hasProtected => throw UnimplementedError();

  @override
  bool get hasRequired => throw UnimplementedError();

  @override
  bool get hasSealed => throw UnimplementedError();

  @override
  bool get hasVisibleForTemplate => throw UnimplementedError();

  @override
  bool get hasVisibleForTesting => throw UnimplementedError();

  @override
  int get id => throw UnimplementedError();

  @override
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn(LibraryElement? library) {
    throw UnimplementedError();
  }

  @override
  bool get isConst => throw UnimplementedError();

  @override
  bool get isConstantEvaluated => throw UnimplementedError();

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
  bool get isPublic => throw UnimplementedError();

  @override
  bool get isStatic => throw UnimplementedError();

  @override
  bool get isSynthetic => throw UnimplementedError();

  @override
  ElementKind get kind => throw UnimplementedError();

  @override
  LibraryElement get library => throw UnimplementedError();

  @override
  ElementLocation? get location => throw UnimplementedError();

  @override
  List<ElementAnnotation> get metadata => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  int get nameLength => throw UnimplementedError();

  @override
  int get nameOffset => throw UnimplementedError();

  @override
  AnalysisSession? get session => throw UnimplementedError();

  @override
  PropertyAccessorElement? get setter => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching<E extends Element>(predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() {
    throw UnimplementedError();
  }

  @override
  DartType get type => throw UnimplementedError();

  @override
  void visitChildren(ElementVisitor visitor) {}

  @override
  bool get hasUseResult => throw UnimplementedError();

  @override
  bool get hasVisibleForOverriding => throw UnimplementedError();

  @override
  Element get nonSynthetic => throw UnimplementedError();

  @override
  bool get hasMustBeOverridden => throw UnimplementedError();

  @override
  List<Element> get children => throw UnimplementedError();

  @override
  bool get hasReopen => throw UnimplementedError();

  @override
  bool get isPromotable => throw UnimplementedError();

  @override
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  FieldElement? get augmentationTarget => throw UnimplementedError();

  @override
  bool get hasImmutable => throw UnimplementedError();

  @override
  bool get hasRedeclare => throw UnimplementedError();

  @override
  bool get hasVisibleOutsideTemplate => throw UnimplementedError();

  @override
  bool get isAugmentation => throw UnimplementedError();

  @override
  FieldElement? get augmentation => throw UnimplementedError();

  @override
  Element get enclosingElement3 => throw UnimplementedError();

  @override
  String getDisplayString({bool withNullability = true, bool multiline = false}) {
    throw UnimplementedError();
  }

  @override
  bool get hasDoNotSubmit => throw UnimplementedError();

  @override
  bool get hasMustBeConst => throw UnimplementedError();

  @override
  LibraryElement2? get library2 => throw UnimplementedError();

  @override
  Source? get librarySource => throw UnimplementedError();

  @override
  Source? get source => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching3<E extends Element>(bool Function(Element p1) predicate) {
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType3<E extends Element>() {
    throw UnimplementedError();
  }
}

class FakeDartObject implements DartObject {
  @override
  String toString() => 'Null (null)';

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
  ExecutableElement? toFunctionValue() {
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
  ParameterizedType? get type => throw UnimplementedError();

  @override
  VariableElement? get variable => throw UnimplementedError();

  @override
  ExecutableElement2? toFunctionValue2() {
    throw UnimplementedError();
  }

  @override
  ({Map<String, DartObject> named, List<DartObject> positional})? toRecordValue() {
    throw UnimplementedError();
  }

  @override
  VariableElement2? get variable2 => throw UnimplementedError();
}
