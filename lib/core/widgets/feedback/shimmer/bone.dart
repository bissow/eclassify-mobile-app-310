/// Shape + size spec for a shimmer placeholder block.
/// Callers pick a bone; [ShimmerContainer] turns it into a sized, rounded box.
sealed class Bone {
  final double? width;
  final double height;
  final double radius;

  const Bone._({
    required this.width,
    required this.height,
    required this.radius,
  });

  /// Single line of text. Leave [width] null to fill available width.
  const factory Bone.text({double? width, double fontSize}) = _TextBone;

  /// Circular block (avatars, round icons).
  const factory Bone.circle({required double size}) = _CircleBone;

  /// Rounded square/rect block (thumbnails, checkboxes).
  const factory Bone.square({required double size, double radius}) =
      _SquareBone;

  /// Small icon-sized block.
  const factory Bone.icon({double size}) = _IconBone;

  /// Pill-shaped block (buttons, chips, badges).
  const factory Bone.button({double width, double height}) = _ButtonBone;

  /// Arbitrary width/height/radius, for shapes the presets don't cover.
  const factory Bone.custom({
    double? width,
    required double height,
    double radius,
  }) = _CustomBone;
}

class _TextBone extends Bone {
  const _TextBone({double? width, double fontSize = 12})
    : super._(width: width, height: fontSize * 1.3, radius: 8);
}

class _CircleBone extends Bone {
  const _CircleBone({required double size})
    : super._(width: size, height: size, radius: 999);
}

class _SquareBone extends Bone {
  const _SquareBone({required double size, double radius = 8})
    : super._(width: size, height: size, radius: radius);
}

class _IconBone extends Bone {
  const _IconBone({double size = 24})
    : super._(width: size, height: size, radius: 4);
}

class _ButtonBone extends Bone {
  const _ButtonBone({double width = 88, double height = 36})
    : super._(width: width, height: height, radius: 999);
}

class _CustomBone extends Bone {
  const _CustomBone({double? width, required double height, double radius = 8})
    : super._(width: width, height: height, radius: radius);
}
