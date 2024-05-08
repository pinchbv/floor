import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
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
  String getDisplayString(
      {required bool withNullability, bool multiline = false}) {
    throw UnimplementedError();
  }

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
  Source get librarySource => throw UnimplementedError();

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
  Source get source => throw UnimplementedError();

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
  // TODO: implement augmented
  AugmentedClassElement get augmented => throw UnimplementedError();

  @override
  // TODO: implement hasMustBeOverridden
  bool get hasMustBeOverridden => throw UnimplementedError();

  @override
  // TODO: implement children
  List<Element> get children => throw UnimplementedError();

  @override
  // TODO: implement hasReopen
  bool get hasReopen => throw UnimplementedError();

  @override
  // TODO: implement isBase
  bool get isBase => throw UnimplementedError();

  @override
  // TODO: implement isConstructable
  bool get isConstructable => throw UnimplementedError();

  @override
  // TODO: implement isExhaustive
  bool get isExhaustive => throw UnimplementedError();

  @override
  bool isExtendableIn(LibraryElement library) {
    // TODO: implement isExtendableIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement isFinal
  bool get isFinal => throw UnimplementedError();

  @override
  bool isImplementableIn(LibraryElement library) {
    // TODO: implement isImplementableIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement isInterface
  bool get isInterface => throw UnimplementedError();

  @override
  bool isMixableIn(LibraryElement library) {
    // TODO: implement isMixableIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement isMixinClass
  bool get isMixinClass => throw UnimplementedError();

  @override
  // TODO: implement isSealed
  bool get isSealed => throw UnimplementedError();

  @override
  // TODO: implement sinceSdkVersion
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  // TODO: implement augmentationTarget
  ClassElement? get augmentationTarget => throw UnimplementedError();

  @override
  // TODO: implement hasImmutable
  bool get hasImmutable => throw UnimplementedError();

  @override
  // TODO: implement hasRedeclare
  bool get hasRedeclare => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleOutsideTemplate
  bool get hasVisibleOutsideTemplate => throw UnimplementedError();

  @override
  // TODO: implement isAugmentation
  bool get isAugmentation => throw UnimplementedError();

  @override
  // TODO: implement isInline
  bool get isInline => throw UnimplementedError();

  @override
  // TODO: implement augmentation
  ClassElement? get augmentation => throw UnimplementedError();
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
  String getDisplayString(
      {required bool withNullability, bool multiline = false}) {
    throw UnimplementedError();
  }

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
  Source? get librarySource => throw UnimplementedError();

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
  Source? get source => throw UnimplementedError();

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
  // TODO: implement hasMustBeOverridden
  bool get hasMustBeOverridden => throw UnimplementedError();

  @override
  // TODO: implement children
  List<Element> get children => throw UnimplementedError();

  @override
  // TODO: implement hasReopen
  bool get hasReopen => throw UnimplementedError();

  @override
  // TODO: implement isPromotable
  bool get isPromotable => throw UnimplementedError();

  @override
  // TODO: implement sinceSdkVersion
  Version? get sinceSdkVersion => throw UnimplementedError();

  @override
  // TODO: implement augmentationTarget
  FieldElement? get augmentationTarget => throw UnimplementedError();

  @override
  // TODO: implement hasImmutable
  bool get hasImmutable => throw UnimplementedError();

  @override
  // TODO: implement hasRedeclare
  bool get hasRedeclare => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleOutsideTemplate
  bool get hasVisibleOutsideTemplate => throw UnimplementedError();

  @override
  // TODO: implement isAugmentation
  bool get isAugmentation => throw UnimplementedError();

  @override
  // TODO: implement augmentation
  FieldElement? get augmentation => throw UnimplementedError();
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
  // TODO: implement variable
  VariableElement? get variable => throw UnimplementedError();
}
