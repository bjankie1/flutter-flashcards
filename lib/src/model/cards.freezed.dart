// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cards.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Deck _$DeckFromJson(Map<String, dynamic> json) {
  return _Deck.fromJson(json);
}

/// @nodoc
mixin _$Deck {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get parentDeckId => throw _privateConstructorUsedError;
  DeckOptions? get deckOptions => throw _privateConstructorUsedError;

  /// Serializes this Deck to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeckCopyWith<Deck> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckCopyWith<$Res> {
  factory $DeckCopyWith(Deck value, $Res Function(Deck) then) =
      _$DeckCopyWithImpl<$Res, Deck>;
  @useResult
  $Res call(
      {String name,
      String? description,
      String? parentDeckId,
      DeckOptions? deckOptions});

  $DeckOptionsCopyWith<$Res>? get deckOptions;
}

/// @nodoc
class _$DeckCopyWithImpl<$Res, $Val extends Deck>
    implements $DeckCopyWith<$Res> {
  _$DeckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? parentDeckId = freezed,
    Object? deckOptions = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      parentDeckId: freezed == parentDeckId
          ? _value.parentDeckId
          : parentDeckId // ignore: cast_nullable_to_non_nullable
              as String?,
      deckOptions: freezed == deckOptions
          ? _value.deckOptions
          : deckOptions // ignore: cast_nullable_to_non_nullable
              as DeckOptions?,
    ) as $Val);
  }

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeckOptionsCopyWith<$Res>? get deckOptions {
    if (_value.deckOptions == null) {
      return null;
    }

    return $DeckOptionsCopyWith<$Res>(_value.deckOptions!, (value) {
      return _then(_value.copyWith(deckOptions: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeckImplCopyWith<$Res> implements $DeckCopyWith<$Res> {
  factory _$$DeckImplCopyWith(
          _$DeckImpl value, $Res Function(_$DeckImpl) then) =
      __$$DeckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      String? parentDeckId,
      DeckOptions? deckOptions});

  @override
  $DeckOptionsCopyWith<$Res>? get deckOptions;
}

/// @nodoc
class __$$DeckImplCopyWithImpl<$Res>
    extends _$DeckCopyWithImpl<$Res, _$DeckImpl>
    implements _$$DeckImplCopyWith<$Res> {
  __$$DeckImplCopyWithImpl(_$DeckImpl _value, $Res Function(_$DeckImpl) _then)
      : super(_value, _then);

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? parentDeckId = freezed,
    Object? deckOptions = freezed,
  }) {
    return _then(_$DeckImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      parentDeckId: freezed == parentDeckId
          ? _value.parentDeckId
          : parentDeckId // ignore: cast_nullable_to_non_nullable
              as String?,
      deckOptions: freezed == deckOptions
          ? _value.deckOptions
          : deckOptions // ignore: cast_nullable_to_non_nullable
              as DeckOptions?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeckImpl with DiagnosticableTreeMixin implements _Deck {
  const _$DeckImpl(
      {required this.name,
      this.description,
      this.parentDeckId,
      this.deckOptions});

  factory _$DeckImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeckImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final String? parentDeckId;
  @override
  final DeckOptions? deckOptions;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Deck(name: $name, description: $description, parentDeckId: $parentDeckId, deckOptions: $deckOptions)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Deck'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('parentDeckId', parentDeckId))
      ..add(DiagnosticsProperty('deckOptions', deckOptions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeckImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.parentDeckId, parentDeckId) ||
                other.parentDeckId == parentDeckId) &&
            (identical(other.deckOptions, deckOptions) ||
                other.deckOptions == deckOptions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, description, parentDeckId, deckOptions);

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeckImplCopyWith<_$DeckImpl> get copyWith =>
      __$$DeckImplCopyWithImpl<_$DeckImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeckImplToJson(
      this,
    );
  }
}

abstract class _Deck implements Deck {
  const factory _Deck(
      {required final String name,
      final String? description,
      final String? parentDeckId,
      final DeckOptions? deckOptions}) = _$DeckImpl;

  factory _Deck.fromJson(Map<String, dynamic> json) = _$DeckImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  String? get parentDeckId;
  @override
  DeckOptions? get deckOptions;

  /// Create a copy of Deck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeckImplCopyWith<_$DeckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeckOptions _$DeckOptionsFromJson(Map<String, dynamic> json) {
  return _DeckOptions.fromJson(json);
}

/// @nodoc
mixin _$DeckOptions {
  int get cardsDaily => throw _privateConstructorUsedError;
  int get newCardsDailyLimit => throw _privateConstructorUsedError;
  Duration get maxInterval => throw _privateConstructorUsedError;

  /// Serializes this DeckOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeckOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeckOptionsCopyWith<DeckOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckOptionsCopyWith<$Res> {
  factory $DeckOptionsCopyWith(
          DeckOptions value, $Res Function(DeckOptions) then) =
      _$DeckOptionsCopyWithImpl<$Res, DeckOptions>;
  @useResult
  $Res call({int cardsDaily, int newCardsDailyLimit, Duration maxInterval});
}

/// @nodoc
class _$DeckOptionsCopyWithImpl<$Res, $Val extends DeckOptions>
    implements $DeckOptionsCopyWith<$Res> {
  _$DeckOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeckOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardsDaily = null,
    Object? newCardsDailyLimit = null,
    Object? maxInterval = null,
  }) {
    return _then(_value.copyWith(
      cardsDaily: null == cardsDaily
          ? _value.cardsDaily
          : cardsDaily // ignore: cast_nullable_to_non_nullable
              as int,
      newCardsDailyLimit: null == newCardsDailyLimit
          ? _value.newCardsDailyLimit
          : newCardsDailyLimit // ignore: cast_nullable_to_non_nullable
              as int,
      maxInterval: null == maxInterval
          ? _value.maxInterval
          : maxInterval // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeckOptionsImplCopyWith<$Res>
    implements $DeckOptionsCopyWith<$Res> {
  factory _$$DeckOptionsImplCopyWith(
          _$DeckOptionsImpl value, $Res Function(_$DeckOptionsImpl) then) =
      __$$DeckOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int cardsDaily, int newCardsDailyLimit, Duration maxInterval});
}

/// @nodoc
class __$$DeckOptionsImplCopyWithImpl<$Res>
    extends _$DeckOptionsCopyWithImpl<$Res, _$DeckOptionsImpl>
    implements _$$DeckOptionsImplCopyWith<$Res> {
  __$$DeckOptionsImplCopyWithImpl(
      _$DeckOptionsImpl _value, $Res Function(_$DeckOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeckOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardsDaily = null,
    Object? newCardsDailyLimit = null,
    Object? maxInterval = null,
  }) {
    return _then(_$DeckOptionsImpl(
      cardsDaily: null == cardsDaily
          ? _value.cardsDaily
          : cardsDaily // ignore: cast_nullable_to_non_nullable
              as int,
      newCardsDailyLimit: null == newCardsDailyLimit
          ? _value.newCardsDailyLimit
          : newCardsDailyLimit // ignore: cast_nullable_to_non_nullable
              as int,
      maxInterval: null == maxInterval
          ? _value.maxInterval
          : maxInterval // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeckOptionsImpl with DiagnosticableTreeMixin implements _DeckOptions {
  const _$DeckOptionsImpl(
      {required this.cardsDaily,
      required this.newCardsDailyLimit,
      required this.maxInterval});

  factory _$DeckOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeckOptionsImplFromJson(json);

  @override
  final int cardsDaily;
  @override
  final int newCardsDailyLimit;
  @override
  final Duration maxInterval;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DeckOptions(cardsDaily: $cardsDaily, newCardsDailyLimit: $newCardsDailyLimit, maxInterval: $maxInterval)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DeckOptions'))
      ..add(DiagnosticsProperty('cardsDaily', cardsDaily))
      ..add(DiagnosticsProperty('newCardsDailyLimit', newCardsDailyLimit))
      ..add(DiagnosticsProperty('maxInterval', maxInterval));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeckOptionsImpl &&
            (identical(other.cardsDaily, cardsDaily) ||
                other.cardsDaily == cardsDaily) &&
            (identical(other.newCardsDailyLimit, newCardsDailyLimit) ||
                other.newCardsDailyLimit == newCardsDailyLimit) &&
            (identical(other.maxInterval, maxInterval) ||
                other.maxInterval == maxInterval));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cardsDaily, newCardsDailyLimit, maxInterval);

  /// Create a copy of DeckOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeckOptionsImplCopyWith<_$DeckOptionsImpl> get copyWith =>
      __$$DeckOptionsImplCopyWithImpl<_$DeckOptionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeckOptionsImplToJson(
      this,
    );
  }
}

abstract class _DeckOptions implements DeckOptions {
  const factory _DeckOptions(
      {required final int cardsDaily,
      required final int newCardsDailyLimit,
      required final Duration maxInterval}) = _$DeckOptionsImpl;

  factory _DeckOptions.fromJson(Map<String, dynamic> json) =
      _$DeckOptionsImpl.fromJson;

  @override
  int get cardsDaily;
  @override
  int get newCardsDailyLimit;
  @override
  Duration get maxInterval;

  /// Create a copy of DeckOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeckOptionsImplCopyWith<_$DeckOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_$TagImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl with DiagnosticableTreeMixin implements _Tag {
  const _$TagImpl({required this.name});

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final String name;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Tag(name: $name)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Tag'))
      ..add(DiagnosticsProperty('name', name));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(
      this,
    );
  }
}

abstract class _Tag implements Tag {
  const factory _Tag({required final String name}) = _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  String get name;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Content _$ContentFromJson(Map<String, dynamic> json) {
  return _Content.fromJson(json);
}

/// @nodoc
mixin _$Content {
  String get text => throw _privateConstructorUsedError;
  List<String>? get attachments => throw _privateConstructorUsedError;

  /// Serializes this Content to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentCopyWith<Content> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentCopyWith<$Res> {
  factory $ContentCopyWith(Content value, $Res Function(Content) then) =
      _$ContentCopyWithImpl<$Res, Content>;
  @useResult
  $Res call({String text, List<String>? attachments});
}

/// @nodoc
class _$ContentCopyWithImpl<$Res, $Val extends Content>
    implements $ContentCopyWith<$Res> {
  _$ContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? attachments = freezed,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContentImplCopyWith<$Res> implements $ContentCopyWith<$Res> {
  factory _$$ContentImplCopyWith(
          _$ContentImpl value, $Res Function(_$ContentImpl) then) =
      __$$ContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, List<String>? attachments});
}

/// @nodoc
class __$$ContentImplCopyWithImpl<$Res>
    extends _$ContentCopyWithImpl<$Res, _$ContentImpl>
    implements _$$ContentImplCopyWith<$Res> {
  __$$ContentImplCopyWithImpl(
      _$ContentImpl _value, $Res Function(_$ContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? attachments = freezed,
  }) {
    return _then(_$ContentImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContentImpl with DiagnosticableTreeMixin implements _Content {
  const _$ContentImpl({required this.text, final List<String>? attachments})
      : _attachments = attachments;

  factory _$ContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContentImplFromJson(json);

  @override
  final String text;
  final List<String>? _attachments;
  @override
  List<String>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Content(text: $text, attachments: $attachments)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Content'))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('attachments', attachments));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentImpl &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, text, const DeepCollectionEquality().hash(_attachments));

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentImplCopyWith<_$ContentImpl> get copyWith =>
      __$$ContentImplCopyWithImpl<_$ContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContentImplToJson(
      this,
    );
  }
}

abstract class _Content implements Content {
  const factory _Content(
      {required final String text,
      final List<String>? attachments}) = _$ContentImpl;

  factory _Content.fromJson(Map<String, dynamic> json) = _$ContentImpl.fromJson;

  @override
  String get text;
  @override
  List<String>? get attachments;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentImplCopyWith<_$ContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardOptions _$CardOptionsFromJson(Map<String, dynamic> json) {
  return _CardOptions.fromJson(json);
}

/// @nodoc
mixin _$CardOptions {
  String get deckId => throw _privateConstructorUsedError;
  bool get reverse => throw _privateConstructorUsedError;
  bool get inputRequire => throw _privateConstructorUsedError;

  /// Serializes this CardOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardOptionsCopyWith<CardOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardOptionsCopyWith<$Res> {
  factory $CardOptionsCopyWith(
          CardOptions value, $Res Function(CardOptions) then) =
      _$CardOptionsCopyWithImpl<$Res, CardOptions>;
  @useResult
  $Res call({String deckId, bool reverse, bool inputRequire});
}

/// @nodoc
class _$CardOptionsCopyWithImpl<$Res, $Val extends CardOptions>
    implements $CardOptionsCopyWith<$Res> {
  _$CardOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? reverse = null,
    Object? inputRequire = null,
  }) {
    return _then(_value.copyWith(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      reverse: null == reverse
          ? _value.reverse
          : reverse // ignore: cast_nullable_to_non_nullable
              as bool,
      inputRequire: null == inputRequire
          ? _value.inputRequire
          : inputRequire // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardOptionsImplCopyWith<$Res>
    implements $CardOptionsCopyWith<$Res> {
  factory _$$CardOptionsImplCopyWith(
          _$CardOptionsImpl value, $Res Function(_$CardOptionsImpl) then) =
      __$$CardOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deckId, bool reverse, bool inputRequire});
}

/// @nodoc
class __$$CardOptionsImplCopyWithImpl<$Res>
    extends _$CardOptionsCopyWithImpl<$Res, _$CardOptionsImpl>
    implements _$$CardOptionsImplCopyWith<$Res> {
  __$$CardOptionsImplCopyWithImpl(
      _$CardOptionsImpl _value, $Res Function(_$CardOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? reverse = null,
    Object? inputRequire = null,
  }) {
    return _then(_$CardOptionsImpl(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      reverse: null == reverse
          ? _value.reverse
          : reverse // ignore: cast_nullable_to_non_nullable
              as bool,
      inputRequire: null == inputRequire
          ? _value.inputRequire
          : inputRequire // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardOptionsImpl with DiagnosticableTreeMixin implements _CardOptions {
  const _$CardOptionsImpl(
      {required this.deckId,
      required this.reverse,
      required this.inputRequire});

  factory _$CardOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardOptionsImplFromJson(json);

  @override
  final String deckId;
  @override
  final bool reverse;
  @override
  final bool inputRequire;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CardOptions(deckId: $deckId, reverse: $reverse, inputRequire: $inputRequire)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CardOptions'))
      ..add(DiagnosticsProperty('deckId', deckId))
      ..add(DiagnosticsProperty('reverse', reverse))
      ..add(DiagnosticsProperty('inputRequire', inputRequire));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardOptionsImpl &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.reverse, reverse) || other.reverse == reverse) &&
            (identical(other.inputRequire, inputRequire) ||
                other.inputRequire == inputRequire));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deckId, reverse, inputRequire);

  /// Create a copy of CardOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardOptionsImplCopyWith<_$CardOptionsImpl> get copyWith =>
      __$$CardOptionsImplCopyWithImpl<_$CardOptionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardOptionsImplToJson(
      this,
    );
  }
}

abstract class _CardOptions implements CardOptions {
  const factory _CardOptions(
      {required final String deckId,
      required final bool reverse,
      required final bool inputRequire}) = _$CardOptionsImpl;

  factory _CardOptions.fromJson(Map<String, dynamic> json) =
      _$CardOptionsImpl.fromJson;

  @override
  String get deckId;
  @override
  bool get reverse;
  @override
  bool get inputRequire;

  /// Create a copy of CardOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardOptionsImplCopyWith<_$CardOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Card _$CardFromJson(Map<String, dynamic> json) {
  return _Card.fromJson(json);
}

/// @nodoc
mixin _$Card {
  String get deckId => throw _privateConstructorUsedError;
  Content get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  CardOptions? get options => throw _privateConstructorUsedError;
  List<Tag>? get tags => throw _privateConstructorUsedError;
  List<String>? get alternativeAnswers => throw _privateConstructorUsedError;
  Content? get explanation => throw _privateConstructorUsedError;

  /// Serializes this Card to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardCopyWith<Card> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardCopyWith<$Res> {
  factory $CardCopyWith(Card value, $Res Function(Card) then) =
      _$CardCopyWithImpl<$Res, Card>;
  @useResult
  $Res call(
      {String deckId,
      Content question,
      String answer,
      CardOptions? options,
      List<Tag>? tags,
      List<String>? alternativeAnswers,
      Content? explanation});

  $ContentCopyWith<$Res> get question;
  $CardOptionsCopyWith<$Res>? get options;
  $ContentCopyWith<$Res>? get explanation;
}

/// @nodoc
class _$CardCopyWithImpl<$Res, $Val extends Card>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? question = null,
    Object? answer = null,
    Object? options = freezed,
    Object? tags = freezed,
    Object? alternativeAnswers = freezed,
    Object? explanation = freezed,
  }) {
    return _then(_value.copyWith(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as Content,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      options: freezed == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as CardOptions?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>?,
      alternativeAnswers: freezed == alternativeAnswers
          ? _value.alternativeAnswers
          : alternativeAnswers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as Content?,
    ) as $Val);
  }

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentCopyWith<$Res> get question {
    return $ContentCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CardOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $CardOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentCopyWith<$Res>? get explanation {
    if (_value.explanation == null) {
      return null;
    }

    return $ContentCopyWith<$Res>(_value.explanation!, (value) {
      return _then(_value.copyWith(explanation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CardImplCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$$CardImplCopyWith(
          _$CardImpl value, $Res Function(_$CardImpl) then) =
      __$$CardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deckId,
      Content question,
      String answer,
      CardOptions? options,
      List<Tag>? tags,
      List<String>? alternativeAnswers,
      Content? explanation});

  @override
  $ContentCopyWith<$Res> get question;
  @override
  $CardOptionsCopyWith<$Res>? get options;
  @override
  $ContentCopyWith<$Res>? get explanation;
}

/// @nodoc
class __$$CardImplCopyWithImpl<$Res>
    extends _$CardCopyWithImpl<$Res, _$CardImpl>
    implements _$$CardImplCopyWith<$Res> {
  __$$CardImplCopyWithImpl(_$CardImpl _value, $Res Function(_$CardImpl) _then)
      : super(_value, _then);

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? question = null,
    Object? answer = null,
    Object? options = freezed,
    Object? tags = freezed,
    Object? alternativeAnswers = freezed,
    Object? explanation = freezed,
  }) {
    return _then(_$CardImpl(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as Content,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      options: freezed == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as CardOptions?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>?,
      alternativeAnswers: freezed == alternativeAnswers
          ? _value._alternativeAnswers
          : alternativeAnswers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as Content?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardImpl with DiagnosticableTreeMixin implements _Card {
  const _$CardImpl(
      {required this.deckId,
      required this.question,
      required this.answer,
      this.options,
      final List<Tag>? tags,
      final List<String>? alternativeAnswers,
      this.explanation})
      : _tags = tags,
        _alternativeAnswers = alternativeAnswers;

  factory _$CardImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardImplFromJson(json);

  @override
  final String deckId;
  @override
  final Content question;
  @override
  final String answer;
  @override
  final CardOptions? options;
  final List<Tag>? _tags;
  @override
  List<Tag>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _alternativeAnswers;
  @override
  List<String>? get alternativeAnswers {
    final value = _alternativeAnswers;
    if (value == null) return null;
    if (_alternativeAnswers is EqualUnmodifiableListView)
      return _alternativeAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Content? explanation;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Card(deckId: $deckId, question: $question, answer: $answer, options: $options, tags: $tags, alternativeAnswers: $alternativeAnswers, explanation: $explanation)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Card'))
      ..add(DiagnosticsProperty('deckId', deckId))
      ..add(DiagnosticsProperty('question', question))
      ..add(DiagnosticsProperty('answer', answer))
      ..add(DiagnosticsProperty('options', options))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('alternativeAnswers', alternativeAnswers))
      ..add(DiagnosticsProperty('explanation', explanation));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardImpl &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._alternativeAnswers, _alternativeAnswers) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      deckId,
      question,
      answer,
      options,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_alternativeAnswers),
      explanation);

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardImplCopyWith<_$CardImpl> get copyWith =>
      __$$CardImplCopyWithImpl<_$CardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardImplToJson(
      this,
    );
  }
}

abstract class _Card implements Card {
  const factory _Card(
      {required final String deckId,
      required final Content question,
      required final String answer,
      final CardOptions? options,
      final List<Tag>? tags,
      final List<String>? alternativeAnswers,
      final Content? explanation}) = _$CardImpl;

  factory _Card.fromJson(Map<String, dynamic> json) = _$CardImpl.fromJson;

  @override
  String get deckId;
  @override
  Content get question;
  @override
  String get answer;
  @override
  CardOptions? get options;
  @override
  List<Tag>? get tags;
  @override
  List<String>? get alternativeAnswers;
  @override
  Content? get explanation;

  /// Create a copy of Card
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardImplCopyWith<_$CardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardStats _$CardStatsFromJson(Map<String, dynamic> json) {
  return _CardStats.fromJson(json);
}

/// @nodoc
mixin _$CardStats {
  String get cardId => throw _privateConstructorUsedError;
  double get stability => throw _privateConstructorUsedError;
  double get difficulty => throw _privateConstructorUsedError;
  double get lastAnswerRate => throw _privateConstructorUsedError;
  DateTime get lastAnswerDate => throw _privateConstructorUsedError;
  int get numberOfAnswers => throw _privateConstructorUsedError;
  DateTime get dateAdded => throw _privateConstructorUsedError;

  /// Serializes this CardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardStatsCopyWith<CardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardStatsCopyWith<$Res> {
  factory $CardStatsCopyWith(CardStats value, $Res Function(CardStats) then) =
      _$CardStatsCopyWithImpl<$Res, CardStats>;
  @useResult
  $Res call(
      {String cardId,
      double stability,
      double difficulty,
      double lastAnswerRate,
      DateTime lastAnswerDate,
      int numberOfAnswers,
      DateTime dateAdded});
}

/// @nodoc
class _$CardStatsCopyWithImpl<$Res, $Val extends CardStats>
    implements $CardStatsCopyWith<$Res> {
  _$CardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? stability = null,
    Object? difficulty = null,
    Object? lastAnswerRate = null,
    Object? lastAnswerDate = null,
    Object? numberOfAnswers = null,
    Object? dateAdded = null,
  }) {
    return _then(_value.copyWith(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      stability: null == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double,
      lastAnswerRate: null == lastAnswerRate
          ? _value.lastAnswerRate
          : lastAnswerRate // ignore: cast_nullable_to_non_nullable
              as double,
      lastAnswerDate: null == lastAnswerDate
          ? _value.lastAnswerDate
          : lastAnswerDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      numberOfAnswers: null == numberOfAnswers
          ? _value.numberOfAnswers
          : numberOfAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardStatsImplCopyWith<$Res>
    implements $CardStatsCopyWith<$Res> {
  factory _$$CardStatsImplCopyWith(
          _$CardStatsImpl value, $Res Function(_$CardStatsImpl) then) =
      __$$CardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cardId,
      double stability,
      double difficulty,
      double lastAnswerRate,
      DateTime lastAnswerDate,
      int numberOfAnswers,
      DateTime dateAdded});
}

/// @nodoc
class __$$CardStatsImplCopyWithImpl<$Res>
    extends _$CardStatsCopyWithImpl<$Res, _$CardStatsImpl>
    implements _$$CardStatsImplCopyWith<$Res> {
  __$$CardStatsImplCopyWithImpl(
      _$CardStatsImpl _value, $Res Function(_$CardStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? stability = null,
    Object? difficulty = null,
    Object? lastAnswerRate = null,
    Object? lastAnswerDate = null,
    Object? numberOfAnswers = null,
    Object? dateAdded = null,
  }) {
    return _then(_$CardStatsImpl(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      stability: null == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double,
      lastAnswerRate: null == lastAnswerRate
          ? _value.lastAnswerRate
          : lastAnswerRate // ignore: cast_nullable_to_non_nullable
              as double,
      lastAnswerDate: null == lastAnswerDate
          ? _value.lastAnswerDate
          : lastAnswerDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      numberOfAnswers: null == numberOfAnswers
          ? _value.numberOfAnswers
          : numberOfAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardStatsImpl with DiagnosticableTreeMixin implements _CardStats {
  const _$CardStatsImpl(
      {required this.cardId,
      required this.stability,
      required this.difficulty,
      required this.lastAnswerRate,
      required this.lastAnswerDate,
      required this.numberOfAnswers,
      required this.dateAdded});

  factory _$CardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardStatsImplFromJson(json);

  @override
  final String cardId;
  @override
  final double stability;
  @override
  final double difficulty;
  @override
  final double lastAnswerRate;
  @override
  final DateTime lastAnswerDate;
  @override
  final int numberOfAnswers;
  @override
  final DateTime dateAdded;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CardStats(cardId: $cardId, stability: $stability, difficulty: $difficulty, lastAnswerRate: $lastAnswerRate, lastAnswerDate: $lastAnswerDate, numberOfAnswers: $numberOfAnswers, dateAdded: $dateAdded)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CardStats'))
      ..add(DiagnosticsProperty('cardId', cardId))
      ..add(DiagnosticsProperty('stability', stability))
      ..add(DiagnosticsProperty('difficulty', difficulty))
      ..add(DiagnosticsProperty('lastAnswerRate', lastAnswerRate))
      ..add(DiagnosticsProperty('lastAnswerDate', lastAnswerDate))
      ..add(DiagnosticsProperty('numberOfAnswers', numberOfAnswers))
      ..add(DiagnosticsProperty('dateAdded', dateAdded));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardStatsImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.stability, stability) ||
                other.stability == stability) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.lastAnswerRate, lastAnswerRate) ||
                other.lastAnswerRate == lastAnswerRate) &&
            (identical(other.lastAnswerDate, lastAnswerDate) ||
                other.lastAnswerDate == lastAnswerDate) &&
            (identical(other.numberOfAnswers, numberOfAnswers) ||
                other.numberOfAnswers == numberOfAnswers) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cardId, stability, difficulty,
      lastAnswerRate, lastAnswerDate, numberOfAnswers, dateAdded);

  /// Create a copy of CardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardStatsImplCopyWith<_$CardStatsImpl> get copyWith =>
      __$$CardStatsImplCopyWithImpl<_$CardStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardStatsImplToJson(
      this,
    );
  }
}

abstract class _CardStats implements CardStats {
  const factory _CardStats(
      {required final String cardId,
      required final double stability,
      required final double difficulty,
      required final double lastAnswerRate,
      required final DateTime lastAnswerDate,
      required final int numberOfAnswers,
      required final DateTime dateAdded}) = _$CardStatsImpl;

  factory _CardStats.fromJson(Map<String, dynamic> json) =
      _$CardStatsImpl.fromJson;

  @override
  String get cardId;
  @override
  double get stability;
  @override
  double get difficulty;
  @override
  double get lastAnswerRate;
  @override
  DateTime get lastAnswerDate;
  @override
  int get numberOfAnswers;
  @override
  DateTime get dateAdded;

  /// Create a copy of CardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardStatsImplCopyWith<_$CardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardAnswer _$CardAnswerFromJson(Map<String, dynamic> json) {
  return _CardAnswer.fromJson(json);
}

/// @nodoc
mixin _$CardAnswer {
  String get cardId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get answerRate => throw _privateConstructorUsedError;
  Duration get timeSpent => throw _privateConstructorUsedError;

  /// Serializes this CardAnswer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardAnswerCopyWith<CardAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardAnswerCopyWith<$Res> {
  factory $CardAnswerCopyWith(
          CardAnswer value, $Res Function(CardAnswer) then) =
      _$CardAnswerCopyWithImpl<$Res, CardAnswer>;
  @useResult
  $Res call(
      {String cardId, DateTime date, double answerRate, Duration timeSpent});
}

/// @nodoc
class _$CardAnswerCopyWithImpl<$Res, $Val extends CardAnswer>
    implements $CardAnswerCopyWith<$Res> {
  _$CardAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? date = null,
    Object? answerRate = null,
    Object? timeSpent = null,
  }) {
    return _then(_value.copyWith(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      answerRate: null == answerRate
          ? _value.answerRate
          : answerRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardAnswerImplCopyWith<$Res>
    implements $CardAnswerCopyWith<$Res> {
  factory _$$CardAnswerImplCopyWith(
          _$CardAnswerImpl value, $Res Function(_$CardAnswerImpl) then) =
      __$$CardAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cardId, DateTime date, double answerRate, Duration timeSpent});
}

/// @nodoc
class __$$CardAnswerImplCopyWithImpl<$Res>
    extends _$CardAnswerCopyWithImpl<$Res, _$CardAnswerImpl>
    implements _$$CardAnswerImplCopyWith<$Res> {
  __$$CardAnswerImplCopyWithImpl(
      _$CardAnswerImpl _value, $Res Function(_$CardAnswerImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? date = null,
    Object? answerRate = null,
    Object? timeSpent = null,
  }) {
    return _then(_$CardAnswerImpl(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      answerRate: null == answerRate
          ? _value.answerRate
          : answerRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardAnswerImpl with DiagnosticableTreeMixin implements _CardAnswer {
  const _$CardAnswerImpl(
      {required this.cardId,
      required this.date,
      required this.answerRate,
      required this.timeSpent});

  factory _$CardAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardAnswerImplFromJson(json);

  @override
  final String cardId;
  @override
  final DateTime date;
  @override
  final double answerRate;
  @override
  final Duration timeSpent;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CardAnswer(cardId: $cardId, date: $date, answerRate: $answerRate, timeSpent: $timeSpent)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CardAnswer'))
      ..add(DiagnosticsProperty('cardId', cardId))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('answerRate', answerRate))
      ..add(DiagnosticsProperty('timeSpent', timeSpent));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardAnswerImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.answerRate, answerRate) ||
                other.answerRate == answerRate) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cardId, date, answerRate, timeSpent);

  /// Create a copy of CardAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardAnswerImplCopyWith<_$CardAnswerImpl> get copyWith =>
      __$$CardAnswerImplCopyWithImpl<_$CardAnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardAnswerImplToJson(
      this,
    );
  }
}

abstract class _CardAnswer implements CardAnswer {
  const factory _CardAnswer(
      {required final String cardId,
      required final DateTime date,
      required final double answerRate,
      required final Duration timeSpent}) = _$CardAnswerImpl;

  factory _CardAnswer.fromJson(Map<String, dynamic> json) =
      _$CardAnswerImpl.fromJson;

  @override
  String get cardId;
  @override
  DateTime get date;
  @override
  double get answerRate;
  @override
  Duration get timeSpent;

  /// Create a copy of CardAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardAnswerImplCopyWith<_$CardAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
