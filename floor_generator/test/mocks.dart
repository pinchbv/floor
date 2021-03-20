import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/source.dart';

class MockClassElement implements ClassElement {
  @override
  T? accept<T>(ElementVisitor<T> visitor) {
    // TODO: implement accept
    throw UnimplementedError();
  }

  @override
  // TODO: implement accessors
  List<PropertyAccessorElement> get accessors => throw UnimplementedError();

  @override
  // TODO: implement allSupertypes
  List<InterfaceType> get allSupertypes => throw UnimplementedError();

  @override
  // TODO: implement constructors
  List<ConstructorElement> get constructors => throw UnimplementedError();

  @override
  // TODO: implement context
  AnalysisContext get context => throw UnimplementedError();

  @override
  // TODO: implement declaration
  Element get declaration => throw UnimplementedError();

  @override
  // TODO: implement displayName
  String get displayName => throw UnimplementedError();

  @override
  // TODO: implement documentationComment
  String? get documentationComment => throw UnimplementedError();

  @override
  // TODO: implement enclosingElement
  CompilationUnitElement get enclosingElement => throw UnimplementedError();

  @override
  // TODO: implement fields
  List<FieldElement> get fields => throw UnimplementedError();

  @override
  String getDisplayString({required bool withNullability}) {
    // TODO: implement getDisplayString
    throw UnimplementedError();
  }

  @override
  String getExtendedDisplayName(String? shortName) {
    // TODO: implement getExtendedDisplayName
    throw UnimplementedError();
  }

  @override
  FieldElement? getField(String name) {
    // TODO: implement getField
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getGetter(String name) {
    // TODO: implement getGetter
    throw UnimplementedError();
  }

  @override
  MethodElement? getMethod(String name) {
    // TODO: implement getMethod
    throw UnimplementedError();
  }

  @override
  ConstructorElement? getNamedConstructor(String name) {
    // TODO: implement getNamedConstructor
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getSetter(String name) {
    // TODO: implement getSetter
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasAlwaysThrows
  bool get hasAlwaysThrows => throw UnimplementedError();

  @override
  // TODO: implement hasDeprecated
  bool get hasDeprecated => throw UnimplementedError();

  @override
  // TODO: implement hasDoNotStore
  bool get hasDoNotStore => throw UnimplementedError();

  @override
  // TODO: implement hasFactory
  bool get hasFactory => throw UnimplementedError();

  @override
  // TODO: implement hasInternal
  bool get hasInternal => throw UnimplementedError();

  @override
  // TODO: implement hasIsTest
  bool get hasIsTest => throw UnimplementedError();

  @override
  // TODO: implement hasIsTestGroup
  bool get hasIsTestGroup => throw UnimplementedError();

  @override
  // TODO: implement hasJS
  bool get hasJS => throw UnimplementedError();

  @override
  // TODO: implement hasLiteral
  bool get hasLiteral => throw UnimplementedError();

  @override
  // TODO: implement hasMustCallSuper
  bool get hasMustCallSuper => throw UnimplementedError();

  @override
  // TODO: implement hasNonFinalField
  bool get hasNonFinalField => throw UnimplementedError();

  @override
  // TODO: implement hasNonVirtual
  bool get hasNonVirtual => throw UnimplementedError();

  @override
  // TODO: implement hasOptionalTypeArgs
  bool get hasOptionalTypeArgs => throw UnimplementedError();

  @override
  // TODO: implement hasOverride
  bool get hasOverride => throw UnimplementedError();

  @override
  // TODO: implement hasProtected
  bool get hasProtected => throw UnimplementedError();

  @override
  // TODO: implement hasRequired
  bool get hasRequired => throw UnimplementedError();

  @override
  // TODO: implement hasSealed
  bool get hasSealed => throw UnimplementedError();

  @override
  // TODO: implement hasStaticMember
  bool get hasStaticMember => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleForTemplate
  bool get hasVisibleForTemplate => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleForTesting
  bool get hasVisibleForTesting => throw UnimplementedError();

  @override
  // TODO: implement id
  int get id => throw UnimplementedError();

  @override
  InterfaceType instantiate({required List<DartType> typeArguments, required NullabilitySuffix nullabilitySuffix}) {
    // TODO: implement instantiate
    throw UnimplementedError();
  }

  @override
  // TODO: implement interfaces
  List<InterfaceType> get interfaces => throw UnimplementedError();

  @override
  // TODO: implement isAbstract
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn(LibraryElement? library) {
    // TODO: implement isAccessibleIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement isDartCoreObject
  bool get isDartCoreObject => throw UnimplementedError();

  @override
  // TODO: implement isEnum
  bool get isEnum => throw UnimplementedError();

  @override
  // TODO: implement isMixin
  bool get isMixin => throw UnimplementedError();

  @override
  // TODO: implement isMixinApplication
  bool get isMixinApplication => throw UnimplementedError();

  @override
  // TODO: implement isPrivate
  bool get isPrivate => throw UnimplementedError();

  @override
  // TODO: implement isPublic
  bool get isPublic => throw UnimplementedError();

  @override
  // TODO: implement isSimplyBounded
  bool get isSimplyBounded => throw UnimplementedError();

  @override
  // TODO: implement isSynthetic
  bool get isSynthetic => throw UnimplementedError();

  @override
  // TODO: implement isValidMixin
  bool get isValidMixin => throw UnimplementedError();

  @override
  // TODO: implement kind
  ElementKind get kind => throw UnimplementedError();

  @override
  // TODO: implement library
  LibraryElement get library => throw UnimplementedError();

  @override
  // TODO: implement librarySource
  Source get librarySource => throw UnimplementedError();

  @override
  // TODO: implement location
  ElementLocation? get location => throw UnimplementedError();

  @override
  MethodElement? lookUpConcreteMethod(String methodName, LibraryElement library) {
    // TODO: implement lookUpConcreteMethod
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpGetter(String getterName, LibraryElement library) {
    // TODO: implement lookUpGetter
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpInheritedConcreteGetter(String getterName, LibraryElement library) {
    // TODO: implement lookUpInheritedConcreteGetter
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpInheritedConcreteMethod(String methodName, LibraryElement library) {
    // TODO: implement lookUpInheritedConcreteMethod
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpInheritedConcreteSetter(String setterName, LibraryElement library) {
    // TODO: implement lookUpInheritedConcreteSetter
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpInheritedMethod(String methodName, LibraryElement library) {
    // TODO: implement lookUpInheritedMethod
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpMethod(String methodName, LibraryElement library) {
    // TODO: implement lookUpMethod
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpSetter(String setterName, LibraryElement library) {
    // TODO: implement lookUpSetter
    throw UnimplementedError();
  }

  @override
  // TODO: implement metadata
  List<ElementAnnotation> get metadata => throw UnimplementedError();

  @override
  // TODO: implement methods
  List<MethodElement> get methods => throw UnimplementedError();

  @override
  // TODO: implement mixins
  List<InterfaceType> get mixins => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement nameLength
  int get nameLength => throw UnimplementedError();

  @override
  // TODO: implement nameOffset
  int get nameOffset => throw UnimplementedError();

  @override
  // TODO: implement session
  AnalysisSession? get session => throw UnimplementedError();

  @override
  // TODO: implement source
  Source get source => throw UnimplementedError();

  @override
  // TODO: implement superclassConstraints
  List<InterfaceType> get superclassConstraints => throw UnimplementedError();

  @override
  // TODO: implement supertype
  InterfaceType? get supertype => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching<E extends Element>(predicate) {
    // TODO: implement thisOrAncestorMatching
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() {
    // TODO: implement thisOrAncestorOfType
    throw UnimplementedError();
  }

  @override
  // TODO: implement thisType
  InterfaceType get thisType => throw UnimplementedError();

  @override
  // TODO: implement typeParameters
  List<TypeParameterElement> get typeParameters => throw UnimplementedError();

  @override
  // TODO: implement unnamedConstructor
  ConstructorElement? get unnamedConstructor => throw UnimplementedError();

  @override
  void visitChildren(ElementVisitor visitor) {
    // TODO: implement visitChildren
  }

}

class MockFieldElement implements FieldElement {
  @override
  T? accept<T>(ElementVisitor<T> visitor) {
    // TODO: implement accept
    throw UnimplementedError();
  }

  @override
  DartObject? computeConstantValue() {
    // TODO: implement computeConstantValue
    throw UnimplementedError();
  }

  @override
  // TODO: implement context
  AnalysisContext get context => throw UnimplementedError();

  @override
  // TODO: implement declaration
  FieldElement get declaration => throw UnimplementedError();

  @override
  // TODO: implement displayName
  String get displayName => throw UnimplementedError();

  @override
  // TODO: implement documentationComment
  String? get documentationComment => throw UnimplementedError();

  @override
  // TODO: implement enclosingElement
  Element get enclosingElement => throw UnimplementedError();

  @override
  String getDisplayString({required bool withNullability}) {
    // TODO: implement getDisplayString
    throw UnimplementedError();
  }

  @override
  String getExtendedDisplayName(String? shortName) {
    // TODO: implement getExtendedDisplayName
    throw UnimplementedError();
  }

  @override
  // TODO: implement getter
  PropertyAccessorElement? get getter => throw UnimplementedError();

  @override
  // TODO: implement hasAlwaysThrows
  bool get hasAlwaysThrows => throw UnimplementedError();

  @override
  // TODO: implement hasDeprecated
  bool get hasDeprecated => throw UnimplementedError();

  @override
  // TODO: implement hasDoNotStore
  bool get hasDoNotStore => throw UnimplementedError();

  @override
  // TODO: implement hasFactory
  bool get hasFactory => throw UnimplementedError();

  @override
  // TODO: implement hasImplicitType
  bool get hasImplicitType => throw UnimplementedError();

  @override
  // TODO: implement hasInitializer
  bool get hasInitializer => throw UnimplementedError();

  @override
  // TODO: implement hasInternal
  bool get hasInternal => throw UnimplementedError();

  @override
  // TODO: implement hasIsTest
  bool get hasIsTest => throw UnimplementedError();

  @override
  // TODO: implement hasIsTestGroup
  bool get hasIsTestGroup => throw UnimplementedError();

  @override
  // TODO: implement hasJS
  bool get hasJS => throw UnimplementedError();

  @override
  // TODO: implement hasLiteral
  bool get hasLiteral => throw UnimplementedError();

  @override
  // TODO: implement hasMustCallSuper
  bool get hasMustCallSuper => throw UnimplementedError();

  @override
  // TODO: implement hasNonVirtual
  bool get hasNonVirtual => throw UnimplementedError();

  @override
  // TODO: implement hasOptionalTypeArgs
  bool get hasOptionalTypeArgs => throw UnimplementedError();

  @override
  // TODO: implement hasOverride
  bool get hasOverride => throw UnimplementedError();

  @override
  // TODO: implement hasProtected
  bool get hasProtected => throw UnimplementedError();

  @override
  // TODO: implement hasRequired
  bool get hasRequired => throw UnimplementedError();

  @override
  // TODO: implement hasSealed
  bool get hasSealed => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleForTemplate
  bool get hasVisibleForTemplate => throw UnimplementedError();

  @override
  // TODO: implement hasVisibleForTesting
  bool get hasVisibleForTesting => throw UnimplementedError();

  @override
  // TODO: implement id
  int get id => throw UnimplementedError();

  @override
  // TODO: implement isAbstract
  bool get isAbstract => throw UnimplementedError();

  @override
  bool isAccessibleIn(LibraryElement? library) {
    // TODO: implement isAccessibleIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement isConst
  bool get isConst => throw UnimplementedError();

  @override
  // TODO: implement isConstantEvaluated
  bool get isConstantEvaluated => throw UnimplementedError();

  @override
  // TODO: implement isCovariant
  bool get isCovariant => throw UnimplementedError();

  @override
  // TODO: implement isEnumConstant
  bool get isEnumConstant => throw UnimplementedError();

  @override
  // TODO: implement isExternal
  bool get isExternal => throw UnimplementedError();

  @override
  // TODO: implement isFinal
  bool get isFinal => throw UnimplementedError();

  @override
  // TODO: implement isLate
  bool get isLate => throw UnimplementedError();

  @override
  // TODO: implement isPrivate
  bool get isPrivate => throw UnimplementedError();

  @override
  // TODO: implement isPublic
  bool get isPublic => throw UnimplementedError();

  @override
  // TODO: implement isStatic
  bool get isStatic => throw UnimplementedError();

  @override
  // TODO: implement isSynthetic
  bool get isSynthetic => throw UnimplementedError();

  @override
  // TODO: implement kind
  ElementKind get kind => throw UnimplementedError();

  @override
  // TODO: implement library
  LibraryElement get library => throw UnimplementedError();

  @override
  // TODO: implement librarySource
  Source? get librarySource => throw UnimplementedError();

  @override
  // TODO: implement location
  ElementLocation? get location => throw UnimplementedError();

  @override
  // TODO: implement metadata
  List<ElementAnnotation> get metadata => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement nameLength
  int get nameLength => throw UnimplementedError();

  @override
  // TODO: implement nameOffset
  int get nameOffset => throw UnimplementedError();

  @override
  // TODO: implement session
  AnalysisSession? get session => throw UnimplementedError();

  @override
  // TODO: implement setter
  PropertyAccessorElement? get setter => throw UnimplementedError();

  @override
  // TODO: implement source
  Source? get source => throw UnimplementedError();

  @override
  E? thisOrAncestorMatching<E extends Element>(predicate) {
    // TODO: implement thisOrAncestorMatching
    throw UnimplementedError();
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() {
    // TODO: implement thisOrAncestorOfType
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  DartType get type => throw UnimplementedError();

  @override
  void visitChildren(ElementVisitor visitor) {
    // TODO: implement visitChildren
  }
}

class MockDartType implements DartType {
  @override
  R accept<R>(TypeVisitor<R> visitor) {
    // TODO: implement accept
    throw UnimplementedError();
  }

  @override
  R acceptWithArgument<R, A>(TypeVisitorWithArgument<R, A> visitor, A argument) {
    // TODO: implement acceptWithArgument
    throw UnimplementedError();
  }

  @override
  // TODO: implement aliasArguments
  List<DartType>? get aliasArguments => throw UnimplementedError();

  @override
  // TODO: implement aliasElement
  TypeAliasElement? get aliasElement => throw UnimplementedError();

  @override
  InterfaceType? asInstanceOf(ClassElement element) {
    // TODO: implement asInstanceOf
    throw UnimplementedError();
  }

  @override
  // TODO: implement displayName
  String get displayName => throw UnimplementedError();

  @override
  // TODO: implement element
  Element? get element => throw UnimplementedError();

  @override
  String getDisplayString({required bool withNullability}) {
    // TODO: implement getDisplayString
    throw UnimplementedError();
  }

  @override
  // TODO: implement isBottom
  bool get isBottom => throw UnimplementedError();

  @override
  // TODO: implement isDartAsyncFuture
  bool get isDartAsyncFuture => throw UnimplementedError();

  @override
  // TODO: implement isDartAsyncFutureOr
  bool get isDartAsyncFutureOr => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreBool
  bool get isDartCoreBool => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreDouble
  bool get isDartCoreDouble => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreFunction
  bool get isDartCoreFunction => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreInt
  bool get isDartCoreInt => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreIterable
  bool get isDartCoreIterable => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreList
  bool get isDartCoreList => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreMap
  bool get isDartCoreMap => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreNull
  bool get isDartCoreNull => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreNum
  bool get isDartCoreNum => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreObject
  bool get isDartCoreObject => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreSet
  bool get isDartCoreSet => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreString
  bool get isDartCoreString => throw UnimplementedError();

  @override
  // TODO: implement isDartCoreSymbol
  bool get isDartCoreSymbol => throw UnimplementedError();

  @override
  // TODO: implement isDynamic
  bool get isDynamic => throw UnimplementedError();

  @override
  // TODO: implement isVoid
  bool get isVoid => throw UnimplementedError();

  @override
  // TODO: implement name
  String? get name => throw UnimplementedError();

  @override
  // TODO: implement nullabilitySuffix
  NullabilitySuffix get nullabilitySuffix => throw UnimplementedError();

  @override
  DartType resolveToBound(DartType objectType) {
    // TODO: implement resolveToBound
    throw UnimplementedError();
  }
}

class MockDartObject implements DartObject {
  @override
  String toString() => 'Null (null)';

  @override
  DartObject? getField(String name) {
    // TODO: implement getField
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasKnownValue
  bool get hasKnownValue => throw UnimplementedError();

  @override
  // TODO: implement isNull
  bool get isNull => throw UnimplementedError();

  @override
  bool? toBoolValue() {
    // TODO: implement toBoolValue
    throw UnimplementedError();
  }

  @override
  double? toDoubleValue() {
    // TODO: implement toDoubleValue
    throw UnimplementedError();
  }

  @override
  ExecutableElement? toFunctionValue() {
    // TODO: implement toFunctionValue
    throw UnimplementedError();
  }

  @override
  int? toIntValue() {
    // TODO: implement toIntValue
    throw UnimplementedError();
  }

  @override
  List<DartObject>? toListValue() {
    // TODO: implement toListValue
    throw UnimplementedError();
  }

  @override
  Map<DartObject?, DartObject?>? toMapValue() {
    // TODO: implement toMapValue
    throw UnimplementedError();
  }

  @override
  Set<DartObject>? toSetValue() {
    // TODO: implement toSetValue
    throw UnimplementedError();
  }

  @override
  String? toStringValue() {
    // TODO: implement toStringValue
    throw UnimplementedError();
  }

  @override
  String? toSymbolValue() {
    // TODO: implement toSymbolValue
    throw UnimplementedError();
  }

  @override
  DartType? toTypeValue() {
    // TODO: implement toTypeValue
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  ParameterizedType? get type => throw UnimplementedError();
}
