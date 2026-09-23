base class PaginatedResult<T> {
  PaginatedResult({
    required this.data,
    required this.total,
    this.metadata = const NoMetadata(),
  });

  final List<T> data;
  final int total;
  final Metadata metadata;

  PaginatedResult<T> copyWithData(List<T> data, int? total) =>
      PaginatedResult<T>(
        data: data,
        total: total ?? this.total,
        metadata: metadata,
      );

  PaginatedResult<T> copyWithMetadata(Metadata metadata) =>
      PaginatedResult<T>(data: data, total: total, metadata: metadata);

  M metadataAs<M extends Metadata>() => metadata as M;
}

abstract class Metadata {
  const Metadata();
}

final class NoMetadata extends Metadata {
  const NoMetadata();
}

final class StringMetadata extends Metadata {
  const StringMetadata(this.value);

  final String value;
}
